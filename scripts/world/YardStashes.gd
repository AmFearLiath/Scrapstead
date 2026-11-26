class_name YardStashes
extends Node3D
## Searchable yard fixtures (block 4, docs/yard-stashes.md). Scene-local like
## ScrapDeliveries: it puts a YardStash interaction body on each fixture of
## its table, counts charges and their slow refill in play time, spawns the
## found pieces as real ScrapItems and frees them again once they are sold.
## Nothing refills while the game is closed.

## A found piece became part of the world (also when restored from a save).
signal item_spawned(item: ScrapItem)
## A found piece left the world for good (sold or consumed).
signal item_removed(object_id: String)
## A stash was searched; `items` are the pieces that turned up.
signal searched(stash_id: String, items: Array)

const OBJECT_PREFIX := "stash_"

@export var table: StashTable
@export var item_catalog: ItemCatalog
@export var item_scene: PackedScene

## stash id -> {"charges": int, "timer": float}
var _state: Dictionary = {}
## stash id -> YardStash
var _bodies: Dictionary = {}
var _counter: int = 0
var _searches: int = 0
## Live found pieces: {"id", "item", "node"}.
var _live: Array[Dictionary] = []


## Creates the interaction bodies on the fixtures below `scene_root`.
func setup(scene_root: Node, player: Node3D) -> void:
	if table == null:
		return
	for definition: StashDefinition in table.stashes:
		for problem: String in definition.validate(item_catalog):
			push_error("YardStashes: " + problem)
		var fixture: Node3D = scene_root.get_node_or_null(definition.fixture_path) as Node3D
		if fixture == null:
			push_warning("YardStashes: fixture '%s' not found." % definition.fixture_path)
			continue
		var body := YardStash.new()
		body.name = "Stash"
		body.object_id = OBJECT_PREFIX + definition.id
		body.name_key = definition.name_key
		body.definition = definition
		body.stashes = self
		body.player = player
		body.collision_layer = 4
		body.collision_mask = 0
		body.highlight_radius = 0.7
		fixture.add_child(body)
		body.build_shapes(fixture)
		_bodies[definition.id] = body
		if not _state.has(definition.id):
			_state[definition.id] = {"charges": definition.capacity, "timer": 0.0}


func get_body(stash_id: String) -> YardStash:
	return _bodies.get(stash_id) as YardStash


func get_charges(stash_id: String) -> int:
	return int(_state.get(stash_id, {}).get("charges", 0))


## Play seconds until the next charge comes back (0 when full).
func get_seconds_until_refill(stash_id: String) -> float:
	var definition: StashDefinition = table.get_definition(stash_id) if table != null else null
	if definition == null or get_charges(stash_id) >= definition.capacity:
		return 0.0
	return maxf(definition.refill_seconds - float(_state[stash_id]["timer"]), 0.0)


func get_live_items() -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for entry: Dictionary in _live:
		if is_instance_valid(entry["node"]):
			items.append(entry["node"])
	return items


func _process(delta: float) -> void:
	advance(delta)


## Counts play time for the refill (also used by tests).
func advance(seconds: float) -> void:
	if table == null:
		return
	for definition: StashDefinition in table.stashes:
		var entry: Dictionary = _state.get(definition.id, {})
		if entry.is_empty() or int(entry["charges"]) >= definition.capacity:
			continue
		entry["timer"] = float(entry["timer"]) + seconds
		while float(entry["timer"]) >= definition.refill_seconds and int(entry["charges"]) < definition.capacity:
			entry["timer"] = float(entry["timer"]) - definition.refill_seconds
			entry["charges"] = int(entry["charges"]) + 1
		if int(entry["charges"]) >= definition.capacity:
			entry["timer"] = 0.0


