extends Control
## Modal panel that displays a prepared inspection text. Pure presentation:
## closing is reported, nothing else.

signal closed

@onready var _title: Label = %Title
@onready var _body: Label = %Body
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)


## Shows an already localized title and text.
func open(title: String, body: String) -> void:
	_title.text = title
	_body.text = body
	show()
	_close_button.grab_focus()


func close() -> void:
	if not visible:
		return
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if (event.is_action_pressed("interact") or event.is_action_pressed("pause_menu")
			or event.is_action_pressed("inspect_target")):
		get_viewport().set_input_as_handled()
		close()
