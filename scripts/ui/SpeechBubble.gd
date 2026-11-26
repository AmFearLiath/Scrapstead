extends Control
## Speech bubble that follows a 3D anchor (Scrappy's head) on screen, with a
## typewriter reveal. Presentation only; the StoryDirector decides what is said.

signal finished

## Seconds per character for the typewriter.
@export var seconds_per_character: float = 0.028
## Minimum reading time after the text is complete.
@export var min_hold_seconds: float = 2.2

@onready var _label: Label = %Text
@onready var _panel: PanelContainer = $Panel

## Bubbles of off-screen speakers stop below the top HUD band.
const HUD_TOP: float = 210.0

var _camera: Camera3D
var _anchor: Node3D
var _tween: Tween


func _ready() -> void:
	hide()


func setup(camera: Camera3D, anchor: Node3D) -> void:
	_camera = camera
	_anchor = anchor


func is_speaking() -> bool:
	return visible


## Shows an already localized line; returns its total display time in seconds.
func say(text: String) -> float:
	_label.text = text
	_label.visible_ratio = 0.0
	show()
	modulate.a = 1.0
	_place()
	if _tween != null:
		_tween.kill()
	var type_time: float = text.length() * seconds_per_character
	var hold: float = maxf(min_hold_seconds, text.length() * 0.055)
	_panel.scale = Vector2(0.6, 0.6)
	_tween = create_tween()
	_tween.tween_property(_panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_label, "visible_ratio", 1.0, type_time)
	_tween.tween_interval(hold)
	_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	_tween.tween_callback(_on_done)
	return type_time + hold + 0.4


func _on_done() -> void:
	hide()
	finished.emit()


func _process(_delta: float) -> void:
	if visible:
		_place()


func _place() -> void:
	if _camera == null or not is_instance_valid(_anchor):
		return
	var screen: Vector2 = _camera.unproject_position(_anchor.global_position)
	_panel.pivot_offset = Vector2(_panel.size.x * 0.5, _panel.size.y)
	position = screen - Vector2(_panel.size.x * 0.5, _panel.size.y + 14.0)
	var viewport_size: Vector2 = get_viewport_rect().size
	position.x = clampf(position.x, 12.0, viewport_size.x - _panel.size.x - 12.0)
	# Below the top HUD band (credits, notes, carry panel, toasts), above the prompt.
	position.y = clampf(position.y, HUD_TOP, viewport_size.y - _panel.size.y - 160.0)
