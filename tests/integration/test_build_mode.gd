extends TestSuite
## Build mode (docs/building-system.md, section 3.3): entering and leaving,
## the tools, the info line, repeated placing, undo and redo.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const FREE := Vector2i(50, -34)

var _session: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_session.intro_enabled = false
	tree.root.get_node("SaveService").delete_save()


func after_each() -> void:
	tree.root.get_node("SaveService").delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	return scene


func _cell_point(cell: Vector2i) -> Vector3:
	return BuildGrid.cell_center(cell)


func test_entering_and_leaving_build_mode() -> void:
	var scene: Node = await _new_game()
	var mode: BuildMode = scene.get_node("BuildMode")
	var menu: Control = scene.get_node("HUD/BuildMenu")
	var player: Node3D = scene.get_node("Player")
	send_action("build_mode")
	await wait_process_frames(2)
	check(mode.is_active(), "B opens build mode")
	check(menu.visible, "menu shown")
	check(not player.is_input_enabled() if player.has_method("is_input_enabled") else true, "player stands still")
	check(scene.get_node("HUD/BuildMenu").find_child("Controls", true, false).text.contains("WASD"),
		"the menu explains the keys")
	var before: Vector3 = player.global_position
	Input.action_press("move_right")
	await wait_process_frames(20)
	Input.action_release("move_right")
	check(player.global_position.distance_to(before) < 0.05, "WASD moves the camera, not the player")
	check(mode.get_node("BuildCursor").global_position.distance_to(Vector3(before.x, 0, before.z)) > 0.5,
		"build cursor moved")
	send_action("pause_menu")
	await wait_process_frames(2)
	check(not mode.is_active(), "Esc leaves build mode when nothing is going on")
	check(not scene.get_node("HUD/PauseMenu").visible, "and does not open the pause menu")
	check(not menu.visible, "menu hidden")


func test_build_tool_places_repeatedly_and_explains_problems() -> void:
	var scene: Node = await _new_game()
	var mode: BuildMode = scene.get_node("BuildMode")
	var menu: Control = scene.get_node("HUD/BuildMenu")
	var placed: PlacedObjects = scene.get_placed()
	scene.get_wallet().credit(40, "test", "test")
	scene.enter_build_mode()
	menu.set_category("decor")
	var gnome_card: Button = null
	for card: Button in menu.get_cards():
		if card.name == "decor_gnome":
			gnome_card = card
	check(gnome_card != null and not gnome_card.disabled, "gnome offered and affordable")
	check(gnome_card.text.contains("9 Cr"), "card shows the price: %s" % gnome_card.text)
	gnome_card.pressed.emit()
	check_eq(mode.get_selected().id, "decor_gnome", "card selects the object")
	mode.aim_at(_cell_point(FREE))
	check(mode.get_last_check()["ok"], "free spot")
	check(menu.get_info_text().contains("9"), "info line tells the price: %s" % menu.get_info_text())
	check(mode.get_node("Ghost") != null, "see-through preview shown")
	var result: Dictionary = mode.confirm()
	check(result["ok"], "placed by click")
	check_eq(mode.get_selected().id, "decor_gnome", "still selected for the next one")
	mode.aim_at(_cell_point(FREE))
	check(not mode.get_last_check()["ok"], "same spot is taken now")
	check(menu.get_info_text().contains(tr("build.problem.overlap")), "info line says why: %s" % menu.get_info_text())
	var balance: int = scene.get_wallet().get_balance()
	check(not mode.confirm()["ok"], "click on a bad spot does nothing")
	check_eq(scene.get_wallet().get_balance(), balance, "nothing paid for it")
	mode.aim_at(_cell_point(FREE + Vector2i(2, 0)))
	check(mode.confirm()["ok"], "second gnome next to it")
	check_eq(placed.count_placed("decor_gnome"), 2, "two gnomes")
	mode.aim_at(_cell_point(BuildGrid.world_to_cell(Vector3(17.5, 0, -2.8))))
	check(menu.get_info_text().contains(tr("build.problem.keep_free_route")), "Juri's way is explained")
	mode.aim_at(_cell_point(FREE + Vector2i(6, 0)))
	var ghost_cells: Array = mode.get_last_check()["footprint"]
	mode.rotate_preview()
	check_eq(mode.get_rotation_steps(), 1, "R turns the preview")
	check(mode.cancel(), "right click drops the selection")
	check_eq(mode.get_tool(), BuildMode.TOOL_LOOK, "back to looking")
	check(ghost_cells.size() == 1, "gnome takes one cell")


