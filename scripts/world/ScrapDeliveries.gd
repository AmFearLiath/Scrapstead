class_name ScrapDeliveries
extends Node3D
## Drop-off spot where neighbors leave scrap once the yard looks open for
## business (DeliveryTable). Scene-local: it spawns real ScrapItem placements
## at its slot markers, announces them to the scene controller (which owns the
## object registry) and frees them again once they were sold.
##
## Only counts play time; nothing arrives while the game is closed. The
## delivered items are ordinary common materials: no story or key items.

## A delivered item became part of the world (also when restored from a save).
signal item_spawned(item: ScrapItem)
## A delivered item left the world for good (sold or consumed).
signal item_removed(object_id: String)
## A new delivery arrived (not emitted when restoring a save).
signal delivery_arrived(entry: Dictionary, items: Array)

const OBJECT_PREFIX := "delivery_"
## Seconds before checking again when the drop-off spot is still full.
const BLOCKED_RETRY_SECONDS := 20.0

@export var table: DeliveryTable
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene

var _upgrades: UpgradeProgress
var _timer: float = 0.0
var _next_entry: int = 0
var _counter: int = 0
## Live delivered items in spawn order: {"id", "item", "slot", "node"}.
var _live: Array[Dictionary] = []


func _ready() -> void:
	if table != null:
		_timer = table.first_delay_seconds


func setup(upgrades: UpgradeProgress) -> void:
	_upgrades = upgrades


## Whether deliveries are unlocked (the entrance is spruced up).
func is_unlocked() -> bool:
	return table != null and _upgrades != null and _upgrades.is_owned(table.required_upgrade)


## Seconds of play time until the next attempt (diagnostics, HUD, tests).
func get_seconds_until_next() -> float:
	return maxf(_timer, 0.0)


## Delivered items still lying in the yard (not carried, not sold).
func get_waiting_count() -> int:
	var count: int = 0
	for entry: Dictionary in _live:
		var item: ScrapItem = entry["node"]
		if is_instance_valid(item) and item.get_state() == ScrapItem.State.IN_WORLD:
			count += 1
	return count


func get_live_items() -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for entry: Dictionary in _live:
		if is_instance_valid(entry["node"]):
			items.append(entry["node"])
	return items


func _process(delta: float) -> void:
	if not is_unlocked():
		return
	_timer -= delta
	if _timer > 0.0:
		return
	if get_waiting_count() >= table.max_waiting_items:
		_timer = BLOCKED_RETRY_SECONDS
		return
	deliver_next()
	_timer = table.interval_seconds


## Delivers the next table entry now. Returns the spawned items.
func deliver_next() -> Array[ScrapItem]:
	var spawned: Array[ScrapItem] = []
	if table == null or table.entries.is_empty():
		return spawned
	var entry: Dictionary = table.get_entry(_next_entry)
	_next_entry = posmod(_next_entry + 1, table.entries.size())
	var used_slots: Dictionary = {}
	for live: Dictionary in _live:
		var live_item: ScrapItem = live["node"]
		if is_instance_valid(live_item) and live_item.get_state() == ScrapItem.State.IN_WORLD:
			used_slots[int(live["slot"])] = true
	for item_id: String in entry.get("items", PackedStringArray()):
		_counter += 1
		var slot: int = _free_slot(used_slots)
		used_slots[slot] = true
		var item: ScrapItem = _spawn("%s%d" % [OBJECT_PREFIX, _counter], item_id, slot)
		if item != null:
			item.reveal()
			spawned.append(item)
	delivery_arrived.emit(entry, spawned)
	return spawned


func get_save_state() -> Dictionary:
	var items: Array = []
	for entry: Dictionary in _live:
		var saved: Dictionary = {"id": entry["id"], "item": entry["item"], "slot": entry["slot"]}
		if entry.has("pos"):
			saved["pos"] = entry["pos"]
		items.append(saved)
	return {"timer": snappedf(_timer, 0.01), "next_entry": _next_entry, "counter": _counter,
		"items": items}


## Recreates the delivered items of a save. Call before the world object
## states are applied, so moved or carried items find their placement.
func apply_save_state(state: Dictionary) -> void:
	if table != null:
		_timer = float(state.get("timer", table.first_delay_seconds))
	_next_entry = int(state.get("next_entry", 0))
	_counter = int(state.get("counter", 0))
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			push_warning("ScrapDeliveries: ignoring foreign object id '%s'." % object_id)
			continue
		var item: ScrapItem = _spawn(object_id, str(saved.get("item", "")), int(saved.get("slot", 0)))
		var saved_position: Variant = saved.get("pos")
		if item != null and typeof(saved_position) == TYPE_ARRAY and saved_position.size() == 3:
			item.global_position = Vector3(float(saved_position[0]), float(saved_position[1]), float(saved_position[2]))
			_live[-1]["pos"] = saved_position


func _spawn(object_id: String, item_id: String, slot: int) -> ScrapItem:
	var definition: ItemDefinition = item_catalog.get_definition(item_id) if item_catalog != null else null
	if definition == null or item_scene == null:
		push_warning("ScrapDeliveries: cannot deliver unknown item '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	var marker: Node3D = _slot_marker(slot)
	item.global_position = marker.global_position if marker != null else global_position
	item.rotation.y = fposmod(float(_hash_id(object_id)) * 0.7, TAU)
	item.tool_source = _upgrades
	_live.append({"id": object_id, "item": item_id, "slot": slot, "node": item})
	item.interaction_state_changed.connect(_on_item_state_changed)
	item.opened.connect(_on_item_opened)
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


## A crate was pried open: its contents spill out around it.
func _on_item_opened(crate: ScrapItem) -> void:
	var centre: Vector3 = crate.global_position
	var count: int = crate.definition.contents.size()
	for index: int in count:
		var content: ItemDefinition = crate.definition.contents[index]
		_counter += 1
		var item: ScrapItem = _spawn("%s%d" % [OBJECT_PREFIX, _counter], content.id, -1)
		if item == null:
			continue
		var angle: float = TAU * float(index) / float(count) + 0.6
		var at: Vector3 = centre + Vector3(cos(angle), 0.0, sin(angle)) * 0.42
		item.global_position = at
		_live[-1]["pos"] = [snappedf(at.x, 0.001), snappedf(at.y, 0.001), snappedf(at.z, 0.001)]
		item.reveal()


func _slot_count() -> int:
	var count: int = 0
	for child: Node in get_children():
		if child is Marker3D:
			count += 1
	return count


func _slot_marker(slot: int) -> Node3D:
	var markers: Array[Node3D] = []
	for child: Node in get_children():
		if child is Marker3D:
			markers.append(child)
	if markers.is_empty():
		return null
	return markers[posmod(slot, markers.size())]


func _free_slot(used: Dictionary) -> int:
	var count: int = maxi(_slot_count(), 1)
	for slot: int in count:
		if not used.has(slot):
			return slot
	return used.size() % count


func _hash_id(text: String) -> int:
	return absi(text.hash()) % 1000
