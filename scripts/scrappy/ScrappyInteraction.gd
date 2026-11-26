class_name ScrappyInteraction
extends Interactable
## Talking to Scrappy (P2): toggles between "come along" and "wait here".
## Only offered when the player actually faces him, so he does not steal the
## prompt while trailing behind.

signal follow_toggled(following: bool)

var _scrappy: Node3D
var _player: Node3D


func bind(scrappy: Node3D, player: Node3D) -> void:
	_scrappy = scrappy
	_player = player


func is_interaction_available() -> bool:
	if _scrappy == null or not _scrappy.is_active() or _player == null:
		return false
	var to_scrappy: Vector3 = _scrappy.global_position - _player.global_position
	to_scrappy.y = 0.0
	return to_scrappy.length() > 0.01 and _player.get_facing_direction().dot(to_scrappy.normalized()) > 0.5


func get_action_key() -> String:
	return "ui.action.scrappy_wait" if _scrappy != null and _scrappy.is_following() else "ui.action.scrappy_follow"


func get_prompt_detail(_context: InteractionContext) -> String:
	return tr("scrappy.prompt_detail")


func interact(_context: InteractionContext) -> Dictionary:
	var following: bool = _scrappy.toggle_follow()
	follow_toggled.emit(following)
	interaction_state_changed.emit(self)
	return make_result(true)
