extends CharacterBody3D
## Player movement (docs/p0-player-controller.md).
##
## Reads the movement actions, moves camera-relative on the XZ plane with
## separate acceleration and braking, applies gravity and turns the visual model
## smoothly. Knows the gameplay camera only as a movement reference and handles
## no interaction, inventory or persistence logic.

## Maximum horizontal speed in m/s.
@export var move_speed: float = 4.5
## Acceleration towards the target speed in m/s².
@export var acceleration: float = 18.0
## Braking deceleration after releasing the input in m/s².
@export var deceleration: float = 22.0
## Turn speed of the visual model in rad/s.
@export var turn_speed: float = 10.0
## Spawn used when no valid saved position exists.
@export var fallback_spawn: Vector3 = Vector3(8.0, 0.1, -4.6)
## Saved positions outside this XZ rectangle (plot minus margin) are rejected.
## Rect2 uses (world x, world z); north is -Z.
@export var valid_area: Rect2 = Rect2(0.5, -35.5, 47.0, 35.0)

@onready var _visual_root: Node3D = $VisualRoot

var _movement_camera: Camera3D
var _input_enabled: bool = false
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _input_vector: Vector2 = Vector2.ZERO
var _move_direction: Vector3 = Vector3.ZERO
var _warned_missing_camera: bool = false


## Sets the camera whose horizontal orientation defines "up" on screen.
func set_movement_camera(camera: Camera3D) -> void:
	_movement_camera = camera


## Movement input is ignored until the scene has finished initializing.
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if not enabled:
		_input_vector = Vector2.ZERO


## Places the player, e.g. when restoring a save. Invalid positions fall back
## to the safe spawn. Returns false when the fallback was used.
func place(position_value: Vector3, facing: float) -> bool:
	var accepted: bool = valid_area.has_point(Vector2(position_value.x, position_value.z))
	global_position = position_value if accepted else fallback_spawn
	velocity = Vector3.ZERO
	_visual_root.rotation.y = facing
	reset_physics_interpolation()
	return accepted


## Horizontal facing of the visual model in radians (yaw, model forward = +Z).
func get_facing_yaw() -> float:
	return _visual_root.rotation.y


## Unit vector of the current facing on the XZ plane.
func get_facing_direction() -> Vector3:
	return Vector3(sin(get_facing_yaw()), 0.0, cos(get_facing_yaw()))


## Read-only diagnostics for the debug overlay.
func get_debug_data() -> Dictionary:
	return {
		"input": _input_vector,
		"direction": _move_direction,
		"horizontal_speed": Vector2(velocity.x, velocity.z).length(),
		"on_floor": is_on_floor(),
	}


func _physics_process(delta: float) -> void:
	_input_vector = Vector2.ZERO
	if _input_enabled:
		# get_vector clamps the length to 1, so diagonals are not faster.
		_input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_move_direction = _camera_relative_direction(_input_vector)
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var target: Vector3 = _move_direction * move_speed
	var rate: float = acceleration if _move_direction != Vector3.ZERO else deceleration
	horizontal = horizontal.move_toward(target, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= _gravity * delta
	move_and_slide()
	_update_visual_facing(delta)


func _camera_relative_direction(input: Vector2) -> Vector3:
	if input == Vector2.ZERO:
		return Vector3.ZERO
	var forward := Vector3.FORWARD
	var right := Vector3.RIGHT
	if is_instance_valid(_movement_camera):
		var basis: Basis = _movement_camera.global_basis
		forward = Vector3(-basis.z.x, 0.0, -basis.z.z)
		right = Vector3(basis.x.x, 0.0, basis.x.z)
	if forward.length_squared() < 0.0001 or right.length_squared() < 0.0001:
		forward = Vector3.FORWARD
		right = Vector3.RIGHT
		_warn_missing_camera()
	elif not is_instance_valid(_movement_camera):
		_warn_missing_camera()
	var direction: Vector3 = right.normalized() * input.x + forward.normalized() * -input.y
	return direction.limit_length(1.0)


func _update_visual_facing(delta: float) -> void:
	if _move_direction == Vector3.ZERO:
		return
	var target_yaw: float = atan2(_move_direction.x, _move_direction.z)
	_visual_root.rotation.y = rotate_toward(_visual_root.rotation.y, target_yaw, turn_speed * delta)


func _warn_missing_camera() -> void:
	if not _warned_missing_camera and OS.is_debug_build():
		push_warning("PlayerController: no usable camera reference, using world-axis fallback.")
	_warned_missing_camera = true
