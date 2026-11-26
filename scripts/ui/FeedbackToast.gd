extends Control
## Short, unobtrusive feedback line for action results ("what happened").

const DISPLAY_SECONDS: float = 2.6
## Longer texts (e.g. a neighbor's delivery note) stay readable a little longer.
const SECONDS_PER_CHARACTER: float = 0.045
const MAX_DISPLAY_SECONDS: float = 7.0

@onready var _label: Label = %Message
@onready var _panel: PanelContainer = $PanelContainer

var _tween: Tween


func _ready() -> void:
	modulate.a = 0.0


## How long a message stays fully visible.
static func display_seconds_for(text: String) -> float:
	return clampf(1.2 + text.length() * SECONDS_PER_CHARACTER, DISPLAY_SECONDS, MAX_DISPLAY_SECONDS)


## Shows an already localized message. `positive` colours the accent.
func show_message(text: String, positive: bool = true) -> void:
	if text.is_empty():
		return
	_label.text = text
	_label.add_theme_color_override("font_color",
		Color(0.949, 0.902, 0.812) if positive else Color(1.0, 0.68, 0.52))
	if _tween != null:
		_tween.kill()
	modulate.a = 1.0
	_panel.position.y = 8.0
	_tween = create_tween()
	_tween.tween_property(_panel, "position:y", 0.0, 0.15)
	_tween.tween_interval(display_seconds_for(text))
	_tween.tween_property(self, "modulate:a", 0.0, 0.4)
