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
	var pickup: Node3D = scene.get_world_object("p0_pickup_test_01")
	player.place(pickup.global_position + Vector3(-0.3, 0.1, 1.0), PI - 0.3)
	await _frames(30)
	await _shot("04_pickup_prompt")
	scene.get_node("GameplayCamera")._target_zoom = 19.0
	player.place(Vector3(24, 0.1, -18), 2.4)
	await _frames(120)
	await _shot("05_overview_zoomed_out")
	await _extra_shots(scene, player)
	quit()


## Hook for additional shots; extended as the prototype grows.
func _extra_shots(_scene: Node, _player: Node3D) -> void:
	pass


func _frames(count: int) -> void:
	for index: int in count:
		await process_frame


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(_out.path_join(shot_name + ".png")))
	print("captured ", shot_name)
