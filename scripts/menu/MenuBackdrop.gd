extends Node3D
## Presentation-only background of the main menu: a slow camera ride along a
## prepared path around the Old Yard blockout. It has no reference to the
## player or the gameplay camera (docs/p0-scene-architecture.md, section 5.2).

## World point the menu camera keeps looking at.
@export var focus_point: Vector3 = Vector3(22.0, 0.0, -17.0)

@onready var _menu_camera: Camera3D = $CameraPath/CameraPathFollow/MenuCamera


func _ready() -> void:
	_menu_camera.make_current()
	_aim_camera()


func _process(_delta: float) -> void:
	_aim_camera()


func _aim_camera() -> void:
	_menu_camera.look_at(focus_point, Vector3.UP)
