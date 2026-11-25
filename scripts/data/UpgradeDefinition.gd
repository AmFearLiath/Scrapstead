class_name UpgradeDefinition
extends Resource
## Data definition of a purchasable upgrade. Further upgrades are added as new
## resources in data/upgrades without code changes, as long as they modify a
## supported stat.

## Stats an upgrade can modify in the prototype.
const STAT_CARRY_CAPACITY: String = "carry_capacity"

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
@export_range(0, 1000000) var price: int = 0
## Modified stat, see STAT_* constants.
@export var stat: String = STAT_CARRY_CAPACITY
## Additive bonus to the stat.
@export var bonus: int = 0
## Optional upgrade ID that must be owned first.
@export var requires: String = ""
