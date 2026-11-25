extends Interactable
## P0 use test object: a yard floodlight that can be switched on and off.
## The visible state change is the light and the glowing lens.

## Light switched by this object.
@export var light: Light3D
## Mesh whose material emission mirrors the state.
@export var lens: MeshInstance3D

var _is_on: bool = false


func _ready() -> void:
	super()
	_apply_visual_state()


func interact(_context: InteractionContext) -> Dictionary:
	_is_on = not _is_on
	_apply_visual_state()
	return make_result(true, "object.use_test.on" if _is_on else "object.use_test.off")


func is_on() -> bool:
	return _is_on


func get_save_state() -> Dictionary:
	return {"on": true} if _is_on else {}


func apply_save_state(state: Dictionary) -> void:
	_is_on = bool(state.get("on", false))
	_apply_visual_state()


func _apply_visual_state() -> void:
	if light != null:
		light.visible = _is_on
	if lens != null and lens.material_override is StandardMaterial3D:
		(lens.material_override as StandardMaterial3D).emission_energy_multiplier = 3.0 if _is_on else 0.0
