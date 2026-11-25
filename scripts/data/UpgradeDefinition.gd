class_name UpgradeDefinition
extends Resource
## Data definition of a ware in the office order catalog: an upgrade that
## modifies a stat and/or grants a tool. Further wares are added as new
## resources in data/upgrades without code changes, as long as they use a
## supported stat or tool ID.

## Stats an upgrade can modify in the prototype.
const STAT_CARRY_CAPACITY: String = "carry_capacity"

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
@export_range(0, 1000000) var price: int = 0
## Modified stat, see STAT_* constants; empty for pure tools.
@export var stat: String = ""
## Additive bonus to the stat.
@export var bonus: int = 0
## Tool ID granted by this ware, e.g. "crowbar" or "hoist"; empty if none.
@export var grants_tool: String = ""
## Optional upgrade ID that must be owned first.
@export var requires: String = ""
