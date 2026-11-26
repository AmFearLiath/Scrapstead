class_name MaterialGroup
extends Resource
## A material family of the processing chain (docs/processing-chain.md):
## which items belong to it, which bale a press makes from it and from how
## many pieces. The sorting machine sorts by these groups, the press presses
## each group into its own bale.

@export var id: String = ""
@export var name_key: String = ""
## Item IDs of this material.
@export var items: PackedStringArray = []
## Item ID of the bale pressed from it.
@export var bale_item: String = ""
@export_range(2, 20) var pieces_per_bale: int = 6


func has_item(item_id: String) -> bool:
	return items.has(item_id)


func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or items.is_empty() or bale_item.is_empty():
		problems.append("material group '%s' incomplete" % id)
	if catalog != null:
		if catalog.get_definition(bale_item) == null:
			problems.append("%s: unknown bale '%s'" % [id, bale_item])
		for item_id: String in items:
			if catalog.get_definition(item_id) == null:
				problems.append("%s: unknown item '%s'" % [id, item_id])
	return problems
