extends Node
## Entry point of the project. Hands over to the main menu and contains no
## gameplay or menu logic (docs/p0-implementation-readiness.md, section 3.1).

const MENU_SCENE_PATH: String = "res://scenes/menu/MainMenu.tscn"


func _ready() -> void:
	# Deferred so the scene change does not happen while the tree is still
	# adding this node.
	_open_main_menu.call_deferred()


func _open_main_menu() -> void:
	var error: Error = get_tree().change_scene_to_file(MENU_SCENE_PATH)
	if error != OK:
		push_error("Main: main menu could not be loaded (%s)." % error_string(error))
