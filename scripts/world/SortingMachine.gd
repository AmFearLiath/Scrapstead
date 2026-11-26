class_name SortingMachine
extends Node3D
## The sorting machine, the third machine (docs/processing-chain.md). Mixed
## scrap goes into its hopper - by hand, by Juri or over a conveyor - and the
## drum drops every piece into the bin of its material: steel to the left,
## copper & electronics to the front, wood to the right. Each bin is an output
## channel (named after its MaterialGroup) that can feed its own press.
##
## Process logic only; SortingAnimator shows the drum and the lamp.

signal status_changed(status: String)
signal piece_fed(item_id: String)
## A piece landed in a bin (presentation).
signal piece_sorted(item: ScrapItem, channel: String)
signal item_spawned(item: ScrapItem)
signal item_removed(object_id: String)

const OBJECT_PREFIX := "sorted_"
const STATUS_WORKING := "working"
const STATUS_OFF := "off"
const STATUS_WAITING := "waiting"
const STATUS_BIN_FULL := "bin_full"
## Items closer than this to a bin count as lying in it.
const BIN_RADIUS := 0.45

@export var profile: SorterProfile
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene
## Group id -> bin node (Marker3D children are the slots), set up from `bins`.
@export var bins: Array[Node3D] = []
@export var hopper_point: Node3D

var _objects: Dictionary = {}
var _switched_on: bool = true
var _timer: float = 0.0
var _queue: Array[String] = []
var _counter: int = 0
var _status: String = ""
## {"id", "item", "slot", "channel", "node"}
var _live: Array[Dictionary] = []
var _installed: bool = false
## Prefix of the items this machine creates; unique per placed machine.
var _prefix: String = OBJECT_PREFIX


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
	return _queue.size()


func get_bin_count(channel: String) -> int:
	return get_output_items(channel).size()


func get_live_items() -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for entry: Dictionary in _live:
		if is_instance_valid(entry["node"]):
			items.append(entry["node"])
	return items


func get_cycle_progress() -> float:
	if _status != STATUS_WORKING:
		return 0.0
	return clampf(1.0 - _timer / get_cycle_seconds(), 0.0, 1.0)


func get_status() -> String:
	if not is_installed():
		return ""
	if not _switched_on:
		return STATUS_OFF
	if _queue.is_empty():
		return STATUS_WAITING
	if _next_index() < 0:
		return STATUS_BIN_FULL
	return STATUS_WORKING


# --- Machine ports -----------------------------------------------------------------

func get_port_position(kind: String) -> Vector3:
	if kind == "in" and hopper_point != null:
		return hopper_point.global_position
	return global_position


func accepts_item_type(item_id: String) -> bool:
	return profile != null and profile.accepts(item_id)


func can_accept(item_id: String) -> bool:
	return is_installed() and profile.accepts(item_id) and _queue.size() < profile.hopper_capacity


func accept_item(item: ScrapItem) -> bool:
	if item == null or not can_accept(item.get_item_id()):
		return false
	_queue.append(item.get_item_id())
	item.set_state(ScrapItem.State.PROCESSED)
	piece_fed.emit(item.get_item_id())
	_update_status()
	return true


## Pieces lying in one bin (the channel is the material group id).
func get_output_items(channel: String = "") -> Array[ScrapItem]:
	var result: Array[ScrapItem] = []
	var bin: Node3D = _bin(channel)
	if bin == null:
		return result
	for entry: Dictionary in _live:
		var item: ScrapItem = entry["node"]
		if not is_instance_valid(item) or item.get_state() != ScrapItem.State.IN_WORLD:
			continue
		var offset: Vector3 = item.global_position - bin.global_position
		offset.y = 0.0
		if offset.length() <= BIN_RADIUS:
			result.append(item)
	return result


func get_output_item_ids(channel: String = "") -> PackedStringArray:
	var group: MaterialGroup = profile.get_group(channel) if profile != null else null
	return group.items if group != null else PackedStringArray()


func feed_from_inventory(inventory: CarryInventory) -> int:
	var fed: int = 0
	for entry: Dictionary in inventory.get_entries():
		var item: ScrapItem = _objects.get(entry["object_id"]) as ScrapItem
		if item == null or not can_accept(item.get_item_id()):
			continue
		if not inventory.remove(item.object_id):
			continue
		_queue.append(item.get_item_id())
		item.set_state(ScrapItem.State.PROCESSED)
		piece_fed.emit(item.get_item_id())
		fed += 1
	_update_status()
	return fed


