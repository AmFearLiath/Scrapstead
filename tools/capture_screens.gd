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
	# Art style 2 scenery outside the fence (docs/art-style-2.md).
	player.place(Vector3(40, 0.1, -33), 2.4)
	await _frames(120)
	await _shot("05b_north_east_corner")
	player.place(Vector3(4, 0.1, -32), 2.4)
	await _frames(120)
	await _shot("05c_north_west_corner")
	# Block 4: searchable yard fixtures (docs/yard-stashes.md).
	var heap: YardStash = scene.yard_stashes.get_body("scrap_heap_large")
	player.place(heap.global_position + Vector3(0, 0.1, 3.2), PI)
	await _frames(40)
	await _shot("06a_stash_prompt")
	var found: Dictionary = heap.interact(scene._context)
	scene.feedback_toast.show_message(tr(found["message_key"]).format(found["message_args"]))
	await _frames(40)
	await _shot("06b_stash_found")
	player.place(Vector3(24, 0.1, -18), 2.4)
	await _frames(60)
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
	mode.aim_at(Vector3(32.0, 0, -20.5))
	mode.rotate_preview()
	await _frames(10)
	await _shot("56_build_move_car_wreck")
	mode.confirm()
	await _frames(10)
	scene.exit_build_mode()
	await _wait_for(func() -> bool: return false, 0.6)
	await _shot("57_car_wreck_moved")
	await _press_shots(scene, player, placed, mode)
	await _chain_shots(scene, player, placed)


## The scrap press and a conveyor from the magnet (docs/scrap-press.md, machine-links.md).
func _press_shots(scene: Node, player: Node3D, placed: PlacedObjects, mode: BuildMode) -> void:
	var magnet_uid: String = ""
	for entry: Dictionary in placed.get_entries():
		if entry["node"] is MagnetCollector:
			magnet_uid = entry["uid"]
	if magnet_uid.is_empty():
		return
	var definition: PlaceableDefinition = placed.catalog.get_definition("scrap_press")
	scene.get_wallet().credit(500, "capture-press", "test")
	var press_uid: String = ""
	for anchor: Vector2i in [Vector2i(62, -27), Vector2i(62, -22), Vector2i(76, -27), Vector2i(69, -36), Vector2i(62, -18)]:
		if placed.check_placement(definition, anchor, 1)["ok"]:
			press_uid = placed.place("scrap_press", anchor, 1).get("uid", "")
			if not press_uid.is_empty():
				break
	if press_uid.is_empty():
		print("capture: no place for the press")
		return
	var press: ScrapPress = placed.get_node_for(press_uid) as ScrapPress
	player.place(press.global_position + Vector3(2.5, 0.1, 2.5), 2.4)
	await _wait_for(func() -> bool: return false, 0.4)
	scene.enter_build_mode()
	mode.set_tool(BuildMode.TOOL_CONNECT)
	mode.aim_at(placed.get_node_for(magnet_uid).global_position)
	mode.confirm()
	mode.aim_at(press.global_position)
	await _frames(10)
	await _shot("58_build_connect_preview")
	mode.confirm()
	scene.exit_build_mode()
	var magnet: MagnetCollector = placed.get_node_for(magnet_uid) as MagnetCollector
	for index: int in magnet.profile.bin_capacity:
		magnet.collect_once()
	var link_id: int = placed.links.find_link(magnet_uid, press_uid)
	for index: int in 6:
		placed.links.send_once(link_id)
	press.press_once()
	for index: int in 3:
		magnet.collect_once()
	placed.links.send_once(link_id)
	await _wait_for(func() -> bool: return false, 0.8)
	await _shot("59_press_conveyor")
	var controls: Interactable = press.get_node("Machine/Controls")
	player.place(controls.get_interaction_point() + Vector3(0.3, 0.1, 0.0), -PI * 0.5)
	await _wait_for(func() -> bool: return false, 0.5)
	await _shot("60_press_controls")


## The full processing chain: sorting machine with three presses (docs/processing-chain.md).
func _chain_shots(scene: Node, player: Node3D, placed: PlacedObjects) -> void:
	scene.get_wallet().credit(2000, "capture-chain", "test")
	var sorter_uid: String = _place_free(placed, "sorter", Vector2i(36, -56), Callable())
	if sorter_uid.is_empty():
		print("capture: no place for the sorter")
		return
	var sorter: SortingMachine = placed.get_node_for(sorter_uid) as SortingMachine
	var directions: Dictionary = {"steel": Vector3.LEFT, "copper": Vector3.BACK, "wood": Vector3.RIGHT}
	for channel: String in ["steel", "copper", "wood"]:
		var uid: String = _place_free(placed, "scrap_press", Vector2i(36, -56), func(candidate: String) -> bool:
			var offset: Vector3 = placed.get_node_for(candidate).global_position - sorter.global_position
			return offset.dot(directions[channel]) > 2.4 and absf(offset.dot(directions[channel].cross(Vector3.UP))) < 2.0 				and placed.links.check_link(sorter_uid, candidate, -1, channel)["ok"])
		if not uid.is_empty():
			placed.links.link(sorter_uid, uid, -1, channel)
	for object_id: String in ["scrap_wire_coil_01", "scrap_wire_coil_02", "scrap_empty_can_01", "scrap_empty_can_02"]:
		var item: ScrapItem = scene.get_world_object(object_id) as ScrapItem
		if item != null and item.get_state() == ScrapItem.State.IN_WORLD:
			sorter.accept_item(item)
	for index: int in 3:
		sorter.sort_once()
	for link: Dictionary in placed.links.get_links():
		if link["from"] == sorter_uid:
			placed.links.send_once(link["id"])
	player.place(sorter.global_position + Vector3(3.0, 0.1, 3.5), 2.4)
	scene.get_node("GameplayCamera")._target_zoom = 17.0
	await _wait_for(func() -> bool: return false, 1.2)
	await _shot("61_processing_chain")
	var hopper: Interactable = sorter.get_node("Machine/Hopper")
	player.place(hopper.get_interaction_point() + Vector3(0, 0.1, 0.2), PI)
	scene.get_node("GameplayCamera")._target_zoom = 12.0
	await _wait_for(func() -> bool: return false, 0.8)
	await _shot("62_sorter_prompt")


func _place_free(placed: PlacedObjects, placeable_id: String, near: Vector2i, accept: Callable) -> String:
	var definition: PlaceableDefinition = placed.catalog.get_definition(placeable_id)
	for distance: int in range(0, 24):
		for dx: int in range(-distance, distance + 1):
			for dy: int in range(-distance, distance + 1):
				if maxi(absi(dx), absi(dy)) != distance:
					continue
				var anchor: Vector2i = near + Vector2i(dx, dy)
				if not placed.check_placement(definition, anchor, 0)["ok"]:
					continue
				var result: Dictionary = placed.place(placeable_id, anchor, 0)
				if not result["ok"]:
					continue
				if not accept.is_valid() or accept.call(result["uid"]):
					return result["uid"]
				placed.remove(result["uid"])
	return ""


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
