extends TestSuite
## P0 integration tests INT-01 .. INT-12 (docs/p0-system-integration.md, 12)
## plus the movement, camera and interaction acceptance checks.

const MENU: String = "res://scenes/menu/MainMenu.tscn"
const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _session: Node
var _save: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_save = tree.root.get_node("SaveService")
	_save.save_directory = "user://test_run/saves"
	_save.delete_save()
	for action: String in ["move_up", "move_down", "move_left", "move_right"]:
		Input.action_release(action)


func after_each() -> void:
	for action: String in ["move_up", "move_down", "move_left", "move_right"]:
		Input.action_release(action)
	_save.save_directory = "user://test_run/saves"
	_save.delete_save()


func _start_new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	return scene


func _player(scene: Node) -> CharacterBody3D:
	return scene.get_node("Player")


func _interactor(scene: Node) -> Node:
	return scene.get_node("Player/PlayerInteractor")


func _teleport(scene: Node, position_value: Vector3, facing: float = 0.0) -> void:
	_player(scene).place(position_value, facing)
	await wait_physics_frames(4)


func test_int01_menu_without_save_disables_continue() -> void:
	tree.change_scene_to_file(MENU)
	var menu: Node = await wait_for_scene(MENU)
	check(menu != null, "main menu loads")
	await wait_process_frames(2)
	var button: Button = menu.get_node("MenuUI/Root/MenuPanel/ContinueButton")
	check(button.disabled, "continue disabled without save")
	check(tree.root.get_node("MainMenu/MenuBackdrop/CameraPath/CameraPathFollow/MenuCamera").current,
		"menu camera is the active camera")


func test_int02_new_game_starts_clean() -> void:
	var scene: Node = await _start_new_game()
	check(scene != null, "gameplay scene loads")
	check(_session.is_session_active(), "session active")
	var player: CharacterBody3D = _player(scene)
	check(player.global_position.distance_to(Vector3(8, 0, -3)) < 0.3, "player at spawn")
	check(scene.get_world_object("scrap_rusted_bolt_02").is_interaction_available(), "pickup available")
	check(not scene.get_world_object("p0_use_floodlight_01").is_on(), "floodlight off")


func test_int05_camera_starts_on_player_without_jump() -> void:
	var scene: Node = await _start_new_game()
	var rig: Node3D = scene.get_node("GameplayCamera")
	var anchor: Node3D = scene.get_node("Player/CameraAnchor")
	check(rig.global_position.distance_to(anchor.global_position) < 0.05, "rig snapped to anchor")
	check(rig.get_camera().current, "gameplay camera active")
	check_eq(rig.get_camera().projection, Camera3D.PROJECTION_ORTHOGONAL, "orthographic projection")


func test_movement_is_camera_relative_and_stops() -> void:
	var scene: Node = await _start_new_game()
	var player: CharacterBody3D = _player(scene)
	await _teleport(scene, Vector3(30, 0.1, -10))
	var start: Vector3 = player.global_position
	Input.action_press("move_up")
	await wait_physics_frames(60)
	var moved: Vector3 = player.global_position - start
	moved.y = 0
	var camera_forward: Vector3 = -scene.get_node("GameplayCamera").get_camera().global_basis.z
	camera_forward.y = 0
	check(moved.normalized().dot(camera_forward.normalized()) > 0.99, "move_up follows camera forward")
	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	check_near(speed, 4.5, 0.05, "reaches max speed")
	Input.action_release("move_up")
	var release_position: Vector3 = player.global_position
	await wait_physics_frames(20)
	check(Vector2(player.velocity.x, player.velocity.z).length() < 0.01, "stops after release")
	check(player.global_position.distance_to(release_position) < 0.7, "controlled braking distance")
	var yaw_before: float = player.get_facing_yaw()
	await wait_physics_frames(10)
	check_near(player.get_facing_yaw(), yaw_before, 0.0001, "facing kept while idle")


func test_diagonal_is_not_faster() -> void:
	var scene: Node = await _start_new_game()
	var player: CharacterBody3D = _player(scene)
	await _teleport(scene, Vector3(30, 0.1, -10))
	Input.action_press("move_up")
	Input.action_press("move_right")
	await wait_physics_frames(45)
	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	check(speed <= 4.5 + 0.01, "diagonal speed limited (got %.3f)" % speed)
	check_near(speed, 4.5, 0.05, "diagonal reaches max speed")


func test_collision_blocks_walls() -> void:
	var scene: Node = await _start_new_game()
	var player: CharacterBody3D = _player(scene)
	# South of the workshop shed (south face at world z = -15), walking north (-Z).
	await _teleport(scene, Vector3(8.5, 0.1, -13.5))
	# move_up + move_left points world north (camera faces north-east).
	Input.action_press("move_up")
	Input.action_press("move_left")
	await wait_physics_frames(90)
	check(player.global_position.z > -15.0 + 0.25, "shed blocks the player (z=%.2f)" % player.global_position.z)


