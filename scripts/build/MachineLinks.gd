class_name MachineLinks
extends Node3D
## Simple machine links (docs/machine-links.md, building-and-logistics.md
## section 4): the player connects the output of one machine with the input
## of another, the game finds the conveyor route on the build grid by itself.
##
## Rules
## - A machine with an "out" port feeds at most one link; a machine with an
##   "in" port is fed by at most one link.
## - The route starts next to the output port and ends next to the input
##   port, avoids everything built or standing in the yard and other belts.
##   Belts are low and walkable: they may cross walkways and operator areas
##   (at a higher cost), but nothing can be built on them.
## - When a machine moves, its links are routed again. If no route exists any
##   more, the link stays but is "blocked" until the layout allows it again.
## - Transport is decided logically when a piece leaves the source: the target
##   takes it at once (hopper count), the piece riding the belt is only its
##   picture. So saving never has to know about pieces in transit.
##
## Machines take part through duck-typed hooks: sources implement
## get_output_items(channel); targets can_accept(item_id) and accept_item(item).
## A machine may have several outputs ("channels", e.g. the sorting machine's
## steel, copper and wood chutes); every channel feeds its own link.

signal changed
## A link was created (by the player or when loading).
signal linked(link_id: int)
## A link could no longer be routed (or works again).
signal link_blocked(link_id: int, blocked: bool)
## A piece left a source towards a target (presentation).
signal piece_sent(link_id: int, item_id: String)

const BELT_SPEED := 1.4
const SEND_INTERVAL := 2.0
## The last hop from the belt end into the hopper.
const HOP_SECONDS := 0.35
const BELT_HEIGHT := 0.36
const COST_PROTECTED := 3.0
const COST_NEAR_PORT := 12.0

var placed: PlacedObjects
var straight_scene: PackedScene = preload("res://assets/models/conveyor_straight.glb")
var corner_scene: PackedScene = preload("res://assets/models/conveyor_corner.glb")

## id -> {"id", "from", "to", "cells": Array[Vector2i], "blocked": bool, "timer": float, "visual": Node3D}
var _links: Dictionary = {}
var _next_id: int = 1


func get_links() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for link_id: int in _links:
		list.append(_links[link_id])
	return list


func get_link(link_id: int) -> Dictionary:
	return _links.get(link_id, {})


func find_link(from_uid: String, to_uid: String) -> int:
	for link_id: int in _links:
		if _links[link_id]["from"] == from_uid and _links[link_id]["to"] == to_uid:
			return link_id
	return -1


## The link whose belt covers this cell, or -1.
func get_link_at(cell: Vector2i) -> int:
	for link_id: int in _links:
		if not _links[link_id]["blocked"] and (_links[link_id]["cells"] as Array).has(cell):
			return link_id
	return -1


## Cell -> link id of every belt (placement checks).
func get_belt_cells() -> Dictionary:
	var cells: Dictionary = {}
	for link_id: int in _links:
		if _links[link_id]["blocked"]:
			continue
		for cell: Vector2i in _links[link_id]["cells"]:
			cells[cell] = link_id
	return cells


func involves(link_id: int, uid: String) -> bool:
	var current: Dictionary = _links.get(link_id, {})
	return not current.is_empty() and (current["from"] == uid or current["to"] == uid)


func has_output(uid: String) -> bool:
	return not _ports(uid, "out").is_empty()


func has_input(uid: String) -> bool:
	return not _ports(uid, "in").is_empty()


## Output channels of a machine ("" for a single unnamed output).
func get_channels(uid: String) -> PackedStringArray:
	var channels: PackedStringArray = []
	for entry: Dictionary in placed.get_entries():
		if entry["uid"] != uid:
			continue
		for port: Dictionary in (entry["def"] as PlaceableDefinition).ports:
			var channel: String = str(port.get("channel", ""))
			if str(port.get("kind", "")) == "out" and not channels.has(channel):
				channels.append(channel)
	return channels