## Uses one charge and spawns the found pieces around `at`.
func search(stash_id: String, at: Vector3) -> Array[ScrapItem]:
	var found: Array[ScrapItem] = []
	var definition: StashDefinition = table.get_definition(stash_id) if table != null else null
	if definition == null or get_charges(stash_id) <= 0:
		return found
	_state[stash_id]["charges"] = get_charges(stash_id) - 1
	_searches += 1
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s:%d" % [stash_id, _searches])
	var count: int = rng.randi_range(definition.min_items, definition.max_items)
	var body: YardStash = get_body(stash_id)
	var centre: Vector3 = body.global_position if body != null else at
	var outward: Vector3 = Vector3(at.x - centre.x, 0.0, at.z - centre.z)
	outward = outward.normalized() if outward.length() > 0.01 else Vector3.BACK
	var side: Vector3 = outward.cross(Vector3.UP)
	for index: int in count:
		_counter += 1
		var item: ScrapItem = _spawn("%s%d" % [OBJECT_PREFIX, _counter], definition.roll_item(rng))
		if item == null:
			continue
		var spread: float = (float(index) - float(count - 1) * 0.5) * 0.45
		var position_value: Vector3 = at + outward * (0.25 + rng.randf() * 0.2) + side * spread
		position_value.y = at.y
		item.global_position = position_value
		_live[-1]["pos"] = _pack(position_value)
		item.reveal()
		found.append(item)
	searched.emit(stash_id, found)
	return found


func pick_result_key(definition: StashDefinition) -> String:
	if definition.result_keys.is_empty():
		return "ui.stash.result.generic"
	return definition.result_keys[_searches % definition.result_keys.size()]


func get_save_state() -> Dictionary:
	var stashes: Dictionary = {}
	for stash_id: String in _state:
		stashes[stash_id] = {"charges": _state[stash_id]["charges"],
			"timer": snappedf(float(_state[stash_id]["timer"]), 0.01)}
	var items: Array = []
	for entry: Dictionary in _live:
		var node: ScrapItem = entry["node"]
		if is_instance_valid(node):
			entry["pos"] = _pack(node.global_position)
		items.append({"id": entry["id"], "item": entry["item"], "pos": entry.get("pos", [])})
	return {"stashes": stashes, "counter": _counter, "searches": _searches, "items": items}


## Restores charges and recreates found pieces. Call before setup() is not
## required; call before the world object states are applied.
func apply_save_state(state: Dictionary) -> void:
	_counter = int(state.get("counter", 0))
	_searches = int(state.get("searches", 0))
	var saved_stashes: Variant = state.get("stashes", {})
	if typeof(saved_stashes) == TYPE_DICTIONARY and table != null:
		for stash_id: Variant in saved_stashes:
			var definition: StashDefinition = table.get_definition(str(stash_id))
			var saved: Variant = saved_stashes[stash_id]
			if definition == null or typeof(saved) != TYPE_DICTIONARY:
				continue
			_state[definition.id] = {"charges": clampi(int(saved.get("charges", definition.capacity)), 0,
				definition.capacity), "timer": maxf(float(saved.get("timer", 0.0)), 0.0)}
	for saved: Variant in state.get("items", []):
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var object_id: String = str(saved.get("id", ""))
		if not object_id.begins_with(OBJECT_PREFIX):
			continue
		var item: ScrapItem = _spawn(object_id, str(saved.get("item", "")))
		var saved_position: Variant = saved.get("pos")
		if item != null and typeof(saved_position) == TYPE_ARRAY and saved_position.size() == 3:
			item.global_position = Vector3(float(saved_position[0]), float(saved_position[1]), float(saved_position[2]))
			_live[-1]["pos"] = saved_position


func _spawn(object_id: String, item_id: String) -> ScrapItem:
	var definition: ItemDefinition = item_catalog.get_definition(item_id) if item_catalog != null else null
	if definition == null or item_scene == null:
		push_warning("YardStashes: unknown item '%s'." % item_id)
		return null
	var item: ScrapItem = item_scene.instantiate()
	item.definition = definition
	item.object_id = object_id
	item.name = object_id
	add_child(item)
	item.rotation.y = fposmod(float(absi(object_id.hash()) % 1000) * 0.7, TAU)
	_live.append({"id": object_id, "item": item_id, "node": item})
	item.interaction_state_changed.connect(_on_item_state_changed)
	item_spawned.emit(item)
	return item


func _on_item_state_changed(target: Interactable) -> void:
	var item: ScrapItem = target as ScrapItem
	if item == null:
		return
	var state: ScrapItem.State = item.get_state()
	if state != ScrapItem.State.SOLD and state != ScrapItem.State.PROCESSED:
		return
	for index: int in _live.size():
		if _live[index]["node"] == item:
			_live.remove_at(index)
			break
	item_removed.emit(item.object_id)
	item.queue_free()


func _pack(value: Vector3) -> Array:
	return [snappedf(value.x, 0.001), snappedf(value.y, 0.001), snappedf(value.z, 0.001)]
