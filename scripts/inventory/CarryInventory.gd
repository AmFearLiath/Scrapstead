class_name CarryInventory
extends RefCounted
## Minimal carried-items inventory with a slot capacity. Holds stable world
## object IDs in pickup order; item sizes come from the ItemCatalog.

## Emitted whenever content or capacity changed.
signal changed

var _catalog: ItemCatalog
var _capacity: int = 4
## Entries: {"object_id": String, "item_id": String}
var _entries: Array[Dictionary] = []
var _revision: int = 0


func _init(catalog: ItemCatalog, capacity: int) -> void:
	_catalog = catalog
	_capacity = maxi(1, capacity)


func get_capacity() -> int:
	return _capacity


## Applies a new capacity (e.g. after an upgrade). Content is never dropped;
## a lower capacity only blocks new pickups.
func set_capacity(capacity: int) -> void:
	if capacity == _capacity:
		return
	_capacity = maxi(1, capacity)
	_touch()


func get_used_slots() -> int:
	var used: int = 0
	for entry: Dictionary in _entries:
		used += _size_of(entry["item_id"])
	return used


func get_free_slots() -> int:
	return maxi(0, _capacity - get_used_slots())


func can_add(item_id: String) -> bool:
	var definition: ItemDefinition = _catalog.get_definition(item_id)
	return definition != null and definition.carry_size <= get_free_slots()


## Adds a world object. Returns false without change if it does not fit, is
## unknown or already carried.
func add(object_id: String, item_id: String) -> bool:
	if contains(object_id) or not can_add(item_id):
		return false
	_entries.append({"object_id": object_id, "item_id": item_id})
	_touch()
	return true


## Restores an entry from a save game. Capacity is not enforced here so that a
## valid save is never silently truncated; unknown item IDs are rejected.
func restore(object_id: String, item_id: String) -> bool:
	if contains(object_id) or _catalog.get_definition(item_id) == null:
		return false
	_entries.append({"object_id": object_id, "item_id": item_id})
	_touch()
	return true


func remove(object_id: String) -> bool:
	for index: int in _entries.size():
		if _entries[index]["object_id"] == object_id:
			_entries.remove_at(index)
			_touch()
			return true
	return false


func contains(object_id: String) -> bool:
	for entry: Dictionary in _entries:
		if entry["object_id"] == object_id:
			return true
	return false


func is_empty() -> bool:
	return _entries.is_empty()


## Copy of the entries in pickup order.
func get_entries() -> Array[Dictionary]:
	return _entries.duplicate(true)


## Object ID of the most recently picked up entry, or "".
func get_last_object_id() -> String:
	return _entries.back()["object_id"] if not _entries.is_empty() else ""


## Entries grouped by item ID in first-pickup order:
## [{"item_id", "count", "definition"}].
func get_grouped() -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		var found: bool = false
		for group: Dictionary in groups:
			if group["item_id"] == entry["item_id"]:
				group["count"] += 1
				found = true
				break
		if not found:
			groups.append({"item_id": entry["item_id"], "count": 1,
				"definition": _catalog.get_definition(entry["item_id"])})
	return groups


## Increases with every change; used to detect stale sale quotes.
func get_revision() -> int:
	return _revision


func to_save_data() -> Array:
	var ids: Array = []
	for entry: Dictionary in _entries:
		ids.append(entry["object_id"])
	return ids


func _size_of(item_id: String) -> int:
	var definition: ItemDefinition = _catalog.get_definition(item_id)
	return definition.carry_size if definition != null else 1


func _touch() -> void:
	_revision += 1
	changed.emit()
