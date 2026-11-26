extends Control
## Order catalog panel at the office desk: lists the wares with effect, price
## and status. Purchases are executed by OrderDesk; the panel reports results
## and refreshes itself.

## Emitted after a purchase attempt.
signal action_result(result: Dictionary)
signal closed

@onready var _offers: VBoxContainer = %Offers
@onready var _close_button: Button = %CloseButton

var _station: OrderDesk


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)


func open(station: OrderDesk) -> void:
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
	var first_available: Button
	for offer: Dictionary in _station.get_offers():
		var definition: UpgradeDefinition = offer["definition"]
		var card := HBoxContainer.new()
		card.add_theme_constant_override("separation", 16)
		var text_column := VBoxContainer.new()
		text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_column.add_theme_constant_override("separation", 2)
		var title := Label.new()
		title.text = tr(definition.name_key)
		title.add_theme_font_size_override("font_size", 22)
		title.add_theme_color_override("font_color", Color(0.878, 0.663, 0.231))
		text_column.add_child(title)
		var description := Label.new()
		description.text = tr(definition.description_key)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.custom_minimum_size = Vector2(430, 0)
		description.add_theme_font_size_override("font_size", 17)
		description.add_theme_color_override("font_color", Color(0.949, 0.902, 0.812, 0.8))
		text_column.add_child(description)
		var effect := Label.new()
		effect.text = _effect_text(offer)
		effect.add_theme_font_size_override("font_size", 17)
		text_column.add_child(effect)
		card.add_child(text_column)
		var buy_column := VBoxContainer.new()
		buy_column.alignment = BoxContainer.ALIGNMENT_CENTER
		var price := Label.new()
		price.text = tr("ui.credits_amount").format({"credits": definition.price})
		price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price.add_theme_font_size_override("font_size", 22)
		buy_column.add_child(price)
		var button := Button.new()
		button.custom_minimum_size = Vector2(170, 0)
		button.text = tr("ui.catalog.status." + offer["status"])
		button.disabled = offer["status"] != "available"
		var upgrade_id: String = definition.id
		button.pressed.connect(func() -> void: _on_buy_pressed(button, upgrade_id))
		buy_column.add_child(button)
		card.add_child(buy_column)
		_offers.add_child(card)
		_offers.add_child(HSeparator.new())
		if first_available == null and not button.disabled:
			first_available = button
	(first_available if first_available != null else _close_button).grab_focus()


func _effect_text(offer: Dictionary) -> String:
	var definition: UpgradeDefinition = offer["definition"]
	var lines: PackedStringArray = []
	if not definition.stat.is_empty():
		var key: String = "ui.catalog.effect."
		if offer["status"] == "owned":
			key = "ui.catalog.effect_owned."
		elif offer["status"] == "locked":
			key = "ui.catalog.effect_locked."
		lines.append(tr(key + definition.stat).format({"current": offer["current"], "after": offer["after"],
			"bonus": definition.bonus}))
	if not definition.grants_tool.is_empty():
		lines.append(tr("ui.catalog.effect.tool").format(
			{"tool": tr(UpgradeProgress.tool_name_key(definition.grants_tool))}))
	if not definition.effect_key.is_empty():
		lines.append(tr(definition.effect_key))
	elif definition.stat.is_empty() and definition.grants_tool.is_empty():
		lines.append(tr("ui.catalog.effect.decor"))
	if offer["status"] == "locked" and not definition.requires.is_empty():
		var requirement: UpgradeDefinition = _station.get_offers()[0]["definition"]
		for other: Dictionary in _station.get_offers():
			if other["definition"].id == definition.requires:
				requirement = other["definition"]
		lines.append(tr("ui.catalog.requires").format({"requirement": tr(requirement.name_key)}))
	return "  ·  ".join(lines)


func _on_buy_pressed(button: Button, upgrade_id: String) -> void:
	if button.disabled or _station == null:
		return
	button.disabled = true
	action_result.emit(_station.buy(upgrade_id))
	_rebuild()
