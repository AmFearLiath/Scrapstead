extends Control
## Build mode UI (docs/building-system.md, section 3.3): a slim tool bar at
## the left edge, a small info strip at the top that always says what a click
## will do (or why not), and the build catalog as a centred window with
## categories, picture cards and a detail pane. Pure presentation; BuildMode
## and PlacedObjects do the work.

signal done_requested

const CATEGORY_KEYS: Dictionary = {"machines": "build.category.machines", "storage": "build.category.storage",
	"paths": "build.category.paths", "decor": "build.category.decor"}
const TOOLS: Array = [["catalog", "build.tool.build", "build_catalog"], ["move", "build.tool.move", "build_tool_move"],
	["remove", "build.tool.remove", "build_tool_remove"], ["connect", "build.tool.connect", "build_tool_connect"],
	["look", "build.tool.look", "build_tool_look"]]
const INK_BAD := Color(1.0, 0.55, 0.45)
const INK := Color(0.949, 0.902, 0.812)
const GOLD := Color(0.878, 0.663, 0.231)
const THUMB_PATH := "res://assets/ui/thumbs/%s.png"

var _mode: BuildMode
var _placed: PlacedObjects
var _category: String = PlaceableDefinition.CATEGORY_DECOR
var _focus: PlaceableDefinition
## The catalog opens by itself only the first time build mode is entered.
var _opened_once: bool = false
# Tool bar
var _toolbar: PanelContainer
var _tool_buttons: Dictionary = {}
var _undo_button: Button
var _redo_button: Button
var _done_button: Button
# Info strip
var _strip: PanelContainer
var _info: Label
var _hint: Label
var _controls: Label
# Catalog window
var _catalog: Control
var _category_buttons: Dictionary = {}
var _grid: GridContainer
var _detail_image: TextureRect
var _detail_name: Label
var _detail_text: Label
var _detail_facts: Label
var _detail_status: Label
var _place_button: Button
var _catalog_title: Label
var _close_button: Button


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_toolbar()
	_build_strip()
	_build_catalog()
	_retranslate()


func setup(mode: BuildMode, placed: PlacedObjects) -> void:
	_mode = mode
	_placed = placed
	_mode.preview_changed.connect(_refresh_info)
	_mode.mode_changed.connect(func(active: bool) -> void:
		visible = active
		if active:
			_rebuild_cards()
			_refresh_info()
			if _mode.get_selected() == null and not _opened_once:
				_opened_once = true
				open_catalog()
		else:
			close_catalog())
	_placed.changed.connect(func() -> void:
		if visible:
			_rebuild_cards()
			_refresh_detail())


## Wallet changed: prices may have become affordable.
func refresh() -> void:
	if visible:
		_rebuild_cards()
		_refresh_detail()
		_refresh_info()


func open_catalog() -> void:
	_catalog.show()
	_rebuild_cards()
	if _focus == null or _focus.category != _category:
		var first: Array[PlaceableDefinition] = _placed.catalog.in_category(_category)
		_focus = first[0] if not first.is_empty() else null
	_refresh_detail()
	_refresh_info()


func close_catalog() -> void:
	if _catalog.visible:
		_catalog.hide()
		_refresh_info()


func is_catalog_open() -> bool:
	return _catalog.visible


func get_category() -> String:
	return _category


func set_category(category: String) -> void:
	_category = category
	var first: Array[PlaceableDefinition] = _placed.catalog.in_category(category) if _placed != null \
		else [] as Array[PlaceableDefinition]
	_focus = first[0] if not first.is_empty() else null
	_rebuild_cards()
	_refresh_detail()


## Card buttons of the current category (tests).
func get_cards() -> Array[Button]:
	var cards: Array[Button] = []
	for child: Node in _grid.get_children():
		cards.append(child as Button)
	return cards


func get_place_button() -> Button:
	return _place_button


func get_focus() -> PlaceableDefinition:
	return _focus


func get_info_text() -> String:
	return _info.text


