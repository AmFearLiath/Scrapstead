class_name ScrapPress
extends Node3D
## The scrap press, the second machine (docs/scrap-press.md), placed and moved
## in build mode. Small steel scrap goes into its hopper - by hand, by Juri or
## over a conveyor from another machine - and as soon as enough pieces of one
## material group (MaterialGroup) are together, they become one bale of that
## material on the output tray. A bale is worth more than its
## pieces and needs far less room in the basket.
##
## Process logic only; ScrapPressAnimator shows the ram.
##
## Machine port interface (used by MachineLinks, docs/machine-links.md):
## inputs: can_accept(item_id), accept_item(item); outputs: get_output_items().

signal status_changed(status: String)
## A piece went into the hopper (presentation: clank).
signal piece_fed(item_id: String)
## A bale was pressed (presentation: thump, dust).
signal bale_pressed(bale: ScrapItem)
## A bale became part of the world (also when restored from a save).
signal item_spawned(item: ScrapItem)
## A bale left the world for good (sold or consumed).
signal item_removed(object_id: String)

const OBJECT_PREFIX := "press_"
const STATUS_WORKING := "working"
const STATUS_OFF := "off"
const STATUS_WAITING := "waiting"
const STATUS_TRAY_FULL := "tray_full"
## Bales closer than this to the tray count as lying on it.
const TRAY_RADIUS := 0.8
## Machine origin relative to the footprint centre (build grid).
const SCENE_OFFSET := Vector3(0.0, 0.0, -0.4)

@export var profile: PressProfile
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene
## Output tray; its Marker3D children are the slots.
@export var tray: Node3D
## Where pieces enter (conveyor end, feeding animation).
@export var hopper_point: Node3D

var _objects: Dictionary = {}
var _switched_on: bool = true
var _timer: float = 0.0
## Item IDs waiting in the hopper, in feeding order.
var _hopper: Array[String] = []
var _counter: int = 0
var _status: String = ""
var _live: Array[Dictionary] = []
var _installed: bool = false
## Pieces on their way over a belt: {"item": id, "left": seconds}. They
## count against the hopper but arrive (and get processed) only when the
## piece visibly drops in.
var _incoming: Array[Dictionary] = []
## Prefix of the items this machine creates; unique per placed machine.
var _prefix: String = OBJECT_PREFIX


## `objects` is the scene's live registry (object ID -> Interactable).
func setup(objects: Dictionary, uid: String = "") -> void:
	_objects = objects
	if not uid.is_empty():
		_prefix = "%s%s_" % [OBJECT_PREFIX, uid]
		for node: Node in find_children("*", "Interactable", true, false):
			if not node is ScrapItem:
				(node as Interactable).object_id += "_" + uid
	_timer = get_cycle_seconds()
	_installed = true
	_update_status()


func is_installed() -> bool:
	return _installed and profile != null


func get_cycle_seconds() -> float:
	return profile.cycle_seconds if profile != null else 1.0


func is_switched_on() -> bool:
	return _switched_on


func toggle() -> bool:
	_switched_on = not _switched_on
	_update_status()
	return _switched_on


func get_hopper_count() -> int:
	return _hopper.size() + _incoming.size()


func get_hopper_items() -> Array[String]:
	return _hopper.duplicate()


func get_tray_count() -> int:
	return _items_on_tray().size()


func get_live_items() -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for entry: Dictionary in _live:
		if is_instance_valid(entry["node"]):
			items.append(entry["node"])
	return items


## 0..1 progress of the running press stroke (animation only).
func get_cycle_progress() -> float:
	if _status != STATUS_WORKING:
		return 0.0
	return clampf(1.0 - _timer / get_cycle_seconds(), 0.0, 1.0)


## "working", "off", "waiting" or "tray_full"; empty while not installed.
func get_status() -> String:
	if not is_installed():
		return ""
	if not _switched_on:
		return STATUS_OFF
	if get_tray_count() >= profile.tray_capacity:
		return STATUS_TRAY_FULL
	if _next_group() == null:
		return STATUS_WAITING
	return STATUS_WORKING