func test_camera_zoom_is_bounded() -> void:
	var scene: Node = await _start_new_game()
	var rig: Node3D = scene.get_node("GameplayCamera")
	for index: int in 20:
		send_action("camera_zoom_out")
	await wait_process_frames(90)
	check_near(rig.get_camera().size, 19.0, 0.05, "zoom max")
	for index: int in 20:
		send_action("camera_zoom_in")
	await wait_process_frames(90)
	check_near(rig.get_camera().size, 9.0, 0.05, "zoom min")


func test_int06_int08_pickup_inspect_use() -> void:
	var scene: Node = await _start_new_game()
	var interactor: Node = _interactor(scene)
	var pickup: Interactable = scene.get_world_object("scrap_rusted_bolt_02")
	await _teleport(scene, pickup.global_position + Vector3(0, 0.1, 1.0), PI)
	check(interactor.get_current_target() == pickup, "pickup selected")
	check(scene.get_node("HUD/InteractionPrompt").visible, "prompt visible")
	send_action("interact")
	await wait_physics_frames(2)
	check(not pickup.is_interaction_available(), "pickup consumed")
	check(interactor.get_current_target() != pickup, "pickup no longer selected")
	check(not pickup.visible, "pickup stays consumed")
	var floodlight: Interactable = scene.get_world_object("p0_use_floodlight_01")
	await _teleport(scene, floodlight.get_interaction_point() + Vector3(-0.6, 0.1, 0.6), PI * 0.75)
	check(interactor.get_current_target() == floodlight, "floodlight selected")
	send_action("interact")
	await wait_physics_frames(2)
	check(floodlight.is_on(), "use toggles floodlight on")
	var board: Interactable = scene.get_world_object("p0_inspect_board_01")
	await _teleport(scene, board.get_interaction_point() + Vector3(-0.4, 0.1, 0.4), PI * 0.75)
	check(interactor.get_current_target() == board, "board selected")
	send_action("interact")
	await wait_physics_frames(2)
	check(scene.get_node("HUD/InspectPanel").visible, "inspect panel open")
	check(not scene.get_node("Player").get("_input_enabled"), "movement locked while inspecting")
	send_action("interact")
	await wait_physics_frames(2)
	check(not scene.get_node("HUD/InspectPanel").visible, "inspect panel closed")
	check(board.is_interaction_available(), "inspect does not change world state")


func test_selection_prefers_near_then_facing_and_is_stable() -> void:
	var scene: Node = await _start_new_game()
	var interactor: Node = _interactor(scene)
	var pickup: Interactable = scene.get_world_object("scrap_rusted_bolt_02")
	var floodlight: Interactable = scene.get_world_object("p0_use_floodlight_01")
	# Place the floodlight test object 2 m east of the pickup for this test.
	floodlight.global_position = pickup.global_position + Vector3(2.0, 0, 0) - (floodlight.get_interaction_point() - floodlight.global_position)
	await wait_physics_frames(2)
	var mid: Vector3 = pickup.global_position + Vector3(1.0, 0.1, 0)
	# Facing east (+X): yaw = PI/2.
	await _teleport(scene, mid, PI * 0.5)
	check(interactor.get_current_target() == floodlight, "facing resolves a tie (east)")
	await _teleport(scene, mid, -PI * 0.5)
	check(interactor.get_current_target() == pickup, "facing resolves a tie (west)")
	# Clearly nearer target wins even when facing away from it.
	await _teleport(scene, pickup.global_position + Vector3(0.3, 0.1, 0), PI * 0.5)
	check(interactor.get_current_target() == pickup, "nearer target wins")
	# Hysteresis: tiny moves around the midpoint must not flip the target.
	await _teleport(scene, mid + Vector3(-0.05, 0, 0), -PI * 0.5)
	var held: Interactable = interactor.get_current_target()
	var flips: int = 0
	for offset: float in [0.04, 0.08, 0.1, 0.06]:
		_player(scene).global_position = mid + Vector3(offset, 0, 0)
		await wait_physics_frames(2)
		if interactor.get_current_target() != held:
			flips += 1
	check_eq(flips, 0, "no flicker on small moves")


func test_int07_target_invalidated_before_key_press() -> void:
	var scene: Node = await _start_new_game()
	var interactor: Node = _interactor(scene)
	var pickup: Interactable = scene.get_world_object("scrap_rusted_bolt_02")
	await _teleport(scene, pickup.global_position + Vector3(0, 0.1, 1.0), PI)
	check(interactor.get_current_target() == pickup, "pickup selected")
	var results: Array = []
	interactor.interaction_finished.connect(func(id: String, r: Dictionary) -> void: results.append([id, r]))
	# (a) Becomes unavailable without notifying the interactor.
	pickup.visible = false
	send_action("interact")
	await wait_physics_frames(1)
	check(results.size() == 0 or not results[-1][1]["success"], "unavailable target is not executed")
	check(pickup.collision_layer == 4, "pickup state untouched")
	# (b) Freed between display and key press.
	pickup.visible = true
	await wait_physics_frames(2)
	pickup.free()
	send_action("interact")
	await wait_physics_frames(3)
	for entry: Array in results:
		check(not entry[1]["success"], "no successful action on stale reference")
	check(interactor.get_current_target() == null, "selection cleared")
	check(not scene.get_node("HUD/InteractionPrompt").visible, "prompt hidden")


