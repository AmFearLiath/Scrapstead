class_name PressProfile
extends Resource
## Data of the scrap press (docs/scrap-press.md): which material groups it
## presses (each into its own bale), how long a bale takes and how much fits
## into the hopper and onto the output tray. A bale always holds one material.

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
## Catalog ware that is the purchase of the machine.
@export var required_upgrade: String = ""
## Material groups it presses (steel, copper & electronics, wood).
@export var groups: Array[MaterialGroup] = []
## Seconds of pressing per bale.
@export_range(1.0, 120.0) var cycle_seconds: float = 8.0
## Pieces the hopper holds (all materials together).
@export_range(1, 40) var hopper_capacity: int = 12
## Bales the output tray holds.
@export_range(1, 8) var tray_capacity: int = 3


func accepts(item_id: String) -> bool:
	return group_for(item_id) != null


func group_for(item_id: String) -> MaterialGroup:
	for group: MaterialGroup in groups:
		if group != null and group.has_item(item_id):
			return group
	return null


func get_bale_items() -> PackedStringArray:
	var bales: PackedStringArray = []
	for group: MaterialGroup in groups:
		bales.append(group.bale_item)
	return bales


func get_accepted_items() -> PackedStringArray:
	var items: PackedStringArray = []
	for group: MaterialGroup in groups:
		items.append_array(group.items)
	return items


func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or groups.is_empty():
		problems.append("press profile incomplete")
	for group: MaterialGroup in groups:
		problems.append_array(group.validate(catalog))
		if hopper_capacity < group.pieces_per_bale:
			problems.append("%s: hopper smaller than one %s bale" % [id, group.id])
	return problems
