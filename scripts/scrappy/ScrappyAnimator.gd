extends Node
## Procedural expression for Scrappy (scrappy-companion.md sections 14 and 25):
## blinking eye shutters, curious head tilt, antenna wobble, rolling wheels,
## a happy hop and a little wobble when starting or stopping. Visual only.

@export var blink_interval: Vector2 = Vector2(2.5, 6.0)

var _body: CharacterBody3D
var _model: Node3D
var _head: Node3D
var _antenna: Node3D
var _lids: Array[Node3D] = []
var _lid_rest: Array[Vector3] = []
var _wheels: Array[Node3D] = []
var _body_part: Node3D
var _time: float = 0.0
var _blink_timer: float = 2.0
var _blink: float = 0.0
var _antenna_swing: Vector2 = Vector2.ZERO
var _antenna_velocity: Vector2 = Vector2.ZERO
var _previous_speed: float = 0.0
var _hop: float = 0.0
var _talk: float = 0.0
var _rng := RandomNumberGenerator.new()


func setup(body: CharacterBody3D, model: Node3D) -> void:
	_body = body
	_model = model
	_head = model.get_node_or_null("Head")
	_antenna = _head.get_node_or_null("Antenna") if _head != null else null
	_body_part = model.get_node_or_null("Body")
	for side: String in ["EyeL", "EyeR"]:
		var lid: Node3D = _head.get_node_or_null("%s/Lid%s" % [side, side.right(1)]) if _head != null else null
		if lid != null:
			_lids.append(lid)
			_lid_rest.append(lid.position)
	var chassis: Node3D = model.get_node_or_null("Chassis")
	if chassis != null:
		for child: Node in chassis.get_children():
			if child.name.begins_with("Wheel"):
				_wheels.append(child)
	_rng.randomize()


## Small jump of joy (e.g. after the repair or a big sale).
func hop() -> void:
	_hop = 1.0


## Head bobs while a speech bubble is shown.
func set_talking(talking: bool) -> void:
	_talk = 1.0 if talking else 0.0


func _process(delta: float) -> void:
	if _model == null or not _body.visible:
		return
	_time += delta
	var speed: float = Vector2(_body.velocity.x, _body.velocity.z).length()
	_update_blink(delta)
	_update_antenna(delta, speed)
	for wheel: Node3D in _wheels:
		wheel.rotation.x += speed * delta / 0.045
	_hop = maxf(0.0, _hop - delta * 2.2)
	var hop_height: float = sin(_hop * PI) * 0.18 if _hop > 0.0 else 0.0
	_model.position.y = hop_height + absf(sin(_time * 14.0)) * 0.01 * minf(speed, 1.0)
	if _body_part != null:
		_body_part.rotation.z = sin(_time * 9.0) * 0.03 * minf(speed, 1.0) + (speed - _previous_speed) * 0.02
	if _head != null:
		var look: Node3D = _body.get_look_target() if _body.has_method("get_look_target") else null
		var tilt: float = 0.35 if look != null else sin(_time * 0.7) * 0.06
		_head.rotation.z = lerpf(_head.rotation.z, tilt, 1.0 - exp(-4.0 * delta))
		var nod: float = sin(_time * 11.0) * 0.06 * _talk + (0.15 if look != null else 0.0)
		_head.rotation.x = lerpf(_head.rotation.x, nod, 1.0 - exp(-8.0 * delta))
		_head.rotation.y = sin(_time * 0.45) * 0.25 * (1.0 - minf(speed, 1.0))
	_previous_speed = speed


func _update_blink(delta: float) -> void:
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink = 1.0
		_blink_timer = _rng.randf_range(blink_interval.x, blink_interval.y)
	_blink = maxf(0.0, _blink - delta * 7.0)
	var closed: float = sin(_blink * PI)
	for index: int in _lids.size():
		var rest: Vector3 = _lid_rest[index]
		_lids[index].position = Vector3(rest.x, lerpf(rest.y, 0.0, closed), rest.z)
		_lids[index].scale = Vector3(1.0, lerpf(1.0, 4.2, closed), 1.0)


func _update_antenna(delta: float, speed: float) -> void:
	if _antenna == null:
		return
	# Damped spring: the antenna lags behind accelerations.
	var push: float = (speed - _previous_speed) * 6.0
	_antenna_velocity += Vector2(-push, 0.0) - _antenna_swing * 60.0 * delta * 10.0
	_antenna_velocity *= exp(-6.0 * delta)
	_antenna_swing += _antenna_velocity * delta
	_antenna.rotation.x = clampf(_antenna_swing.x, -0.5, 0.5)
	_antenna.rotation.z = sin(_time * 3.0) * 0.05
