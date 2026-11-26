class_name StoryState
extends RefCounted
## Persistent story progress (P2): event flags, key items outside the carry
## basket (never sellable), and one-time dialogue lines already spoken.

signal changed

const KEY_SCRAPPY_HEAD: String = "scrappy_head"
const KEY_SCRAPPY_CORE: String = "scrappy_core"

var _flags: PackedStringArray = []
var _key_items: PackedStringArray = []
var _spoken_once: PackedStringArray = []


func _init(data: Dictionary = {}) -> void:
	_flags = PackedStringArray(data.get("flags", []))
	_key_items = PackedStringArray(data.get("key_items", []))
	_spoken_once = PackedStringArray(data.get("spoken_once", []))


func has_flag(flag: String) -> bool:
	return _flags.has(flag)


## Sets a flag; returns true only the first time (useful for one-off events).
func set_flag(flag: String) -> bool:
	if _flags.has(flag):
		return false
	_flags.append(flag)
	changed.emit()
	return true


func has_key_item(item_id: String) -> bool:
	return _key_items.has(item_id)


func add_key_item(item_id: String) -> void:
	if not _key_items.has(item_id):
		_key_items.append(item_id)
		changed.emit()


func remove_key_item(item_id: String) -> void:
	var index: int = _key_items.find(item_id)
	if index != -1:
		_key_items.remove_at(index)
		changed.emit()


func get_key_items() -> PackedStringArray:
	return _key_items.duplicate()


func was_spoken(line_id: String) -> bool:
	return _spoken_once.has(line_id)


func mark_spoken(line_id: String) -> void:
	if not _spoken_once.has(line_id):
		_spoken_once.append(line_id)


func to_save_data() -> Dictionary:
	return {"flags": Array(_flags), "key_items": Array(_key_items), "spoken_once": Array(_spoken_once)}
