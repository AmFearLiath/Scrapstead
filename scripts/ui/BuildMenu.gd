extends Control
## Build menu (docs/building-system.md, section 3.3): tool bar, categories,
## object cards with price, size and stock, and one info line that always
## says what a click will do - or why it will not work. Pure presentation;
## BuildMode and PlacedObjects do the work.

signal done_requested

const CATEGORY_KEYS: Dictionary = {"machines": "build.category.machines", "storage": "build.category.storage",
	"paths": "build.category.paths", "decor": "build.category.decor"}
const TOOL_KEYS: Dictionary = {"build": "build.tool.build", "move": "build.tool.move", "remove": "build.tool.remove",
	"look": "build.tool.look"}
const INK_OK := Color(0.75, 0.95, 0.6)
const INK_BAD := Color(1.0, 0.55, 0.45)
const INK := Color(0.949, 0.902, 0.812)

var _mode: BuildMode
var _placed: PlacedObjects
var _category: String = PlaceableDefinition.CATEGORY_DECOR
var _info: Label
var _hint: Label
var _controls: Label
var _tool_buttons: Dictionary = {}
var _category_buttons: Dictionary = {}
var _undo_button: Button
var _redo_button: Button
var _cards: HBoxContainer
var _panel: PanelContainer


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func setup(mode: BuildMode, placed: PlacedObjects) -> void:
	_mode = mode
	_placed = placed
	_mode.preview_changed.connect(_refresh_info)
	_mode.mode_changed.connect(func(active: bool) -> void:
		visible = active
		if active:
			_rebuild_cards()
			_refresh_info())
	_placed.changed.connect(func() -> void:
		if visible:
			_rebuild_cards())


## Wallet changed: prices may have become affordable.
func refresh() -> void:
	if visible:
		_rebuild_cards()
		_refresh_info()


func get_category() -> String:
	return _category


func set_category(category: String) -> void:
	_category = category
	for key: String in _category_buttons:
		(_category_buttons[key] as Button).button_pressed = key == category
	_rebuild_cards()


## Card buttons of the current category (tests).
func get_cards() -> Array[Button]:
	var cards: Array[Button] = []
	for child: Node in _cards.get_children():
		cards.append(child as Button)
	return cards


func get_info_text() -> String:
	return _info.text


## The key line (shown inside the menu so nothing hides it).
func set_controls_text(text: String) -> void:
	_controls.text = text


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _info != null:
		_retranslate()


# --- Layout -----------------------------------------------------------------------

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -560
	_panel.offset_right = 560
	_panel.offset_top = -282
	_panel.offset_bottom = -12
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	_panel.add_child(rows)
	_controls = Label.new()
	_controls.name = "Controls"
	_controls.add_theme_font_size_override("font_size", 14)
	_controls.add_theme_color_override("font_color", Color(0.949, 0.902, 0.812, 0.65))
	_controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_controls)
	_info = Label.new()
	_info.name = "Info"
	_info.add_theme_font_size_override("font_size", 19)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_info)
	_hint = Label.new()
	_hint.name = "Hint"
	_hint.add_theme_font_size_override("font_size", 15)
	_hint.add_theme_color_override("font_color", Color(0.88, 0.66, 0.23))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_hint)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 8)
	rows.add_child(tools)
	for tool: String in TOOL_KEYS:
		var button := Button.new()
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(120, 0)
		button.pressed.connect(func() -> void: _mode.set_tool(tool))
		_tool_buttons[tool] = button
		tools.add_child(button)
	tools.add_child(VSeparator.new())
	_undo_button = Button.new()
	_undo_button.focus_mode = Control.FOCUS_NONE
	_undo_button.pressed.connect(func() -> void: _mode.action_result.emit(_mode.undo()))
	tools.add_child(_undo_button)
	_redo_button = Button.new()
	_redo_button.focus_mode = Control.FOCUS_NONE
	_redo_button.pressed.connect(func() -> void: _mode.action_result.emit(_mode.redo()))
	tools.add_child(_redo_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools.add_child(spacer)
	var done := Button.new()
	done.name = "DoneButton"
	done.focus_mode = Control.FOCUS_NONE
	done.custom_minimum_size = Vector2(130, 0)
	done.pressed.connect(func() -> void: done_requested.emit())
	tools.add_child(done)
	var categories := HBoxContainer.new()
	categories.add_theme_constant_override("separation", 6)
	rows.add_child(categories)
	for category: String in PlaceableDefinition.CATEGORIES:
		var button := Button.new()
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: set_category(category))
		_category_buttons[category] = button
		categories.add_child(button)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 86)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rows.add_child(scroll)
	_cards = HBoxContainer.new()
	_cards.add_theme_constant_override("separation", 8)
	scroll.add_child(_cards)
	_retranslate()