## The output channel whose port lies closest to `point` (where the player
## clicked); free channels first.
func nearest_channel(uid: String, point: Vector3) -> String:
	var best: String = ""
	var best_score: float = INF
	for channel: String in get_channels(uid):
		var used: bool = _channel_used(uid, channel, -1)
		for cell: Vector2i in _ports(uid, "out", channel):
			var score: float = BuildGrid.cell_center(cell).distance_to(Vector3(point.x, 0, point.z)) + (100.0 if used else 0.0)
			if score < best_score:
				best_score = score
				best = channel
	return best


## Checks a link without creating it: {"ok", "key", "cells", "channel"}.
## Without a channel the first free compatible one is taken.
func check_link(from_uid: String, to_uid: String, ignore_link: int = -1, channel: Variant = null) -> Dictionary:
	if from_uid == to_uid:
		return {"ok": false, "key": "link_same", "cells": [], "channel": ""}
	if not has_output(from_uid):
		return {"ok": false, "key": "link_no_output", "cells": [], "channel": ""}
	if not has_input(to_uid):
		return {"ok": false, "key": "link_no_input", "cells": [], "channel": ""}
	var channels: PackedStringArray = get_channels(from_uid) if channel == null else PackedStringArray([str(channel)])
	var key: String = "link_output_used"
	for candidate: String in channels:
		if _channel_used(from_uid, candidate, ignore_link):
			continue
		key = "link_incompatible"
		if _compatible(from_uid, to_uid, candidate):
			key = ""
			channels = PackedStringArray([candidate])
			break
	if not key.is_empty():
		return {"ok": false, "key": key, "cells": [], "channel": ""}
	for link_id: int in _links:
		if link_id != ignore_link and _links[link_id]["to"] == to_uid:
			return {"ok": false, "key": "link_input_used", "cells": [], "channel": ""}
	var cells: Array[Vector2i] = _route(from_uid, to_uid, ignore_link, channels[0])
	if cells.is_empty():
		return {"ok": false, "key": "link_no_route", "cells": [], "channel": channels[0]}
	return {"ok": true, "key": "", "cells": cells, "channel": channels[0]}


func _channel_used(uid: String, channel: String, ignore_link: int) -> bool:
	for link_id: int in _links:
		if link_id != ignore_link and _links[link_id]["from"] == uid and _links[link_id]["channel"] == channel:
			return true
	return false


## Creates a link. Returns {"ok", "message_key", "message_args", "link_id"}.
func link(from_uid: String, to_uid: String, link_id: int = -1, channel: Variant = null) -> Dictionary:
	var check: Dictionary = check_link(from_uid, to_uid, -1, channel)
	if not check["ok"]:
		return {"ok": false, "message_key": "build.problem." + str(check["key"]), "message_args": {}, "link_id": -1}
	if link_id < 0:
		link_id = _next_id
	_next_id = maxi(_next_id, link_id + 1)
	_links[link_id] = {"id": link_id, "from": from_uid, "to": to_uid, "channel": check["channel"],
		"cells": check["cells"], "blocked": false, "timer": SEND_INTERVAL, "visual": null}
	_build_visual(link_id)
	changed.emit()
	linked.emit(link_id)
	return {"ok": true, "message_key": "build.linked", "message_args": {"from": _name(from_uid), "to": _name(to_uid)},
		"link_id": link_id}


func unlink(link_id: int) -> Dictionary:
	if not _links.has(link_id):
		return {"ok": false, "message_key": "build.failed", "message_args": {}, "link_id": -1}
	var current: Dictionary = _links[link_id]
	_free_visual(current)
	_links.erase(link_id)
	changed.emit()
	return {"ok": true, "message_key": "build.unlinked", "message_args": {"from": _name(current["from"]),
		"to": _name(current["to"])}, "link_id": link_id}


