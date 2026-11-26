class_name ItemDefinition
extends Resource
## Data definition of a collectible item type (docs/starting-yard-item-catalog.md,
## section 3). Gameplay values live here, not in gameplay scripts.

enum HandlingClass { HAND, CARRY, TOOL }

## Stable, language independent ID, e.g. "scrap_rusted_bolt".
@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
## Gameplay grouping: "loose_scrap", "bulk_scrap" or "device".
@export var category: String = "loose_scrap"
@export var handling_class: HandlingClass = HandlingClass.HAND
## Fixed direct-sale value in credits (P1: no dynamic prices).
@export_range(0, 100000) var sell_value: int = 1
## Carry slots the item occupies.
@export_range(1, 16) var carry_size: int = 1
## Sound played when picked up (name in data/audio/sound_library.tres).
@export var pickup_sound: String = "clink"
## Visual placeholder scene, independent of localized text.
@export var model: PackedScene
## Tool that opens this item where it lies (e.g. "crowbar" for nailed crates);
## empty for ordinary items. Opening consumes it and releases `contents`.
@export var open_tool: String = ""
@export var contents: Array[ItemDefinition] = []
@export_range(0.5, 10.0) var open_seconds: float = 1.6


## Localization key of the category label.
func get_category_key() -> String:
	return "item.category." + category
