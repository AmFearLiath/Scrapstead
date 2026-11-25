extends Node
## Controller of the main menu scene. Queries the continue state through
## GameSession, handles menu actions and keeps only local menu state
## (docs/p0-implementation-readiness.md, section 3.2).

@onready var _ui: CanvasLayer = $MenuUI

var _busy: bool = false


func _ready() -> void:
	_ui.new_game_requested.connect(_on_new_game_requested)
	_ui.continue_requested.connect(_on_continue_requested)
	_ui.quit_requested.connect(_on_quit_requested)
	_ui.setting_changed.connect(_on_setting_changed)
	GameSession.session_error.connect(_on_session_error)
	_ui.show_settings(GameSession.get_setting(GameSession.SETTING_LOCALE),
		GameSession.get_setting(GameSession.SETTING_WINDOW_MODE))
	_refresh_continue_state()


func _refresh_continue_state() -> void:
	# The button state only mirrors the check; continue_game() validates again.
	_ui.set_continue_available(GameSession.has_valid_save())


func _on_new_game_requested() -> void:
	if _busy:
		return
	_busy = true
	await _ui.fade_out()
	if not GameSession.start_new_game():
		_recover_from_failed_start()


func _on_continue_requested() -> void:
	if _busy:
		return
	_busy = true
	await _ui.fade_out()
	if not GameSession.continue_game():
		_recover_from_failed_start()


func _recover_from_failed_start() -> void:
	_busy = false
	_ui.fade_in(GameSession.has_valid_save())


func _on_session_error(message_key: String) -> void:
	_ui.show_status(message_key)
	_refresh_continue_state()


func _on_setting_changed(key: String, value: String) -> void:
	if not GameSession.set_setting(key, value):
		push_warning("MainMenu: setting %s=%s was rejected." % [key, value])
	_ui.show_settings(GameSession.get_setting(GameSession.SETTING_LOCALE),
		GameSession.get_setting(GameSession.SETTING_WINDOW_MODE))


func _on_quit_requested() -> void:
	if _busy:
		return
	get_tree().quit()
