class_name DismantleStation
extends Interactable
## Optional processing station (P1b, generalised for the yard helper). Takes
## any carried input of its ProcessingProfile and, after a hold action,
## replaces it with the profile's outputs in the carry basket. The input can
## always be sold directly instead; processing is never required.
##
## The authored radio keeps its prepared output placements (P1b saves stay
## valid). Every other input gets fresh outputs created at runtime, announced
## to the scene controller like the deliveries and freed once sold.

## A runtime output became part of the world (also when restored from a save).
signal item_spawned(item: ScrapItem)
## A runtime output left the world for good (sold or consumed).
signal item_removed(object_id: String)
## An input was dismantled (by the player or by staff).
signal dismantled(input: ScrapItem, outputs: Array)

const OBJECT_PREFIX := "dismantled_"

@export var profile: ProcessingProfile
## Further inputs the station handles (e.g. the toaster).
@export var extra_profiles: Array[ProcessingProfile] = []
## Stable ID of the authored input placement with prepared outputs (P1b).
@export var input_object_id: String = ""
## Prepared output placements of that input (pending until produced).
@export var output_items: Array[ScrapItem] = []
## Scene used for runtime outputs.
@export var item_scene: PackedScene

var _inputs: Dictionary = {}
var _counter: int = 0
## Live runtime outputs: {"id", "item", "node"}.
var _live: Array[Dictionary] = []


## The scene controller hands over the world objects so the station can
## resolve stable IDs without global lookups.
func set_world_objects(objects: Dictionary) -> void:
	_inputs = objects


var _last_context: InteractionContext


func get_hold_duration() -> float:
	var input_id: String = _carried_input(_last_context)
	var input: ScrapItem = _inputs.get(input_id) as ScrapItem
	return get_seconds_for(input)


## Processing profile for an input item, or null.
func get_profile_for(item_id: String) -> ProcessingProfile:
	for candidate: ProcessingProfile in [profile] + extra_profiles:
		if candidate != null and candidate.input_item != null and candidate.input_item.id == item_id:
			return candidate
	return null


## Seconds this input takes (the default profile if unknown).
func get_seconds_for(item: ScrapItem) -> float:
	var found: ProcessingProfile = get_profile_for(item.get_item_id()) if item != null else null
	return found.seconds if found != null else profile.seconds


## Whether this item can be dismantled here.
func accepts(item: ScrapItem) -> bool:
	return item != null and get_profile_for(item.get_item_id()) != null \
		and (item.get_state() == ScrapItem.State.CARRIED or item.get_state() == ScrapItem.State.IN_WORLD)


func get_prompt_detail(context: InteractionContext) -> String:
	_last_context = context
	var input_id: String = _carried_input(context)
	var shown: ProcessingProfile = profile
	if not input_id.is_empty() and _inputs.get(input_id) is ScrapItem:
		shown = get_profile_for((_inputs[input_id] as ScrapItem).get_item_id())
	var args: Dictionary = {
		"input": tr(shown.input_item.name_key),
		"direct": shown.input_item.sell_value,
		"outputs": _output_names(shown),
		"value": shown.get_output_value(),
		"seconds": NumberFormat.decimal(shown.seconds, 1),
	}
	if input_id.is_empty():
		return tr("ui.dismantle.detail_missing").format(args)
	return tr("ui.dismantle.detail").format(args)


