extends CharacterBody3D
## Scrappy's movement and behaviour (P2, scrappy-companion.md sections 14, 18, 19).
##
## States: dormant (not yet repaired, hidden) · follow · wait · explore.
## Scrappy never picks anything up and never triggers actions; he only moves,
## looks and talks. He has no collision layer, so he can never block the player.

signal state_changed(state: State)
## Arrived at an object he wanted to look at.
signal explored(target: Node3D)

enum State { DORMANT, FOLLOW, WAIT, EXPLORE }

## Preferred distance behind the player.
@export var follow_distance: float = 2.0
## Inside this distance Scrappy stops.
@export var stop_distance: float = 1.5
@export var move_speed: float = 3.4
@export var catch_up_speed: float = 6.0
@export var acceleration: float = 10.0
@export var turn_speed: float = 7.0
## Seconds the player has to stand still before Scrappy wanders off to look.
@export var explore_after_idle: float = 12.0
@export var explore_radius: float = 7.0
@export var explore_look_seconds: float = 2.6
## Beyond this distance Scrappy reappears behind the player.
@export var teleport_distance: float = 18.0

@onready var _visual_root: Node3D = $VisualRoot

var _state: State = State.DORMANT
var _follow_enabled: bool = true
var _player: CharacterBody3D
var _candidates: Callable
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _idle_timer: float = 0.0
var _explore_target: Node3D
var _explore_timer: float = 0.0
var _stuck_timer: float = 0.0
var _rng := RandomNumberGenerator.new()


## `candidates` returns an Array of Node3D that may be looked at (never touched).
func setup(player: CharacterBody3D, candidates: Callable) -> void:
	_player = player
	_candidates = candidates


func get_state() -> State:
	return _state


func is_active() -> bool:
	return _state != State.DORMANT


func is_following() -> bool:
	return _follow_enabled


## Wakes Scrappy at a position (after the repair or when loading).
func activate(at: Vector3, facing: float = 0.0) -> void:
	visible = true
	global_position = at
	_visual_root.rotation.y = facing
	reset_physics_interpolation()
	_set_state(State.FOLLOW if _follow_enabled else State.WAIT)


func set_dormant() -> void:
	visible = false
	_set_state(State.DORMANT)


## Toggles between following and waiting; returns the new follow setting.
func toggle_follow() -> bool:
	_follow_enabled = not _follow_enabled
	if is_active():
		_set_state(State.FOLLOW if _follow_enabled else State.WAIT)
	return _follow_enabled


func get_save_state() -> Dictionary:
	var data: Dictionary = {"state": "active" if is_active() else "dormant", "follow": _follow_enabled}
	if is_active():
		data["position"] = [snappedf(global_position.x, 0.001), snappedf(global_position.y, 0.001),
			snappedf(global_position.z, 0.001)]
	return data


func apply_save_state(data: Dictionary) -> void:
	_follow_enabled = bool(data.get("follow", true))
	if data.get("state", "dormant") == "active":
		var saved: Variant = data.get("position")
		var at: Vector3 = _player.global_position - _player.get_facing_direction() * follow_distance
		if typeof(saved) == TYPE_ARRAY and saved.size() == 3:
			at = Vector3(saved[0], saved[1], saved[2])
		activate(at)
	else:
		set_dormant()


func _ready() -> void:
	_rng.seed = 2026
	visible = false


