class_name DismantleStation
extends Interactable
## Optional processing station (P1b). Takes the carried input object of its
## ProcessingProfile and, after a hold action, replaces it with the prepared
## output placements in the carry basket. The input can always be sold
## directly instead; processing is never required.

@export var profile: ProcessingProfile
## Stable ID of the input placement this prototype station processes.
@export var input_object_id: String = ""
## Prepared output placements (pending until produced), one per profile output.
@export var output_items: Array[ScrapItem] = []

var _inputs: Dictionary = {}


## The scene controller hands over the world objects so the station can
## resolve stable IDs without global lookups.
func set_world_objects(objects: Dictionary) -> void:
	_inputs = objects


func get_hold_duration() -> float:
	return profile.seconds


func get_prompt_detail(context: InteractionContext) -> String:
	var args: Dictionary = {
		"input": tr(profile.input_item.name_key),
		"direct": profile.input_item.sell_value,
		"outputs": _output_names(),
		"value": profile.get_output_value(),
		"seconds": snappedf(profile.seconds, 0.1),
	}
	if not _carries_input(context):
		return tr("ui.dismantle.detail_missing").format(args)
	return tr("ui.dismantle.detail").format(args)


func check_requirements(context: InteractionContext) -> Dictionary:
	if not _carries_input(context):
		return {"ok": false, "message_key": "ui.dismantle.missing_input",
			"message_args": {"input": tr(profile.input_item.name_key)}}
	if not _outputs_ready():
		return {"ok": false, "message_key": "ui.dismantle.done_already", "message_args": {}}
	var free_after: int = context.inventory.get_free_slots() + profile.input_item.carry_size
	if free_after < profile.get_output_size():
		return {"ok": false, "message_key": "ui.inventory.full_short", "message_args": {}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	var requirements: Dictionary = check_requirements(context)
	if not requirements["ok"]:
		return make_result(false, requirements["message_key"], requirements["message_args"])
	var input: ScrapItem = _inputs.get(input_object_id) as ScrapItem
	context.inventory.remove(input_object_id)
	input.set_state(ScrapItem.State.PROCESSED)
	for output: ScrapItem in output_items:
		context.inventory.add(output.object_id, output.get_item_id())
		output.set_state(ScrapItem.State.CARRIED)
	interaction_state_changed.emit(self)
	return make_result(true, "ui.dismantle.done", {"input": tr(profile.input_item.name_key),
		"outputs": _output_names(), "value": profile.get_output_value()})


func _carries_input(context: InteractionContext) -> bool:
	return context != null and context.inventory != null and context.inventory.contains(input_object_id)


func _outputs_ready() -> bool:
	if output_items.size() != profile.outputs.size():
		return false
	for output: ScrapItem in output_items:
		if output == null or output.get_state() != ScrapItem.State.PENDING:
			return false
	return true


func _output_names() -> String:
	var names: PackedStringArray = []
	for output: ItemDefinition in profile.outputs:
		names.append(tr(output.name_key))
	return " + ".join(names)
