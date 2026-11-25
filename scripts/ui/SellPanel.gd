extends Control
## Sales counter panel: overview of carried items, the resulting revenue and a
## confirmation. Rules and booking stay in SellStation; the panel only
## displays the quote and forwards the confirmation once.

## Emitted when the panel closes; `result` is empty when cancelled.
signal closed(result: Dictionary)

@onready var _lines: GridContainer = %Lines
@onready var _total_value: Label = %TotalValue
@onready var _confirm_button: Button = %ConfirmButton
@onready var _cancel_button: Button = %CancelButton

var _station: SellStation
var _quote: Dictionary = {}


func _ready() -> void:
	hide()
	_confirm_button.pressed.connect(_on_confirm)
	_cancel_button.pressed.connect(func() -> void: _close({}))


## Shows a fresh quote of the station.
func open(station: SellStation) -> void:
	_station = station
	_quote = station.create_quote()
	for child: Node in _lines.get_children():
		child.queue_free()
	for line: Dictionary in _quote["lines"]:
		_add_cell(tr(line["name_key"]), HORIZONTAL_ALIGNMENT_LEFT, true)
		_add_cell(tr("ui.sell.line_count").format({"count": line["count"], "unit": line["unit_value"]}),
			HORIZONTAL_ALIGNMENT_RIGHT)
		_add_cell(tr("ui.credits_amount").format({"credits": line["total"]}), HORIZONTAL_ALIGNMENT_RIGHT)
	_total_value.text = tr("ui.credits_amount").format({"credits": _quote["total"]})
	_confirm_button.text = tr("ui.sell.confirm").format({"credits": _quote["total"]})
	_confirm_button.disabled = _quote["total"] <= 0
	show()
	_confirm_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		_close({})


func _on_confirm() -> void:
	# Guard against double clicks: the button is disabled before booking.
	if _confirm_button.disabled or _station == null:
		return
	_confirm_button.disabled = true
	_close(_station.confirm_sale(_quote))


func _close(result: Dictionary) -> void:
	if not visible:
		return
	hide()
	_quote = {}
	_station = null
	closed.emit(result)


func _add_cell(text: String, alignment: HorizontalAlignment, expand: bool = false) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	if expand:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lines.add_child(label)
