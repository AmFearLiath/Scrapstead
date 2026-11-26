class_name ScrappyHeadSite
extends Interactable
## Scrappy's half-buried head at the edge of the large scrap heap (P2). Freeing
## it is a hold action without tools, so the discovery never sits behind a
## purchase. The head becomes a key item (never sellable).

@export_range(0.5, 10.0) var dig_seconds: float = 2.0
## Visual removed once the head is taken.
@export var buried_visual: Node3D

var _taken: bool = false


func is_taken() -> bool:
	return _taken


func is_interaction_available() -> bool:
	return super() and not _taken


func get_hold_duration() -> float:
	return dig_seconds


func get_prompt_detail(_context: InteractionContext) -> String:
	return tr("story.head_site.detail")


func interact(context: InteractionContext) -> Dictionary:
	if _taken or context == null or context.story == null:
		return make_result(false, "ui.interaction.unavailable")
	_set_taken(true)
	context.story.add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	context.story.set_flag("found_head")
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	result["panel_data"] = {"title": tr("story.head_found.title"), "body": tr("story.head_found.body")}
	return result


func get_save_state() -> Dictionary:
	return {"taken": true} if _taken else {}


func apply_save_state(state: Dictionary) -> void:
	_set_taken(bool(state.get("taken", false)))


func _set_taken(value: bool) -> void:
	_taken = value
	if buried_visual != null:
		buried_visual.visible = not value
	collision_layer = 0 if value else 4
	interaction_state_changed.emit(self)