func _retranslate() -> void:
	for tool: String in _tool_buttons:
		(_tool_buttons[tool] as Button).text = tr(TOOL_KEYS[tool])
	for category: String in _category_buttons:
		(_category_buttons[category] as Button).text = tr(CATEGORY_KEYS[category])
	_undo_button.text = tr("build.undo")
	_redo_button.text = tr("build.redo")
	(_panel.find_child("DoneButton", true, false) as Button).text = tr("build.done")
	if _mode != null and visible:
		_rebuild_cards()
		_refresh_info()


func _rebuild_cards() -> void:
	if _placed == null:
		return
	for child: Node in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	for definition: PlaceableDefinition in _placed.catalog.in_category(_category):
		var status: String = _placed.get_offer_status(definition)
		var card := Button.new()
		card.name = definition.id
		card.toggle_mode = true
		card.focus_mode = Control.FOCUS_NONE
		card.custom_minimum_size = Vector2(212, 78)
		card.clip_text = true
		card.add_theme_font_size_override("font_size", 16)
		var size_m: Vector2 = Vector2(definition.size) * BuildGrid.CELL
		var line: String = tr("build.card.status." + status).format({
			"price": _placed.get_price(definition), "count": _placed.get_available(definition)})
		card.text = "%s\n%s · %s" % [tr(definition.name_key), line, tr("build.card.size").format({
			"w": _format_m(size_m.x), "d": _format_m(size_m.y)})]
		card.tooltip_text = tr(definition.description_key)
		card.disabled = status in ["locked", "limit", "too_expensive"]
		card.button_pressed = _mode != null and _mode.get_selected() == definition
		card.pressed.connect(func() -> void: _mode.select(definition))
		_cards.add_child(card)
	for category: String in _category_buttons:
		(_category_buttons[category] as Button).button_pressed = category == _category


func _refresh_info() -> void:
	if _mode == null:
		return
	for tool: String in _tool_buttons:
		(_tool_buttons[tool] as Button).button_pressed = _mode.get_tool() == tool
	_undo_button.disabled = not _mode.can_undo()
	_redo_button.disabled = not _mode.can_redo()
	for card: Button in get_cards():
		card.button_pressed = _mode.get_selected() != null and card.name == _mode.get_selected().id
	var check: Dictionary = _mode.get_last_check()
	var text: String = ""
	var ok: bool = true
	var hint: String = ""
	var hover_name: String = _hover_name()
	match _mode.get_tool():
		"build":
			var definition: PlaceableDefinition = _mode.get_selected()
			if definition == null:
				text = tr("build.info.pick")
			elif not check.get("ok", false):
				ok = false
				text = "%s: %s" % [tr(definition.name_key), PlacementValidator.describe({"problems": check.get("problems", [])})]
			else:
				var status: String = _placed.get_offer_status(definition)
				text = tr("build.info.place_stock" if status == "available" else "build.info.place_buy").format({
					"name": tr(definition.name_key), "price": _placed.get_price(definition)})
		"move":
			if not _mode.get_moving_uid().is_empty():
				ok = check.get("ok", false)
				text = tr("build.info.set_down") if ok else PlacementValidator.describe({"problems": check.get("problems", [])})
			else:
				text = tr("build.info.pick_up").format({"name": hover_name}) if not hover_name.is_empty() \
					else tr("build.info.choose_move")
		"remove":
			text = tr("build.info.remove").format({"name": hover_name}) if not hover_name.is_empty() \
				else tr("build.info.choose_remove")
		"look":
			if not hover_name.is_empty():
				var entry: Dictionary = _hover_entry()
				text = "%s — %s" % [hover_name, tr((entry["def"] as PlaceableDefinition).description_key)]
			else:
				text = tr("build.info.look")
	var hints: PackedStringArray = check.get("hints", PackedStringArray())
	if not hints.is_empty():
		hint = tr(hints[0])
	_info.text = text
	_info.add_theme_color_override("font_color", INK if ok else INK_BAD)
	_hint.text = hint
	_hint.visible = not hint.is_empty()


func _hover_entry() -> Dictionary:
	for entry: Dictionary in _placed.get_entries():
		if entry["uid"] == _mode.get_hover_uid():
			return entry
	return {}


func _hover_name() -> String:
	var entry: Dictionary = _hover_entry()
	return tr((entry["def"] as PlaceableDefinition).name_key) if not entry.is_empty() else ""


static func _format_m(value: float) -> String:
	return NumberFormat.decimal(value, 1) if fmod(value, 1.0) > 0.01 else str(int(value))