## The key line (shown in the info strip).
func set_controls_text(text: String) -> void:
	_controls.text = text


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _info != null:
		_retranslate()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _mode == null:
		return
	if event.is_action_pressed("build_catalog"):
		get_viewport().set_input_as_handled()
		if is_catalog_open():
			close_catalog()
		else:
			open_catalog()
	elif event.is_action_pressed("build_tool_move"):
		get_viewport().set_input_as_handled()
		_use_tool("move")
	elif event.is_action_pressed("build_tool_remove"):
		get_viewport().set_input_as_handled()
		_use_tool("remove")
	elif event.is_action_pressed("build_tool_look"):
		get_viewport().set_input_as_handled()
		_use_tool("look")
	elif event.is_action_pressed("build_tool_connect"):
		get_viewport().set_input_as_handled()
		_use_tool("connect")


# --- Layout ---------------------------------------------------------------------

func _build_toolbar() -> void:
	_toolbar = PanelContainer.new()
	_toolbar.name = "Toolbar"
	_toolbar.anchor_top = 0.5
	_toolbar.anchor_bottom = 0.5
	_toolbar.offset_left = 16
	_toolbar.offset_right = 196
	_toolbar.offset_top = -215
	_toolbar.offset_bottom = 215
	_toolbar.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_toolbar)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	_toolbar.add_child(column)
	for tool: Array in TOOLS:
		var button := _small_button(tool[0])
		button.toggle_mode = true
		var tool_id: String = tool[0]
		button.pressed.connect(func() -> void: _use_tool(tool_id))
		_tool_buttons[tool_id] = button
		column.add_child(button)
	column.add_child(HSeparator.new())
	_undo_button = _small_button("Undo")
	_undo_button.pressed.connect(func() -> void: _mode.action_result.emit(_mode.undo()))
	column.add_child(_undo_button)
	_redo_button = _small_button("Redo")
	_redo_button.pressed.connect(func() -> void: _mode.action_result.emit(_mode.redo()))
	column.add_child(_redo_button)
	column.add_child(HSeparator.new())
	_done_button = _small_button("DoneButton")
	_done_button.pressed.connect(func() -> void: done_requested.emit())
	column.add_child(_done_button)


func _build_strip() -> void:
	_strip = PanelContainer.new()
	_strip.name = "InfoStrip"
	_strip.anchor_left = 0.5
	_strip.anchor_right = 0.5
	_strip.anchor_top = 1.0
	_strip.anchor_bottom = 1.0
	_strip.offset_left = -420
	_strip.offset_right = 420
	_strip.offset_top = -104
	_strip.offset_bottom = -14
	_strip.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_strip)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 2)
	_strip.add_child(rows)
	_info = _label("Info", 18, INK)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(_info)
	_hint = _label("Hint", 15, GOLD)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(_hint)
	_controls = _label("Controls", 13, Color(INK, 0.6))
	_controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(_controls)


func _build_catalog() -> void:
	_catalog = Control.new()
	_catalog.name = "Catalog"
	_catalog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_catalog.mouse_filter = Control.MOUSE_FILTER_STOP
	_catalog.hide()
	add_child(_catalog)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.1, 0.07, 0.05, 0.35)
	dim.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.is_pressed():
			close_catalog())
	_catalog.add_child(dim)
	var window := PanelContainer.new()
	window.name = "Window"
	window.set_anchors_preset(Control.PRESET_CENTER)
	window.offset_left = -470
	window.offset_right = 470
	window.offset_top = -290
	window.offset_bottom = 290
	_catalog.add_child(window)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	window.add_child(rows)
	var header := HBoxContainer.new()
	rows.add_child(header)
	_catalog_title = _label("Title", 26, GOLD)
	_catalog_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_catalog_title)
	_close_button = _small_button("CloseButton")
	_close_button.pressed.connect(close_catalog)
	header.add_child(_close_button)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	rows.add_child(body)
	var categories := VBoxContainer.new()
	categories.custom_minimum_size = Vector2(170, 0)
	categories.add_theme_constant_override("separation", 6)
	body.add_child(categories)
	for category: String in PlaceableDefinition.CATEGORIES:
		var button := _small_button(category)
		button.toggle_mode = true
		button.pressed.connect(func() -> void: set_category(category))
		_category_buttons[category] = button
		categories.add_child(button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)
	var detail := VBoxContainer.new()
	detail.custom_minimum_size = Vector2(250, 0)
	detail.add_theme_constant_override("separation", 6)
	body.add_child(detail)
	_detail_image = TextureRect.new()
	_detail_image.custom_minimum_size = Vector2(250, 208)
	_detail_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail.add_child(_detail_image)
	_detail_name = _label("DetailName", 21, GOLD)
	detail.add_child(_detail_name)
	_detail_text = _label("DetailText", 15, INK)
	detail.add_child(_detail_text)
	_detail_facts = _label("DetailFacts", 15, Color(INK, 0.75))
	detail.add_child(_detail_facts)
	_detail_status = _label("DetailStatus", 15, INK_BAD)
	detail.add_child(_detail_status)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(spacer)
	_place_button = _small_button("PlaceButton")
	_place_button.custom_minimum_size = Vector2(0, 44)
	_place_button.pressed.connect(_on_place_pressed)
	detail.add_child(_place_button)


