class_name BuildMode
extends Node3D
## The build mode (docs/building-system.md, section 3.3; build-mode-and-interactions.md).
##
## While active the player stands still, the camera follows a build cursor
## moved with WASD and the mouse aims at the grid. Tools: build (place the
## selected object, repeatedly), move (pick up and set down), remove (back to
## storage) and look (what is this?). Every action can be undone and redone.
##
## The preview shows exactly what will happen: a see-through model, the cells
## it takes (green/red), the space in front that must stay free (blue), the
## work radius and nearby areas that have to stay free (Juri's walkways,
## stations), plus one sentence explaining any problem.
## All rules live in PlacedObjects; this node only shows and asks.

signal mode_changed(active: bool)
## Result of an action for the toast: {"ok", "message_key", "message_args"}.
signal action_result(result: Dictionary)
## The selection, tool, hover or check changed (the menu refreshes).
signal preview_changed

const TOOL_BUILD := "build"
const TOOL_MOVE := "move"
const TOOL_REMOVE := "remove"
const TOOL_LOOK := "look"
const HISTORY_LIMIT := 50
const PAN_SPEED := 9.0
const NEARBY_RADIUS := 4.5
const COLOR_OK := Color(0.45, 0.9, 0.45, 0.55)
const COLOR_BAD := Color(0.95, 0.3, 0.25, 0.6)
const COLOR_CLEAR := Color(0.35, 0.65, 0.95, 0.45)
const COLOR_GRID := Color(1.0, 0.97, 0.88, 0.12)
const ZONE_COLORS: Dictionary = {"route": Color(0.95, 0.6, 0.2, 0.28), "gate": Color(0.95, 0.6, 0.2, 0.28),
	"station": Color(0.35, 0.75, 0.75, 0.28), "scrap": Color(0.95, 0.85, 0.3, 0.35)}

@export var placed: PlacedObjects
@export var camera_rig: Node3D

var _active: bool = false
var _tool: String = TOOL_BUILD
var _selected: PlaceableDefinition
var _moving_uid: String = ""
var _rotation: int = 0
var _anchor: Vector2i = Vector2i.ZERO
var _hover_uid: String = ""
var _last_check: Dictionary = {}
var _undo: Array[Dictionary] = []
var _redo: Array[Dictionary] = []
var _cursor: Node3D
var _ghost: Node3D
var _ghost_for: String = ""
var _cells: MultiMeshInstance3D
var _zones: MultiMeshInstance3D
var _ring: MeshInstance3D
var _hover_box: MeshInstance3D
var _mouse_position: Vector2 = Vector2.ZERO
var _has_mouse: bool = false


func _ready() -> void:
	_cursor = Node3D.new()
	_cursor.name = "BuildCursor"
	add_child(_cursor)
	_cells = _make_multimesh("Cells")
	_zones = _make_multimesh("Zones")
	_ring = MeshInstance3D.new()
	_ring.name = "WorkRadius"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.96
	torus.outer_radius = 1.0
	torus.rings = 48
	torus.ring_segments = 4
	_ring.mesh = torus
	_ring.material_override = _flat_material(Color(0.88, 0.66, 0.23, 0.8))
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring)
	_hover_box = MeshInstance3D.new()
	_hover_box.name = "HoverBox"
	_hover_box.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_hover_box)
	_hide_preview()
	set_process(false)


# --- Public API (menu, controller, tests) ----------------------------------------------

func is_active() -> bool:
	return _active


func get_tool() -> String:
	return _tool


func get_selected() -> PlaceableDefinition:
	return _selected


func get_rotation_steps() -> int:
	return _rotation


func get_anchor() -> Vector2i:
	return _anchor


func get_last_check() -> Dictionary:
	return _last_check


func get_hover_uid() -> String:
	return _hover_uid


func get_moving_uid() -> String:
	return _moving_uid


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


## Enters build mode with the cursor at `at` (usually the player).
func enter(at: Vector3) -> void:
	if _active:
		return
	_active = true
	_cursor.global_position = Vector3(at.x, 0.0, at.z)
	camera_rig.set_follow_target(_cursor)
	set_process(true)
	set_tool(TOOL_BUILD if _selected != null else TOOL_LOOK)
	mode_changed.emit(true)


func exit(follow: Node3D) -> void:
	if not _active:
		return
	_cancel_move()
	_active = false
	_hide_preview()
	camera_rig.set_follow_target(follow)
	set_process(false)
	mode_changed.emit(false)


func set_tool(tool: String) -> void:
	_cancel_move()
	_tool = tool
	if tool != TOOL_BUILD:
		_selected = null
	_free_ghost()
	_refresh()