func check_requirements(context: InteractionContext) -> Dictionary:
	var input_id: String = _carried_input(context)
	if input_id.is_empty():
		return {"ok": false, "message_key": "ui.dismantle.missing_input",
			"message_args": {"input": tr(profile.input_item.name_key)}}
	if not _can_produce(input_id):
		return {"ok": false, "message_key": "ui.dismantle.done_already", "message_args": {}}
	var input_profile: ProcessingProfile = _profile_of(input_id)
	var free_after: int = context.inventory.get_free_slots() + input_profile.input_item.carry_size
	if free_after < input_profile.get_output_size():
		return {"ok": false, "message_key": "ui.inventory.full_short", "message_args": {}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	var requirements: Dictionary = check_requirements(context)
	if not requirements["ok"]:
		return make_result(false, requirements["message_key"], requirements["message_args"])
	var input_id: String = _carried_input(context)
	var input: ScrapItem = _inputs.get(input_id) as ScrapItem
	if input == null:
		return make_result(false, "ui.interaction.unavailable")
	context.inventory.remove(input_id)
	for output: ScrapItem in _produce(input):
		context.inventory.add(output.object_id, output.get_item_id())
	interaction_state_changed.emit(self)
	var used: ProcessingProfile = get_profile_for(input.get_item_id())
	return make_result(true, "ui.dismantle.done", {"input": tr(used.input_item.name_key),
		"outputs": _output_names(used), "value": used.get_output_value()})


## Dismantles an input a staff member carries (not in the player's basket).
## Returns the outputs, already in state "carried", or an empty array.
func dismantle_for_staff(input: ScrapItem) -> Array[ScrapItem]:
	if not accepts(input) or input.get_state() != ScrapItem.State.CARRIED or not _can_produce(input.object_id):
		return []
	var outputs: Array[ScrapItem] = _produce(input)
	interaction_state_changed.emit(self)
	return outputs


## Plain data: runtime outputs still in the world. Empty = initial state.
func get_save_state() -> Dictionary:
	if _counter == 0:
		return {}
	var items: Array = []
	for entry: Dictionary in _live:
		items.append({"id": entry["id"], "item": entry["item"]})
	return {"counter": _counter, "items": items}


## Recreates runtime outputs. The scene applies this before the states of
## the outputs themselves (carried, dropped somewhere).
func apply_save_state(state: Dictionary) -> void:
	_counter = int(state.get("counter", 0))
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			push_warning("DismantleStation: ignoring foreign object id '%s'." % object_id)
			continue
		_spawn(object_id, str(saved.get("item", "")))


# --- Helpers ------------------------------------------------------------------

## Consumes the input and returns its outputs in state "carried".
func _produce(input: ScrapItem) -> Array[ScrapItem]:
	var outputs: Array[ScrapItem] = []
	input.set_state(ScrapItem.State.PROCESSED)
	if input.object_id == input_object_id and _prepared_outputs_ready():
		outputs.assign(output_items)
	else:
		for definition: ItemDefinition in get_profile_for(input.get_item_id()).outputs:
			_counter += 1
			var item: ScrapItem = _spawn("%s%d" % [OBJECT_PREFIX, _counter], definition.id)
			if item != null:
				outputs.append(item)
	for output: ScrapItem in outputs:
		output.set_state(ScrapItem.State.CARRIED)
	dismantled.emit(input, outputs)
	return outputs


func _can_produce(input_id: String) -> bool:
	if input_id == input_object_id and _prepared_outputs_ready():
		return true
	return item_scene != null


## The carried input in the player's basket (the authored radio first).
func _carried_input(context: InteractionContext) -> String:
	if context == null or context.inventory == null:
		return ""
	if context.inventory.contains(input_object_id):
		return input_object_id
	for entry: Dictionary in context.inventory.get_entries():
		if get_profile_for(entry["item_id"]) != null:
			return entry["object_id"]
	return ""


func _profile_of(input_id: String) -> ProcessingProfile:
	var input: ScrapItem = _inputs.get(input_id) as ScrapItem
	var found: ProcessingProfile = get_profile_for(input.get_item_id()) if input != null else null
	return found if found != null else profile


func _prepared_outputs_ready() -> bool:
	if output_items.size() != profile.outputs.size():
		return false
	for output: ScrapItem in output_items:
		if output == null or output.get_state() != ScrapItem.State.PENDING:
			return false
	return true


func _spawn(object_id: String, item_id: String) -> ScrapItem:
	var definition: ItemDefinition
	for known: ProcessingProfile in [profile] + extra_profiles:
		for candidate: ItemDefinition in known.outputs:
			if candidate.id == item_id:
				definition = candidate
	if definition == null or item_scene == null:
		push_warning("DismantleStation: cannot create '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	item.global_position = get_interaction_point() + Vector3(0, 0.1, 0)
	_live.append({"id": object_id, "item": item_id, "node": item})
	item.interaction_state_changed.connect(_on_output_state_changed)
	item_spawned.emit(item)
	return item


func _on_output_state_changed(target: Interactable) -> void:
	var item: ScrapItem = target as ScrapItem
	if item == null or (item.get_state() != ScrapItem.State.SOLD and item.get_state() != ScrapItem.State.PROCESSED):
		return
	for index: int in _live.size():
		if _live[index]["node"] == item:
			_live.remove_at(index)
			break
	item_removed.emit(item.object_id)
	item.queue_free()


func _output_names(shown: ProcessingProfile = null) -> String:
	var names: PackedStringArray = []
	for output: ItemDefinition in (shown if shown != null else profile).outputs:
		names.append(tr(output.name_key))
	return " + ".join(names)