## After any layout change: drop links of removed machines, route the rest
## again and mark those without a route as blocked.
func refresh() -> void:
	var dropped: Array[int] = []
	for link_id: int in _links:
		var current: Dictionary = _links[link_id]
		if placed.get_node_for(current["from"]) == null or placed.get_node_for(current["to"]) == null:
			dropped.append(link_id)
	for link_id: int in dropped:
		_free_visual(_links[link_id])
		_links.erase(link_id)
	for link_id: int in _links:
		var current: Dictionary = _links[link_id]
		var cells: Array[Vector2i] = []
		if _still_valid(current):
			cells.assign(current["cells"])
		else:
			cells = _route(current["from"], current["to"], link_id, current["channel"])
		var blocked: bool = cells.is_empty()
		var was_blocked: bool = current["blocked"]
		current["blocked"] = blocked
		if cells != Array(current["cells"]) or blocked != was_blocked:
			current["cells"] = cells if not blocked else current["cells"]
			_build_visual(link_id)
		if blocked != was_blocked:
			link_blocked.emit(link_id, blocked)
	if not dropped.is_empty():
		changed.emit()


# --- Transport -----------------------------------------------------------------------

func _process(delta: float) -> void:
	for link_id: int in _links:
		var current: Dictionary = _links[link_id]
		if current["blocked"]:
			continue
		current["timer"] = float(current["timer"]) - delta
		if float(current["timer"]) > 0.0:
			continue
		current["timer"] = SEND_INTERVAL
		send_once(link_id)


## Moves one piece over the link now. Returns the item ID or "".
func send_once(link_id: int) -> String:
	var current: Dictionary = _links.get(link_id, {})
	if current.is_empty() or current["blocked"]:
		return ""
	var source: Object = PlacedObjects.hook(placed.get_node_for(current["from"]), "get_output_items")
	var target: Object = PlacedObjects.hook(placed.get_node_for(current["to"]), "accept_item")
	if source == null or target == null:
		return ""
	for item: ScrapItem in source.get_output_items(current["channel"]):
		if not target.can_accept(item.get_item_id()):
			continue
		var start: Vector3 = item.global_position
		var item_id: String = item.get_item_id()
		var model: PackedScene = item.definition.model if item.definition != null else null
		if target.accept_item(item, _travel_seconds(current, start)):
			_animate_piece(current, start, model)
			piece_sent.emit(link_id, item_id)
			return item_id
	return ""


# --- Save ------------------------------------------------------------------------------

func get_save_state() -> Array:
	var saved: Array = []
	for link_id: int in _links:
		saved.append({"id": link_id, "from": _links[link_id]["from"], "to": _links[link_id]["to"],
			"channel": _links[link_id]["channel"]})
	return saved


## Recreates links after the placed objects exist. Returns notes for skipped ones.
func apply_save_state(saved: Array) -> PackedStringArray:
	var notes: PackedStringArray = []
	for entry: Variant in saved:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var from_uid: String = str(entry.get("from", ""))
		var to_uid: String = str(entry.get("to", ""))
		var link_id: int = int(entry.get("id", -1))
		var channel: String = str(entry.get("channel", ""))
		if placed.get_node_for(from_uid) == null or placed.get_node_for(to_uid) == null:
			notes.append("link %s -> %s dropped: machine missing" % [from_uid, to_uid])
			continue
		var result: Dictionary = link(from_uid, to_uid, link_id, channel)
		if not result["ok"]:
			# Keep it as blocked: the player sees it and can fix the layout.
			var id: int = link_id if link_id >= 0 else _next_id
			_next_id = maxi(_next_id, id + 1)
			_links[id] = {"id": id, "from": from_uid, "to": to_uid, "channel": channel, "cells": [], "blocked": true,
				"timer": SEND_INTERVAL, "visual": null}
			notes.append("link %s -> %s blocked after loading" % [from_uid, to_uid])
	return notes


# --- Routing ----------------------------------------------------------------------------

