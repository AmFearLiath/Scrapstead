class_name BuildGrid
extends RefCounted
## The 0.5 m build grid (docs/building-system.md, section 2). Pure geometry:
## cell <-> world conversion and the cells an object occupies for a given
## anchor cell and rotation. A cell (x, y) covers world X [x*0.5, x*0.5+0.5)
## and world Z [y*0.5, y*0.5+0.5).
##
## Rotation steps turn clockwise when seen from above (rotation.y = -steps*90°).

const CELL := 0.5


static func world_to_cell(position: Vector3) -> Vector2i:
	return Vector2i(floori(position.x / CELL), floori(position.z / CELL))


static func cell_center(cell: Vector2i) -> Vector3:
	return Vector3((cell.x + 0.5) * CELL, 0.0, (cell.y + 0.5) * CELL)


static func rotation_y(rotation_steps: int) -> float:
	return -float(posmod(rotation_steps, 4)) * PI * 0.5


## World centre of an object whose rotated footprint starts at `anchor`.
static func object_center(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int) -> Vector3:
	var rotated: Vector2i = definition.get_size(rotation_steps)
	return Vector3((anchor.x + rotated.x * 0.5) * CELL, 0.0, (anchor.y + rotated.y * 0.5) * CELL)


## Anchor cell that centres an object's footprint on a world point.
static func anchor_for(definition: PlaceableDefinition, point: Vector3, rotation_steps: int) -> Vector2i:
	var rotated: Vector2i = definition.get_size(rotation_steps)
	return Vector2i(roundi(point.x / CELL - rotated.x * 0.5), roundi(point.z / CELL - rotated.y * 0.5))


## World cells of a local cell rectangle (footprint or clearance).
static func local_rect_cells(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int,
		rect: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var center: Vector3 = object_center(definition, anchor, rotation_steps)
	var basis := Basis(Vector3.UP, rotation_y(rotation_steps))
	var half := Vector3(definition.size.x * 0.5, 0.0, definition.size.y * 0.5)
	for x: int in range(rect.position.x, rect.end.x):
		for y: int in range(rect.position.y, rect.end.y):
			var local := (Vector3(x + 0.5, 0.0, y + 0.5) - half) * CELL
			cells.append(world_to_cell(center + basis * local))
	return cells


static func footprint_cells(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int) -> Array[Vector2i]:
	return local_rect_cells(definition, anchor, rotation_steps, Rect2i(Vector2i.ZERO, definition.size))


static func clearance_cells(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for rect: Rect2i in definition.clearance:
		cells.append_array(local_rect_cells(definition, anchor, rotation_steps, rect))
	return cells


## World position of a local point (in cells, may be fractional).
static func local_point(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int,
		local_cells: Vector2) -> Vector3:
	var center: Vector3 = object_center(definition, anchor, rotation_steps)
	var basis := Basis(Vector3.UP, rotation_y(rotation_steps))
	var half := Vector3(definition.size.x * 0.5, 0.0, definition.size.y * 0.5)
	return center + basis * ((Vector3(local_cells.x, 0.0, local_cells.y) - half) * CELL)
