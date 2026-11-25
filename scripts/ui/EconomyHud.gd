extends Control
## Always-visible compact HUD: credits (top left) and carry basket (top right).
## Pure presentation; updates through signals of Wallet and CarryInventory.

@onready var _credits_value: Label = %CreditsValue
@onready var _credits_delta: Label = %CreditsDelta
@onready var _carry_value: Label = %CarryValue
@onready var _carry_slots: HBoxContainer = %CarrySlots
@onready var _carry_list: VBoxContainer = %CarryList
@onready var _drop_hint: Label = %DropHint

var _wallet: Wallet
var _inventory: CarryInventory
var _displayed_credits: int = 0
var _delta_tween: Tween
var _count_tween: Tween


func _ready() -> void:
	_credits_delta.modulate.a = 0.0


## Connects the display sources.
func setup(wallet: Wallet, inventory: CarryInventory) -> void:
	_wallet = wallet
	_inventory = inventory
	_wallet.balance_changed.connect(_on_balance_changed)
	_inventory.changed.connect(_refresh_inventory)
	_drop_hint.text = tr("ui.hud.drop_hint").format({"key": InputHints.key_name(&"drop_item")})
	_displayed_credits = _wallet.get_balance()
	_credits_value.text = _format_credits(_displayed_credits)
	_refresh_inventory()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _inventory != null and is_node_ready():
		_refresh_inventory()


func _on_balance_changed(balance: int, delta: int, _reason_key: String) -> void:
	_credits_delta.text = ("+%d" % delta) if delta > 0 else str(delta)
	_credits_delta.add_theme_color_override("font_color",
		Color(0.7, 0.9, 0.5) if delta > 0 else Color(1.0, 0.62, 0.45))
	if _delta_tween != null:
		_delta_tween.kill()
	_credits_delta.modulate.a = 1.0
	_delta_tween = create_tween()
	_delta_tween.tween_interval(1.4)
	_delta_tween.tween_property(_credits_delta, "modulate:a", 0.0, 0.6)
	if _count_tween != null:
		_count_tween.kill()
	_count_tween = create_tween()
	_count_tween.tween_method(_set_displayed_credits, _displayed_credits, balance, 0.6)


func _set_displayed_credits(value: int) -> void:
	_displayed_credits = value
	_credits_value.text = _format_credits(value)


func _refresh_inventory() -> void:
	var used: int = _inventory.get_used_slots()
	var capacity: int = _inventory.get_capacity()
	_carry_value.text = tr("ui.hud.carry_value").format({"used": used, "capacity": capacity})
	for child: Node in _carry_slots.get_children():
		child.queue_free()
	for index: int in capacity:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(16, 16)
		pip.color = Color(0.878, 0.663, 0.231) if index < used else Color(0.949, 0.902, 0.812, 0.18)
		_carry_slots.add_child(pip)
	for child: Node in _carry_list.get_children():
		child.queue_free()
	for group: Dictionary in _inventory.get_grouped():
		var definition: ItemDefinition = group["definition"]
		var line := Label.new()
		line.add_theme_font_size_override("font_size", 17)
		line.text = tr("ui.hud.carry_line").format({"name": tr(definition.name_key), "count": group["count"],
			"value": definition.sell_value * int(group["count"])})
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_carry_list.add_child(line)
	_drop_hint.visible = not _inventory.is_empty()


func _format_credits(value: int) -> String:
	return tr("ui.hud.credits_value").format({"credits": _group_digits(value)})


## Locale-neutral digit grouping with a thin space.
func _group_digits(value: int) -> String:
	var text: String = str(absi(value))
	var grouped: String = ""
	while text.length() > 3:
		grouped = " " + text.substr(text.length() - 3) + grouped
		text = text.substr(0, text.length() - 3)
	return ("-" if value < 0 else "") + text + grouped
