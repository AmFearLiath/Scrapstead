extends Interactable
## P0 pickup test object: marks itself as picked up and leaves the world
## interaction. No inventory in P0 (docs/p0-interaction-controller.md, 10).

var _picked_up: bool = false


func is_interaction_available() -> bool:
	return super() and not _picked_up


func interact(_context: InteractionContext) -> Dictionary:
	if _picked_up:
		return make_result(false, "ui.interaction.unavailable")
	_set_picked_up(true)
	return make_result(true, "ui.interaction.picked_up", {"name": get_display_name()})


func get_save_state() -> Dictionary:
	return {"picked_up": true} if _picked_up else {}


func apply_save_state(state: Dictionary) -> void:
	_set_picked_up(bool(state.get("picked_up", false)))


func _set_picked_up(value: bool) -> void:
	_picked_up = value
	visible = not value
	# Leaving the interactable layer makes the detector report the exit.
	collision_layer = 0 if value else 4
	interaction_state_changed.emit(self)