## World cells of a machine's ports of a kind.
func _ports(uid: String, kind: String, channel: Variant = null) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for entry: Dictionary in placed.get_entries():
		if entry["uid"] != uid:
			continue
		var definition: PlaceableDefinition = entry["def"]
		for port: Dictionary in definition.ports:
			if str(port.get("kind", "")) == kind and (channel == null or str(port.get("channel", "")) == str(channel)):
				cells.append_array(BuildGrid.local_rect_cells(definition, entry["anchor"], entry["rot"],
					Rect2i(port["cell"], Vector2i.ONE)))
	return cells


func _footprint(uid: String) -> Array[Vector2i]:
	for entry: Dictionary in placed.get_entries():
		if entry["uid"] == uid:
			return BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"])
	return []


## Free cells right next to a port, outside the machine's footprint.
func _port_ends(uid: String, kind: String, solid: Dictionary, channel: Variant = null) -> Array[Vector2i]:
	var footprint: Array[Vector2i] = _footprint(uid)
	var ends: Array[Vector2i] = []
	for port: Vector2i in _ports(uid, kind, channel):
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var cell: Vector2i = port + step
			if not footprint.has(cell) and not solid.has(cell) and placed.validator.plot.has_point(cell):
				ends.append(cell)
	return ends


## Cells right next to every port of every placed machine.
func _all_port_ends() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var none: Dictionary = {}
	for entry: Dictionary in placed.get_entries():
		if (entry["def"] as PlaceableDefinition).ports.is_empty():
			continue
		for kind: String in ["in", "out"]:
			cells.append_array(_port_ends(entry["uid"], kind, none))
	return cells


func _solid_cells(ignore_link: int) -> Dictionary:
	var solid: Dictionary = placed.get_static_solid().duplicate()
	for entry: Dictionary in placed.get_entries():
		for cell: Vector2i in BuildGrid.footprint_cells(entry["def"], entry["anchor"], entry["rot"]):
			solid[cell] = true
	for link_id: int in _links:
		if link_id == ignore_link or _links[link_id]["blocked"]:
			continue
		for cell: Vector2i in _links[link_id]["cells"]:
			solid[cell] = true
	return solid


func _route(from_uid: String, to_uid: String, ignore_link: int, channel: String = "") -> Array[Vector2i]:
	var solid: Dictionary = _solid_cells(ignore_link)
	var starts: Array[Vector2i] = _port_ends(from_uid, "out", solid, channel)
	var ends: Array[Vector2i] = _port_ends(to_uid, "in", solid)
	if starts.is_empty() or ends.is_empty():
		return []
	# A belt never covers the cell in front of another port: it would cut that
	# output or input off for good.
	var foreign: Array[Vector2i] = []
	for cell: Vector2i in _all_port_ends():
		if not starts.has(cell) and not ends.has(cell):
			solid[cell] = true
			foreign.append(cell)
	var region: Rect2i = placed.validator.plot
	var astar := AStarGrid2D.new()
	astar.region = region
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()
	for cell: Vector2i in solid:
		if region.has_point(cell):
			astar.set_point_solid(cell, true)
	placed.refresh_validator_for_links()
	var costly: Dictionary = placed.validator.protected.duplicate()
	costly.merge(placed.validator.reserved)
	for cell: Variant in costly:
		if region.has_point(cell) and not solid.has(cell):
			astar.set_point_weight_scale(cell, COST_PROTECTED)
	# ... and stays away from them, so it does not wall a free port in.
	for cell: Vector2i in foreign:
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var near: Vector2i = cell + step
			if region.has_point(near) and not solid.has(near):
				astar.set_point_weight_scale(near, COST_NEAR_PORT)
	var best: Array[Vector2i] = []
	for start: Vector2i in starts:
		for end: Vector2i in ends:
			var path: Array[Vector2i] = astar.get_id_path(start, end)
			if not path.is_empty() and (best.is_empty() or path.size() < best.size()):
				best = path
	return best


