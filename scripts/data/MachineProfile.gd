class_name MachineProfile
extends Resource
## Data of a fixed yard machine (P3b, docs/first-machine.md): what unlocks it,
## how fast it works, what it handles and where its material comes from.

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
## Catalog ware that installs the machine.
@export var required_upgrade: String = ""
## Optional catalog ware that makes it faster.
@export var speed_upgrade: String = ""
@export var cycle_seconds: float = 20.0
@export var upgraded_cycle_seconds: float = 12.0
## Items the output crate holds before the machine stops.
@export var bin_capacity: int = 6
## Loose items within this distance of the heap centre are collected too.
@export var work_radius: float = 3.0
## Item IDs the magnet can lift (iron and steel only).
@export var magnetic_items: PackedStringArray = []
## Stock of the heap the machine works on, taken in this repeating order.
## The heap starts with and never holds more than `heap_size` pieces; it only
## grows through the supplier's refills below.
@export var heap_pattern: PackedStringArray = []
@export var heap_size: int = 0
## A supplier tips more small scrap onto the heap at this play-time interval
## (0 = never). The heap never grows beyond `heap_size`.
@export var refill_interval_seconds: float = 0.0
@export var refill_amount: int = 0
## Localized announcement of a refill ({amount} placeholder).
@export var refill_message_key: String = ""


func get_heap_item(index: int) -> String:
	if heap_pattern.is_empty():
		return ""
	return heap_pattern[posmod(index, heap_pattern.size())]


func validate(catalog: ItemCatalog) -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or required_upgrade.is_empty():
		problems.append("machine needs an id and an unlocking ware")
	if cycle_seconds <= 0.0 or upgraded_cycle_seconds <= 0.0 or bin_capacity < 1:
		problems.append("%s: invalid timing or capacity" % id)
	for item_id: String in magnetic_items:
		if catalog.get_definition(item_id) == null:
			problems.append("%s: unknown magnetic item '%s'" % [id, item_id])
	for item_id: String in heap_pattern:
		if not magnetic_items.has(item_id):
			problems.append("%s: heap holds non-magnetic '%s'" % [id, item_id])
	return problems