# --- Machine ports -----------------------------------------------------------------

func get_port_position(kind: String) -> Vector3:
	if kind == "in" and hopper_point != null:
		return hopper_point.global_position
	return tray.global_position if tray != null else global_position


## Whether the press takes this kind of item at all (link compatibility).
func accepts_item_type(item_id: String) -> bool:
	return profile != null and profile.accepts(item_id)


func get_output_item_ids(_channel: String = "") -> PackedStringArray:
	return profile.get_bale_items() if profile != null else PackedStringArray()


## Whether the hopper takes this item now.
func can_accept(item_id: String) -> bool:
	return is_installed() and profile.accepts(item_id) and get_hopper_count() < profile.hopper_capacity


## Takes a piece into the hopper: the item is consumed (state "processed").
## `delay`: seconds until the piece arrives (it rides a belt meanwhile).
func accept_item(item: ScrapItem, delay: float = 0.0) -> bool:
	if item == null or not can_accept(item.get_item_id()):
		return false
	item.set_state(ScrapItem.State.PROCESSED)
	if delay > 0.0:
		_incoming.append({"item": item.get_item_id(), "left": delay})
		return true
	_hopper.append(item.get_item_id())
	piece_fed.emit(item.get_item_id())
	_update_status()
	return true


## Bales on the tray are this machine's output (for a following machine).
func get_output_items(_channel: String = "") -> Array[ScrapItem]:
	return _items_on_tray()


func holds_output(item: ScrapItem) -> bool:
	return _items_on_tray().has(item)


## Feeds every fitting piece from the player's basket. Returns the count.
func feed_from_inventory(inventory: CarryInventory) -> int:
	var fed: int = 0
	for entry: Dictionary in inventory.get_entries():
		var item: ScrapItem = _objects.get(entry["object_id"]) as ScrapItem
		if item == null or not can_accept(item.get_item_id()):
			continue
		if not inventory.remove(item.object_id):
			continue
		_hopper.append(item.get_item_id())
		item.set_state(ScrapItem.State.PROCESSED)
		piece_fed.emit(item.get_item_id())
		fed += 1
	_update_status()
	return fed


# --- Build mode (PlacedObjects) ---------------------------------------------------

func get_scene_offset() -> Vector3:
	return SCENE_OFFSET


func get_placed_state() -> Dictionary:
	return get_save_state()


func apply_placed_state(state: Dictionary) -> void:
	apply_save_state(state)


## Bales are children of the press and move along; nothing else to do.
func on_relocated(_old_transform: Transform3D, _new_transform: Transform3D) -> void:
	_update_status()


## Hopper and tray must be empty before the press goes back to storage.
func get_removal_problem() -> String:
	if get_tray_count() > 0 or get_hopper_count() > 0:
		return "build.problem.press_not_empty"
	return ""


# --- Process -----------------------------------------------------------------------

func _process(delta: float) -> void:
	if not is_installed():
		return
	_advance_incoming(delta)
	_update_status()
	if _status != STATUS_WORKING:
		_timer = get_cycle_seconds()
		return
	_timer -= delta
	if _timer <= 0.0:
		press_once()
		_timer = get_cycle_seconds()


## Finishes one stroke now: one bale onto the tray. Returns it or null.
func press_once() -> ScrapItem:
	if not is_installed() or get_tray_count() >= profile.tray_capacity:
		return null
	var group: MaterialGroup = _next_group()
	if group == null:
		return null
	var taken: int = 0
	var rest: Array[String] = []
	for item_id: String in _hopper:
		if taken < group.pieces_per_bale and group.has_item(item_id):
			taken += 1
		else:
			rest.append(item_id)
	_hopper = rest
	_counter += 1
	var bale: ScrapItem = _spawn("%s%d" % [_prefix, _counter], group.bale_item, _free_slot())
	if bale != null:
		bale.reveal()
		bale_pressed.emit(bale)
	_update_status()
	return bale


