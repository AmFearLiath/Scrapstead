class_name MagnetCollector
extends Node3D
## The small magnetic collector, the first machine (P3b, docs/first-machine.md),
## placed and moved in build mode (docs/building-system.md, section 4).
##
## It swings its magnet over its work area and drops one iron piece per cycle
## into its output crate. Loose magnetic scrap in reach is taken first; then it
## digs into Walt's nail heap - but only while the heap is within reach of the
## boom. It never creates anything beyond the heap's stock and never duplicates.
##
## Process logic only: the result of a cycle is decided here when the timer
## runs out. MagnetAnimator merely shows the progress (scripts/world).

signal status_changed(status: String)
## A piece landed in the crate (presentation: clank, dust).
signal piece_collected(item: ScrapItem, from_heap: bool)
## A crate item became part of the world (also when restored from a save).
signal item_spawned(item: ScrapItem)
## A crate item left the world for good (sold or consumed).
signal item_removed(object_id: String)
## The supplier tipped new small scrap onto the heap.
signal refilled(amount: int)

const OBJECT_PREFIX := "magnet_"
const STATUS_WORKING := "working"
const STATUS_OFF := "off"
const STATUS_BIN_FULL := "bin_full"
const STATUS_EMPTY := "empty"
## Items closer than this to the crate count as lying in it.
const BIN_RADIUS := 0.95
## Slewing column in machine space: the centre of reach and work area.
const COLUMN := Vector3(0.1, 0.0, -0.05)
## The heap counts as in reach between these distances from the column.
const HEAP_REACH_MIN := 1.3
const HEAP_REACH_MAX := 2.8
## Machine origin relative to the footprint centre (build grid).
const SCENE_OFFSET := Vector3(0.0, 0.0, -1.0)

@export var profile: MachineProfile
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene
## Walt's nail heap (fixed in the yard); set by the scene.
var heap_center: Node3D
## Output crate; its Marker3D children are the slots.
@export var bin: Node3D

var _upgrades: UpgradeProgress
var _objects: Dictionary = {}
var _switched_on: bool = true
var _timer: float = 0.0
## Pieces ever taken from the heap (position in the heap pattern).
var _heap_taken: int = 0
## Pieces currently in the heap.
var _heap_stock: int = 0
var _refill_timer: float = 0.0
var _counter: int = 0
var _status: String = ""
## Live crate items created from the heap: {"id", "item", "slot", "node"}.
var _live: Array[Dictionary] = []
var _installed: bool = false


func _ready() -> void:
	if profile != null:
		_heap_stock = profile.heap_size
		_refill_timer = profile.refill_interval_seconds


## `objects` is the scene's live registry (object ID -> Interactable).
func setup(upgrades: UpgradeProgress, objects: Dictionary, heap: Node3D) -> void:
	_upgrades = upgrades
	_objects = objects
	heap_center = heap
	_timer = get_cycle_seconds()
	_upgrades.upgrade_purchased.connect(_on_upgrade_purchased)
	_installed = true


## Standing on the yard and wired up by the scene.
func is_installed() -> bool:
	return _installed and profile != null


## Centre of reach and work area (world).
func get_work_center() -> Vector3:
	return to_global(COLUMN)


## Whether Walt's nail heap lies within reach of the boom.
func heap_in_reach() -> bool:
	if heap_center == null:
		return false
	var offset: Vector3 = heap_center.global_position - get_work_center()
	offset.y = 0.0
	return offset.length() >= HEAP_REACH_MIN and offset.length() <= HEAP_REACH_MAX


## Where the magnet dips next (animation): the loose piece or the heap.
func get_lift_point() -> Vector3:
	var loose: ScrapItem = _find_loose_piece()
	if loose != null:
		return loose.global_position
	if heap_in_reach():
		return heap_center.global_position
	return get_work_center() + global_basis.x * 2.0


# --- Machine ports (MachineLinks, docs/machine-links.md) ---------------------------

## The crate is the output: everything lying in it can leave over a belt.
func get_output_items(_channel: String = "") -> Array[ScrapItem]:
	return _items_in_bin()


func get_output_item_ids(_channel: String = "") -> PackedStringArray:
	return profile.magnetic_items if profile != null else PackedStringArray()


func get_port_position(_kind: String) -> Vector3:
	return bin.global_position if bin != null else global_position


# --- Build mode (PlacedObjects) ---------------------------------------------------

func get_scene_offset() -> Vector3:
	return SCENE_OFFSET


func get_placed_state() -> Dictionary:
	return get_save_state()


func apply_placed_state(state: Dictionary) -> void:
	apply_save_state(state)


