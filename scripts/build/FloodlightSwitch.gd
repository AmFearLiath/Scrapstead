class_name FloodlightSwitch
extends Interactable
## Switch box of a placed floodlight: on/off.

@export var floodlight: PlacedFloodlight


func get_action_key() -> String:
	return "ui.action.light_off" if floodlight.is_on() else "ui.action.light_on"


func interact(_context: InteractionContext) -> Dictionary:
	var on: bool = floodlight.toggle()
	return make_result(true, "ui.light.switched_on" if on else "ui.light.switched_off")
