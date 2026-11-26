class_name YardNavigation
extends RefCounted
## Walkable grid of the yard for helpers (docs/building-system.md): A* on the
## 0.5 m build grid. Solid cells come from the static yard (physics scan) and
## from the footprints of everything placed or adopted in build mode, so
## paths follow any layout the player builds. Recalculated when build mode
## closes; also answers "can you still reach X?" for placement checks.

var region: Rect2i
var _astar := AStarGrid2D.new()
## Cells blocked by things that are not managed by PlacedObjects (fences, gate posts).
var _static_solid: Dictionary = {}
## Cells blocked by placed / adopted solid footprints: cell -> uid.
var _footprints: Dictionary = {}


func _init(buildable: Rect2i = Rect2i()) -> void:
	region = buildable


## Rebuilds everything. `static_solid`: cells; `footprints`: cell -> uid.
func rebuild(static_solid: Dictionary, footprints: Dictionary) -> void:
	_static_solid = static_solid
	_footprints = footprints
	_astar.region = region
	_astar.cell_size = Vector2.ONE
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()
	for cell: Vector2i in _static_solid:
		if region.has_point(cell):
			_astar.set_point_solid(cell, true)
	for cell: Vector2i in _footprints:
		if region.has_point(cell):
			_astar.set_point_solid(cell, true)


func is_ready() -> bool:
	return region.has_area() and not _astar.is_dirty()


func is_solid(cell: Vector2i) -> bool:
	return not region.has_point(cell) or _astar.is_point_solid(cell)


## World path from `from` to `to` as waypoints (start excluded, target
## included). Empty if there is no way. Targets inside something solid lead
## to the nearest free cell next to it.
func find_path(from: Vector3, to: Vector3) -> Array[Vector3]:
	var path: Array[Vector3] = []
	if not is_ready():
		return path
	var start: Vector2i = nearest_free(BuildGrid.world_to_cell(from))
	var goal: Vector2i = nearest_free(BuildGrid.world_to_cell(to))
	if start == Vector2i(-99999, -99999) or goal == Vector2i(-99999, -99999):
		return path
	var cells: Array[Vector2i] = _astar.get_id_path(start, goal)
	if cells.is_empty():
		return path
	for cell: Vector2i in _smooth(cells):
		path.append(BuildGrid.cell_center(cell))
	if goal == BuildGrid.world_to_cell(to):
		path[-1] = Vector3(to.x, 0.0, to.z)
	return path


## Whether `to` can be reached from `from`, optionally with extra cells blocked.
func is_reachable(from: Vector3, to: Vector3, extra_solid: Array[Vector2i] = [],
		freed: Array[Vector2i] = []) -> bool:
	var changed: Array[Vector2i] = []
	var released: Array[Vector2i] = []
	for cell: Vector2i in freed:
		if region.has_point(cell) and _astar.is_point_solid(cell) and not _static_solid.has(cell):
			_astar.set_point_solid(cell, false)
			released.append(cell)
	for cell: Vector2i in extra_solid:
		if region.has_point(cell) and not _astar.is_point_solid(cell):
			_astar.set_point_solid(cell, true)
			changed.append(cell)
	var start: Vector2i = nearest_free(BuildGrid.world_to_cell(from))
	var goal: Vector2i = nearest_free(BuildGrid.world_to_cell(to))
	var reachable: bool = start != Vector2i(-99999, -99999) and goal != Vector2i(-99999, -99999) \
		and not _astar.get_id_path(start, goal).is_empty()
	for cell: Vector2i in changed:
		_astar.set_point_solid(cell, false)
	for cell: Vector2i in released:
		_astar.set_point_solid(cell, true)
	return reachable


## Nearest walkable cell (rings up to 6 cells); a sentinel if none.
func nearest_free(cell: Vector2i) -> Vector2i:
	if region.has_point(cell) and not _astar.is_point_solid(cell):
		return cell
	for radius: int in range(1, 7):
		var best := Vector2i(-99999, -99999)
		var best_distance: float = INF
		for x: int in range(-radius, radius + 1):
			for y: int in range(-radius, radius + 1):
				if maxi(absi(x), absi(y)) != radius:
					continue
				var candidate := cell + Vector2i(x, y)
				if region.has_point(candidate) and not _astar.is_point_solid(candidate):
					var distance: float = Vector2(x, y).length()
					if distance < best_distance:
						best = candidate
						best_distance = distance
		if best_distance < INF:
			return best
	return Vector2i(-99999, -99999)


## Drops waypoints that a straight walk can skip (clear line over free cells).
func _smooth(cells: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var anchor: int = 0
	var index: int = 1
	while index < cells.size():
		if not _line_free(cells[anchor], cells[index]):
			result.append(cells[index - 1])
			anchor = index - 1
		index += 1
	result.append(cells[-1])
	return result


func _line_free(a: Vector2i, b: Vector2i) -> bool:
	var steps: int = maxi(absi(b.x - a.x), absi(b.y - a.y)) * 2
	for step: int in range(steps + 1):
		var t: float = float(step) / maxf(steps, 1)
		var point := Vector2(a).lerp(Vector2(b), t)
		# Check the cells a 0.5 m wide body would touch.
		for offset: Vector2 in [Vector2(0.35, 0.35), Vector2(-0.35, 0.35), Vector2(0.35, -0.35), Vector2(-0.35, -0.35)]:
			var cell := Vector2i(roundi(point.x + offset.x), roundi(point.y + offset.y))
			if is_solid(cell):
				return false
	return true
