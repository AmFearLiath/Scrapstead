class_name ItemCatalog
extends Resource
## Lookup of all item definitions used by a scene.

@export var items: Array[ItemDefinition] = []


## Definition for a stable item ID or null.
func get_definition(item_id: String) -> ItemDefinition:
	for definition: ItemDefinition in items:
		if definition.id == item_id:
			return definition
	return null


## Returns a list of problems (duplicate or empty IDs); empty when valid.
func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	var seen: Dictionary = {}
	for definition: ItemDefinition in items:
		if definition == null or definition.id.is_empty():
			problems.append("item definition without id")
			continue
		if seen.has(definition.id):
			problems.append("duplicate item id " + definition.id)
		seen[definition.id] = true
	return problems
