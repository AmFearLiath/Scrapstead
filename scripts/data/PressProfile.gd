class_name PressProfile
extends Resource
## Data of the scrap press (docs/scrap-press.md): which small steel scrap it
## takes, how many pieces make one bale, how long pressing takes and how much
## fits into the hopper and onto the output tray.

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
## Catalog ware that is the purchase of the machine.
@export var required_upgrade: String = ""
## Item IDs the hopper accepts.
@export var accepted_items: PackedStringArray = []
## Pieces pressed into one bale.
@export_range(2, 20) var pieces_per_bale: int = 6
## Item ID of the bale.
@export var bale_item: String = ""
## Seconds of pressing per bale.
@export_range(1.0, 120.0) var cycle_seconds: float = 8.0
## Pieces the hopper holds.
@export_range(1, 40) var hopper_capacity: int = 12
## Bales the output tray holds.
@export_range(1, 8) var tray_capacity: int = 3


func accepts(item_id: String) -> bool:
	return accepted_items.has(item_id)


func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or bale_item.is_empty() or accepted_items.is_empty():
		problems.append("press profile incomplete")
	if catalog != null:
		if catalog.get_definition(bale_item) == null:
			problems.append("%s: unknown bale item '%s'" % [id, bale_item])
		for item_id: String in accepted_items:
			if catalog.get_definition(item_id) == null:
				problems.append("%s: unknown accepted item '%s'" % [id, item_id])
	if hopper_capacity < pieces_per_bale:
		problems.append("%s: hopper smaller than one bale" % id)
	return problems
