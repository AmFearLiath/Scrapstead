extends Control
## Workbench panel: lists the upgrade offers with effect, price and status.
## Purchases are executed by UpgradeStation; the panel reports results and
## refreshes itself.

## Emitted after a purchase attempt.
signal action_result(result: Dictionary)
signal closed

@onready var _offers: VBoxContainer = %Offers
@onready var _close_button: Button = %CloseButton

var _station: UpgradeStation


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)


func open(station: UpgradeStation) -> void:
	_station = station
	_rebuild()
	show()


func close() -> void:
	if not visible:
		return
	hide()
	_station = null
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		close()


func _rebuild() -> void:
	for child: Node in _offers.get_children():
		child.queue_free()
	var first_button: Button
	for offer: Dictionary in _station.get_offers():
		var definition: UpgradeDefinition = offer["definition"]
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 6)
		var title := Label.new()
		title.text = tr(definition.name_key)
		title.add_theme_font_size_override("font_size", 24)
		title.add_theme_color_override("font_color", Color(0.878, 0.663, 0.231))
		card.add_child(title)
		var description := Label.new()
		description.text = tr(definition.description_key)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.custom_minimum_size = Vector2(440, 0)
		card.add_child(description)
		var effect := Label.new()
		var effect_key: String = "ui.upgrade.effect_owned." if offer["status"] == "owned" else "ui.upgrade.effect."
		effect.text = tr(effect_key + definition.stat).format({"current": offer["current"],
			"after": offer["after"]})
		card.add_child(effect)
		var row := HBoxContainer.new()
		var price := Label.new()
		price.text = tr("ui.upgrade.price").format({"credits": definition.price})
		price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(price)
		var button := Button.new()
		button.text = tr("ui.upgrade.status." + offer["status"])
		button.disabled = offer["status"] != "available"
		var upgrade_id: String = definition.id
		button.pressed.connect(func() -> void: _on_buy_pressed(button, upgrade_id))
		row.add_child(button)
		card.add_child(row)
		_offers.add_child(card)
		if first_button == null:
			first_button = button
	if first_button != null and not first_button.disabled:
		first_button.grab_focus()
	else:
		_close_button.grab_focus()


func _on_buy_pressed(button: Button, upgrade_id: String) -> void:
	if button.disabled or _station == null:
		return
	button.disabled = true
	action_result.emit(_station.buy(upgrade_id))
	_rebuild()
