class_name ScrapPressAnimator
extends Node
## Shows the scrap press working (docs/scrap-press.md): the ram goes down
## while pressing and snaps back up when a bale is done; the status lamp shows
## the state. Purely visual, never decides anything.

## How far the ram travels down (metres).
const STROKE := 0.42
const LAMP_COLORS: Dictionary = {"working": Color(0.45, 0.9, 0.4), "waiting": Color(0.95, 0.75, 0.25),
	"tray_full": Color(0.95, 0.35, 0.25), "off": Color(0.35, 0.33, 0.3)}

@export var machine: ScrapPress
@export var lamp: MeshInstance3D

var _ram: Node3D
var _ram_rest: Vector3
var _lever: Node3D
var _lamp_material: StandardMaterial3D


func _ready() -> void:
	_ram = machine.find_child("Ram", true, false) as Node3D
	if _ram != null:
		_ram_rest = _ram.position
	_lever = machine.find_child("Lever", true, false) as Node3D
	if lamp != null:
		_lamp_material = StandardMaterial3D.new()
		_lamp_material.emission_enabled = true
		lamp.material_override = _lamp_material
	machine.status_changed.connect(_on_status_changed)
	machine.bale_pressed.connect(func(_bale: ScrapItem) -> void: _bump())


func _process(_delta: float) -> void:
	if _ram == null:
		return
	# Ease the ram down over the stroke, holding at the bottom for the last bit.
	var progress: float = clampf(machine.get_cycle_progress() / 0.85, 0.0, 1.0)
	var target: Vector3 = _ram_rest + Vector3(0, -STROKE * smoothstep(0.0, 1.0, progress), 0)
	_ram.position = _ram.position.lerp(target, 0.25)
	if _lever != null:
		_lever.rotation.x = lerpf(_lever.rotation.x, -0.5 if machine.get_status() == ScrapPress.STATUS_WORKING else 0.3, 0.1)


func _on_status_changed(status: String) -> void:
	if _lamp_material == null:
		return
	var color: Color = LAMP_COLORS.get(status, Color(0.35, 0.33, 0.3))
	_lamp_material.albedo_color = color
	_lamp_material.emission = color
	_lamp_material.emission_energy_multiplier = 0.0 if status == "off" else 1.4


func _bump() -> void:
	if _ram != null:
		_ram.position = _ram_rest + Vector3(0, 0.05, 0)
