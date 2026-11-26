class_name PlacedStorage
extends Interactable
## A placed storage object - pallets, crate stack, barrels (docs/building-system.md):
## press E to put everything you carry away, or, with empty hands, to take as
## much as fits into the basket. Stored items stay real world objects in
## state "stored"; the storage only keeps their IDs.

## Pieces it holds.
@export var capacity: int = 8

## Object ID -> ScrapItem of the scene and the player's interaction context
## (both set by the scene controller).
var objects: Dictionary = {}
var context: InteractionContext
var _stored: PackedStringArray = []


func _ready() -> void:
	if object_id.is_empty():
		object_id = get_parent().name + "_storage"
	super()


func get_stored_ids() -> PackedStringArray:
	return _stored


func get_action_key() -> String:
	return "ui.action.store" if _carrying_anything() else "ui.action.take_out"


func get_prompt_detail(_context: InteractionContext) -> String:
	var counts: Dictionary = {}
	for object_id_value: String in _stored:
		var item: ScrapItem = objects.get(object_id_value) as ScrapItem
		if item != null:
			counts[item.get_display_name()] = int(counts.get(item.get_display_name(), 0)) + 1
	var parts: PackedStringArray = []
	for item_name: String in counts:
		parts.append("%s ×%d" % [item_name, counts[item_name]])
	return tr("ui.storage.detail").format({"used": _stored.size(), "capacity": capacity,
		"contents": ", ".join(parts) if not parts.is_empty() else tr("ui.storage.empty")})


func check_requirements(context: InteractionContext) -> Dictionary:
	if context == null or context.inventory == null:
		return {"ok": false, "message_key": "ui.interaction.unavailable", "message_args": {}}
	if not context.inventory.is_empty():
		if _stored.size() >= capacity:
			return {"ok": false, "message_key": "ui.storage.full", "message_args": {}}
		return {"ok": true, "message_key": "", "message_args": {}}
	if _stored.is_empty():
		return {"ok": false, "message_key": "ui.storage.nothing_inside", "message_args": {}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	var requirements: Dictionary = check_requirements(context)
	if not requirements["ok"]:
		return make_result(false, requirements["message_key"])
	if not context.inventory.is_empty():
		var count: int = 0
		for entry: Dictionary in context.inventory.get_entries():
			if _stored.size() >= capacity:
				break
			var item: ScrapItem = objects.get(entry["object_id"]) as ScrapItem
			if item == null:
				continue
			context.inventory.remove(item.object_id)
			item.set_state(ScrapItem.State.STORED)
			_stored.append(item.object_id)
			count += 1
		interaction_state_changed.emit(self)
		return make_result(true, "ui.storage.stored", {"count": count, "used": _stored.size(), "capacity": capacity})
	var taken: int = 0
	for object_id_value: String in _stored.duplicate():
		var item: ScrapItem = objects.get(object_id_value) as ScrapItem
		if item == null:
			_stored.erase(object_id_value)
			continue
		if not context.inventory.add(item.object_id, item.get_item_id()):
			break
		item.set_state(ScrapItem.State.CARRIED)
		_stored.erase(object_id_value)
		taken += 1
	interaction_state_changed.emit(self)
	if taken == 0:
		return make_result(false, "ui.inventory.full_short")
	return make_result(true, "ui.storage.taken", {"count": taken})


## Build mode: storage must be empty before it goes back into the shed.
func get_removal_problem() -> String:
	return "build.problem.storage_not_empty" if not _stored.is_empty() else ""


func get_placed_state() -> Dictionary:
	return {"stored": Array(_stored)}


## Restores the list; the items themselves are in state "stored" already
## (world_objects). Unknown or non-stored IDs are dropped.
func apply_placed_state(state: Dictionary) -> void:
	_stored = PackedStringArray()
	for value: Variant in state.get("stored", []):
		_stored.append(str(value))


## Called by the scene once all object states are restored.
func verify_contents() -> PackedStringArray:
	var notes: PackedStringArray = []
	for object_id_value: String in _stored.duplicate():
		var item: ScrapItem = objects.get(object_id_value) as ScrapItem
		if item == null or item.get_state() != ScrapItem.State.STORED:
			notes.append("stored item '%s' missing, dropped from %s" % [object_id_value, object_id])
			_stored.erase(object_id_value)
	return notes


func _carrying_anything() -> bool:
	return context != null and context.inventory != null and not context.inventory.is_empty()


func get_display_name() -> String:
	return tr(name_key)
