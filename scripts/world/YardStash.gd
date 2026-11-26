class_name YardStash
extends Interactable
## Interaction body on a yard fixture that can be searched repeatedly (block
## 4, docs/yard-stashes.md). Created at runtime by YardStashes as a child of
## the fixture, so it moves along in build mode. It only reports; charges,
## refill and the found items belong to YardStashes.

## How close to the fixture's surface the interaction point sits.
const SURFACE_OFFSET: float = 0.35

var definition: StashDefinition
var stashes: YardStashes
## Player whose position decides the nearest point on the fixture.
var player: Node3D

## [global transform, half extents] of the fixture's collision boxes.
var _boxes: Array = []


## Copies the fixture's collision boxes as interaction shapes.
func build_shapes(fixture: Node3D) -> void:
	for node: Node in fixture.find_children("*", "CollisionShape3D", true, false):
		var source := node as CollisionShape3D
		if source.shape == null or source.get_parent() == self:
			continue
		var shape := CollisionShape3D.new()
		shape.shape = source.shape
		add_child(shape)
		shape.global_transform = source.global_transform
	_refresh_boxes()


func get_interaction_point() -> Vector3:
	if player == null or _boxes.is_empty():
		return global_position
	_refresh_boxes()
	var best: Vector3 = global_position
	var best_distance: float = INF
	var from: Vector3 = player.global_position
	for box: Array in _boxes:
		var xform: Transform3D = box[0]
		var half: Vector3 = box[1]
		var local: Vector3 = xform.affine_inverse() * from
		var grown: Vector3 = half + Vector3(SURFACE_OFFSET, 0.0, SURFACE_OFFSET)
		var clamped := Vector3(clampf(local.x, -grown.x, grown.x), clampf(local.y, -half.y, half.y),
			clampf(local.z, -grown.z, grown.z))
		var point: Vector3 = xform * clamped
		point.y = global_position.y
		var distance: float = point.distance_squared_to(Vector3(from.x, point.y, from.z))
		if distance < best_distance:
			best_distance = distance
			best = point
	return best


func get_display_name() -> String:
	return tr(definition.name_key) if definition != null else super()


func get_action_key() -> String:
	return definition.action_key if definition != null else super()


func get_hold_duration() -> float:
	return definition.search_seconds if definition != null else 1.0


func get_prompt_detail(context: InteractionContext) -> String:
	if not _has_tool(context):
		return tr("ui.search.needs_tool").format({"tool": tr(UpgradeProgress.tool_name_key(definition.required_tool))})
	var charges: int = stashes.get_charges(definition.id)
	if charges <= 0:
		return tr("ui.stash.detail.empty").format({"minutes": _minutes_left()})
	return tr("ui.stash.detail.charges").format({"count": charges})


func check_requirements(context: InteractionContext) -> Dictionary:
	if not _has_tool(context):
		return {"ok": false, "message_key": "ui.search.missing_tool." + definition.required_tool,
			"message_args": {"name": get_display_name()}}
	if stashes.get_charges(definition.id) <= 0:
		return {"ok": false, "message_key": definition.empty_key,
			"message_args": {"name": get_display_name(), "minutes": _minutes_left()}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	var requirements: Dictionary = check_requirements(context)
	if not requirements["ok"]:
		return make_result(false, requirements["message_key"], requirements["message_args"])
	var found: Array[ScrapItem] = stashes.search(definition.id, get_interaction_point())
	var key: String = stashes.pick_result_key(definition)
	return make_result(true, key, {"count": found.size(), "name": get_display_name()})


func _minutes_left() -> int:
	return maxi(1, ceili(stashes.get_seconds_until_refill(definition.id) / 60.0))


func _has_tool(context: InteractionContext) -> bool:
	return definition == null or definition.required_tool.is_empty() or (context != null
		and context.upgrades != null and context.upgrades.has_tool(definition.required_tool))


func _refresh_boxes() -> void:
	_boxes.clear()
	for child: Node in get_children():
		var shape := child as CollisionShape3D
		if shape == null or not shape.shape is BoxShape3D:
			continue
		_boxes.append([shape.global_transform, (shape.shape as BoxShape3D).size * 0.5])
