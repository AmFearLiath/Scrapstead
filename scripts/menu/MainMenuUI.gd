extends CanvasLayer
## Presentation of the main menu. Forwards button presses as signals and shows
## the state provided by MainMenuController. It checks neither save games nor
## progress itself (docs/p0-implementation-readiness.md, section 3.3).

signal new_game_requested
signal continue_requested
signal quit_requested
signal setting_changed(key: String, value: String)

const LOCALE_OPTIONS: PackedStringArray = ["de", "en"]
const WINDOW_MODE_OPTIONS: PackedStringArray = ["windowed", "fullscreen"]

@onready var _menu_panel: VBoxContainer = %MenuPanel
@onready var _new_game_button: Button = %NewGameButton
@onready var _continue_button: Button = %ContinueButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _settings_panel: PanelContainer = %SettingsPanel
@onready var _language_option: OptionButton = %LanguageOption
@onready var _window_mode_option: OptionButton = %WindowModeOption
@onready var _settings_back_button: Button = %SettingsBackButton
@onready var _status_message: Label = %StatusMessage
@onready var _fade: ColorRect = %Fade


func _ready() -> void:
	_new_game_button.pressed.connect(func() -> void: new_game_requested.emit())
	_continue_button.pressed.connect(func() -> void: continue_requested.emit())
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_settings_button.pressed.connect(_open_settings)
	_settings_back_button.pressed.connect(_close_settings)
	_language_option.item_selected.connect(
		func(index: int) -> void: setting_changed.emit("locale", LOCALE_OPTIONS[index]))
	_window_mode_option.item_selected.connect(
		func(index: int) -> void: setting_changed.emit("window_mode", WINDOW_MODE_OPTIONS[index]))
	_settings_panel.hide()
	_status_message.text = ""
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.6)


func _unhandled_input(event: InputEvent) -> void:
	if _settings_panel.visible and event.is_action_pressed("ui_cancel"):
		_close_settings()
		get_viewport().set_input_as_handled()


## Enables or disables "Continue" according to the save check.
func set_continue_available(available: bool) -> void:
	_continue_button.disabled = not available
	_continue_button.tooltip_text = "" if available else "ui.menu.continue_unavailable"
	_focus_default()


## Shows a localized status or error message; an empty key clears it.
func show_status(message_key: String) -> void:
	_status_message.text = message_key


## Reflects the current setting values in the settings panel.
func show_settings(locale: String, window_mode: String) -> void:
	_language_option.select(maxi(0, LOCALE_OPTIONS.find(locale)))
	_window_mode_option.select(maxi(0, WINDOW_MODE_OPTIONS.find(window_mode)))


## Locks the menu and fades to black; awaitable.
func fade_out() -> void:
	_set_buttons_disabled(true)
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", 1.0, 0.35)
	await tween.finished


## Reverts fade_out after a failed start.
func fade_in(continue_available: bool) -> void:
	_set_buttons_disabled(false)
	set_continue_available(continue_available)
	create_tween().tween_property(_fade, "color:a", 0.0, 0.3)


func _open_settings() -> void:
	_menu_panel.hide()
	_settings_panel.show()
	_language_option.grab_focus()


func _close_settings() -> void:
	_settings_panel.hide()
	_menu_panel.show()
	_settings_button.grab_focus()


func _set_buttons_disabled(disabled: bool) -> void:
	for button: Button in [_new_game_button, _continue_button, _settings_button, _quit_button]:
		button.disabled = disabled


func _focus_default() -> void:
	if not _settings_panel.visible:
		(_new_game_button if _continue_button.disabled else _continue_button).grab_focus()
