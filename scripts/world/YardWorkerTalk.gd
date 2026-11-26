class_name YardWorkerTalk
extends Interactable
## Talking to the yard worker (P3a): opens the staff panel, where the player
## hires, pauses or dismisses him. The decisions themselves live in YardWorker.

@export var worker: YardWorker


func _ready() -> void:
	if worker == null:
		worker = get_parent() as YardWorker
	if worker != null and worker.profile != null and name_key.is_empty():
		name_key = worker.profile.name_key
	super()


func is_interaction_available() -> bool:
	return worker != null and worker.get_presence() != YardWorker.Presence.ABSENT and not object_id.is_empty()


func get_action_key() -> String:
	return "ui.action.staff_manage" if worker.is_hired() else "ui.action.talk"


func get_prompt_detail(_context: InteractionContext) -> String:
	if worker.is_hired():
		return tr("ui.staff.status." + worker.get_status())
	return tr("ui.staff.prompt_available").format({"fee": worker.profile.hire_fee})


func get_inspection(_context: InteractionContext) -> Dictionary:
	return {"title": worker.get_display_name(), "body": tr(worker.profile.description_key)}


func interact(_context: InteractionContext) -> Dictionary:
	var result: Dictionary = make_result(true)
	result["panel"] = "staff"
	result["panel_data"] = {"worker": worker}
	return result
