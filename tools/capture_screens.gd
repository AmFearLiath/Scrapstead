extends SceneTree
## Development tool: runs the real game windowed, drives a short scripted
## sequence and stores screenshots for visual review.
##   godot --path . -s res://tools/capture_screens.gd -- --out=<dir>
## Uses an isolated save directory; never touches the player's save game.

var _out: String = "res://tests/_output/screens"


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			_out = argument.trim_prefix("--out=")
	_run.call_deferred()


func _run() -> void:
	var save_service: Node = root.get_node("SaveService")
	save_service.save_directory = "user://capture_run/saves"
	save_service.settings_directory = "user://capture_run"
	save_service.delete_save()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out))
	change_scene_to_file("res://scenes/menu/MainMenu.tscn")
	await _frames(150)
	await _shot("01_main_menu")
	await _frames(240)
	await _shot("02_main_menu_later")
	root.get_node("GameSession").start_new_game()
	await _frames(90)
	var scene: Node = current_scene
	await _shot("03a_walts_letter")
	scene.get_node("HUD/LetterPanel").close()
	await _frames(30)
	await _shot("03_yard_start")
	var player: Node3D = scene.get_node("Player")
	var pickup: Node3D = scene.get_world_object("scrap_rusted_bolt_02")
	player.place(pickup.global_position + Vector3(-0.3, 0.1, 1.0), PI - 0.3)
	await _frames(30)
	await _shot("04_pickup_prompt")
	scene.get_node("GameplayCamera")._target_zoom = 19.0
	player.place(Vector3(24, 0.1, -18), 2.4)
	await _frames(120)
	await _shot("05_overview_zoomed_out")
	await _extra_shots(scene, player)
	TranslationServer.set_locale("de")
	await _p2_shots(scene, player)
	quit()


## P2: head in the heap, red toolbox, repair moment, Scrappy talking, entrance.
func _p2_shots(scene: Node, player: Node3D) -> void:
	var interactor: Node = scene.get_node("Player/PlayerInteractor")
	scene.get_node("HUD/InspectPanel").close()
	var site: Interactable = scene.get_world_object("story_scrappy_head")
	player.place(site.get_interaction_point() + Vector3(-0.4, 0.1, 0.5), PI * 0.5)
	await _frames(60)
	await _shot("20_scrappy_head_in_heap")
	interactor._execute(site)
	await _frames(20)
	await _shot("21_head_found")
	scene.get_node("HUD/InspectPanel").close()
	var box: Interactable = scene.get_world_object("story_red_toolbox")
	player.place(box.get_interaction_point() + Vector3(0.1, 0.1, 0.5), PI)
	await _frames(60)
	await _shot("22_red_toolbox")
	interactor._execute(box)
	await _frames(20)
	await _shot("23_core_found")
	scene.get_node("HUD/InspectPanel").close()
	var bench: Interactable = scene.get_world_object("station_workbench")
	player.place(bench.get_interaction_point() + Vector3(0.6, 0.1, 0.7), PI)
	await _frames(40)
	await _shot("24_repair_prompt")
	interactor._execute(bench)
	await _frames(25)
	await _shot("25_repair_sparks")
	await _frames(70)
	await _shot("26_scrappy_wakes")
	await _frames(200)
	await _shot("27_scrappy_talks")
	player.place(Vector3(16.5, 0.1, -9.0), PI * 0.75)
	await _frames(240)
	await _shot("28_scrappy_follows")
	scene.get_wallet().credit(30, "capture-entrance", "ui.ledger.sale")
	var desk: OrderDesk = scene.get_world_object("station_order_desk")
	desk.interact(scene._context)
	desk.buy("yard_entrance")
	scene.get_node("HUD/CatalogPanel").close()
	player.place(Vector3(9.5, 0.1, -3.0), PI * 0.8)
	await _frames(240)
	await _shot("29_entrance_improved")
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries._process(deliveries.get_seconds_until_next() + 0.1)
	await _frames(30)
	await _shot("30_delivery_arrived")
	player.place(Vector3(6.2, 0.1, -3.1), 0.3)
	await _frames(120)
	await _shot("31_delivery_pickup")
	await _staff_shots(scene, player)


