extends Interactable
## P0 inspect test object: shows a prepared, localized text. The world state
## stays unchanged.

## Localization key of the inspection text.
@export var text_key: String = ""


func interact(_context: InteractionContext) -> Dictionary:
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	result["panel_data"] = {"title_key": name_key, "text_key": text_key}
	return result
