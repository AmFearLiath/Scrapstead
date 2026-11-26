extends Control
## Walt's letter on a sheet of paper. Shown when a new game starts and from the
## pause menu. Closes with the button, E or Esc.

signal closed

@onready var _body: Label = %Body
@onready var _close_button: Button = %CloseButton
@onready var _sheet: Control = $Sheet


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)


func open() -> void:
	_body.text = tr("story.letter.body")
	show()
	_sheet.pivot_offset = _sheet.size * 0.5
	_sheet.scale = Vector2(0.9, 0.9)
	_sheet.rotation = -0.06
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(_sheet, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sheet, "rotation", -0.015, 0.3)
	_close_button.grab_focus()


func close() -> void:
	if not visible:
		return
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("pause_menu") or event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		close()
