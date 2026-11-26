class_name PlaceableCatalog
extends Resource
## Everything the build menu offers (docs/building-system.md, section 4).

@export var placeables: Array[PlaceableDefinition] = []


func get_definition(placeable_id: String) -> PlaceableDefinition:
	for definition: PlaceableDefinition in placeables:
		if definition != null and definition.id == placeable_id:
			return definition
	return null


func in_category(category: String) -> Array[PlaceableDefinition]:
	var result: Array[PlaceableDefinition] = []
	for definition: PlaceableDefinition in placeables:
		if definition != null and definition.category == category:
			result.append(definition)
	return result


func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	var seen: Dictionary = {}
	for definition: PlaceableDefinition in placeables:
		if definition == null:
			problems.append("empty placeable entry")
			continue
		if seen.has(definition.id):
			problems.append("duplicate placeable " + definition.id)
		seen[definition.id] = true
		problems.append_array(definition.validate())
	return problems
