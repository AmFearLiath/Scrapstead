extends Node3D
## Coordinator of the Old Yard gameplay scene (docs/p0-implementation-readiness.md,
## sections 3.5 and 6).
##
## Restores player and world objects from GameSession data, wires the
## components explicitly, routes interaction results to the HUD and creates
## the data snapshot on save requests. Performs no file I/O.

@export var player: CharacterBody3D
@export var player_start: Marker3D
@export var camera_rig: Node3D
@export var world_objects_root: Node3D
@export var interaction_prompt: Control
@export var feedback_toast: Control
@export var inspect_panel: Control
@export var debug_overlay: Control

var _interactor: Node
var _context := InteractionContext.new()
## Stable object ID -> Interactable placed in this scene.
var _objects: Dictionary = {}
var _modal_open: bool = false
var _restore_notes: PackedStringArray = []


func _ready() -> void:
	_interactor = player.get_node("PlayerInteractor")
	player.set_input_enabled(false)
	# Steps 1-2: static content is loaded; read the validated session state.
	_register_world_objects()
	var state: Dictionary = GameSession.get_current_state()
	# Steps 3-4: player and object states.
	_restore_player(state.get("player", {}))
	_restore_world_objects(state.get("world_objects", {}))
	# Steps 5-7: camera snaps to the anchor, player gets its movement reference.
	camera_rig.set_follow_target(player.get_node("CameraAnchor"))
	camera_rig.activate()
	player.set_movement_camera(camera_rig.get_camera())
	# Step 8: interaction wiring.
	_context.player = player
	_interactor.setup(player.get_node("InteractionDetector"), player, player.get_facing_direction,
		interaction_prompt, _context)
	_interactor.interaction_finished.connect(_on_interaction_finished)
	# Step 9: HUD and diagnostics.
	inspect_panel.closed.connect(_on_modal_closed)
	debug_overlay.setup(player, camera_rig, _interactor, _debug_extra_lines)
	GameSession.save_completed.connect(_on_save_completed)
	# Step 10: release input once physics has seen the restored positions.
	await get_tree().physics_frame
	_set_gameplay_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_save") and OS.is_debug_build():
		get_viewport().set_input_as_handled()
		save_game()
	elif event.is_action_pressed("debug_toggle_overlay"):
		get_viewport().set_input_as_handled()
		debug_overlay.toggle()


## Builds the snapshot of all persistent runtime values and hands it to
## GameSession. Returns whether the save succeeded.
func save_game() -> bool:
	return GameSession.request_save(create_snapshot())


## Plain-data snapshot; no nodes or resources are serialized.
func create_snapshot() -> Dictionary:
	var position_value: Vector3 = player.global_position
	var objects: Dictionary = {}
	for object_id: String in _objects:
		var object_state: Dictionary = _objects[object_id].get_save_state()
		if not object_state.is_empty():
			objects[object_id] = object_state
	return {
		"player": {
			"position": [snappedf(position_value.x, 0.001), snappedf(position_value.y, 0.001),
				snappedf(position_value.z, 0.001)],
			"facing": snappedf(player.get_facing_yaw(), 0.0001),
		},
		"world_objects": objects,
	}


## Registered interactable for a stable ID (used by tests and diagnostics).
func get_world_object(object_id: String) -> Interactable:
	return _objects.get(object_id)


## Notes collected while restoring (unknown IDs, fallbacks).
func get_restore_notes() -> PackedStringArray:
	return _restore_notes


func _register_world_objects() -> void:
	for node: Node in world_objects_root.find_children("*", "Interactable", true, false):
		var target := node as Interactable
		if _objects.has(target.object_id):
			push_error("OldYard: duplicate object_id '%s'." % target.object_id)
			continue
		_objects[target.object_id] = target


func _restore_player(player_state: Dictionary) -> void:
	var start: Vector3 = player_start.global_position
	var facing: float = player_start.global_rotation.y
	if player_state.has("position"):
		var saved: Array = player_state["position"]
		start = Vector3(saved[0], saved[1], saved[2])
		facing = float(player_state.get("facing", facing))
	player.fallback_spawn = player_start.global_position
	if not player.place(start, facing):
		_note("player position outside the plot, using spawn")


func _restore_world_objects(saved_objects: Dictionary) -> void:
	for object_id: String in saved_objects:
		if not _objects.has(object_id):
			_note("unknown object id '%s' ignored" % object_id)
			continue
		_objects[object_id].apply_save_state(saved_objects[object_id])


func _note(text: String) -> void:
	_restore_notes.append(text)
	if OS.is_debug_build():
		push_warning("OldYard restore: " + text)


func _set_gameplay_input(enabled: bool) -> void:
	player.set_input_enabled(enabled)
	_interactor.set_enabled(enabled)


func _on_interaction_finished(_target_id: String, result: Dictionary) -> void:
	var message_key: String = result.get("message_key", "")
	if not message_key.is_empty():
		feedback_toast.show_message(tr(message_key).format(result.get("message_args", {})),
			result.get("success", false))
	var panel: String = result.get("panel", "")
	if panel == "inspect":
		var data: Dictionary = result.get("panel_data", {})
		_open_modal()
		inspect_panel.open(data.get("title_key", ""), data.get("text_key", ""))


func _open_modal() -> void:
	_modal_open = true
	_set_gameplay_input(false)


func _on_modal_closed() -> void:
	_modal_open = false
	_set_gameplay_input(true)


func _on_save_completed(success: bool, message_key: String) -> void:
	feedback_toast.show_message(tr(message_key), success)


func _debug_extra_lines() -> String:
	return "Restore notes: %s" % (", ".join(_restore_notes) if not _restore_notes.is_empty() else "-")
