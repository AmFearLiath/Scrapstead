extends Interactable
## Inspect-only object (P0 notice board, P1 workbench): its main action shows a
## prepared, localized text. The world state stays unchanged.


func interact(context: InteractionContext) -> Dictionary:
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	result["panel_data"] = get_inspection(context)
	return result