## P3a: Juri waits at the gate, the staff panel, Juri at work.
func _staff_shots(scene: Node, player: Node3D) -> void:
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	for item: ScrapItem in deliveries.get_live_items():
		if item.get_state() == ScrapItem.State.IN_WORLD:
			item.set_state(ScrapItem.State.SOLD)
	deliveries.deliver_next()
	var worker: YardWorker = scene.get_worker()
	player.place(Vector3(8.4, 0.1, -2.6), -2.2)
	await _frames(150)
	await _shot("32_staff_at_gate")
	var talk: YardWorkerTalk = worker.get_node("Talk")
	scene._on_interaction_finished(talk.object_id, talk.interact(scene._context))
	await _frames(20)
	await _shot("33_staff_panel")
	scene.get_node("HUD/StaffPanel").get_node("%PrimaryButton").pressed.emit()
	await _frames(20)
	await _shot("34_staff_hired_panel")
	scene.get_node("HUD/StaffPanel").close()
	player.place(Vector3(9.6, 0.1, -6.2), 0.6)
	await _frames(300)
	await _shot("35_staff_working")
	await _frames(240)
	await _shot("36_staff_at_counter")
	await _machine_shots(scene, player)


## P3b: reserved pad, catalog, the magnetic collector at work, full crate.
func _machine_shots(scene: Node, player: Node3D) -> void:
	var magnet: MagnetCollector = scene.get_magnet()
	scene.get_node("GameplayCamera")._target_zoom = 10.0
	player.place(Vector3(34.0, 0.1, -9.0), 2.6)
	await _frames(150)
	await _shot("37_machine_pad_reserved")
	var desk: OrderDesk = scene.get_world_object("station_order_desk") as OrderDesk
	scene.get_wallet().credit(120, "capture-machine", "capture")
	scene._on_interaction_finished(desk.object_id, desk.interact(scene._context))
	await _frames(10)
	var panel: Control = scene.get_node("HUD/CatalogPanel")
	var scroll: ScrollContainer = panel.get_node("PanelContainer/Content/Scroll")
	scroll.scroll_vertical = 10000
	await _frames(10)
	await _shot("38_catalog_machine")
	panel.close()
	scene.get_placed().place("magnet_collector", Vector2i(69, -27), 0)
	magnet = scene.get_magnet()
	await _frames(90)
	await _shot("39_machine_installed")
	magnet._timer = magnet.get_cycle_seconds() * 0.58
	await _frames(25)
	await _shot("40_machine_lowering")
	magnet._timer = magnet.get_cycle_seconds() * 0.25
	await _frames(25)
	await _shot("41_machine_carrying")
	for index: int in magnet.profile.bin_capacity:
		magnet.collect_once()
	await _frames(60)
	await _shot("42_machine_crate_full")
	await _staff_tool_shots(scene, player)


## Juri with the handcart and at the dismantling table.
func _staff_tool_shots(scene: Node, player: Node3D) -> void:
	var worker: YardWorker = scene.get_worker()
	var upgrades: UpgradeProgress = scene.get_upgrades()
	for ware_id: String in ["upgrade_carry_basket", "upgrade_handcart"]:
		if not upgrades.is_owned(ware_id):
			scene.get_wallet().credit(upgrades.get_catalog().get_definition(ware_id).price, "capture", "capture")
			upgrades.purchase(ware_id, scene.get_wallet())
	(scene.get_world_object("station_order_desk") as OrderDesk).refresh_deliveries(upgrades)
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	for item: ScrapItem in deliveries.get_live_items():
		if item.get_state() == ScrapItem.State.IN_WORLD:
			item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = 8
	var beam: ScrapItem = deliveries.deliver_next()[0]
	scene.get_node("GameplayCamera")._target_zoom = 11.0
	await _wait_for(func() -> bool: return worker.has_cart(), 40.0)
	await _wait_for(func() -> bool: return false, 0.6)
	player.place(worker.global_position + Vector3(0.9, 0.1, 1.1), 3.8)
	await _wait_for(func() -> bool: return false, 0.8)
	player.place(worker.global_position + Vector3(0.9, 0.1, 1.1), 3.8)
	await _wait_for(func() -> bool: return false, 0.3)
	await _shot("43_staff_handcart")
	deliveries._next_entry = 4
	await _wait_for(func() -> bool: return worker.get_carried_items().is_empty() and not worker.has_cart(), 60.0)
	deliveries.deliver_next()
	await _wait_for(func() -> bool: return worker._task == YardWorker.Task.DISMANTLING, 60.0)
	player.place(worker.global_position + Vector3(0.9, 0.1, 1.1), 3.8)
	await _frames(20)
	await _shot("44_staff_dismantling")
	if not upgrades.is_owned("tool_crowbar"):
		scene.get_wallet().credit(upgrades.get_catalog().get_definition("tool_crowbar").price, "capture", "capture")
		upgrades.purchase("tool_crowbar", scene.get_wallet())
	(scene.get_world_object("station_order_desk") as OrderDesk).refresh_deliveries(upgrades)
	await _wait_for(func() -> bool: return worker.get_carried_items().is_empty() and worker.get_tool().is_empty(), 60.0)
	deliveries._next_entry = 10
	deliveries.deliver_next()
	await _wait_for(func() -> bool: return worker._task == YardWorker.Task.PRYING, 60.0)
	player.place(worker.global_position + Vector3(0.9, 0.1, 1.1), 3.8)
	await _wait_for(func() -> bool: return false, 0.5)
	await _shot("45_staff_crowbar")
	await _wait_for(func() -> bool: return worker.get_tool().is_empty(), 60.0)
	deliveries._next_entry = 8
	deliveries.deliver_next()
	await _wait_for(func() -> bool: return worker.has_cart(), 60.0)
	await _wait_for(func() -> bool: return false, 1.2)
	player.place(worker.global_position + Vector3(0.9, 0.1, 1.1), 3.8)
	await _wait_for(func() -> bool: return false, 0.5)
	await _shot("46_staff_handcart_grip")
	scene._open_pause_menu()
	await _frames(10)
	await _shot("47_pause_menu")
	scene.get_node("HUD/PauseMenu").get_node("%TasksButton").pressed.emit()
	await _frames(30)
	await _shot("48_walts_list")
	scene.get_node("HUD/TaskListPanel").close()
	scene.get_node("HUD/PauseMenu").get_node("%SettingsButton").pressed.emit()
	await _frames(10)
	await _shot("49_settings_in_game")
	scene.get_node("HUD/SettingsPanel").close()
	scene._close_pause_menu()
	await _build_shots(scene, player)