func test_move_remove_undo_and_redo() -> void:
	var scene: Node = await _new_game()
	var mode: BuildMode = scene.get_node("BuildMode")
	var placed: PlacedObjects = scene.get_placed()
	scene.get_wallet().credit(40, "test", "test")
	scene.enter_build_mode()
	mode.select(placed.catalog.get_definition("decor_bench"))
	mode.aim_at(BuildGrid.object_center(placed.catalog.get_definition("decor_bench"), FREE, 0))
	var uid: String = mode.confirm()["uid"]
	var balance: int = scene.get_wallet().get_balance()
	mode.set_tool(BuildMode.TOOL_MOVE)
	mode.aim_at(placed.get_node_for(uid).global_position)
	check_eq(mode.get_hover_uid(), uid, "pointing at the bench")
	check(mode.confirm()["ok"], "picked up")
	check_eq(mode.get_moving_uid(), uid, "carrying it in the preview")
	var target: Vector3 = BuildGrid.cell_center(FREE + Vector2i(0, -8))
	mode.aim_at(target)
	mode.rotate_preview()
	check(mode.confirm()["ok"], "set down")
	var node: Node3D = placed.get_node_for(uid)
	check(node.global_position.distance_to(target) < 1.0, "bench moved")
	check_near(node.rotation.y, -PI * 0.5, 0.001, "and turned")
	check(mode.undo()["ok"], "undo the move")
	check(placed.get_node_for(uid).global_position.distance_to(
		BuildGrid.object_center(placed.catalog.get_definition("decor_bench"), FREE, 0)) < 0.01, "back in place")
	check(mode.redo()["ok"], "redo the move")
	mode.set_tool(BuildMode.TOOL_REMOVE)
	mode.aim_at(placed.get_node_for(uid).global_position)
	check(mode.confirm()["ok"], "removed")
	await wait_process_frames(1)
	check(placed.get_node_for(uid) == null, "gone")
	check(mode.undo()["ok"], "undo the removal")
	check(placed.get_node_for(uid) != null, "bench is back with the same id")
	check_eq(scene.get_wallet().get_balance(), balance, "moving, removing and undoing never cost money")
	check(mode.undo()["ok"] and mode.undo()["ok"], "undo the move and the placement")
	await wait_process_frames(1)
	check(placed.get_node_for(uid) == null, "placement undone: back to storage")
	check_eq(placed.get_available(placed.catalog.get_definition("decor_bench")), 1, "the bought bench is kept")
	check(not mode.undo()["ok"], "nothing left to undo")
	check(mode.redo()["ok"], "redo the placement")
	check(placed.get_node_for(uid) != null, "bench stands again")


func test_ghost_never_blocks_and_never_gets_saved() -> void:
	var scene: Node = await _new_game()
	var mode: BuildMode = scene.get_node("BuildMode")
	var placed: PlacedObjects = scene.get_placed()
	scene.get_wallet().credit(100, "test", "test")
	scene.enter_build_mode()
	mode.select(placed.catalog.get_definition("magnet_collector"))
	mode.aim_at(BuildGrid.object_center(placed.catalog.get_definition("magnet_collector"), Vector2i(69, -27), 0))
	await wait_physics_frames(2)
	check(mode.get_last_check()["ok"], "ghost machine does not block its own spot")
	check(mode.get_node("WorkRadius").visible, "work radius shown for the magnet")
	check(mode.get_last_check()["hints"].has("build.hint.heap_in_reach"), "heap hint shown")
	check(scene.get_magnet() == null, "a preview is not a machine")
	check_eq(scene.create_snapshot()["placed"]["objects"], [], "nothing placed in the save")
	scene.exit_build_mode()
	await wait_process_frames(1)
	check(mode.get_node_or_null("Ghost") == null, "preview cleared on leaving")
