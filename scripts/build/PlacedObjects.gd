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


func _ready() -> void:
	validator.plot = Rect2i(BuildGrid.world_to_cell(Vector3(buildable_area.position.x, 0, buildable_area.position.y)),
		Vector2i(roundi(buildable_area.size.x / BuildGrid.CELL), roundi(buildable_area.size.y / BuildGrid.CELL)))
	validator.static_blocked = _static_blocked


func setup(upgrades: UpgradeProgress, wallet: Wallet, story: StoryState = null) -> void:
	_upgrades = upgrades
	_wallet = wallet
	_story = story


## Cells that must stay free for the yard to keep working: cell -> reason.
func set_static_protected(cells: Dictionary) -> void:
	_static_protected = cells


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
	return validator.check(definition, anchor, rotation_steps, ignore_uid)


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
	_apply_transform(node, definition, anchor, entry["rot"])
	if node.has_method("on_relocated"):
		node.on_relocated(old_transform, node.global_transform)
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
	if node.has_method("get_removal_problem"):
		var problem: String = node.get_removal_problem()
		if not problem.is_empty():
			return _result(false, problem)
	if node.has_method("get_placed_state"):
		_stored_states[definition.id] = node.get_placed_state()
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
	for uid: String in _entries:
		var entry: Dictionary = _entries[uid]
		var saved: Dictionary = {"uid": uid, "def": (entry["def"] as PlaceableDefinition).id,
			"cell": [entry["anchor"].x, entry["anchor"].y], "rot": entry["rot"]}
		var node: Node3D = entry["node"]
		if node.has_method("get_placed_state"):
			saved["state"] = node.get_placed_state()
		objects.append(saved)
	return {"counter": _counter, "objects": objects, "stored": _stored.duplicate(),
		"stored_states": _stored_states.duplicate(true)}


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
	if node.has_method("apply_placed_state"):
		node.apply_placed_state(state)
	return node


func _apply_transform(node: Node3D, definition: PlaceableDefinition, anchor: Vector2i, rot: int) -> void:
	node.global_position = BuildGrid.object_center(definition, anchor, rot)
	node.rotation = Vector3(0, BuildGrid.rotation_y(rot), 0)
	if node.has_method("get_scene_offset"):
		node.global_position += node.global_basis * node.get_scene_offset()


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