## Items someone dropped into the crate move along with it.
func on_relocated(old_transform: Transform3D, new_transform: Transform3D) -> void:
	var old_bin: Vector3 = old_transform * bin.position
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if item == null or not is_instance_valid(item) or item.get_state() != ScrapItem.State.IN_WORLD:
			continue
		if item.get_parent() == self:
			continue
		var offset: Vector3 = item.global_position - old_bin
		offset.y = 0.0
		if offset.length() <= BIN_RADIUS:
			item.drop_at(new_transform * (old_transform.affine_inverse() * item.global_position), item.rotation.y)
	_update_status()


## The crate must be empty before the machine goes back to storage.
func get_removal_problem() -> String:
	return "build.problem.crate_not_empty" if get_bin_count() > 0 else ""


func is_switched_on() -> bool:
	return _switched_on


func get_cycle_seconds() -> float:
	if profile == null:
		return 1.0
	if _upgrades != null and not profile.speed_upgrade.is_empty() and _upgrades.is_owned(profile.speed_upgrade):
		return profile.upgraded_cycle_seconds
	return profile.cycle_seconds


## 0..1 progress of the running cycle (animation only).
func get_cycle_progress() -> float:
	if _status != STATUS_WORKING:
		return 0.0
	return clampf(1.0 - _timer / get_cycle_seconds(), 0.0, 1.0)


func get_heap_remaining() -> int:
	return _heap_stock


## Seconds of play time until the supplier's next load (diagnostics, tests).
func get_seconds_until_refill() -> float:
	return maxf(_refill_timer, 0.0)


## "working", "off", "bin_full" or "empty"; empty string while not installed.
func get_status() -> String:
	if not is_installed():
		return ""
	if not _switched_on:
		return STATUS_OFF
	if get_bin_count() >= profile.bin_capacity:
		return STATUS_BIN_FULL
	if _find_loose_piece() == null and (get_heap_remaining() <= 0 or not heap_in_reach()):
		return STATUS_EMPTY
	return STATUS_WORKING


## Items lying in the output crate.
func get_bin_count() -> int:
	return _items_in_bin().size()


func get_live_items() -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for entry: Dictionary in _live:
		if is_instance_valid(entry["node"]):
			items.append(entry["node"])
	return items


## Item ID the magnet will lift next (animation shows it); empty if none.
func peek_next_item_id() -> String:
	var loose: ScrapItem = _find_loose_piece()
	if loose != null:
		return loose.get_item_id()
	return profile.get_heap_item(_heap_taken) if get_heap_remaining() > 0 and heap_in_reach() else ""


## Switches the machine on or off. Returns the new state.
func toggle() -> bool:
	_switched_on = not _switched_on
	_update_status()
	return _switched_on


func _process(delta: float) -> void:
	if not is_installed():
		return
	_process_refill(delta)
	_update_status()
	if _status != STATUS_WORKING:
		return
	_timer -= delta
	if _timer <= 0.0:
		collect_once()
		_timer = get_cycle_seconds()


## Finishes one cycle now: one piece into the crate. Returns it or null.
func collect_once() -> ScrapItem:
	if not is_installed() or get_bin_count() >= profile.bin_capacity:
		return null
	var slot: int = _free_slot()
	var target: Vector3 = _slot_position(slot)
	var loose: ScrapItem = _find_loose_piece()
	if loose != null:
		loose.drop_at(target, _yaw_for(loose.object_id))
		piece_collected.emit(loose, false)
		_update_status()
		return loose
	if get_heap_remaining() <= 0 or not heap_in_reach():
		return null
	var item_id: String = profile.get_heap_item(_heap_taken)
	_heap_taken += 1
	_heap_stock -= 1
	_counter += 1
	var item: ScrapItem = _spawn("%s%d" % [OBJECT_PREFIX, _counter], item_id, slot)
	if item != null:
		item.reveal()
		piece_collected.emit(item, true)
	_update_status()
	return item


func get_save_state() -> Dictionary:
	var items: Array = []
	for entry: Dictionary in _live:
		items.append({"id": entry["id"], "item": entry["item"], "slot": entry["slot"]})
	return {"on": _switched_on, "timer": snappedf(_timer, 0.01), "heap_taken": _heap_taken,
		"heap_stock": _heap_stock, "refill_timer": snappedf(_refill_timer, 0.01), "counter": _counter,
		"items": items}


