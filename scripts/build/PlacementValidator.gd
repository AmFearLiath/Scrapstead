class_name PlacementValidator
extends RefCounted
## Checks a placement and explains every problem (docs/building-system.md,
## section 3.2). Pure logic: the world facts come in as data and callables,
## so the rules can be tested without a scene.
##
## Result dictionary of `check()`:
##   ok         bool                 no blocking problem
##   problems   Array[Dictionary]    [{"key": String, "cells": Array[Vector2i]}], blocking
##   hints      PackedStringArray    non-blocking functional notes (localization keys)
##   footprint  Array[Vector2i]      cells the object occupies
##   clearance  Array[Vector2i]      cells that must stay free

## Buildable cells (inside the fence, with a margin).
var plot: Rect2i = Rect2i()
## Cells blocked by the static yard, as `func(cells: Array[Vector2i]) -> Array[Vector2i]`.
var static_blocked: Callable
## Cell -> uid of placed objects' footprints and operator areas.
var occupied: Dictionary = {}
var reserved: Dictionary = {}
## Cell -> reason key ("gate", "route", "station", "scrap") of areas to keep free.
var protected: Dictionary = {}
## Cell -> uid of the object a protected cell belongs to (it may move over it).
var protected_owner: Dictionary = {}
## Optional extra hints: `func(definition, anchor, rotation) -> PackedStringArray`.
var hint_source: Callable


## `ignore_uid`: the object being moved does not collide with itself.
func check(definition: PlaceableDefinition, anchor: Vector2i, rotation_steps: int,
		ignore_uid: String = "") -> Dictionary:
	var footprint: Array[Vector2i] = BuildGrid.footprint_cells(definition, anchor, rotation_steps)
	var clearance: Array[Vector2i] = BuildGrid.clearance_cells(definition, anchor, rotation_steps)
	var problems: Array[Dictionary] = []
	_add(problems, "outside", footprint.filter(func(cell: Vector2i) -> bool: return not plot.has_point(cell)))
	_add(problems, "clearance_outside", clearance.filter(func(cell: Vector2i) -> bool:
		return not plot.has_point(cell)))
	if static_blocked.is_valid():
		if definition.solid:
			_add(problems, "obstacle", static_blocked.call(footprint))
		_add(problems, "clearance_blocked", static_blocked.call(clearance))
	_add(problems, "overlap", footprint.filter(func(cell: Vector2i) -> bool:
		return _taken(occupied, cell, ignore_uid) or _taken(reserved, cell, ignore_uid)))
	_add(problems, "clearance_taken", clearance.filter(func(cell: Vector2i) -> bool:
		return _taken(occupied, cell, ignore_uid)))
	if definition.solid:
		for reason: String in ["gate", "route", "station", "scrap"]:
			_add(problems, "keep_free_" + reason, footprint.filter(func(cell: Vector2i) -> bool:
				return protected.get(cell, "") == reason and protected_owner.get(cell, "") != ignore_uid \
					or ignore_uid.is_empty() and protected.get(cell, "") == reason))
	else:
		_add(problems, "keep_free_scrap", footprint.filter(func(cell: Vector2i) -> bool:
			return protected.get(cell, "") == "scrap"))
	var hints: PackedStringArray = []
	if hint_source.is_valid():
		hints = hint_source.call(definition, anchor, rotation_steps)
	return {"ok": problems.is_empty(), "problems": problems, "hints": hints, "footprint": footprint,
		"clearance": clearance}


## Localized one-line explanation of the first problem (or the first hint).
static func describe(result: Dictionary) -> String:
	var problems: Array = result.get("problems", [])
	if not problems.is_empty():
		return TranslationServer.translate("build.problem." + str(problems[0]["key"])).format(
			problems[0].get("args", {}))
	var hints: PackedStringArray = result.get("hints", PackedStringArray())
	if not hints.is_empty():
		return TranslationServer.translate(hints[0])
	return ""


static func _taken(map: Dictionary, cell: Vector2i, ignore_uid: String) -> bool:
	return map.has(cell) and map[cell] != ignore_uid


static func _add(problems: Array[Dictionary], key: String, cells: Array) -> void:
	if not cells.is_empty():
		var typed: Array[Vector2i] = []
		typed.assign(cells)
		problems.append({"key": key, "cells": typed})