func _retranslate() -> void:
	for tool: Array in TOOLS:
		(_tool_buttons[tool[0]] as Button).text = "%s  [%s]" % [tr(tool[1]), InputHints.key_name(StringName(tool[2]))]
	_undo_button.text = tr("build.undo")
	_redo_button.text = tr("build.redo")
	_done_button.text = tr("build.done")
	_catalog_title.text = tr("build.catalog.title")
	_close_button.text = tr("ui.panel.close")
	for category: String in _category_buttons:
		(_category_buttons[category] as Button).text = tr(CATEGORY_KEYS[category])
	if _mode != null and visible:
		_rebuild_cards()
		_refresh_detail()
		_refresh_info()


func _rebuild_cards() -> void:
	if _placed == null:
		return
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for definition: PlaceableDefinition in _placed.catalog.in_category(_category):
		var status: String = _placed.get_offer_status(definition)
		var card := Button.new()
		card.name = definition.id
		card.toggle_mode = true
		card.focus_mode = Control.FOCUS_NONE
		card.custom_minimum_size = Vector2(150, 168)
		card.icon = _thumbnail(definition)
		card.expand_icon = true
		card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		card.add_theme_font_size_override("font_size", 14)
		card.text = "%s\n%s" % [tr(definition.name_key), _status_line(definition, status)]
		card.tooltip_text = tr(definition.description_key)
		card.modulate = Color(1, 1, 1, 0.55) if status in ["locked", "limit", "too_expensive"] else Color.WHITE
		card.button_pressed = _focus == definition
		card.pressed.connect(func() -> void: _on_card_pressed(definition))
		card.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and (event as InputEventMouseButton).double_click:
				_focus = definition
				_on_place_pressed())
		_grid.add_child(card)
	for category: String in _category_buttons:
		(_category_buttons[category] as Button).button_pressed = category == _category


func _refresh_detail() -> void:
	if _focus == null or _placed == null:
		_detail_name.text = ""
		_detail_text.text = ""
		_detail_facts.text = ""
		_detail_status.text = ""
		_detail_image.texture = null
		_place_button.disabled = true
		return
	var status: String = _placed.get_offer_status(_focus)
	var size_m: Vector2 = Vector2(_focus.size) * BuildGrid.CELL
	_detail_image.texture = _thumbnail(_focus)
	_detail_name.text = tr(_focus.name_key)
	_detail_text.text = tr(_focus.description_key)
	var facts: PackedStringArray = [tr("build.card.size").format({"w": _format_m(size_m.x), "d": _format_m(size_m.y)})]
	facts.append(_status_line(_focus, status))
	if _focus.work_radius > 0.0:
		facts.append(tr("build.detail.radius").format({"r": NumberFormat.decimal(_focus.work_radius, 1)}))
	if not _focus.solid:
		facts.append(tr("build.detail.walkable"))
	_detail_facts.text = "\n".join(facts)
	_detail_status.text = tr("build.status." + status) if status in ["locked", "limit", "too_expensive"] else ""
	_place_button.disabled = status in ["locked", "limit", "too_expensive"]
	_place_button.text = tr("build.detail.place_stock" if status == "available" else "build.detail.place_buy").format({
		"price": _placed.get_price(_focus)})
	for card: Button in get_cards():
		card.button_pressed = card.name == _focus.id


