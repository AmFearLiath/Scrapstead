class_name PlaceableDefinition
extends Resource
## Data profile of an object the player can place in build mode
## (docs/building-system.md, section 3.1). Cells are 0.5 m (BuildGrid.CELL).
## Local cell coordinates: x to the object's right, y towards its front
## (model +Z) at rotation 0; the footprint spans (0, 0) .. (size - 1).

const CATEGORY_MACHINES := "machines"
const CATEGORY_STORAGE := "storage"
const CATEGORY_PATHS := "paths"
const CATEGORY_DECOR := "decor"
const CATEGORIES: PackedStringArray = ["machines", "storage", "paths", "decor"]

@export var id: String = ""
@export var name_key: String = ""
@export var description_key: String = ""
@export var category: String = CATEGORY_DECOR
## Credits per piece. Ignored when `unlock_ware` sells the object instead.
@export var price: int = 0
## Optional catalog ware that is the purchase of this object (machines);
## owning it puts one piece in storage.
@export var unlock_ware: String = ""
## Optional story flag needed before the object is offered.
@export var requires_flag: String = ""
## 0 = unlimited.
@export var max_count: int = 0
@export var scene: PackedScene
## Footprint in cells at rotation 0.
@export var size: Vector2i = Vector2i(2, 2)
## Cells that must stay free and walkable (operator areas), local cells; may
## lie outside the footprint (e.g. y = size.y is directly in front).
@export var clearance: Array[Rect2i] = []
## Work area radius in metres shown in the preview (0 = none).
@export var work_radius: float = 0.0
## Whether the object blocks movement (collision) or can be walked over.
@export var solid: bool = true
## Collision height in metres for solid objects.
@export var height: float = 1.0
## Connection points for later machine links: [{"kind": "in"/"out", "cell": Vector2i}].
@export var ports: Array[Dictionary] = []


func get_size(rotation_steps: int) -> Vector2i:
	return size if posmod(rotation_steps, 2) == 0 else Vector2i(size.y, size.x)


func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or name_key.is_empty():
		problems.append("placeable needs id and name")
	if not CATEGORIES.has(category):
		problems.append("%s: unknown category '%s'" % [id, category])
	if scene == null:
		problems.append("%s: no scene" % id)
	if size.x < 1 or size.y < 1:
		problems.append("%s: empty footprint" % id)
	if price < 0:
		problems.append("%s: negative price" % id)
	return problems