## Whether a link's current belt still lies free and still touches both ports.
func _still_valid(current: Dictionary) -> bool:
	var cells: Array = current["cells"]
	if cells.is_empty():
		return false
	var solid: Dictionary = _solid_cells(current["id"])
	for cell: Vector2i in cells:
		if solid.has(cell):
			return false
	return _port_ends(current["from"], "out", solid, current["channel"]).has(cells[0]) \
		and _port_ends(current["to"], "in", solid).has(cells[cells.size() - 1])


func _compatible(from_uid: String, to_uid: String, channel: String = "") -> bool:
	var source: Object = PlacedObjects.hook(placed.get_node_for(from_uid), "get_output_item_ids")
	var target: Object = PlacedObjects.hook(placed.get_node_for(to_uid), "accepts_item_type")
	if source == null or target == null:
		return false
	for item_id: String in source.get_output_item_ids(channel):
		if target.accepts_item_type(item_id):
			return true
	return false


# --- Presentation ---------------------------------------------------------------------

func _build_visual(link_id: int) -> void:
	var current: Dictionary = _links[link_id]
	_free_visual(current)
	if current["blocked"]:
		return
	var root := Node3D.new()
	root.name = "Belt%d" % link_id
	add_child(root)
	current["visual"] = root
	var cells: Array = current["cells"]
	for index: int in cells.size():
		var cell: Vector2i = cells[index]
		var into: Vector2i = cell - cells[index - 1] if index > 0 else Vector2i.ZERO
		var out: Vector2i = cells[index + 1] - cell if index < cells.size() - 1 else into
		if into == Vector2i.ZERO:
			into = out
		var corner: bool = into != out
		var piece: Node3D = (corner_scene if corner else straight_scene).instantiate()
		root.add_child(piece)
		piece.global_position = BuildGrid.cell_center(cell)
		piece.rotation.y = atan2(float(out.x), float(out.y))


func _free_visual(current: Dictionary) -> void:
	var visual: Variant = current.get("visual")
	if visual != null and is_instance_valid(visual):
		(visual as Node).queue_free()
	current["visual"] = null


## How long a piece needs from `start` over the belt into the target (the
## same timing as the picture in _animate_piece).
func _travel_seconds(current: Dictionary, start: Vector3) -> float:
	var seconds: float = 0.0
	var previous: Vector3 = start
	for cell: Vector2i in current["cells"]:
		var point: Vector3 = BuildGrid.cell_center(cell) + Vector3(0, BELT_HEIGHT, 0)
		seconds += maxf(previous.distance_to(point) / BELT_SPEED, 0.05)
		previous = point
	return seconds + HOP_SECONDS


## The picture of a piece riding the belt and hopping into the target.
func _animate_piece(current: Dictionary, start: Vector3, model: PackedScene) -> void:
	if model == null or not is_inside_tree():
		return
	var piece: Node3D = model.instantiate()
	add_child(piece)
	piece.global_position = start
	var target_node: Node3D = placed.get_node_for(current["to"])
	var port: Object = PlacedObjects.hook(target_node, "get_port_position")
	var end: Vector3 = port.get_port_position("in") if port != null else target_node.global_position
	var tween: Tween = create_tween()
	var cells: Array = current["cells"]
	var previous: Vector3 = start
	for cell: Vector2i in cells:
		var point: Vector3 = BuildGrid.cell_center(cell) + Vector3(0, BELT_HEIGHT, 0)
		tween.tween_property(piece, "global_position", point, maxf(previous.distance_to(point) / BELT_SPEED, 0.05))
		previous = point
	tween.tween_property(piece, "global_position", end, HOP_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(piece.queue_free)


func _name(uid: String) -> String:
	for entry: Dictionary in placed.get_entries():
		if entry["uid"] == uid:
			return TranslationServer.translate((entry["def"] as PlaceableDefinition).name_key)
	return uid