func _refresh_info() -> void:
	if _mode == null:
		return
	var tool: String = "catalog" if _mode.get_tool() == BuildMode.TOOL_BUILD else _mode.get_tool()
	for tool_id: String in _tool_buttons:
		(_tool_buttons[tool_id] as Button).button_pressed = tool_id == tool
	_undo_button.disabled = not _mode.can_undo()
	_redo_button.disabled = not _mode.can_redo()
	var check: Dictionary = _mode.get_last_check()
	var text: String = ""
	var ok: bool = true
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
			var link: Dictionary = _placed.links.get_link(_mode.get_hover_link())
			if not link.is_empty():
				text = tr("build.info.remove_link").format({"from": _uid_name(link["from"]), "to": _uid_name(link["to"])})
			else:
				text = tr("build.info.remove").format({"name": hover_name}) if not hover_name.is_empty() \
					else tr("build.info.choose_remove")
		"connect":
			var from_uid: String = _mode.get_link_from()
			if from_uid.is_empty():
				text = tr("build.info.connect_pick")
			elif check.is_empty():
				text = tr("build.info.connect_target").format({"name": _uid_name(from_uid)})
			elif not check.get("ok", false):
				ok = false
				text = PlacementValidator.describe({"problems": check.get("problems", [])})
			else:
				text = tr("build.info.connect_ok").format({"from": _uid_name(from_uid), "to": hover_name,
					"cells": _format_m((check.get("cells", []) as Array).size() * BuildGrid.CELL)})
		"look":
			if not hover_name.is_empty():
				var entry: Dictionary = _hover_entry()
				text = "%s — %s" % [hover_name, tr((entry["def"] as PlaceableDefinition).description_key)]
			else:
				text = tr("build.info.look")
	var hints: PackedStringArray = check.get("hints", PackedStringArray())
	_info.text = text
	_info.add_theme_color_override("font_color", INK if ok else INK_BAD)
	_hint.text = tr(hints[0]) if not hints.is_empty() else ""
	_hint.visible = not _hint.text.is_empty()


# --- Actions ---------------------------------------------------------------------

func _use_tool(tool: String) -> void:
	if tool == "catalog":
		open_catalog()
		return
	close_catalog()
	_mode.set_tool(tool)


func _on_card_pressed(definition: PlaceableDefinition) -> void:
	_focus = definition
	_refresh_detail()


func _on_place_pressed() -> void:
	if _focus == null or _place_button.disabled:
		return
	_mode.select(_focus)
	close_catalog()


# --- Helpers -----------------------------------------------------------------------

func _status_line(definition: PlaceableDefinition, status: String) -> String:
	return tr("build.card.status." + status).format({"price": _placed.get_price(definition),
		"count": _placed.get_available(definition)})


func _thumbnail(definition: PlaceableDefinition) -> Texture2D:
	var path: String = THUMB_PATH % definition.id
	return load(path) if ResourceLoader.exists(path) else null


func _hover_entry() -> Dictionary:
	for entry: Dictionary in _placed.get_entries():
		if entry["uid"] == _mode.get_hover_uid():
			return entry
	return {}


func _uid_name(uid: String) -> String:
	var node: Node3D = _placed.get_node_for(uid)
	for entry: Dictionary in _placed.get_entries():
		if entry["node"] == node:
			return tr((entry["def"] as PlaceableDefinition).name_key)
	return uid


func _hover_name() -> String:
	var entry: Dictionary = _hover_entry()
	return tr((entry["def"] as PlaceableDefinition).name_key) if not entry.is_empty() else ""


func _small_button(node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16)
	return button


func _label(node_name: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func _format_m(value: float) -> String:
	return NumberFormat.decimal(value, 1) if fmod(value, 1.0) > 0.01 else str(int(value))
