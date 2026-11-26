class_name DeliveryTable
extends Resource
## Neighbors' scrap deliveries (procurement path 2 of the concept,
## docs/gameplay-economy.md section 6). Authored, not random: the entries are
## delivered in order and then repeat. Each entry is a dictionary:
##   sender  String         localization key of the sender's name
##   note    String         localization key of the note left with the scrap
##   items   PackedStringArray  item IDs (common, sellable materials only)
##
## The pacing keeps the source modest (docs/world-exploration-activities.md
## 4.3: recurring sources must not become an endless profitable farm): a new
## delivery only arrives while little of the previous one is still lying around.

## Upgrade that makes the yard look open for business.
@export var required_upgrade: String = "yard_entrance"
## Seconds of play time between the requirement and the first delivery.
@export var first_delay_seconds: float = 25.0
## Seconds of play time between two deliveries.
@export var interval_seconds: float = 150.0
## A delivery waits while this many delivered items still lie in the yard.
@export var max_waiting_items: int = 2
@export var entries: Array[Dictionary] = []


func get_entry(index: int) -> Dictionary:
	if entries.is_empty():
		return {}
	return entries[posmod(index, entries.size())]


## Problems in the data (empty list = valid). Used by tests.
func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if entries.is_empty():
		problems.append("no delivery entries")
	if interval_seconds <= 0.0 or first_delay_seconds < 0.0:
		problems.append("invalid timing")
	for index: int in entries.size():
		var entry: Dictionary = entries[index]
		var items: PackedStringArray = entry.get("items", PackedStringArray())
		if str(entry.get("sender", "")).is_empty() or str(entry.get("note", "")).is_empty():
			problems.append("entry %d lacks sender or note" % index)
		if items.is_empty():
			problems.append("entry %d delivers nothing" % index)
		for item_id: String in items:
			var definition: ItemDefinition = catalog.get_definition(item_id) if catalog != null else null
			if definition == null:
				problems.append("entry %d: unknown item '%s'" % [index, item_id])
	return problems