## Chooses an object to build (from the menu).
func select(definition: PlaceableDefinition) -> void:
	_cancel_move()
	_tool = TOOL_BUILD
	_selected = definition
	_free_ghost()
	_refresh()


func rotate_preview(clockwise: bool = true) -> void:
	_rotation = posmod(_rotation + (1 if clockwise else -1), 4)
	_refresh()


## Aims at a world point (mouse ray hit, or tests).
func aim_at(point: Vector3) -> void:
	var definition: PlaceableDefinition = _current_definition()
	if definition != null:
		_anchor = BuildGrid.anchor_for(definition, point, _rotation)
	else:
		_anchor = BuildGrid.world_to_cell(point)
	_hover_uid = placed.get_uid_at(BuildGrid.world_to_cell(point)) if _moving_uid.is_empty() else ""
	_refresh()


## The main click: build, pick up / set down, remove or nothing (look).
func confirm() -> Dictionary:
	var result: Dictionary = {"ok": false, "message_key": "", "message_args": {}}
	match _tool:
		TOOL_BUILD:
			if _selected == null:
				return result
			var definition: PlaceableDefinition = _selected
			result = placed.place(definition.id, _anchor, _rotation)
			if result["ok"]:
				_push({"op": "place", "uid": result["uid"], "def": definition.id, "anchor": _anchor, "rot": _rotation})
				if placed.get_offer_status(definition) in ["locked", "limit", "too_expensive"]:
					set_tool(TOOL_LOOK)
		TOOL_MOVE:
			if _moving_uid.is_empty():
				if _hover_uid.is_empty():
					return result
				_start_move(_hover_uid)
				result = {"ok": true, "message_key": "", "message_args": {}}
			else:
				var entry: Dictionary = _entry(_moving_uid)
				var from_anchor: Vector2i = entry["anchor"]
				var from_rot: int = entry["rot"]
				result = placed.move(_moving_uid, _anchor, _rotation)
				if result["ok"]:
					_push({"op": "move", "uid": _moving_uid, "from": from_anchor, "from_rot": from_rot,
						"to": _anchor, "to_rot": _rotation})
					_end_move()
		TOOL_REMOVE:
			result = remove_hovered()
	_refresh()
	action_result.emit(result)
	return result


func remove_hovered() -> Dictionary:
	if _hover_uid.is_empty():
		return {"ok": false, "message_key": "", "message_args": {}}
	var entry: Dictionary = _entry(_hover_uid)
	var uid: String = _hover_uid
	var result: Dictionary = placed.remove(uid)
	if result["ok"]:
		_push({"op": "remove", "uid": uid, "def": (entry["def"] as PlaceableDefinition).id, "anchor": entry["anchor"],
			"rot": entry["rot"]})
		_hover_uid = ""
	return result


## Right click / Esc: drop the current operation. Returns false if there was none.
func cancel() -> bool:
	if not _moving_uid.is_empty():
		_cancel_move()
		_refresh()
		return true
	if _tool == TOOL_BUILD and _selected != null:
		set_tool(TOOL_LOOK)
		return true
	return false


func undo() -> Dictionary:
	return _step(_undo, _redo, true)


func redo() -> Dictionary:
	return _step(_redo, _undo, false)


