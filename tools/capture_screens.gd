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
	await _shot("03_yard_start")
	var scene: Node = current_scene
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
	quit()


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
	scene.get_wallet().credit(30, "capture-topup", "ui.ledger.sale")
	var bench: Interactable = scene.get_world_object("station_workbench")
	player.place(bench.get_interaction_point() + Vector3(0, 0.1, 0.6), PI)
	await _frames(40)
	scene.get_node("Player/PlayerInteractor")._execute(bench)
	await _frames(20)
	await _shot("10_upgrade_panel")
	scene.get_node("HUD/UpgradePanel").get_node("%Offers").find_children("*", "Button", true, false)[0].pressed.emit()
	await _frames(20)
	await _shot("11_upgrade_bought")
	scene.get_node("HUD/UpgradePanel").close()
	scene._open_pause_menu()
	await _frames(10)
	await _shot("12_pause_menu")
	scene._close_pause_menu()


func _frames(count: int) -> void:
	for index: int in count:
		await process_frame


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(_out.path_join(shot_name + ".png")))
	print("captured ", shot_name)
