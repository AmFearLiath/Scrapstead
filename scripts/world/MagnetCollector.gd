class_name MagnetCollector
extends Node3D
## The small magnetic collector, the first machine (P3b, docs/first-machine.md).
##
## Once bought, it swings its magnet over Walt's nail heap and drops one iron
## piece per cycle into its output crate. Loose magnetic scrap lying in its
## work area is taken first; only then does it dig into the heap's finite
## stock. It never creates anything beyond that stock and never duplicates.
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
## The machine was installed (bought) while the scene runs.
signal installed

const OBJECT_PREFIX := "magnet_"
const STATUS_WORKING := "working"
const STATUS_OFF := "off"
const STATUS_BIN_FULL := "bin_full"
const STATUS_EMPTY := "empty"
## Items closer than this to the crate count as lying in it.
const BIN_RADIUS := 0.95

@export var profile: MachineProfile
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene
## Centre of the heap and of the work area.
@export var heap_center: Marker3D
## Output crate; its Marker3D children are the slots.
@export var bin: Node3D

var _upgrades: UpgradeProgress
var _objects: Dictionary = {}
var _switched_on: bool = true
var _timer: float = 0.0
var _heap_taken: int = 0
var _counter: int = 0
var _status: String = ""
## Live crate items created from the heap: {"id", "item", "slot", "node"}.
var _live: Array[Dictionary] = []


func _ready() -> void:
	_apply_installed()


## `objects` is the scene's live registry (object ID -> Interactable).
func setup(upgrades: UpgradeProgress, objects: Dictionary) -> void:
	_upgrades = upgrades
	_objects = objects
	_timer = get_cycle_seconds()
	_upgrades.upgrade_purchased.connect(_on_upgrade_purchased)
	_apply_installed()


func is_installed() -> bool:
	return profile != null and _upgrades != null and _upgrades.is_owned(profile.required_upgrade)


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
	return maxi(profile.heap_size - _heap_taken, 0) if profile != null else 0


## "working", "off", "bin_full" or "empty"; empty string while not installed.
func get_status() -> String:
	if not is_installed():
		return ""
	if not _switched_on:
		return STATUS_OFF
	if get_bin_count() >= profile.bin_capacity:
		return STATUS_BIN_FULL
	if _find_loose_piece() == null and get_heap_remaining() <= 0:
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
	return profile.get_heap_item(_heap_taken) if get_heap_remaining() > 0 else ""


## Switches the machine on or off. Returns the new state.
func toggle() -> bool:
	_switched_on = not _switched_on
	_update_status()
	return _switched_on


func _process(delta: float) -> void:
	if not is_installed():
		return
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
	if get_heap_remaining() <= 0:
		return null
	var item_id: String = profile.get_heap_item(_heap_taken)
	_heap_taken += 1
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
		"counter": _counter, "items": items}


## Recreates the crate items of a save. Call before the world object states.
func apply_save_state(state: Dictionary) -> void:
	_switched_on = bool(state.get("on", true))
	_timer = float(state.get("timer", get_cycle_seconds()))
	_heap_taken = clampi(int(state.get("heap_taken", 0)), 0, profile.heap_size)
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

## Nearest loose magnetic item in the work area that is not already in the crate.
func _find_loose_piece() -> ScrapItem:
	if heap_center == null or profile == null:
		return null
	var best: ScrapItem
	var best_distance: float = INF
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if item == null or not is_instance_valid(item) or item.get_state() != ScrapItem.State.IN_WORLD:
			continue
		if not profile.magnetic_items.has(item.get_item_id()) or _is_in_bin(item):
			continue
		var offset: Vector3 = item.global_position - heap_center.global_position
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
	if definition.id == profile.required_upgrade:
		_timer = get_cycle_seconds()
		_apply_installed()
		installed.emit()
	elif definition.id == profile.speed_upgrade:
		_timer = minf(_timer, get_cycle_seconds())
	_update_status()


func _apply_installed() -> void:
	var present: bool = is_installed()
	var model: Node3D = get_node_or_null("Machine") as Node3D
	if model != null:
		model.visible = present
	var controls: CollisionObject3D = get_node_or_null("Machine/Controls") as CollisionObject3D
	if controls != null:
		controls.collision_layer = 4 if present else 0
	var body: CollisionObject3D = get_node_or_null("Machine/Body") as CollisionObject3D
	if body != null:
		body.collision_layer = 1 if present else 0
	var placeholder: Node3D = get_node_or_null("ReservedPad") as Node3D
	if placeholder != null:
		placeholder.visible = not present
