extends Control
## Small pinned note with up to two suggestions ("Notizen") and the story key
## items ("Besonderes"). Shows what the StoryDirector suggests; it never
## demands anything.

@onready var _lines: VBoxContainer = %Lines
@onready var _title: Label = $Paper/Rows/Title
@onready var _key_items: Label = %KeyItems

var _current: PackedStringArray = []
var _key_names: PackedStringArray = []


func _ready() -> void:
	hide()


## Localized suggestion lines; an empty list hides that part of the note.
func set_notes(lines: PackedStringArray) -> void:
	if lines == _current:
		return
	_current = lines
	for child: Node in _lines.get_children():
		_lines.remove_child(child)
		child.queue_free()
	for line: String in lines:
		var label := Label.new()
		label.text = "• " + line
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(250, 0)
		label.add_theme_color_override("font_color", Color(0.17, 0.13, 0.106))
		label.add_theme_font_size_override("font_size", 16)
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		_lines.add_child(label)
	_title.visible = not lines.is_empty()
	_update_visibility(true)


## Localized names of the carried key items (outside the basket).
func set_key_items(names: PackedStringArray) -> void:
	if names == _key_names:
		return
	_key_names = names
	_key_items.visible = not names.is_empty()
	_key_items.text = tr("ui.notes.key_items").format({"items": ", ".join(names)})
	_update_visibility(true)


## Current suggestions (for tests and diagnostics).
func get_notes() -> PackedStringArray:
	return _current


func get_key_items() -> PackedStringArray:
	return _key_names


func _update_visibility(animate: bool) -> void:
	var was_visible: bool = visible
	visible = not _current.is_empty() or not _key_names.is_empty()
	# Shrink the paper back to its content after rows disappeared.
	$Paper.reset_size.call_deferred()
	if visible and animate and is_inside_tree():
		scale = Vector2(1.06, 1.06) if was_visible else Vector2(0.9, 0.9)
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
