class_name PressControls
extends Interactable
## Interaction points of the scrap press (docs/scrap-press.md): the control box
## switches it on or off and tells its state; the hopper takes every fitting
## piece from the basket.

enum Role { CONTROLS, HOPPER }

@export var machine: ScrapPress
@export var role: Role = Role.CONTROLS


func is_interaction_available() -> bool:
	return machine != null and machine.is_installed() and not object_id.is_empty()


func get_action_key() -> String:
	if role == Role.HOPPER:
		return "ui.action.feed"
	return "ui.action.machine_off" if machine.is_switched_on() else "ui.action.machine_on"


func get_prompt_detail(_context: InteractionContext) -> String:
	return tr("ui.press.detail").format({"status": tr("ui.press.status." + machine.get_status()),
		"hopper": machine.get_hopper_count(), "capacity": machine.profile.hopper_capacity,
		"per_bale": machine.profile.pieces_per_bale, "tray": machine.get_tray_count(),
		"tray_capacity": machine.profile.tray_capacity})


func get_inspection(_context: InteractionContext) -> Dictionary:
	return {"title": tr(machine.profile.name_key), "body": tr(machine.profile.description_key) + "\n\n"
		+ tr("ui.press.rules").format({"per_bale": machine.profile.pieces_per_bale,
			"seconds": NumberFormat.decimal(machine.get_cycle_seconds(), 0)})}


func check_requirements(context: InteractionContext) -> Dictionary:
	if role != Role.HOPPER:
		return {"ok": true, "message_key": "", "message_args": {}}
	if machine.get_hopper_count() >= machine.profile.hopper_capacity:
		return {"ok": false, "message_key": "ui.press.hopper_full", "message_args": {}}
	if context == null or context.inventory == null or _fitting_count(context) == 0:
		return {"ok": false, "message_key": "ui.press.nothing_to_feed", "message_args": {}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	if role == Role.HOPPER:
		var requirements: Dictionary = check_requirements(context)
		if not requirements["ok"]:
			return make_result(false, requirements["message_key"])
		var fed: int = machine.feed_from_inventory(context.inventory)
		interaction_state_changed.emit(self)
		return make_result(fed > 0, "ui.press.fed", {"count": fed, "hopper": machine.get_hopper_count()})
	var on: bool = machine.toggle()
	interaction_state_changed.emit(self)
	return make_result(true, "ui.machine.switched_on" if on else "ui.machine.switched_off",
		{"name": tr(machine.profile.name_key)})


func _fitting_count(context: InteractionContext) -> int:
	var count: int = 0
	for entry: Dictionary in context.inventory.get_entries():
		if machine.profile.accepts(str(entry["item_id"])):
			count += 1
	return count
