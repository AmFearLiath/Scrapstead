extends Node
## Presentation of the magnetic collector (P3b): swings the boom between heap
## and crate, lowers the magnet, shows the piece it lifts, lights the status
## lamp, rumbles while working and shrinks the heap with its stock.
##
## Reads MagnetCollector's state only. The cycle's result is decided there,
## never by this animation (mvp-prototype-plan.md, P3b).

## Cable length with the magnet raised and lowered (metres).
const CABLE_UP := 0.55
const CABLE_DOWN := 1.15
const LAMP_COLORS: Dictionary = {"working": Color(0.45, 0.95, 0.4), "bin_full": Color(1.0, 0.75, 0.2),
	"empty": Color(0.55, 0.55, 0.55), "off": Color(0.35, 0.12, 0.1)}

## Emitted when the magnet touches down (sound).
signal touched_down
## Emitted when the piece is released over the crate (sound).
signal released

@export var machine: MagnetCollector

var _turret: Node3D
var _cable: Node3D
var _magnet: Node3D
var _proxy_root: Node3D
var _proxy_item: String = ""
var _lamp: MeshInstance3D
var _lamp_material: StandardMaterial3D
var _heap: Node3D
var _heap_base_scale: Vector3 = Vector3.ONE
var _yaw: float = 0.0
var _phase_down: bool = false
var _phase_release: bool = false
var _time: float = 0.0
var _hum: AudioStreamPlayer3D


func _ready() -> void:
	if machine == null:
		machine = get_parent() as MagnetCollector
	var model: Node3D = machine.get_node_or_null("Machine/Model") as Node3D
	if model == null:
		set_process(false)
		return
	_turret = model.get_node_or_null("Turret")
	_cable = model.get_node_or_null("Turret/Boom/Cable")
	_magnet = model.get_node_or_null("Turret/Boom/Magnet")
	if _turret == null or _cable == null or _magnet == null:
		push_warning("MagnetAnimator: machine model lacks Turret/Boom/Cable/Magnet; animation disabled.")
		set_process(false)
		return
	_proxy_root = Node3D.new()
	_proxy_root.name = "Proxy"
	_magnet.add_child(_proxy_root)
	_proxy_root.position = Vector3(0, -0.32, 0)
	_lamp = machine.get_node_or_null("Machine/StatusLamp") as MeshInstance3D
	if _lamp != null:
		_lamp_material = StandardMaterial3D.new()
		_lamp_material.emission_enabled = true
		_lamp.material_override = _lamp_material
	_yaw = _yaw_to(machine.bin)
	_set_cable(CABLE_UP)
	_hum = machine.get_node_or_null("Machine/Hum") as AudioStreamPlayer3D
	if _hum != null and _hum.stream != null:
		_hum.stream = AudioLoop.looping(_hum.stream)


func _process(delta: float) -> void:
	_time += delta
	var status: String = machine.get_status()
	_update_lamp(status)
	_update_heap()
	_update_hum(status, delta)
	var target_yaw: float = _yaw_to(machine.bin)
	var cable: float = CABLE_UP
	var carrying: bool = false
	if status == MagnetCollector.STATUS_WORKING:
		var p: float = machine.get_cycle_progress()
		var to_heap: float = _yaw_to_point(machine.get_lift_point())
		var to_bin: float = _yaw_to(machine.bin)
		if p < 0.3:
			target_yaw = lerp_angle(to_bin, to_heap, _smooth(p / 0.3))
			_phase_down = false
			_phase_release = false
		elif p < 0.45:
			target_yaw = to_heap
			cable = lerpf(CABLE_UP, CABLE_DOWN, _smooth((p - 0.3) / 0.15))
			if p > 0.43 and not _phase_down:
				_phase_down = true
				touched_down.emit()
		elif p < 0.6:
			target_yaw = to_heap
			cable = lerpf(CABLE_DOWN, CABLE_UP, _smooth((p - 0.45) / 0.15))
			carrying = true
		elif p < 0.88:
			target_yaw = lerp_angle(to_heap, to_bin, _smooth((p - 0.6) / 0.28))
			carrying = true
		else:
			target_yaw = to_bin
			cable = lerpf(CABLE_UP, CABLE_UP + 0.3, _smooth((p - 0.88) / 0.12))
			carrying = p < 0.97
			if not carrying and not _phase_release:
				_phase_release = true
				released.emit()
		# A little engine shake while working.
		_turret.rotation.z = sin(_time * 31.0) * 0.004
	else:
		_turret.rotation.z = 0.0
	_yaw = lerp_angle(_yaw, target_yaw, 1.0 - exp(-14.0 * delta))
	_turret.rotation.y = _yaw
	_set_cable(cable)
	_update_proxy(carrying)


