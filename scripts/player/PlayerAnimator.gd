extends Node
## Procedural, presentation-only animation of the player model (no skeleton):
## walk cycle, idle breathing, a little squash when stopping, a working pose
## while an action is held, a reach on pickups and a basket that visibly fills.
##
## Reads player velocity and interactor state; never changes gameplay values.
## The model's pivoted groups come from tools/blender/build_props.py.

## Emitted on every footfall (for dust puffs).
signal footstep(world_position: Vector3)

## Walk cycles per second at full speed.
@export var stride_frequency: float = 2.4
## Leg swing in radians at full speed.
@export var leg_swing: float = 0.6
## Arm swing in radians at full speed.
@export var arm_swing: float = 0.5
## Vertical bounce of the body per step in metres.
@export var bounce: float = 0.045

var _player: CharacterBody3D
var _interactor: Node
var _model: Node3D
var _leg_left: Node3D
var _leg_right: Node3D
var _torso: Node3D
var _head: Node3D
var _arm_left: Node3D
var _arm_right: Node3D
var _basket: Node3D
var _fill: Node3D
var _arm_left_rest: Vector3
var _arm_right_rest: Vector3
var _torso_rest_y: float
var _phase: float = 0.0
var _speed: float = 0.0
var _hold: float = 0.0
var _squash: float = 0.0
var _reach: float = 0.0
var _load: float = 0.0
var _target_load: float = 0.0
var _time: float = 0.0
var _basket_tween: Tween


## Connects the model parts. Returns false if the model lacks the rig groups.
func setup(player: CharacterBody3D, interactor: Node, model: Node3D) -> bool:
	_player = player
	_interactor = interactor
	_model = model
	_leg_left = model.get_node_or_null("LegL")
	_leg_right = model.get_node_or_null("LegR")
	_torso = model.get_node_or_null("Torso")
	if _torso == null or _leg_left == null or _leg_right == null:
		push_warning("PlayerAnimator: player model has no rig groups; animation disabled.")
		set_process(false)
		return false
	_head = _torso.get_node_or_null("Head")
	_arm_left = _torso.get_node_or_null("ArmL")
	_arm_right = _torso.get_node_or_null("ArmR")
	_basket = _torso.get_node_or_null("Basket")
	_fill = _basket.get_node_or_null("BasketFill") if _basket != null else null
	_arm_left_rest = _arm_left.rotation
	_arm_right_rest = _arm_right.rotation
	_torso_rest_y = _torso.position.y
	_apply_load()
	return true


## Fraction (0..1) of the carry capacity in use; the basket fill follows.
func set_load(ratio: float) -> void:
	_target_load = clampf(ratio, 0.0, 1.0)


## Short reach forward, used when something is picked up.
func play_pickup() -> void:
	_reach = 1.0


## Small bounce of the basket when an item lands in it.
func bump_basket() -> void:
	if _basket == null:
		return
	if _basket_tween != null:
		_basket_tween.kill()
	_basket.scale = Vector3(1.15, 0.85, 1.15)
	_basket_tween = create_tween()
	_basket_tween.tween_property(_basket, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)


## World position items fly to when picked up.
func get_basket_position() -> Vector3:
	if _basket != null:
		return _basket.global_position + Vector3(0, 0.3, 0)
	return _player.global_position + Vector3(0, 1.2, 0)


func _process(delta: float) -> void:
	_time += delta
	var max_speed: float = maxf(_player.move_speed, 0.01)
	var speed: float = clampf(Vector2(_player.velocity.x, _player.velocity.z).length() / max_speed, 0.0, 1.0)
	var was_fast: bool = _speed > 0.6
	_speed = lerpf(_speed, speed, 1.0 - exp(-10.0 * delta))
	if was_fast and speed < 0.05:
		_squash = 1.0
	if speed > 0.05:
		var previous: float = _phase
		_phase += delta * stride_frequency * TAU * maxf(speed, 0.4)
		if floorf(previous / PI) != floorf(_phase / PI):
			footstep.emit(_player.global_position)
	var holding: bool = _interactor != null and _interactor.has_method("is_holding") and _interactor.is_holding()
	_hold = lerpf(_hold, 1.0 if holding else 0.0, 1.0 - exp(-12.0 * delta))
	_squash = maxf(0.0, _squash - delta * 4.0)
	_reach = maxf(0.0, _reach - delta * 3.5)
	_load = lerpf(_load, _target_load, 1.0 - exp(-8.0 * delta))
	_animate()


func _animate() -> void:
	var swing: float = sin(_phase) * _speed
	_leg_left.rotation.x = swing * leg_swing
	_leg_right.rotation.x = -swing * leg_swing
	# Working pose: lean in and reach forward, with a little effort shake.
	var shake: float = sin(_time * 38.0) * 0.04 * _hold
	var reach: float = maxf(_hold, sin(_reach * PI))
	_arm_left.rotation = _arm_left_rest + Vector3(-swing * arm_swing - 1.1 * reach + shake, 0, 0)
	_arm_right.rotation = _arm_right_rest + Vector3(swing * arm_swing - 1.1 * reach - shake, 0, 0)
	_torso.rotation.x = 0.1 * _speed + 0.32 * _hold + 0.15 * sin(_reach * PI)
	_torso.rotation.z = sin(_phase) * 0.04 * _speed + shake * 0.5
	_torso.position.y = _torso_rest_y + absf(sin(_phase)) * bounce * _speed
	var breath: float = sin(_time * 2.2) * 0.012 * (1.0 - _speed)
	var squash: float = sin(_squash * PI) * _squash
	_torso.scale = Vector3(1.0 + 0.07 * squash, 1.0 + breath - 0.1 * squash, 1.0 + 0.07 * squash)
	if _head != null:
		_head.rotation.x = 0.25 * _hold - 0.05 * _speed + sin(_time * 1.3) * 0.02 * (1.0 - _speed)
	_apply_load()


func _apply_load() -> void:
	if _fill == null:
		return
	_fill.visible = _load > 0.02
	_fill.scale = Vector3(1.0, maxf(_load, 0.02), 1.0)
