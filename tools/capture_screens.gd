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
