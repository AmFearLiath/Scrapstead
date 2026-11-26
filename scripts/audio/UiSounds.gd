extends Node
## Click sound for every Button in this scene (menus, panels, catalog cards).
## Scene-local helper; buttons created later (dynamic panels) are hooked too.

@export var sound_fx: Node
@export var sound_name: String = "click"


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	for node: Node in get_parent().find_children("*", "BaseButton", true, false):
		_hook(node)


func _on_node_added(node: Node) -> void:
	if node is BaseButton and get_parent().is_ancestor_of(node):
		_hook(node)


func _hook(node: Node) -> void:
	var button := node as BaseButton
	if button != null and not button.pressed.is_connected(_on_pressed):
		button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if sound_fx != null:
		sound_fx.play(sound_name, 0.0, 0.08)
