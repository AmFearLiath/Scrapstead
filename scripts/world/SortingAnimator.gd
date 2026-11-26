class_name SortingAnimator
extends Node
## Shows the sorting machine working: the drum turns while it sorts and gives
## a little kick when a piece drops out; the lamp shows the state. Visual only.

const LAMP_COLORS: Dictionary = {"working": Color(0.45, 0.9, 0.4), "waiting": Color(0.95, 0.75, 0.25),
	"bin_full": Color(0.95, 0.35, 0.25), "off": Color(0.35, 0.33, 0.3)}

@export var machine: SortingMachine
@export var lamp: MeshInstance3D

var _drum: Node3D
var _speed: float = 0.0
var _lamp_material: StandardMaterial3D


func _ready() -> void:
	_drum = machine.find_child("Drum", true, false) as Node3D
	if lamp != null:
		_lamp_material = StandardMaterial3D.new()
		_lamp_material.emission_enabled = true
		lamp.material_override = _lamp_material
	machine.status_changed.connect(_on_status_changed)
	machine.piece_sorted.connect(func(_item: ScrapItem, _channel: String) -> void: _speed += 6.0)


func _process(delta: float) -> void:
	if _drum == null:
		return
	var target: float = 3.0 if machine.get_status() == SortingMachine.STATUS_WORKING else 0.0
	_speed = lerpf(_speed, target, minf(delta * 2.0, 1.0))
	_drum.rotate_object_local(Vector3.RIGHT, _speed * delta)


func _on_status_changed(status: String) -> void:
	if _lamp_material == null:
		return
	var color: Color = LAMP_COLORS.get(status, Color(0.35, 0.33, 0.3))
	_lamp_material.albedo_color = color
	_lamp_material.emission = color
	_lamp_material.emission_energy_multiplier = 0.0 if status == "off" else 1.4
