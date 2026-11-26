extends Control
## Settings during play (P4): language, window, music and effects volume.
## Same settings as the main menu; GameSession applies and stores them, the
## panel only shows values and forwards changes.

signal setting_changed(key: String, value: Variant)
signal closed

const LOCALE_OPTIONS: PackedStringArray = ["de", "en"]
const WINDOW_MODE_OPTIONS: PackedStringArray = ["windowed", "fullscreen"]

@onready var _language_option: OptionButton = %LanguageOption
@onready var _window_mode_option: OptionButton = %WindowModeOption
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	hide()
	_back_button.pressed.connect(close)
	_language_option.item_selected.connect(
		func(index: int) -> void: setting_changed.emit("locale", LOCALE_OPTIONS[index]))
	_window_mode_option.item_selected.connect(
		func(index: int) -> void: setting_changed.emit("window_mode", WINDOW_MODE_OPTIONS[index]))
	_music_slider.value_changed.connect(func(value: float) -> void: setting_changed.emit("music_volume", value))
	_sfx_slider.value_changed.connect(func(value: float) -> void: setting_changed.emit("sfx_volume", value))


func open(locale: String, window_mode: String, music_volume: float, sfx_volume: float) -> void:
	show_values(locale, window_mode, music_volume, sfx_volume)
	show()
	_language_option.grab_focus()


func show_values(locale: String, window_mode: String, music_volume: float, sfx_volume: float) -> void:
	_language_option.select(maxi(0, LOCALE_OPTIONS.find(locale)))
	_window_mode_option.select(maxi(0, WINDOW_MODE_OPTIONS.find(window_mode)))
	_music_slider.set_value_no_signal(music_volume)
	_sfx_slider.set_value_no_signal(sfx_volume)


func close() -> void:
	if not visible:
		return
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		close()
