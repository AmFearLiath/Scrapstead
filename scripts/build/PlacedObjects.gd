class_name PlacedObjects
extends Node3D
## Everything the player placed on the yard, plus the storage of owned but
## unplaced pieces (docs/building-system.md, section 3.4). Owns placement,
## moving, removing, the placement rules and the save data of block "placed".
##
## Money: decorations cost their price once when bought; machines are the
## catalog ware named in `unlock_ware`. Removing never refunds and never
## loses anything: the piece goes to storage and can be placed again for free.
##
## Placed scenes may implement (duck typing):
##   apply_placed_state(state: Dictionary), get_placed_state() -> Dictionary,
##   on_relocated(old: Transform3D, new: Transform3D),
##   get_removal_problem() -> String  (localization key; "" = can be removed)

signal object_placed(uid: String, node: Node3D)
signal object_moved(uid: String, node: Node3D)
signal object_removed(uid: String)
signal changed

## Buildable area in world X/Z (inside the fence with a margin).
@export var buildable_area: Rect2 = Rect2(0.5, -35.5, 47.0, 35.0)
@export var catalog: PlaceableCatalog

var validator := PlacementValidator.new()
var _upgrades: UpgradeProgress
var _wallet: Wallet
var _story: StoryState
## uid -> {"uid", "def", "anchor": Vector2i, "rot": int, "node": Node3D}
var _entries: Dictionary = {}
## placeable id -> pieces in storage (decorations).
var _stored: Dictionary = {}
## placeable id -> saved state of a stored machine.
var _stored_states: Dictionary = {}
var _counter: int = 0
## Static "keep free" cells from the scene: cell -> reason.
var _static_protected: Dictionary = {}
## Extra dynamic protected cells (loose scrap), refreshed before each check.
var protected_provider: Callable
## Cells covered by walkable path tiles (cached).
var _path_cells: Dictionary = {}
## Walkable grid for helpers; rebuilt after every layout change.
var navigation: YardNavigation
## Places that must stay reachable from `access_origin`:
## `func() -> Array` of {"position": Vector3, "name": String key, "uid": String owner or ""}.
var access_provider: Callable
var access_origin: Vector3 = Vector3.ZERO
## Cells blocked by things PlacedObjects does not manage (fences, gate posts).
var _static_solid: Dictionary = {}
const PATH_SPEED_FACTOR := 1.25


## Speed factor for someone standing on this cell (gravel paths are faster).
func get_ground_factor(position: Vector3) -> float:
	return PATH_SPEED_FACTOR if _path_cells.has(BuildGrid.world_to_cell(position)) else 1.0


## All placed nodes of one placeable.
func get_nodes_of(placeable_id: String) -> Array[Node3D]:
	var nodes: Array[Node3D] = []
	for uid: String in _entries:
		if (_entries[uid]["def"] as PlaceableDefinition).id == placeable_id:
			nodes.append(_entries[uid]["node"])
	return nodes


func _rebuild_path_cells() -> void:
	_path_cells.clear()
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		var definition: PlaceableDefinition = entry["def"]
		if definition.category == PlaceableDefinition.CATEGORY_PATHS and not definition.solid:
			for cell: Vector2i in BuildGrid.footprint_cells(definition, entry["anchor"], entry["rot"]):
				_path_cells[cell] = true


func _ready() -> void:
	changed.connect(_rebuild_path_cells)
	changed.connect(_update_navigation)
	validator.plot = Rect2i(BuildGrid.world_to_cell(Vector3(buildable_area.position.x, 0, buildable_area.position.y)),
		Vector2i(roundi(buildable_area.size.x / BuildGrid.CELL), roundi(buildable_area.size.y / BuildGrid.CELL)))
	validator.static_blocked = _static_blocked
	navigation = YardNavigation.new(validator.plot)


func setup(upgrades: UpgradeProgress, wallet: Wallet, story: StoryState = null) -> void:
	_upgrades = upgrades
	_wallet = wallet
	_story = story


## Cells that must stay free for the yard to keep working: cell -> reason;
## `owners`: cell -> uid of the object they belong to.
func set_static_protected(cells: Dictionary, owners: Dictionary = {}) -> void:
	_static_protected = cells
	validator.protected_owner = owners


# --- Queries ------------------------------------------------------------------

func get_entries() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for uid: String in _entries:
		list.append(_entries[uid])
	return list


func get_node_for(uid: String) -> Node3D:
	return _entries[uid]["node"] if _entries.has(uid) else null


func get_uid_at(cell: Vector2i) -> String:
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		if BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"]).has(cell):
			return uid
	return ""