## Build system: menu, previews, a reason, the machine, a small garden.
func _build_shots(scene: Node, player: Node3D) -> void:
	var mode: BuildMode = scene.get_node("BuildMode")
	var placed: PlacedObjects = scene.get_placed()
	var menu: Control = scene.get_node("HUD/BuildMenu")
	scene.get_wallet().credit(300, "capture-build", "capture")
	player.place(Vector3(21.0, 0.1, -19.0), 2.4)
	scene.get_node("GameplayCamera")._target_zoom = 12.0
	await _wait_for(func() -> bool: return false, 0.8)
	scene.enter_build_mode()
	menu.set_category("decor")
	menu._on_card_pressed(placed.catalog.get_definition("decor_bench"))
	mode.aim_at(Vector3(21.0, 0, -19.0))
	await _wait_for(func() -> bool: return false, 0.8)
	await _shot("50_build_catalog")
	menu.close_catalog()
	mode.select(placed.catalog.get_definition("decor_bench"))
	mode.aim_at(Vector3(20.0, 0, -21.0))
	await _frames(10)
	await _shot("51_build_preview_ok")
	mode.confirm()
	mode.select(placed.catalog.get_definition("decor_planter"))
	mode.aim_at(Vector3(17.6, 0, -14.6))
	await _frames(10)
	await _shot("52_build_preview_blocked")
	for spot: Array in [["decor_planter", Vector3(23.0, 0, -21.0), 0], ["decor_gnome", Vector3(18.2, 0, -21.2), 0],
			["decor_flamingo", Vector3(24.6, 0, -19.6), 1], ["decor_floodlight", Vector3(17.0, 0, -22.6), 0],
			["paths_gravel", Vector3(20.0, 0, -19.5), 0], ["paths_gravel", Vector3(21.0, 0, -19.5), 0],
			["paths_gravel", Vector3(22.0, 0, -19.5), 0], ["paths_fence_low", Vector3(21.0, 0, -23.0), 0]]:
		mode.select(placed.catalog.get_definition(spot[0]))
		mode._rotation = spot[2]
		mode.aim_at(spot[1])
		mode.confirm()
	mode._rotation = 0
	mode.set_tool(BuildMode.TOOL_LOOK)
	mode.aim_at(Vector3(20.0, 0, -21.0))
	await _frames(10)
	await _shot("53_build_garden")
	scene.exit_build_mode()
	await _wait_for(func() -> bool: return false, 0.8)
	await _shot("54_build_garden_play")
	player.place(Vector3(33.0, 0.1, -9.5), 2.4)
	await _wait_for(func() -> bool: return false, 0.6)
	scene.enter_build_mode()
	mode.set_tool(BuildMode.TOOL_MOVE)
	mode.aim_at(scene.get_magnet().global_position)
	mode.confirm()
	mode.aim_at(Vector3(30.0, 0, -15.0))
	await _frames(10)
	await _shot("55_build_move_magnet")
	mode.cancel()
	scene.exit_build_mode()
	player.place(Vector3(28.0, 0.1, -27.0), 2.4)
	await _wait_for(func() -> bool: return false, 0.6)
	scene.enter_build_mode()
	mode.set_tool(BuildMode.TOOL_MOVE)
	mode.aim_at(placed.get_node_for("yard_car_wreck").global_position)
	mode.confirm()
	mode.aim_at(Vector3(31.0, 0, -24.5))
	mode.rotate_preview()
	await _frames(10)
	await _shot("56_build_move_car_wreck")
	mode.confirm()
	await _frames(10)
	scene.exit_build_mode()
	await _wait_for(func() -> bool: return false, 0.6)
	await _shot("57_car_wreck_moved")


