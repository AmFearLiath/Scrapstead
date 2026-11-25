extends Node3D
## Fixed isometric gameplay camera rig (docs/p0-gameplay-camera-controller.md).
##
## Follows an explicitly assigned anchor with frame-rate independent smoothing
## and offers a bounded, continuous mouse wheel zoom that only changes the
## orthographic size. No free rotation, no obstacle avoidance.

## Yaw of the view in degrees. -45° looks towards the north-east of the plot
## (north = -Z), so the yard extends away from the south entrance.
@export var yaw_degrees: float = -45.0
## Pitch in degrees (negative = looking down).
@export var pitch_degrees: float = -35.0
## Distance of the camera from the focus point along the view axis.
@export var distance: float = 40.0
## Exponential follow smoothing rate.
@export var follow_smoothing: float = 8.0
@export var zoom_default: float = 14.0
@export var zoom_min: float = 9.0
@export var zoom_max: float = 19.0
@export var zoom_step: float = 1.0
@export var zoom_smoothing: float = 10.0

@onready var _camera: Camera3D = $Camera3D
@onready var _camera_target: Node3D = $CameraTarget

var _follow_target: Node3D
var _target_zoom: float
var _warned_missing_target: bool = false


func _ready() -> void:
	_target_zoom = clampf(zoom_default, zoom_min, zoom_max)
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = _target_zoom
	var view_basis := Basis.from_euler(Vector3(deg_to_rad(pitch_degrees), deg_to_rad(yaw_degrees), 0.0))
	_camera.transform = Transform3D(view_basis, view_basis.z * distance)
	_camera.near = 0.5
	_camera.far = distance * 2.5


## Assigns the follow anchor and snaps to it immediately, so no visible pan from
## the world origin happens on scene start.
func set_follow_target(target: Node3D) -> void:
	_follow_target = target
	if is_instance_valid(target):
		global_position = target.global_position
		_camera_target.global_position = target.global_position
		reset_physics_interpolation()
		_camera.reset_physics_interpolation()


## The active gameplay camera, used by the PlayerController as movement basis.
func get_camera() -> Camera3D:
	return _camera


## Makes this camera the current one of the viewport.
func activate() -> void:
	_camera.make_current()


## Read-only diagnostics for the debug overlay.
func get_debug_data() -> Dictionary:
	var has_target: bool = is_instance_valid(_follow_target)
	return {
		"has_target": has_target,
		"rig_position": global_position,
		"follow_distance": global_position.distance_to(_follow_target.global_position) if has_target else -1.0,
		"zoom": _camera.size,
		"target_zoom": _target_zoom,
	}


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		_target_zoom = clampf(_target_zoom - zoom_step, zoom_min, zoom_max)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera_zoom_out"):
		_target_zoom = clampf(_target_zoom + zoom_step, zoom_min, zoom_max)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Losing focus must not leave a pending zoom animation behind.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(_camera):
		_target_zoom = _camera.size


func _process(delta: float) -> void:
	if absf(_camera.size - _target_zoom) > 0.001:
		_camera.size = lerpf(_camera.size, _target_zoom, 1.0 - exp(-zoom_smoothing * delta))


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_follow_target):
		if _follow_target != null or not _warned_missing_target:
			_follow_target = null
			if OS.is_debug_build() and not _warned_missing_target:
				push_warning("GameplayCamera: no follow target assigned.")
			_warned_missing_target = true
		return
	_camera_target.global_position = _follow_target.global_position
	var target_position: Vector3 = _camera_target.global_position
	if global_position.distance_squared_to(target_position) < 0.000001:
		return
	global_position = global_position.lerp(target_position, 1.0 - exp(-follow_smoothing * delta))
