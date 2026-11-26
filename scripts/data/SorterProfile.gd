class_name SorterProfile
extends Resource
## Data of the sorting machine (docs/processing-chain.md): which material
## groups it separates (one output bin and channel per group), how long one
## piece takes and how much fits into the hopper and each bin.

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
@export var required_upgrade: String = ""
## One bin per group; the group id is the output channel.
@export var groups: Array[MaterialGroup] = []
@export_range(0.5, 60.0) var cycle_seconds: float = 2.5
@export_range(1, 40) var hopper_capacity: int = 16
@export_range(1, 20) var bin_capacity: int = 8


func group_for(item_id: String) -> MaterialGroup:
	for group: MaterialGroup in groups:
		if group != null and group.has_item(item_id):
			return group
	return null


func accepts(item_id: String) -> bool:
	return group_for(item_id) != null


func get_group(group_id: String) -> MaterialGroup:
	for group: MaterialGroup in groups:
		if group.id == group_id:
			return group
	return null


func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or groups.is_empty():
		problems.append("sorter profile incomplete")
	for group: MaterialGroup in groups:
		problems.append_array(group.validate(catalog))
	return problems