## Recreates the crate items of a save. Call before the world object states.
func apply_save_state(state: Dictionary) -> void:
	_switched_on = bool(state.get("on", true))
	_timer = float(state.get("timer", get_cycle_seconds()))
	_heap_taken = maxi(int(state.get("heap_taken", 0)), 0)
	# Saves from before the refills only knew how much had been taken.
	_heap_stock = clampi(int(state.get("heap_stock", profile.heap_size - _heap_taken)), 0, profile.heap_size)
	_refill_timer = float(state.get("refill_timer", profile.refill_interval_seconds))
	_counter = int(state.get("counter", 0))
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			push_warning("MagnetCollector: ignoring foreign object id '%s'." % object_id)
			continue
		_spawn(object_id, str(saved.get("item", "")), int(saved.get("slot", 0)))
	_update_status()


# --- Helpers ----------------------------------------------------------------

## The supplier only comes while the machine stands and the heap has room.
func _process_refill(delta: float) -> void:
	if profile.refill_interval_seconds <= 0.0 or profile.refill_amount <= 0:
		return
	_refill_timer -= delta
	if _refill_timer > 0.0:
		return
	_refill_timer = profile.refill_interval_seconds
	refill_now()


## Tips one supplier load onto the heap now. Returns the pieces added.
func refill_now() -> int:
	var amount: int = mini(profile.refill_amount, profile.heap_size - _heap_stock)
	if amount <= 0:
		return 0
	_heap_stock += amount
	refilled.emit(amount)
	_update_status()
	return amount


## Nearest loose magnetic item in the work area that is not already in the crate.
func _find_loose_piece() -> ScrapItem:
	if profile == null or not _installed:
		return null
	var center: Vector3 = get_work_center()
	var best: ScrapItem
	var best_distance: float = INF
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if item == null or not is_instance_valid(item) or item.get_state() != ScrapItem.State.IN_WORLD:
			continue
		if not profile.magnetic_items.has(item.get_item_id()) or _is_in_bin(item):
			continue
		var offset: Vector3 = item.global_position - center
		offset.y = 0.0
		if offset.length() <= profile.work_radius and offset.length() < best_distance:
			best = item
			best_distance = offset.length()
	return best


func _items_in_bin() -> Array[ScrapItem]:
	var result: Array[ScrapItem] = []
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if item != null and is_instance_valid(item) and item.get_state() == ScrapItem.State.IN_WORLD \
				and _is_in_bin(item):
			result.append(item)
	return result


func _is_in_bin(item: ScrapItem) -> bool:
	if bin == null:
		return false
	var offset: Vector3 = item.global_position - bin.global_position
	offset.y = 0.0
	return offset.length() <= BIN_RADIUS


func _slots() -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	if bin != null:
		for child: Node in bin.get_children():
			if child is Marker3D:
				markers.append(child)
	return markers


func _slot_position(slot: int) -> Vector3:
	var markers: Array[Marker3D] = _slots()
	if markers.is_empty():
		return bin.global_position if bin != null else global_position
	return markers[posmod(slot, markers.size())].global_position


## First slot no crate item is lying on.
func _free_slot() -> int:
	var markers: Array[Marker3D] = _slots()
	var occupied: Array[ScrapItem] = _items_in_bin()
	for slot: int in markers.size():
		var free: bool = true
		for item: ScrapItem in occupied:
			var offset: Vector3 = item.global_position - markers[slot].global_position
			offset.y = 0.0
			if offset.length() < 0.15:
				free = false
				break
		if free:
			return slot
	return occupied.size()


func _spawn(object_id: String, item_id: String, slot: int) -> ScrapItem:
	var definition: ItemDefinition = item_catalog.get_definition(item_id) if item_catalog != null else null
	if definition == null or item_scene == null:
		push_warning("MagnetCollector: cannot create unknown item '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	item.global_position = _slot_position(slot)
	item.rotation.y = _yaw_for(object_id)
	_live.append({"id": object_id, "item": item_id, "slot": slot, "node": item})
	item.interaction_state_changed.connect(_on_item_state_changed)
	item_spawned.emit(item)
	return item


func _on_item_state_changed(target: Interactable) -> void:
	var item: ScrapItem = target as ScrapItem
	if item == null:
		return
	var state: ScrapItem.State = item.get_state()
	if state != ScrapItem.State.SOLD and state != ScrapItem.State.PROCESSED:
		return
	for index: int in _live.size():
		if _live[index]["node"] == item:
			_live.remove_at(index)
			break
	item_removed.emit(item.object_id)
	item.queue_free()


func _yaw_for(object_id: String) -> float:
	return fposmod(float(absi(object_id.hash()) % 1000) * 0.7, TAU)


func _update_status() -> void:
	var status: String = get_status()
	if status != _status:
		_status = status
		status_changed.emit(status)


func _on_upgrade_purchased(definition: UpgradeDefinition) -> void:
	if profile == null:
		return
	if definition.id == profile.speed_upgrade:
		_timer = minf(_timer, get_cycle_seconds())
	_update_status()