## Waits real time (physics runs at its own rate) until the condition holds.
func _wait_for(condition: Callable, seconds: float) -> void:
	var deadline: int = Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await process_frame


## P1 sequence: carried items, salvage, sell panel, upgrade panel, pause menu.
func _extra_shots(scene: Node, player: Node3D) -> void:
	scene.get_node("GameplayCamera")._target_zoom = 14.0
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_wire_coil_01"]:
		var item: Interactable = scene.get_world_object(object_id)
		player.place(item.get_interaction_point() + Vector3(0, 0.1, 0.9), PI)
		await _frames(6)
		scene.get_node("Player/PlayerInteractor")._execute(item)
	var beam: Interactable = scene.get_world_object("bulk_metal_beam_01")
	player.place(beam.get_interaction_point() + Vector3(-0.4, 0.1, 1.2), PI)
	await _frames(60)
	await _shot("06_beam_salvage_prompt")
	var counter: Interactable = scene.get_world_object("station_sell_counter")
	player.place(counter.get_interaction_point() + Vector3(-0.3, 0.1, 0.3), PI * 0.5)
	await _frames(60)
	await _shot("07_sell_prompt_with_load")
	scene.get_node("Player/PlayerInteractor")._execute(counter)
	await _frames(20)
	await _shot("08_sell_panel")
	scene.get_node("HUD/SellPanel").get_node("%ConfirmButton").pressed.emit()
	await _frames(20)
	await _shot("09_after_sale")
	scene.get_wallet().credit(60, "capture-topup", "ui.ledger.sale")
	var desk: Interactable = scene.get_world_object("station_order_desk")
	player.place(desk.get_interaction_point() + Vector3(0, 0.1, 0.6), PI)
	await _frames(40)
	scene.get_node("Player/PlayerInteractor")._execute(desk)
	await _frames(20)
	await _shot("10_catalog_panel")
	var buttons: Array[Node] = scene.get_node("HUD/CatalogPanel").get_node("%Offers").find_children("*", "Button", true, false)
	buttons[0].pressed.emit()
	await _frames(10)
	scene.get_node("HUD/CatalogPanel").get_node("%Offers").find_children("*", "Button", true, false)[2].pressed.emit()
	await _frames(20)
	await _shot("11_catalog_bought")
	scene.get_node("HUD/CatalogPanel").close()
	await _frames(10)
	player.place(desk.get_interaction_point() + Vector3(-1.0, 0.1, 2.0), PI)
	await _frames(40)
	await _shot("11b_deliveries")
	var crate: Interactable = scene.get_world_object("source_storage_crate_01")
	player.place(crate.get_interaction_point() + Vector3(0, 0.1, 0.4), PI)
	await _frames(40)
	await _shot("11c_crate_prompt")
	scene.get_node("Player/PlayerInteractor")._execute(crate)
	await _frames(30)
	await _shot("11d_crate_opened")
	var figurine_source: Interactable = scene.get_world_object("source_old_toolbox_01")
	scene.get_node("Player/PlayerInteractor")._inspect_current()
	player.place(figurine_source.get_interaction_point() + Vector3(0.3, 0.1, 0.3), PI * 0.5)
	await _frames(40)
	scene.get_node("Player/PlayerInteractor")._inspect_current()
	await _frames(15)
	await _shot("11e_inspect_toolbox")
	scene.get_node("HUD/InspectPanel").close()
	scene._open_pause_menu()
	await _frames(10)
	await _shot("12_pause_menu")
	scene._close_pause_menu()
	var radio: Interactable = scene.get_world_object("device_broken_radio_01")
	player.place(radio.get_interaction_point() + Vector3(0, 0.1, 0.9), PI)
	await _frames(40)
	await _shot("13_radio_prompt")
	scene.get_node("Player/PlayerInteractor")._execute(radio)
	var table: Interactable = scene.get_world_object("station_dismantle_table")
	player.place(table.get_interaction_point() + Vector3(0.2, 0.1, 0.5), PI)
	await _frames(60)
	await _shot("14_dismantle_prompt")
	TranslationServer.set_locale("en")
	await _frames(30)
	await _shot("15_dismantle_prompt_en")


func _frames(count: int) -> void:
	for index: int in count:
		await process_frame


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(_out.path_join(shot_name + ".png")))
	print("captured ", shot_name)
