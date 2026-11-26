class_name MagnetControls
extends Interactable
## Control box of the magnetic collector (P3b): switches it on or off and
## shows status, heap stock and crate fill in the prompt.

@export var machine: MagnetCollector


func is_interaction_available() -> bool:
	return machine != null and machine.is_installed() and not object_id.is_empty()


func get_action_key() -> String:
	return "ui.action.machine_off" if machine.is_switched_on() else "ui.action.machine_on"


func get_prompt_detail(_context: InteractionContext) -> String:
	return tr("ui.machine.detail").format({"status": tr("ui.machine.status." + machine.get_status()),
		"heap": machine.get_heap_remaining(), "bin": machine.get_bin_count(),
		"capacity": machine.profile.bin_capacity})


func get_inspection(_context: InteractionContext) -> Dictionary:
	return {"title": tr(machine.profile.name_key), "body": tr(machine.profile.description_key) + "\n\n"
		+ tr("ui.machine.rules").format({"seconds": NumberFormat.decimal(machine.get_cycle_seconds(), 0),
			"capacity": machine.profile.bin_capacity, "heap": machine.get_heap_remaining()})}


func interact(_context: InteractionContext) -> Dictionary:
	var on: bool = machine.toggle()
	interaction_state_changed.emit(self)
	return make_result(true, "ui.machine.switched_on" if on else "ui.machine.switched_off",
		{"name": tr(machine.profile.name_key)})
