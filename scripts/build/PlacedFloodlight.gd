class_name PlacedFloodlight
extends Node3D
## A placed yard floodlight (docs/building-system.md): its switch box turns a
## real spot light on and off. The setting is part of the placed object state.

@onready var _light: SpotLight3D = $Light
@onready var _glow: OmniLight3D = $Glow
@onready var _switch: Interactable = $Switch

var _on: bool = true


func _ready() -> void:
	_switch.object_id = name + "_switch"
	_apply()


func is_on() -> bool:
	return _on


func toggle() -> bool:
	_on = not _on
	_apply()
	return _on


func get_placed_state() -> Dictionary:
	return {"on": _on}


func apply_placed_state(state: Dictionary) -> void:
	_on = bool(state.get("on", true))
	if is_node_ready():
		_apply()


func _apply() -> void:
	_light.visible = _on
	_glow.visible = _on
	var lens: MeshInstance3D = get_node_or_null("Lens") as MeshInstance3D
	if lens != null:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 0.95, 0.78) if _on else Color(0.45, 0.45, 0.42)
		material.emission_enabled = _on
		material.emission = Color(1.0, 0.9, 0.65)
		material.emission_energy_multiplier = 2.5
		lens.material_override = material
	_switch.interaction_state_changed.emit(_switch)
