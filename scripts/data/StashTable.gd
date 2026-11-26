class_name StashTable
extends Resource
## All searchable yard fixtures of a scene (docs/yard-stashes.md).

@export var stashes: Array[StashDefinition] = []


func get_definition(stash_id: String) -> StashDefinition:
	for definition: StashDefinition in stashes:
		if definition != null and definition.id == stash_id:
			return definition
	return null
