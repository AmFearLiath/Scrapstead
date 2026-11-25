class_name InputHints
extends RefCounted
## Display names of input bindings, read from the Input Map so hints stay
## correct if bindings change.


## Name of the first keyboard key bound to an action, e.g. "E".
static func key_name(action: StringName) -> String:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			var keycode: Key = key_event.physical_keycode if key_event.physical_keycode != KEY_NONE \
				else key_event.keycode
			return OS.get_keycode_string(keycode)
	return "?"
