extends Control
## Walt's list on a sheet of paper (P4): the short main task sequence with
## ticks. Presentation only; the StoryDirector says what is done.

signal closed

const INK := Color(0.24, 0.18, 0.14, 1.0)
const DONE_INK := Color(0.24, 0.18, 0.14, 0.45)
const TICK := Color(0.6, 0.29, 0.13, 1.0)

@onready var _rows: VBoxContainer = %TaskRows
@onready var _footer: Label = %Footer
@onready var _close_button: Button = %CloseButton
@onready var _sheet: Control = $Sheet


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)


## `states`: [{"entry": Dictionary, "done": bool}] in list order.
func open(states: Array) -> void:
	for child: Node in _rows.get_children():
		child.queue_free()
	var done_count: int = 0
	for state: Dictionary in states:
		var done: bool = state["done"]
		if done:
			done_count += 1
		_rows.add_child(_make_row(state["entry"], done))
	_footer.text = tr("ui.tasks.all_done") if done_count == states.size() and not states.is_empty() \
		else tr("ui.tasks.progress").format({"done": done_count, "total": states.size()})
	show()
	_sheet.pivot_offset = _sheet.size * 0.5
	_sheet.rotation = 0.02
	_sheet.scale = Vector2(0.92, 0.92)
	create_tween().tween_property(_sheet, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
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


func _make_row(entry: Dictionary, done: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var box := Panel.new()
	box.custom_minimum_size = Vector2(22, 22)
	box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var style := StyleBoxFlat.new()
	style.bg_color = TICK if done else Color(0, 0, 0, 0)
	style.border_color = TICK
	style.set_border_width_all(3)
	style.set_corner_radius_all(3)
	box.add_theme_stylebox_override("panel", style)
	box.name = "Done" if done else "Open"
	if done:
		# A drawn tick: independent of the font's symbol coverage.
		var tick := Line2D.new()
		tick.points = PackedVector2Array([Vector2(5, 11), Vector2(9.5, 16), Vector2(17.5, 5.5)])
		tick.width = 3.5
		tick.default_color = Color(0.98, 0.95, 0.88)
		tick.joint_mode = Line2D.LINE_JOINT_ROUND
		tick.begin_cap_mode = Line2D.LINE_CAP_ROUND
		tick.end_cap_mode = Line2D.LINE_CAP_ROUND
		box.add_child(tick)
	row.add_child(box)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 0)
	var title := Label.new()
	title.text = tr(str(entry["title"]))
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", DONE_INK if done else INK)
	text.add_child(title)
	var comment := Label.new()
	comment.text = tr(str(entry["comment"]))
	comment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comment.add_theme_font_size_override("font_size", 15)
	comment.add_theme_color_override("font_color", Color(TICK, 0.8 if not done else 0.4))
	text.add_child(comment)
	row.add_child(text)
	return row