func test_int09_save_restart_continue_restores_state() -> void:
	var scene: Node = await _start_new_game()
	var pickup: Interactable = scene.get_world_object("scrap_rusted_bolt_02")
	await _teleport(scene, pickup.global_position + Vector3(0, 0.1, 1.0), PI)
	send_action("interact")
	await wait_physics_frames(2)
	scene.get_world_object("p0_use_floodlight_01").apply_save_state({"on": true})
	await _teleport(scene, Vector3(20.5, 0.1, -11.25), 1.25)
	check(scene.save_game(), "save succeeds")
	check(_session.has_valid_save(), "save is valid")
	_session.return_to_main_menu()
	var menu: Node = await wait_for_scene(MENU)
	await wait_process_frames(2)
	check(not menu.get_node("MenuUI/Root/MenuPanel/ContinueButton").disabled, "continue enabled with save")
	check(_session.continue_game(), "continue succeeds")
	var restored: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	var player: CharacterBody3D = _player(restored)
	check(player.global_position.distance_to(Vector3(20.5, 0.1, -11.25)) < 0.15, "position restored")
	check_near(player.get_facing_yaw(), 1.25, 0.01, "facing restored")
	check(not restored.get_world_object("scrap_rusted_bolt_02").is_interaction_available(), "pickup state restored")
	check(restored.get_world_object("p0_use_floodlight_01").is_on(), "floodlight state restored")
	var rig: Node3D = restored.get_node("GameplayCamera")
	check(rig.global_position.distance_to(restored.get_node("Player/CameraAnchor").global_position) < 0.3,
		"camera placed at restored player")


func test_int04_corrupt_save_keeps_menu() -> void:
	_session.return_to_main_menu()
	await wait_for_scene(MENU)
	DirAccess.make_dir_recursive_absolute(_save.save_directory)
	var file := FileAccess.open(_save.get_save_path(), FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var errors: Array = []
	var on_error := func(key: String) -> void: errors.append(key)
	_session.session_error.connect(on_error)
	check(not _session.continue_game(), "continue refused")
	_session.session_error.disconnect(on_error)
	await wait_process_frames(3)
	check_eq(tree.current_scene.scene_file_path, MENU, "menu stays active")
	check(errors.has("ui.save.error.corrupt"), "readable corrupt error reported")
	check(not _session.is_session_active(), "no session faked")


func test_int10_unknown_object_id_is_ignored() -> void:
	var data: Dictionary = _session.create_initial_state()
	data["world_objects"] = {"does_not_exist": {"picked_up": true}, "p0_use_floodlight_01": {"on": true}}
	check(_save.save_game(data)["ok"], "prepared save written")
	check(_session.continue_game(), "continue succeeds")
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(2)
	check(scene != null, "scene loaded despite unknown id")
	var notes: PackedStringArray = scene.get_restore_notes()
	check(notes.size() == 1 and notes[0].contains("does_not_exist"), "unknown id noted")
	check(scene.get_world_object("p0_use_floodlight_01").is_on(), "known ids still applied")


func test_invalid_saved_position_falls_back_to_spawn() -> void:
	var data: Dictionary = _session.create_initial_state()
	data["player"] = {"position": [500.0, 0.0, -80.0], "facing": 0.0}
	_save.save_game(data)
	_session.continue_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(2)
	check(_player(scene).global_position.distance_to(Vector3(8, 0, -3)) < 0.3, "fallback spawn used")


func test_int11_save_write_failure_keeps_session() -> void:
	var scene: Node = await _start_new_game()
	var blocker := FileAccess.open("user://test_run/blocker", FileAccess.WRITE)
	blocker.store_string("x")
	blocker.close()
	_save.save_directory = "user://test_run/blocker/saves"
	var reported: Array = []
	var on_saved := func(success: bool, key: String) -> void: reported.append([success, key])
	_session.save_completed.connect(on_saved)
	check(not scene.save_game(), "save fails")
	_session.save_completed.disconnect(on_saved)
	check(reported.size() == 1 and not reported[0][0], "failure reported")
	check(_session.is_session_active(), "session keeps running")
	check_eq(tree.current_scene, scene, "scene unchanged")
	DirAccess.remove_absolute("user://test_run/blocker")


func test_int12_repeated_scene_changes_leave_no_leftovers() -> void:
	for index: int in 3:
		await _start_new_game()
		_session.return_to_main_menu()
		await wait_for_scene(MENU)
	await _start_new_game()
	check_eq(_session.save_completed.get_connections().size(), 1, "one save listener (current scene)")
	check_eq(_session.session_error.get_connections().size(), 0, "menu listener released")
	var children: PackedStringArray = []
	for child: Node in tree.root.get_children():
		children.append(child.name)
	check_eq(children.size(), 3, "root holds 2 autoloads + current scene: %s" % ", ".join(children))