func _physics_process(delta: float) -> void:
	if _state == State.DORMANT or _player == null:
		return
	var to_player: Vector3 = _player.global_position - global_position
	to_player.y = 0.0
	var distance: float = to_player.length()
	if _state != State.WAIT and distance > teleport_distance:
		_reappear_behind_player()
		return
	var target_velocity := Vector3.ZERO
	match _state:
		State.FOLLOW:
			target_velocity = _follow_velocity(to_player, distance)
			_update_idle(delta)
		State.EXPLORE:
			target_velocity = _explore_velocity(delta, distance)
	var horizontal := Vector3(velocity.x, 0, velocity.z).move_toward(target_velocity, acceleration * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravity * delta
	move_and_slide()
	_face(delta, horizontal, to_player)
	_check_stuck(delta, target_velocity, distance)


func _follow_velocity(to_player: Vector3, distance: float) -> Vector3:
	if distance <= stop_distance:
		return Vector3.ZERO
	# Aim slightly behind and beside the player so Scrappy trails, not overtakes.
	var behind: Vector3 = _player.global_position - _player.get_facing_direction() * follow_distance
	behind += _player.get_facing_direction().cross(Vector3.UP) * 0.6
	var to_spot: Vector3 = behind - global_position
	to_spot.y = 0.0
	if distance < follow_distance + 0.3 and to_spot.length() < 0.4:
		return Vector3.ZERO
	var speed: float = catch_up_speed if distance > follow_distance * 3.0 else move_speed
	return to_spot.normalized() * minf(speed, to_spot.length() * 3.0)


func _update_idle(delta: float) -> void:
	var player_speed: float = Vector2(_player.velocity.x, _player.velocity.z).length()
	_idle_timer = _idle_timer + delta if player_speed < 0.1 else 0.0
	if _idle_timer >= explore_after_idle:
		_idle_timer = 0.0
		_start_explore()


func _start_explore() -> void:
	if not _candidates.is_valid():
		return
	var best: Node3D
	var best_distance: float = explore_radius
	for candidate: Node3D in _candidates.call():
		var distance: float = candidate.global_position.distance_to(global_position)
		var to_player: float = candidate.global_position.distance_to(_player.global_position)
		if distance < best_distance and to_player > 1.5 and candidate != _explore_target:
			best = candidate
			best_distance = distance
	if best != null:
		_explore_target = best
		_explore_timer = 0.0
		_set_state(State.EXPLORE)


func _explore_velocity(delta: float, player_distance: float) -> Vector3:
	if not is_instance_valid(_explore_target) or not _explore_target.is_visible_in_tree() or player_distance > 7.0:
		_set_state(State.FOLLOW)
		return Vector3.ZERO
	var to_target: Vector3 = _explore_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > 0.9:
		return to_target.normalized() * move_speed * 0.8
	_explore_timer += delta
	if _explore_timer >= explore_look_seconds:
		explored.emit(_explore_target)
		_set_state(State.FOLLOW)
	return Vector3.ZERO


## Explore target while looking at it (for the animator's head tilt).
func get_look_target() -> Node3D:
	if _state == State.EXPLORE and is_instance_valid(_explore_target):
		var to_target: Vector3 = _explore_target.global_position - global_position
		to_target.y = 0.0
		if to_target.length() <= 1.0:
			return _explore_target
	return null


func _face(delta: float, horizontal: Vector3, to_player: Vector3) -> void:
	var direction: Vector3 = horizontal
	if direction.length() < 0.2:
		var look: Node3D = get_look_target()
		direction = (look.global_position - global_position) if look != null else to_player
		direction.y = 0.0
		if direction.length() < 0.01:
			return
	var target_yaw: float = atan2(direction.x, direction.z)
	_visual_root.rotation.y = rotate_toward(_visual_root.rotation.y, target_yaw, turn_speed * delta)


func _check_stuck(delta: float, target_velocity: Vector3, distance: float) -> void:
	var moving: float = Vector2(velocity.x, velocity.z).length()
	if target_velocity.length() > 0.5 and moving < 0.15 and distance > 4.0:
		_stuck_timer += delta
		if _stuck_timer > 2.0:
			_reappear_behind_player()
	else:
		_stuck_timer = 0.0


func _reappear_behind_player() -> void:
	_stuck_timer = 0.0
	var spot: Vector3 = _player.global_position - _player.get_facing_direction() * follow_distance
	global_position = Vector3(spot.x, _player.global_position.y, spot.z)
	velocity = Vector3.ZERO
	reset_physics_interpolation()
	if _state == State.EXPLORE:
		_set_state(State.FOLLOW)


func _set_state(state: State) -> void:
	if _state == state:
		return
	_state = state
	state_changed.emit(state)