func count_placed(placeable_id: String) -> int:
	var count: int = 0
	for uid: String in _entries:
		if (_entries[uid]["def"] as PlaceableDefinition).id == placeable_id:
			count += 1
	return count


## Pieces that can be placed without paying (storage, or an owned machine).
func get_available(definition: PlaceableDefinition) -> int:
	if not definition.unlock_ware.is_empty():
		var owned: int = 1 if _upgrades != null and _upgrades.is_owned(definition.unlock_ware) else 0
		return maxi(owned - count_placed(definition.id), 0)
	return int(_stored.get(definition.id, 0))


## "available", "buy", "too_expensive", "locked", "limit" for the build menu.
func get_offer_status(definition: PlaceableDefinition) -> String:
	if not definition.requires_flag.is_empty() and not _has_flag(definition.requires_flag):
		return "locked"
	if definition.max_count > 0 and count_placed(definition.id) >= definition.max_count:
		return "limit"
	if get_available(definition) > 0:
		return "available"
	return "buy" if _wallet != null and _wallet.can_afford(get_price(definition)) else "too_expensive"


func get_price(definition: PlaceableDefinition) -> int:
	if not definition.unlock_ware.is_empty() and _upgrades != null:
		var ware: UpgradeDefinition = _upgrades.get_catalog().get_definition(definition.unlock_ware)
		return ware.price if ware != null else definition.price
	return definition.price


## Full check of a placement (see PlacementValidator).
func check_placement(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int,
		ignore_uid: String = "") -> Dictionary:
	_refresh_validator(ignore_uid)
	var result: Dictionary = validator.check(definition, anchor, rotation_steps, ignore_uid)
	if result["ok"] and definition.solid:
		var blocked: Dictionary = _first_cut_off(result["footprint"], ignore_uid)
		if not blocked.is_empty():
			result["ok"] = false
			(result["problems"] as Array).append({"key": "blocks_access", "cells": result["footprint"],
				"args": {"name": TranslationServer.translate(str(blocked["name"]))}})
	return result


## The first important place the footprint would cut off, or {}.
func _first_cut_off(footprint: Array[Vector2i], ignore_uid: String) -> Dictionary:
	if navigation == null or not navigation.is_ready() or not access_provider.is_valid():
		return {}
	var freed: Array[Vector2i] = []
	if not ignore_uid.is_empty() and _entries.has(ignore_uid):
		var entry: Dictionary = _entries[ignore_uid]
		freed = BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"])
	for target: Dictionary in access_provider.call():
		if str(target.get("uid", "")) == ignore_uid and not ignore_uid.is_empty():
			continue
		var cell: Vector2i = BuildGrid.world_to_cell(target["position"])
		if footprint.has(cell):
			return target
		if not navigation.is_reachable(access_origin, target["position"], footprint, freed):
			return target
	return {}


# --- Actions (each returns {"ok", "message_key", "uid"}) ----------------------------

## Places a piece: from storage if available, otherwise buys it.
func place(placeable_id: String, anchor: Vector2i, rotation_steps: int, uid: String = "") -> Dictionary:
	var definition: PlaceableDefinition = catalog.get_definition(placeable_id)
	if definition == null:
		return _result(false, "build.failed")
	var status: String = get_offer_status(definition)
	if status in ["locked", "limit", "too_expensive"]:
		return _result(false, "build.status." + status)
	var check: Dictionary = check_placement(definition, anchor, rotation_steps)
	if not check["ok"]:
		return _result(false, "build.problem." + str(check["problems"][0]["key"]))
	var paid: int = 0
	if status == "buy":
		if not definition.unlock_ware.is_empty():
			if _upgrades.purchase(definition.unlock_ware, _wallet) != UpgradeProgress.PurchaseResult.OK:
				return _result(false, "build.status.too_expensive")
		else:
			if _wallet.debit(definition.price, _wallet.next_transaction_id("build"), "ui.ledger.build") \
					!= Wallet.Result.OK:
				return _result(false, "build.status.too_expensive")
		paid = get_price(definition)
	elif definition.unlock_ware.is_empty():
		_stored[definition.id] = int(_stored[definition.id]) - 1
		if int(_stored[definition.id]) <= 0:
			_stored.erase(definition.id)
	if uid.is_empty():
		_counter += 1
		uid = "placed_%d" % _counter
	var state: Dictionary = _stored_states.get(definition.id, {})
	_stored_states.erase(definition.id)
	_spawn(uid, definition, anchor, rotation_steps, state)
	changed.emit()
	var result: Dictionary = _result(true, "build.placed_bought" if paid > 0 else "build.placed",
		{"name": TranslationServer.translate(definition.name_key), "price": paid})
	result["uid"] = uid
	result["paid"] = paid
	return result


