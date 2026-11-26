extends SceneTree
## End-to-end acceptance across a real process restart.
##   godot --headless --path . -s res://tests/e2e_restart.gd -- --phase=play
##   godot --headless --path . -s res://tests/e2e_restart.gd -- --phase=continue
## Phase "play" runs the P1 loop through the real input pipeline, saves via the
## pause menu and quits. Phase "continue" starts fresh, checks the main menu
## offers "Continue", continues and verifies the restored state.
## Uses an isolated save directory. Exit code 0 = passed.

const MENU: String = "res://scenes/menu/MainMenu.tscn"
const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	var phase: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	var save_service: Node = root.get_node("SaveService")
	save_service.save_directory = "user://e2e_run/saves"
	save_service.settings_directory = "user://e2e_run"
	if phase == "play":
		_play.call_deferred()
	elif phase == "continue":
		_continue.call_deferred()
	else:
		printerr("e2e: unknown phase")
		quit(2)


func _play() -> void:
	root.get_node("SaveService").delete_save()
	change_scene_to_file(MENU)
	var menu: Node = await _wait_scene(MENU)
	_check(menu.get_node("MenuUI/Root/MenuPanel/ContinueButton").disabled, "continue disabled before first save")
	menu.get_node("MenuUI/Root/MenuPanel/NewGameButton").pressed.emit()
	var scene: Node = await _wait_scene(YARD)
	await _physics(5)
	var letter: Control = scene.get_node("HUD/LetterPanel")
	_check(letter.visible, "Walt's letter shown on a new game")
	_check(not scene.get_node("Player/PlayerInteractor").is_enabled(), "input blocked while reading")
	letter.get_node("%CloseButton").pressed.emit()
	await _physics(3)
	_check(not letter.visible and scene.get_story().has_flag("letter_read"), "letter closed and remembered")
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_wire_coil_01", "scrap_rusted_bolt_02"]:
		await _use(scene, object_id, 0.05)
	await _sell(scene)
	await _use(scene, "bulk_metal_beam_01", 3.0)
	_check(not scene.get_world_object("bulk_metal_beam_01").is_salvaged(), "beam refused without hoist")
	await _order(scene, 0)
	await _use(scene, "source_storage_crate_01", 2.0)
	for object_id: String in ["scrap_rusted_bolt_04", "scrap_rusted_bolt_05", "scrap_rusted_bolt_06", "scrap_wire_coil_04"]:
		await _use(scene, object_id, 0.05)
	await _sell(scene)
	await _use(scene, "source_small_scrap_pile_01", 2.0)
	await _use(scene, "source_old_toolbox_01", 2.0)
	for object_id: String in ["scrap_rusted_bolt_03", "scrap_empty_can_03", "scrap_wood_offcut_01", "find_brass_figurine_01"]:
		await _use(scene, object_id, 0.05)
	await _sell(scene)
	await _order(scene, 2)
	await _use(scene, "bulk_metal_beam_01", 3.0)
	await _sell(scene)
	_check(scene.get_wallet().get_balance() == 36, "36 credits before basket (got %d)" % scene.get_wallet().get_balance())
	await _order(scene, 1)
	await _use(scene, "source_rusted_drum_01", 2.0)
	for object_id: String in ["scrap_empty_can_04", "scrap_empty_can_05", "scrap_copper_pipe_01", "scrap_empty_can_02"]:
		await _use(scene, object_id, 0.05)
	_check(scene.get_inventory().get_used_slots() == 4, "4 of 8 slots used after upgrade")
	# P2: find the head and the core, repair Scrappy at the workbench.
	await _use(scene, "story_scrappy_head", 2.5)
	_check(scene.get_node("HUD/InspectPanel").visible, "head discovery is shown")
	scene.get_node("HUD/InspectPanel").close()
	await _physics(2)
	await _use(scene, "story_red_toolbox", 0.05)
	scene.get_node("HUD/InspectPanel").close()
	await _physics(2)
	_check(scene.get_story().has_key_item("scrappy_head") and scene.get_story().has_key_item("scrappy_core"),
		"both key items found")
	await _use(scene, "station_workbench", 3.5)
	await _wait_seconds(3.5)
	_check(scene.get_node("Scrappy").is_active(), "Scrappy restored and awake")
	_check(scene.get_inventory().get_used_slots() == 4, "key items never used basket slots")
	_send("pause_menu", true)
	await _frames(3)
	scene.get_node("HUD/PauseMenu").get_node("%SaveExitButton").pressed.emit()
	await _wait_scene(MENU)
	_finish("play")


