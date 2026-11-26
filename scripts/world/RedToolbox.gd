class_name RedToolbox
extends Interactable
## Walt's red toolbox (P2): guaranteed home of Scrappy's core component and a
## note from Walt. Opening it once adds the core as a key item.

@export var closed_visual: Node3D
@export var open_visual: Node3D

var _opened: bool = false


func is_opened() -> bool:
	return _opened


func get_action_key() -> String:
	return "ui.action.open" if not _opened else "ui.action.inspect"


func is_interaction_available() -> bool:
	return super()


func interact(context: InteractionContext) -> Dictionary:
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	if not _opened:
		if context == null or context.story == null:
			return make_result(false, "ui.interaction.unavailable")
		_set_opened(true)
		context.story.add_key_item(StoryState.KEY_SCRAPPY_CORE)
		context.story.set_flag("found_core")
		result["panel_data"] = {"title": tr("story.core_found.title"), "body": tr("story.core_found.body")}
	else:
		result["panel_data"] = get_inspection(context)
	return result


func get_save_state() -> Dictionary:
	return {"opened": true} if _opened else {}


func apply_save_state(state: Dictionary) -> void:
	_set_opened(bool(state.get("opened", false)))


func _ready() -> void:
	super()
	_set_opened(_opened)


func _set_opened(value: bool) -> void:
	_opened = value
	if closed_visual != null:
		closed_visual.visible = not value
	if open_visual != null:
		open_visual.visible = value
	interaction_state_changed.emit(self)