# --- Build mode -------------------------------------------------------------------

func get_placed_state() -> Dictionary:
	return get_save_state()


func apply_placed_state(state: Dictionary) -> void:
	apply_save_state(state)


func on_relocated(_old_transform: Transform3D, _new_transform: Transform3D) -> void:
	_update_status()


func get_removal_problem() -> String:
	if not _queue.is_empty():
		return "build.problem.sorter_not_empty"
	for group: MaterialGroup in profile.groups:
		if get_bin_count(group.id) > 0:
			return "build.problem.sorter_not_empty"
	return ""


# --- Process -----------------------------------------------------------------------

func _process(delta: float) -> void:
	if not is_installed():
		return
	_update_status()
	if _status != STATUS_WORKING:
		_timer = get_cycle_seconds()
		return
	_timer -= delta
	if _timer <= 0.0:
		sort_once()
		_timer = get_cycle_seconds()


## Sorts the oldest piece whose bin has room. Returns the new item or null.
func sort_once() -> ScrapItem:
	if not is_installed():
		return null
	var index: int = _next_index()
	if index < 0:
		return null
	var item_id: String = _queue[index]
	_queue.remove_at(index)
	var group: MaterialGroup = profile.group_for(item_id)
	_counter += 1
	var item: ScrapItem = _spawn("%s%d" % [_prefix, _counter], item_id, group.id, _free_slot(group.id))
	if item != null:
		item.reveal()
		piece_sorted.emit(item, group.id)
	_update_status()
	return item


func get_save_state() -> Dictionary:
	var items: Array = []
	for entry: Dictionary in _live:
		items.append({"id": entry["id"], "item": entry["item"], "slot": entry["slot"], "channel": entry["channel"]})
	return {"on": _switched_on, "timer": snappedf(_timer, 0.01), "hopper": Array(_queue), "counter": _counter,
		"items": items}


func apply_save_state(state: Dictionary) -> void:
	_switched_on = bool(state.get("on", true))
	_timer = float(state.get("timer", get_cycle_seconds()))
	_counter = int(state.get("counter", 0))
	_queue.clear()
	for item_id: Variant in state.get("hopper", []):
		if profile != null and profile.accepts(str(item_id)) and _queue.size() < profile.hopper_capacity:
			_queue.append(str(item_id))
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			continue
		_spawn(object_id, str(saved.get("item", "")), str(saved.get("channel", "")), int(saved.get("slot", 0)))
	_update_status()


# --- Helpers -----------------------------------------------------------------------

func _next_index() -> int:
	for index: int in _queue.size():
		var group: MaterialGroup = profile.group_for(_queue[index])
		if group != null and get_bin_count(group.id) < profile.bin_capacity:
			return index
	return -1


func _bin(channel: String) -> Node3D:
	for bin: Node3D in bins:
		if bin != null and bin.name.to_lower() == "bin" + channel:
			return bin
	return null


func _slots(channel: String) -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	var bin: Node3D = _bin(channel)
	if bin != null:
		for child: Node in bin.get_children():
			if child is Marker3D:
				markers.append(child)
	return markers


func _free_slot(channel: String) -> int:
	var markers: Array[Marker3D] = _slots(channel)
	var occupied: Array[ScrapItem] = get_output_items(channel)
	for slot: int in markers.size():
		var free: bool = true
		for item: ScrapItem in occupied:
			var offset: Vector3 = item.global_position - markers[slot].global_position
			offset.y = 0.0
			if offset.length() < 0.1:
				free = false
				break
		if free:
			return slot
	return occupied.size()


func _slot_position(channel: String, slot: int) -> Vector3:
	var markers: Array[Marker3D] = _slots(channel)
	if markers.is_empty():
		var bin: Node3D = _bin(channel)
		return bin.global_position if bin != null else global_position
	# More pieces than slots: stack them a little higher.
	var layer: int = slot / markers.size()
	return markers[posmod(slot, markers.size())].global_position + Vector3(0, 0.08 * layer, 0)


func _spawn(object_id: String, item_id: String, channel: String, slot: int) -> ScrapItem:
	var definition: ItemDefinition = item_catalog.get_definition(item_id) if item_catalog != null else null
	if definition == null or item_scene == null:
		push_warning("SortingMachine: cannot create unknown item '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	item.global_position = _slot_position(channel, slot)
	item.rotation.y = fposmod(float(absi(object_id.hash()) % 1000) * 0.7, TAU)
	_live.append({"id": object_id, "item": item_id, "slot": slot, "channel": channel, "node": item})
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