func get_save_state() -> Dictionary:
	var items: Array = []
	for entry: Dictionary in _live:
		items.append({"id": entry["id"], "item": entry["item"], "slot": entry["slot"]})
	return {"on": _switched_on, "timer": snappedf(_timer, 0.01), "hopper": _saved_hopper(),
		"counter": _counter, "items": items}


func apply_save_state(state: Dictionary) -> void:
	_switched_on = bool(state.get("on", true))
	_timer = float(state.get("timer", get_cycle_seconds()))
	_counter = int(state.get("counter", 0))
	_hopper.clear()
	for item_id: Variant in state.get("hopper", []):
		if profile != null and profile.accepts(str(item_id)) and _hopper.size() < profile.hopper_capacity:
			_hopper.append(str(item_id))
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			continue
		_spawn(object_id, str(saved.get("item", "")), int(saved.get("slot", 0)))
	_update_status()


# --- Helpers -----------------------------------------------------------------------

## Hopper contents for saving: pieces still on a belt count as arrived.
func _saved_hopper() -> Array:
	var saved: Array = Array(_hopper)
	for entry: Dictionary in _incoming:
		saved.append(str(entry["item"]))
	return saved


## Pieces riding a belt drop into the hopper when their time is up.
func _advance_incoming(delta: float) -> void:
	for index: int in range(_incoming.size() - 1, -1, -1):
		_incoming[index]["left"] = float(_incoming[index]["left"]) - delta
	while not _incoming.is_empty() and float(_incoming[0]["left"]) <= 0.0:
		var item_id: String = str(_incoming.pop_front()["item"])
		_hopper.append(item_id)
		piece_fed.emit(item_id)

## Pieces waiting per material group id.
func get_group_counts() -> Dictionary:
	var counts: Dictionary = {}
	for item_id: String in _hopper:
		var group: MaterialGroup = profile.group_for(item_id)
		if group != null:
			counts[group.id] = int(counts.get(group.id, 0)) + 1
	return counts


## The material whose pieces fill a bale first (the oldest piece decides).
func _next_group() -> MaterialGroup:
	if profile == null:
		return null
	var counts: Dictionary = get_group_counts()
	for item_id: String in _hopper:
		var group: MaterialGroup = profile.group_for(item_id)
		if group != null and int(counts.get(group.id, 0)) >= group.pieces_per_bale:
			return group
	return null

func _items_on_tray() -> Array[ScrapItem]:
	var result: Array[ScrapItem] = []
	if tray == null:
		return result
	for entry: Dictionary in _live:
		var item: ScrapItem = entry["node"]
		if not is_instance_valid(item) or item.get_state() != ScrapItem.State.IN_WORLD:
			continue
		var offset: Vector3 = item.global_position - tray.global_position
		offset.y = 0.0
		if offset.length() <= TRAY_RADIUS:
			result.append(item)
	return result


func _slots() -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	if tray != null:
		for child: Node in tray.get_children():
			if child is Marker3D:
				markers.append(child)
	return markers


func _free_slot() -> int:
	var markers: Array[Marker3D] = _slots()
	var occupied: Array[ScrapItem] = _items_on_tray()
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


func _slot_position(slot: int) -> Vector3:
	var markers: Array[Marker3D] = _slots()
	if markers.is_empty():
		return tray.global_position if tray != null else global_position
	return markers[posmod(slot, markers.size())].global_position


func _spawn(object_id: String, item_id: String, slot: int) -> ScrapItem:
	var definition: ItemDefinition = item_catalog.get_definition(item_id) if item_catalog != null else null
	if definition == null or item_scene == null:
		push_warning("ScrapPress: cannot create unknown item '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	item.global_position = _slot_position(slot)
	item.rotation.y = fposmod(float(absi(object_id.hash()) % 1000) * 0.3, 0.6) - 0.3
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


func _update_status() -> void:
	var status: String = get_status()
	if status != _status:
		_status = status
		status_changed.emit(status)
