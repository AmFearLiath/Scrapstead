class_name RepairBench
extends Interactable
## The workbench (P2). Until crafting exists it is inspectable; once Scrappy's
## head and core component are both found it offers the one-time repair.

## Emitted after the successful repair; the scene stages Scrappy's awakening.
signal scrappy_restored

@export_range(0.5, 10.0) var repair_seconds: float = 3.0


## The scene binds the shared context so prompt and hold time are correct
## before the first interaction.
func bind_context(context: InteractionContext) -> void:
	_last_context = context


func _can_repair(context: InteractionContext) -> bool:
	return (context != null and context.story != null and not context.story.has_flag("scrappy_restored")
		and context.story.has_key_item(StoryState.KEY_SCRAPPY_HEAD)
		and context.story.has_key_item(StoryState.KEY_SCRAPPY_CORE))


func get_action_key() -> String:
	return "ui.action.repair_scrappy" if _can_repair(_last_context) else "ui.action.inspect"


func get_hold_duration() -> float:
	return repair_seconds if _can_repair(_last_context) else 0.0


func get_prompt_detail(context: InteractionContext) -> String:
	_last_context = context
	if _can_repair(context):
		return tr("story.bench.repair_detail")
	return ""


func interact(context: InteractionContext) -> Dictionary:
	_last_context = context
	if _can_repair(context):
		context.story.remove_key_item(StoryState.KEY_SCRAPPY_HEAD)
		context.story.remove_key_item(StoryState.KEY_SCRAPPY_CORE)
		context.story.set_flag("scrappy_restored")
		scrappy_restored.emit()
		interaction_state_changed.emit(self)
		return make_result(true, "story.bench.repaired")
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	var body_key: String = description_key
	if context != null and context.story != null and context.story.has_flag("scrappy_restored"):
		body_key = "station.workbench.description_after"
	result["panel_data"] = {"title": get_display_name(), "body": tr(body_key)}
	return result


var _last_context: InteractionContext