func _continue() -> void:
	change_scene_to_file(MENU)
	var menu: Node = await _wait_scene(MENU)
	var button: Button = menu.get_node("MenuUI/Root/MenuPanel/ContinueButton")
	_check(not button.disabled, "continue enabled after restart")
	button.pressed.emit()
	var scene: Node = await _wait_scene(YARD)
	await _physics(5)
	_check(scene.get_wallet().get_balance() == 6, "credits restored (got %d)" % scene.get_wallet().get_balance())
	_check(scene.get_inventory().get_capacity() == 8, "upgrade restored")
	_check(scene.get_upgrades().has_tool("hoist") and scene.get_upgrades().has_tool("crowbar"), "tools restored")
	_check(scene.get_inventory().get_used_slots() == 4, "carried load restored")
	_check(scene.get_world_object("bulk_metal_beam_01").get_state() == ScrapItem.State.SOLD, "beam sold")
	_check(scene.get_world_object("source_rusted_drum_01").is_searched(), "drum stays searched")
	_check(not scene.get_node("HUD/LetterPanel").visible, "letter not shown again after loading")
	_check(scene.get_node("Scrappy").is_active(), "Scrappy awake after restart")
	_check(scene.get_story().has_flag("scrappy_restored"), "story flags restored")
	_check(not scene.get_world_object("story_scrappy_head").is_interaction_available(), "head stays taken")
	await _use(scene, "device_broken_radio_01", 0.05)
	await _use(scene, "station_dismantle_table", 4.0)
	_check(scene.get_inventory().contains("device_broken_radio_01_copper_wire"), "P1b works after restart")
	await _sell(scene)
	_check(scene.get_wallet().get_balance() == 6 + 2 + 2 + 6 + 2 + 16, "selling after restart (got %d)" % scene.get_wallet().get_balance())
	_finish("continue")


func _use(scene: Node, object_id: String, hold_seconds: float) -> void:
	var target: Interactable = scene.get_world_object(object_id)
	var point: Vector3 = target.get_interaction_point()
	scene.get_node("Player").place(Vector3(point.x, 0.1, point.z + 0.25), PI)
	await _physics(4)
	_check(scene.get_node("Player/PlayerInteractor").get_current_target() == target, "%s selected" % object_id)
	_send("interact", true)
	await _physics(maxi(1, int(hold_seconds * Engine.physics_ticks_per_second)))
	_send("interact", false)
	await _physics(2)


func _order(scene: Node, offer_index: int) -> void:
	await _use(scene, "station_order_desk", 0.05)
	var panel: Control = scene.get_node("HUD/CatalogPanel")
	_check(panel.visible, "catalog open")
	panel.get_node("%Offers").find_children("*", "Button", true, false)[offer_index].pressed.emit()
	await _frames(2)
	panel.close()
	await _physics(2)


func _sell(scene: Node) -> void:
	await _use(scene, "station_sell_counter", 0.05)
	var panel: Control = scene.get_node("HUD/SellPanel")
	_check(panel.visible, "sell panel open")
	panel.get_node("%ConfirmButton").pressed.emit()
	await _physics(2)


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _send(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _wait_scene(path: String) -> Node:
	for index: int in 240:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == path and current_scene.is_node_ready():
			return current_scene
	_check(false, "scene %s loaded" % path)
	return null


func _frames(count: int) -> void:
	for index: int in count:
		await process_frame


func _physics(count: int) -> void:
	for index: int in count:
		await physics_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(phase: String) -> void:
	for failure: String in _failures:
		print("  FAILURE ", failure)
	print("e2e %s: %s" % [phase, "PASSED" if _failures.is_empty() else "FAILED"])
	quit(0 if _failures.is_empty() else 1)
