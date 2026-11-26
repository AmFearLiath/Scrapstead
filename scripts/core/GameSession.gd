extends Node
## Session service (autoload "GameSession").
##
## Owns the session-wide prototype state as plain data, coordinates
## "New Game", "Continue", save requests and the scene changes between menu and
## gameplay, and owns the persistent player settings. Holds no references to
## scene nodes (see docs/p0-system-integration.md, section 4.1).

## Emitted after the gameplay scene was entered successfully.
signal session_started
## Emitted after every save attempt.
signal save_completed(success: bool, message_key: String)
## Emitted when starting or continuing failed. The caller stays where it is.
signal session_error(message_key: String)

const MENU_SCENE_PATH: String = "res://scenes/menu/MainMenu.tscn"
const GAMEPLAY_SCENE_PATH: String = "res://scenes/world/OldYardTest.tscn"
const GAMEPLAY_SCENE_ID: String = "old_yard_test"

const SETTING_LOCALE: String = "locale"
const SETTING_WINDOW_MODE: String = "window_mode"
const SETTING_MUSIC_VOLUME: String = "music_volume"
const SETTING_SFX_VOLUME: String = "sfx_volume"
const SUPPORTED_LOCALES: PackedStringArray = ["de", "en"]
const WINDOW_MODES: PackedStringArray = ["windowed", "fullscreen"]

## Shows Walt's letter when a new game starts. Automated tests switch it off.
var intro_enabled: bool = true

var _state: Dictionary = {}
var _settings: Dictionary = {}
var _session_active: bool = false
var _last_save_message_key: String = ""
var _last_save_success: bool = false


func _ready() -> void:
	_settings = _sanitize_settings(SaveService.load_settings())
	_apply_settings()


## Creates the defined initial state and enters the gameplay scene.
## Scene-specific start values (spawn point, object defaults) are owned by the
## gameplay scene; an empty entry means "use the initial state".
func start_new_game() -> bool:
	return _enter_gameplay(create_initial_state())


## Loads and validates the save game. The gameplay scene is only entered after
## valid data has been adopted.
func continue_game() -> bool:
	var result: Dictionary = SaveService.load_game()
	if not result["ok"]:
		session_error.emit(result["message_key"])
		return false
	if result["data"]["scene_id"] != GAMEPLAY_SCENE_ID:
		session_error.emit("ui.save.error.invalid_data")
		return false
	return _enter_gameplay(result["data"])


## Adopts the snapshot created by the gameplay scene and persists it.
## A failed write leaves the running session intact and is reported.
func request_save(snapshot: Dictionary) -> bool:
	var candidate: Dictionary = snapshot.duplicate(true)
	candidate["save_version"] = SaveService.SAVE_VERSION
	candidate["scene_id"] = GAMEPLAY_SCENE_ID
	var result: Dictionary = SaveService.save_game(candidate)
	_last_save_success = result["ok"]
	_last_save_message_key = result["message_key"]
	if result["ok"]:
		_state = candidate
	save_completed.emit(result["ok"], result["message_key"])
	return result["ok"]


## Deep copy of the current session state.
func get_current_state() -> Dictionary:
	return _state.duplicate(true)


## Continue availability as determined by SaveService.
func has_valid_save() -> bool:
	return SaveService.has_valid_save()


## True while the gameplay scene is active.
func is_session_active() -> bool:
	return _session_active


## Short status text for the debug overlay (not player-facing).
func get_debug_status() -> String:
	var save_text: String = "none"
	if not _last_save_message_key.is_empty():
		save_text = ("ok" if _last_save_success else "FAILED") + " (" + _last_save_message_key + ")"
	return "session=%s scene=%s last_save=%s" % [
		"active" if _session_active else "idle", _state.get("scene_id", "-"), save_text]


## Leaves the gameplay scene. Unsaved progress is discarded by design;
## callers save first if they want to keep it.
func return_to_main_menu() -> void:
	_session_active = false
	_state = {}
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file(MENU_SCENE_PATH)
	if error != OK:
		push_error("GameSession: main menu scene could not be loaded (%s)." % error_string(error))


## Definition of a fresh session.
func create_initial_state() -> Dictionary:
	return {
		"save_version": SaveService.SAVE_VERSION,
		"scene_id": GAMEPLAY_SCENE_ID,
		"player": {},
		"world_objects": {},
		"wallet": {},
		"inventory": [],
		"upgrades": [],
		"story": {"flags": [], "key_items": [], "spoken_once": []},
		"scrappy": {"state": "dormant", "follow": true},
		"deliveries": {},
		"employee": {},
		"placed": {},
	}


## Current value of a persistent setting.
func get_setting(key: String) -> Variant:
	return _settings.get(key)


## Changes, applies and persists a setting. Unknown keys or values are rejected.
func set_setting(key: String, value: Variant) -> bool:
	var candidate: Dictionary = _settings.duplicate()
	candidate[key] = value
	candidate = _sanitize_settings(candidate)
	var accepted: Variant = candidate.get(key)
	if typeof(accepted) == TYPE_FLOAT and typeof(value) in [TYPE_FLOAT, TYPE_INT]:
		if not is_equal_approx(accepted, float(value)):
			return false
	elif accepted != value:
		return false
	_settings = candidate
	_apply_settings()
	var result: Dictionary = SaveService.save_settings(_settings)
	if not result["ok"]:
		push_warning("GameSession: settings could not be written.")
	return true


func _enter_gameplay(state: Dictionary) -> bool:
	_state = state.duplicate(true)
	var error: Error = get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)
	if error != OK:
		_state = {}
		session_error.emit("ui.session.error.scene_load_failed")
		return false
	_session_active = true
	session_started.emit()
	return true


func _sanitize_settings(raw: Dictionary) -> Dictionary:
	var locale: String = str(raw.get(SETTING_LOCALE, ""))
	if not SUPPORTED_LOCALES.has(locale):
		locale = "de" if OS.get_locale_language() == "de" else "en"
	var window_mode: String = str(raw.get(SETTING_WINDOW_MODE, "windowed"))
	if not WINDOW_MODES.has(window_mode):
		window_mode = "windowed"
	return {
		SETTING_LOCALE: locale,
		SETTING_WINDOW_MODE: window_mode,
		SETTING_MUSIC_VOLUME: _sanitize_volume(raw.get(SETTING_MUSIC_VOLUME, 0.8)),
		SETTING_SFX_VOLUME: _sanitize_volume(raw.get(SETTING_SFX_VOLUME, 0.8)),
	}


func _sanitize_volume(value: Variant) -> float:
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return 0.8
	return clampf(float(value), 0.0, 1.0)


func _apply_settings() -> void:
	TranslationServer.set_locale(_settings[SETTING_LOCALE])
	_apply_bus_volume(&"Music", _settings[SETTING_MUSIC_VOLUME])
	_apply_bus_volume(&"SFX", _settings[SETTING_SFX_VOLUME])
	if DisplayServer.get_name() == "headless":
		return
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED
	if _settings[SETTING_WINDOW_MODE] == "fullscreen":
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)


func _apply_bus_volume(bus_name: StringName, linear: float) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	if bus == -1:
		return
	AudioServer.set_bus_mute(bus, linear <= 0.001)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(linear, 0.001)))
