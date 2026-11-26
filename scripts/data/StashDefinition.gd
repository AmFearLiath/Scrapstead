class_name StashDefinition
extends Resource
## A yard fixture that can be searched again and again (block 4,
## docs/yard-stashes.md): tyre stacks, the car wreck, shelves, crates, the
## container, scrap heaps. Each search uses one charge and turns up a few
## random pieces from the loot list; charges come back slowly while playing.

## Stable ID, also the save key.
@export var id: String = ""
## Path of the yard fixture below the gameplay scene root.
@export var fixture_path: String = ""
## Localization key of the display name.
@export var name_key: String = ""
## Localization key of the action verb ("Search", "Pry open", ...).
@export var action_key: String = "ui.action.search"
## Tool ID needed for searching ("crowbar", "hoist"); empty = bare hands.
@export var required_tool: String = ""
@export_range(0.3, 10.0) var search_seconds: float = 1.6
## Searches available when full.
@export_range(1, 10) var capacity: int = 2
## Play seconds until one more search becomes available.
@export_range(10.0, 3600.0) var refill_seconds: float = 300.0
## Pieces found per search.
@export_range(1, 6) var min_items: int = 1
@export_range(1, 6) var max_items: int = 2
## Item IDs that can turn up and their relative weights (same length).
@export var loot_items: PackedStringArray = []
@export var loot_weights: PackedFloat32Array = []
## Localization keys of the flavor lines after a search (one is picked).
@export var result_keys: PackedStringArray = []
## Localization key of the line when the stash is searched empty.
@export var empty_key: String = "ui.stash.empty"


## Problems with this definition (empty = valid).
func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or fixture_path.is_empty():
		problems.append("stash without id or fixture path")
	if loot_items.is_empty() or loot_items.size() != loot_weights.size():
		problems.append("%s: loot items and weights do not match" % id)
	if min_items > max_items:
		problems.append("%s: min_items > max_items" % id)
	for item_id: String in loot_items:
		if catalog != null and catalog.get_definition(item_id) == null:
			problems.append("%s: unknown loot item '%s'" % [id, item_id])
	return problems


## Picks one loot item ID with the given random generator.
func roll_item(rng: RandomNumberGenerator) -> String:
	var total: float = 0.0
	for weight: float in loot_weights:
		total += maxf(weight, 0.0)
	var pick: float = rng.randf() * total
	for index: int in loot_items.size():
		pick -= maxf(loot_weights[index], 0.0)
		if pick <= 0.0:
			return loot_items[index]
	return loot_items[loot_items.size() - 1]