# --- Input ---------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseMotion:
		_mouse_position = (event as InputEventMouseMotion).position
		_has_mouse = true
		_aim_from_mouse()
	elif event is InputEventMouseButton and event.is_pressed():
		var button: InputEventMouseButton = event
		_mouse_position = button.position
		_has_mouse = true
		if button.button_index == MOUSE_BUTTON_LEFT:
			_aim_from_mouse()
			confirm()
			get_viewport().set_input_as_handled()
		elif button.button_index == MOUSE_BUTTON_RIGHT:
			cancel()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_rotate"):
		var backwards: bool = event is InputEventWithModifiers and (event as InputEventWithModifiers).shift_pressed
		rotate_preview(not backwards)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_undo"):
		action_result.emit(undo())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_redo"):
		action_result.emit(redo())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_remove"):
		action_result.emit(remove_hovered())
		_refresh()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if input.length() > 0.01:
		var camera: Camera3D = camera_rig.get_camera()
		var forward: Vector3 = -camera.global_basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right: Vector3 = camera.global_basis.x
		right.y = 0.0
		right = right.normalized()
		var speed: float = PAN_SPEED * (1.8 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		var step: Vector3 = (right * input.x - forward * input.y) * speed * delta
		var area: Rect2 = placed.buildable_area
		_cursor.global_position = Vector3(clampf(_cursor.global_position.x + step.x, area.position.x, area.end.x),
			0.0, clampf(_cursor.global_position.z + step.z, area.position.y, area.end.y))
		if _has_mouse:
			_aim_from_mouse()


func _aim_from_mouse() -> void:
	var camera: Camera3D = camera_rig.get_camera()
	if camera == null:
		return
	var origin: Vector3 = camera.project_ray_origin(_mouse_position)
	var direction: Vector3 = camera.project_ray_normal(_mouse_position)
	if absf(direction.y) < 0.0001:
		return
	var distance: float = -origin.y / direction.y
	if distance > 0.0:
		aim_at(origin + direction * distance)


# --- Moving -----------------------------------------------------------------------

func _start_move(uid: String) -> void:
	var entry: Dictionary = _entry(uid)
	_moving_uid = uid
	_rotation = entry["rot"]
	_anchor = entry["anchor"]
	_set_object_faded(uid, true)
	_free_ghost()


func _end_move() -> void:
	_set_object_faded(_moving_uid, false)
	_moving_uid = ""
	_free_ghost()


func _cancel_move() -> void:
	if not _moving_uid.is_empty():
		_end_move()


func _set_object_faded(uid: String, faded: bool) -> void:
	var node: Node3D = placed.get_node_for(uid)
	if node == null:
		return
	for mesh: Node in node.find_children("*", "GeometryInstance3D", true, false):
		(mesh as GeometryInstance3D).transparency = 0.7 if faded else 0.0


# --- Undo / redo -------------------------------------------------------------------

func _push(step: Dictionary) -> void:
	_undo.append(step)
	if _undo.size() > HISTORY_LIMIT:
		_undo.pop_front()
	_redo.clear()


func _step(from: Array[Dictionary], to: Array[Dictionary], undoing: bool) -> Dictionary:
	if from.is_empty():
		return {"ok": false, "message_key": "build.nothing_to_undo" if undoing else "build.nothing_to_redo",
			"message_args": {}}
	_cancel_move()
	var step: Dictionary = from.pop_back()
	var result: Dictionary
	match step["op"]:
		"place":
			result = placed.remove(step["uid"]) if undoing else \
				placed.place(step["def"], step["anchor"], step["rot"], step["uid"])
		"remove":
			result = placed.place(step["def"], step["anchor"], step["rot"], step["uid"]) if undoing else \
				placed.remove(step["uid"])
		"move":
			result = placed.move(step["uid"], step["from"] if undoing else step["to"],
				step["from_rot"] if undoing else step["to_rot"])
	if result.get("ok", false):
		to.append(step)
		result["message_key"] = "build.undone" if undoing else "build.redone"
	else:
		# The world changed in between (something stands there now): drop the step.
		result["message_key"] = "build.cannot_" + ("undo" if undoing else "redo")
	_hover_uid = ""
	_refresh()
	return result


# --- Preview -----------------------------------------------------------------------

func _current_definition() -> PlaceableDefinition:
	if _tool == TOOL_BUILD:
		return _selected
	if _tool == TOOL_MOVE and not _moving_uid.is_empty():
		return _entry(_moving_uid)["def"]
	return null


func _entry(uid: String) -> Dictionary:
	for entry: Dictionary in placed.get_entries():
		if entry["uid"] == uid:
			return entry
	return {}


func _refresh() -> void:
	if not _active:
		return
	var definition: PlaceableDefinition = _current_definition()
	if definition == null:
		_last_check = {}
		_free_ghost()
		_cells.visible = false
		_ring.visible = false
		_show_zones(BuildGrid.cell_center(_anchor))
		_show_hover()
		preview_changed.emit()
		return
	_hover_box.visible = false
	_last_check = placed.check_placement(definition, _anchor, _rotation, _moving_uid)
	_update_ghost(definition)
	_show_cells(definition)
	_show_ring(definition)
	_show_zones(BuildGrid.object_center(definition, _anchor, _rotation))
	preview_changed.emit()


func _update_ghost(definition: PlaceableDefinition) -> void:
	if _ghost_for != definition.id:
		_free_ghost()
		_ghost = definition.scene.instantiate()
		_ghost.name = "Ghost"
		_ghost.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(_ghost)
		_ghost_for = definition.id
		for body: Node in _ghost.find_children("*", "CollisionObject3D", true, false):
			(body as CollisionObject3D).collision_layer = 0
			(body as CollisionObject3D).collision_mask = 0
		for sound: Node in _ghost.find_children("*", "AudioStreamPlayer3D", true, false):
			sound.queue_free()
	var ok: bool = _last_check.get("ok", false)
	_ghost.global_position = BuildGrid.object_center(definition, _anchor, _rotation)
	_ghost.rotation = Vector3(0, BuildGrid.rotation_y(_rotation), 0)
	if _ghost.has_method("get_scene_offset"):
		_ghost.global_position += _ghost.global_basis * _ghost.get_scene_offset()
	_ghost.global_position.y = 0.02
	for mesh: Node in _ghost.find_children("*", "GeometryInstance3D", true, false):
		var geometry := mesh as GeometryInstance3D
		geometry.transparency = 0.35 if ok else 0.55
		geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _free_ghost() -> void:
	if _ghost != null:
		_ghost.queue_free()
	_ghost = null
	_ghost_for = ""


func _show_cells(definition: PlaceableDefinition) -> void:
	var bad: Dictionary = {}
	for problem: Dictionary in _last_check.get("problems", []):
		for cell: Vector2i in problem["cells"]:
			bad[cell] = true
	var entries: Array = []
	for cell: Vector2i in _last_check.get("footprint", []):
		entries.append([cell, COLOR_BAD if bad.has(cell) else COLOR_OK])
	for cell: Vector2i in _last_check.get("clearance", []):
		entries.append([cell, COLOR_BAD if bad.has(cell) else COLOR_CLEAR])
	var center: Vector3 = BuildGrid.object_center(definition, _anchor, _rotation)
	var reach: int = ceili(NEARBY_RADIUS / BuildGrid.CELL)
	var taken: Dictionary = {}
	for entry: Array in entries:
		taken[entry[0]] = true
	var middle: Vector2i = BuildGrid.world_to_cell(center)
	for x: int in range(-reach, reach + 1):
		for y: int in range(-reach, reach + 1):
			var cell := middle + Vector2i(x, y)
			if not taken.has(cell) and Vector2(x, y).length() <= reach:
				entries.append([cell, COLOR_GRID])
	_fill(_cells, entries, 0.035)


func _show_zones(center: Vector3) -> void:
	var entries: Array = []
	var protected: Dictionary = placed.validator.protected
	var reach: int = ceili(NEARBY_RADIUS * 1.4 / BuildGrid.CELL)
	var middle: Vector2i = BuildGrid.world_to_cell(center)
	for x: int in range(-reach, reach + 1):
		for y: int in range(-reach, reach + 1):
			var cell := middle + Vector2i(x, y)
			if protected.has(cell):
				entries.append([cell, ZONE_COLORS.get(protected[cell], COLOR_GRID)])
	_fill(_zones, entries, 0.03)


func _show_ring(definition: PlaceableDefinition) -> void:
	_ring.visible = definition.work_radius > 0.0
	if not _ring.visible:
		return
	var at: Vector3 = BuildGrid.object_center(definition, _anchor, _rotation)
	if definition.id == "magnet_collector":
		var basis := Basis(Vector3.UP, BuildGrid.rotation_y(_rotation))
		at += basis * (MagnetCollector.SCENE_OFFSET + MagnetCollector.COLUMN)
	_ring.global_position = Vector3(at.x, 0.05, at.z)
	_ring.scale = Vector3(definition.work_radius, 1.0, definition.work_radius)


func _show_hover() -> void:
	_hover_box.visible = false
	if _hover_uid.is_empty() or _tool == TOOL_BUILD:
		return
	var entry: Dictionary = _entry(_hover_uid)
	if entry.is_empty():
		return
	var definition: PlaceableDefinition = entry["def"]
	var size: Vector2i = definition.get_size(entry["rot"])
	var box := BoxMesh.new()
	box.size = Vector3(size.x * BuildGrid.CELL + 0.1, 0.06, size.y * BuildGrid.CELL + 0.1)
	_hover_box.mesh = box
	var color: Color = COLOR_BAD if _tool == TOOL_REMOVE else Color(0.88, 0.66, 0.23, 0.55)
	_hover_box.material_override = _flat_material(color)
	_hover_box.global_position = BuildGrid.object_center(definition, entry["anchor"], entry["rot"]) + Vector3(0, 0.03, 0)
	_hover_box.visible = true


func _hide_preview() -> void:
	_free_ghost()
	if _cells != null:
		_cells.visible = false
		_zones.visible = false
		_ring.visible = false
		_hover_box.visible = false


func _fill(target: MultiMeshInstance3D, entries: Array, height: float) -> void:
	var multimesh: MultiMesh = target.multimesh
	multimesh.instance_count = entries.size()
	for index: int in entries.size():
		var cell: Vector2i = entries[index][0]
		multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, BuildGrid.cell_center(cell)
			+ Vector3(0, height, 0)))
		multimesh.set_instance_color(index, entries[index][1])
	target.visible = not entries.is_empty()


func _make_multimesh(node_name: String) -> MultiMeshInstance3D:
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	var quad := PlaneMesh.new()
	quad.size = Vector2(BuildGrid.CELL * 0.9, BuildGrid.CELL * 0.9)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = quad
	instance.multimesh = multimesh
	var material := _flat_material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	return instance


static func _flat_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.no_depth_test = false
	return material