## Engine and coil hum while working, fading in and out (presentation only).
func _update_hum(status: String, delta: float) -> void:
	if _hum == null:
		return
	var working: bool = status == MagnetCollector.STATUS_WORKING
	var target_db: float = -6.0 if working else -40.0
	_hum.volume_db = move_toward(_hum.volume_db, target_db, delta * 30.0)
	_hum.pitch_scale = 1.15 if machine.get_cycle_seconds() < machine.profile.cycle_seconds else 1.0
	if working and not _hum.playing:
		_hum.play()
	elif not working and _hum.playing and _hum.volume_db <= -39.0:
		_hum.stop()


func _set_cable(length: float) -> void:
	_cable.scale = Vector3(1.0, length, 1.0)
	_magnet.position.y = _cable.position.y - length


func _update_proxy(carrying: bool) -> void:
	var wanted: String = machine.peek_next_item_id() if carrying else ""
	if wanted == _proxy_item:
		return
	_proxy_item = wanted
	for child: Node in _proxy_root.get_children():
		child.queue_free()
	if wanted.is_empty() or machine.item_catalog == null:
		return
	var definition: ItemDefinition = machine.item_catalog.get_definition(wanted)
	if definition != null and definition.model != null:
		var model: Node3D = definition.model.instantiate()
		model.rotation = Vector3(0.3, 0.8, 0.0)
		_proxy_root.add_child(model)


func _update_lamp(status: String) -> void:
	if _lamp_material == null:
		return
	var color: Color = LAMP_COLORS.get(status, Color(0.2, 0.2, 0.2))
	var pulse: float = 0.6 + 0.4 * sin(_time * 5.0) if status == MagnetCollector.STATUS_BIN_FULL else 1.0
	_lamp_material.albedo_color = color
	_lamp_material.emission = color
	_lamp_material.emission_energy_multiplier = 1.6 * pulse if status != MagnetCollector.STATUS_OFF else 0.1


func _update_heap() -> void:
	if _heap == null and machine.heap_center != null:
		_heap = machine.heap_center.get_node_or_null("Heap") as Node3D
		if _heap != null:
			_heap_base_scale = _heap.scale
	if _heap == null or machine.profile == null or machine.profile.heap_size <= 0:
		return
	var fraction: float = float(machine.get_heap_remaining()) / float(machine.profile.heap_size)
	_heap.visible = fraction > 0.0
	_heap.scale = Vector3(_heap_base_scale.x * (0.55 + 0.45 * fraction), _heap_base_scale.y * (0.2 + 0.8 * fraction),
		_heap_base_scale.z * (0.55 + 0.45 * fraction))


## Turret yaw (machine-local) that points the boom at a node.
func _yaw_to(node: Node3D) -> float:
	if node == null or _turret == null:
		return _yaw
	return _yaw_to_point(node.global_position)


func _yaw_to_point(point: Vector3) -> float:
	if _turret == null:
		return _yaw
	var local: Vector3 = _turret.get_parent_node_3d().to_local(point) - _turret.position
	return atan2(local.x, local.z)


static func _smooth(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