func move(uid: String, anchor: Vector2i, rotation_steps: int) -> Dictionary:
	if not _entries.has(uid):
		return _result(false, "build.failed")
	var entry: Dictionary = _entries[uid]
	var definition: PlaceableDefinition = entry["def"]
	var check: Dictionary = check_placement(definition, anchor, rotation_steps, uid)
	if not check["ok"]:
		return _result(false, "build.problem." + str(check["problems"][0]["key"]))
	var node: Node3D = entry["node"]
	var old_transform: Transform3D = node.global_transform
	entry["anchor"] = anchor
	entry["rot"] = posmod(rotation_steps, 4)
	entry["moved"] = true
	_apply_transform(node, definition, anchor, entry["rot"], entry.get("offset", Vector3.ZERO))
	var mover: Object = hook(node, "on_relocated")
	if mover != null:
		mover.on_relocated(old_transform, node.global_transform)
	object_moved.emit(uid, node)
	changed.emit()
	var result: Dictionary = _result(true, "build.moved", {"name": TranslationServer.translate(definition.name_key)})
	result["uid"] = uid
	return result


## Puts a placed piece back into storage.
func remove(uid: String) -> Dictionary:
	if not _entries.has(uid):
		return _result(false, "build.failed")
	var entry: Dictionary = _entries[uid]
	var definition: PlaceableDefinition = entry["def"]
	var node: Node3D = entry["node"]
	if entry.get("adopted", false):
		return _result(false, "build.problem.yard_fixture")
	var guard: Object = hook(node, "get_removal_problem")
	if guard != null:
		var problem: String = guard.get_removal_problem()
		if not problem.is_empty():
			return _result(false, problem)
	var stateful: Object = hook(node, "get_placed_state")
	if stateful != null:
		_stored_states[definition.id] = stateful.get_placed_state()
	if definition.unlock_ware.is_empty():
		_stored[definition.id] = int(_stored.get(definition.id, 0)) + 1
	_entries.erase(uid)
	object_removed.emit(uid)
	node.queue_free()
	changed.emit()
	var result: Dictionary = _result(true, "build.removed", {"name": TranslationServer.translate(definition.name_key)})
	result["uid"] = uid
	return result


# --- Save ---------------------------------------------------------------------------

func get_save_state() -> Dictionary:
	var objects: Array = []
	var yard: Dictionary = {}
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		if entry.get("adopted", false):
			if entry.get("moved", false):
				yard[uid] = {"cell": [entry["anchor"].x, entry["anchor"].y], "rot": entry["rot"]}
			continue
		var saved: Dictionary = {"uid": uid, "def": (entry["def"] as PlaceableDefinition).id,
			"cell": [entry["anchor"].x, entry["anchor"].y], "rot": entry["rot"]}
		var stateful: Object = hook(entry["node"], "get_placed_state")
		if stateful != null:
			saved["state"] = stateful.get_placed_state()
		objects.append(saved)
	return {"counter": _counter, "objects": objects, "stored": _stored.duplicate(),
		"stored_states": _stored_states.duplicate(true), "yard": yard}


## Recreates placed objects. Unknown definitions are skipped and reported.
func apply_save_state(state: Dictionary) -> PackedStringArray:
	var notes: PackedStringArray = []
	_counter = int(state.get("counter", 0))
	var stored: Variant = state.get("stored", {})
	if typeof(stored) == TYPE_DICTIONARY:
		for key: Variant in stored:
			if catalog.get_definition(str(key)) != null and int(stored[key]) > 0:
				_stored[str(key)] = int(stored[key])
	var stored_states: Variant = state.get("stored_states", {})
	if typeof(stored_states) == TYPE_DICTIONARY:
		_stored_states = (stored_states as Dictionary).duplicate(true)
	for saved: Variant in state.get("objects", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var definition: PlaceableDefinition = catalog.get_definition(str(saved.get("def", "")))
		var cell: Variant = saved.get("cell", [])
		if definition == null or typeof(cell) != TYPE_ARRAY or cell.size() != 2:
			notes.append("placed object '%s' ignored" % saved.get("uid", "?"))
			continue
		var uid: String = str(saved.get("uid", ""))
		if uid.is_empty() or _entries.has(uid):
			_counter += 1
			uid = "placed_%d" % _counter
		var saved_state: Variant = saved.get("state", {})
		_spawn(uid, definition, Vector2i(int(cell[0]), int(cell[1])), int(saved.get("rot", 0)),
			saved_state if typeof(saved_state) == TYPE_DICTIONARY else {})
	changed.emit()
	return notes


# --- The existing yard (adopted fixtures) -------------------------------------------

## Takes over an object that was built into the yard scene, so it can be moved
## like a placed one (not removed). Its footprint comes from its collision
## boxes unless `size` is given. Returns the uid.
func adopt(node: Node3D, uid: String, name_key: String, solid: bool = true, size: Vector2i = Vector2i.ZERO,
		height: float = 1.5) -> String:
	var bounds: Rect2 = _local_footprint(node)
	var definition := PlaceableDefinition.new()
	definition.id = uid
	definition.name_key = name_key
	definition.description_key = "build.yard_fixture"
	definition.category = "yard"
	definition.solid = solid
	definition.height = height
	if size == Vector2i.ZERO:
		size = Vector2i(maxi(1, ceili(bounds.size.x / BuildGrid.CELL - 0.15)), maxi(1, ceili(bounds.size.y / BuildGrid.CELL - 0.15)))
		definition.size = size
	else:
		definition.size = size
		bounds = Rect2(-Vector2(size) * BuildGrid.CELL * 0.5, Vector2(size) * BuildGrid.CELL)
	var rot: int = posmod(roundi(-node.global_rotation.y / (PI * 0.5)), 4)
	var local_center := Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
	var world_center: Vector3 = node.global_transform * local_center
	var anchor: Vector2i = BuildGrid.anchor_for(definition, world_center, rot)
	_entries[uid] = {"uid": uid, "def": definition, "anchor": anchor, "rot": rot, "node": node, "adopted": true,
		"offset": -local_center, "moved": false}
	return uid


## Applies saved moves of adopted fixtures (call after adopting them all).
func apply_yard_state(yard: Dictionary) -> PackedStringArray:
	var notes: PackedStringArray = []
	for uid: Variant in yard:
		var saved: Variant = yard[uid]
		if not _entries.has(str(uid)) or typeof(saved) != TYPE_DICTIONARY:
			notes.append("yard fixture '%s' unknown" % uid)
			continue
		var cell: Variant = saved.get("cell", [])
		if typeof(cell) != TYPE_ARRAY or cell.size() != 2:
			continue
		var entry: Dictionary = _entries[str(uid)]
		var node: Node3D = entry["node"]
		var old_transform: Transform3D = node.global_transform
		entry["anchor"] = Vector2i(int(cell[0]), int(cell[1]))
		entry["rot"] = posmod(int(saved.get("rot", 0)), 4)
		entry["moved"] = true
		_apply_transform(node, entry["def"], entry["anchor"], entry["rot"], entry["offset"])
		var mover: Object = hook(node, "on_relocated")
		if mover != null:
			mover.on_relocated(old_transform, node.global_transform)
	changed.emit()
	return notes


func is_adopted(uid: String) -> bool:
	return _entries.has(uid) and _entries[uid].get("adopted", false)


## Scans the static yard once (everything not managed here) and builds the
## walkable grid. Call after adopting and restoring, and when build mode closes.
func rebuild_navigation() -> void:
	_static_solid.clear()
	var all_cells: Array[Vector2i] = []
	for x: int in range(validator.plot.position.x, validator.plot.end.x):
		for y: int in range(validator.plot.position.y, validator.plot.end.y):
			all_cells.append(Vector2i(x, y))
	for cell: Vector2i in _static_blocked(all_cells):
		_static_solid[cell] = true
	_update_navigation()


func _update_navigation() -> void:
	if navigation == null:
		return
	var footprints: Dictionary = {}
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		if (entry["def"] as PlaceableDefinition).solid:
			for cell: Vector2i in BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"]):
				footprints[cell] = uid
	navigation.rebuild(_static_solid, footprints)


## XZ bounds (node-local) of the node's collision boxes, ignoring scrap items.
func _local_footprint(node: Node3D) -> Rect2:
	var bounds := Rect2()
	var first: bool = true
	var inverse: Transform3D = node.global_transform.affine_inverse()
	for shape_node: Node in node.find_children("*", "CollisionShape3D", true, false):
		var collision := shape_node as CollisionShape3D
		if collision.shape is not BoxShape3D or _inside_scrap_item(collision, node):
			continue
		var extents: Vector3 = (collision.shape as BoxShape3D).size * 0.5
		for corner: Vector3 in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
			var local: Vector3 = inverse * (collision.global_transform * (corner * extents))
			var point := Vector2(local.x, local.z)
			if first:
				bounds = Rect2(point, Vector2.ZERO)
				first = false
			else:
				bounds = bounds.expand(point)
	if first:
		bounds = Rect2(-0.5, -0.5, 1.0, 1.0)
	return bounds


static func _inside_scrap_item(node: Node, root: Node) -> bool:
	var current: Node = node.get_parent()
	while current != null and current != root:
		if current is ScrapItem:
			return true
		current = current.get_parent()
	return false


# --- Helpers ------------------------------------------------------------------

func _spawn(uid: String, definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int,
		state: Dictionary) -> Node3D:
	var node: Node3D = definition.scene.instantiate()
	node.name = uid
	add_child(node)
	var rot: int = posmod(rotation_steps, 4)
	_apply_transform(node, definition, anchor, rot)
	if definition.solid and _find_body(node) == null:
		_add_footprint_body(node, definition)
	_entries[uid] = {"uid": uid, "def": definition, "anchor": anchor, "rot": rot, "node": node}
	object_placed.emit(uid, node)
	var stateful: Object = hook(node, "apply_placed_state")
	if stateful != null:
		stateful.apply_placed_state(state)
	return node


## The node implementing a placement hook: the placed root or its first
## descendant that has the method (e.g. the storage interactable).
static func hook(node: Node, method: String) -> Object:
	if node.has_method(method):
		return node
	for child: Node in node.find_children("*", "", true, false):
		if child.has_method(method):
			return child
	return null


func _apply_transform(node: Node3D, definition: PlaceableDefinition, anchor: Vector2i, rot: int,
		offset: Vector3 = Vector3.ZERO) -> void:
	var position: Vector3 = BuildGrid.object_center(definition, anchor, rot)
	node.global_rotation = Vector3(0, BuildGrid.rotation_y(rot), 0)
	if node.has_method("get_scene_offset"):
		offset = node.get_scene_offset()
	node.global_position = Vector3(position.x, node.global_position.y, position.z) + node.global_basis * offset


func _add_footprint_body(node: Node3D, definition: PlaceableDefinition) -> void:
	var body := StaticBody3D.new()
	body.name = "FootprintBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(definition.size.x * BuildGrid.CELL - 0.06, definition.height, definition.size.y * BuildGrid.CELL - 0.06)
	shape.shape = box
	shape.position = Vector3(0, definition.height * 0.5, 0)
	body.add_child(shape)
	node.add_child(body)


func _find_body(node: Node) -> CollisionObject3D:
	for child: Node in node.find_children("*", "StaticBody3D", true, false):
		if (child as CollisionObject3D).collision_layer & 1:
			return child
	return null


func _refresh_validator(ignore_uid: String) -> void:
	var occupied: Dictionary = {}
	var reserved: Dictionary = {}
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		for cell: Vector2i in BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"]):
			occupied[cell] = uid
		for cell: Vector2i in BuildGrid.clearance_cells(entry["def"], entry["anchor"], entry["rot"]):
			reserved[cell] = uid
	validator.occupied = occupied
	validator.reserved = reserved
	var protected: Dictionary = _static_protected.duplicate()
	if protected_provider.is_valid():
		var extra: Dictionary = protected_provider.call()
		protected.merge(extra, true)
	validator.protected = protected


## Static yard obstacles under the given cells (placed objects excluded: the
## registry handles them, and a moved object must not collide with itself).
func _static_blocked(cells: Array[Vector2i]) -> Array[Vector2i]:
	var blocked: Array[Vector2i] = []
	if not is_inside_tree():
		return blocked
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var exclude: Array[RID] = []
	for uid: String in _entries:
		for body: Node in (_entries[uid]["node"] as Node).find_children("*", "CollisionObject3D", true, false):
			exclude.append((body as CollisionObject3D).get_rid())
	var box := BoxShape3D.new()
	box.size = Vector3(BuildGrid.CELL * 0.8, 1.0, BuildGrid.CELL * 0.8)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	query.collision_mask = 1
	query.exclude = exclude
	for cell: Vector2i in cells:
		query.transform = Transform3D(Basis.IDENTITY, BuildGrid.cell_center(cell) + Vector3(0, 0.65, 0))
		if not space.intersect_shape(query, 1).is_empty():
			blocked.append(cell)
	return blocked


func _has_flag(flag: String) -> bool:
	return _story != null and _story.has_flag(flag)


static func _result(ok: bool, key: String, args: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "message_key": key, "message_args": args, "uid": ""}
