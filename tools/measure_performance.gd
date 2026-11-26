extends SceneTree
## Development tool (P4): measures frame times in the full Old Yard - Scrappy
## following, Juri working, the magnetic collector running, deliveries on
## the pallet - in the real window with the real renderer.
##   godot --path . -s res://tools/measure_performance.gd
## Prints average FPS, the 1 % low, frame time percentiles and render stats.
## Uses an isolated save directory; never touches the player's save game.

const WARMUP_SECONDS := 4.0
const MEASURE_SECONDS := 15.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var save_service: Node = root.get_node("SaveService")
	save_service.save_directory = "user://perf_run/saves"
	save_service.delete_save()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var session: Node = root.get_node("GameSession")
	session.intro_enabled = false
	session.start_new_game()
	await _seconds(1.0)
	var scene: Node = current_scene
	_fill_the_yard(scene)
	await _seconds(WARMUP_SECONDS)
	var frame_times: Array[float] = []
	var start: int = Time.get_ticks_usec()
	var last: int = start
	while Time.get_ticks_usec() - start < int(MEASURE_SECONDS * 1000000.0):
		await process_frame
		var now: int = Time.get_ticks_usec()
		frame_times.append(float(now - last) / 1000.0)
		last = now
	frame_times.sort()
	var total: float = 0.0
	for value: float in frame_times:
		total += value
	var average: float = total / frame_times.size()
	var worst_percent: Array[float] = frame_times.slice(int(frame_times.size() * 0.99))
	var low_total: float = 0.0
	for value: float in worst_percent:
		low_total += value
	print("PERF frames=%d avg_ms=%.2f avg_fps=%.0f p50_ms=%.2f p95_ms=%.2f p99_ms=%.2f one_percent_low_fps=%.0f max_ms=%.2f" % [
		frame_times.size(), average, 1000.0 / average, frame_times[frame_times.size() / 2],
		frame_times[int(frame_times.size() * 0.95)], frame_times[int(frame_times.size() * 0.99)],
		1000.0 / (low_total / worst_percent.size()), frame_times[-1]])
	print("PERF draw_calls=%d objects=%d primitives=%d video_mem_mb=%.0f nodes=%d" % [
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT)])
	print("PERF gpu=%s window=%s" % [RenderingServer.get_video_adapter_name(), DisplayServer.window_get_size()])
	save_service.delete_save()
	quit()


## Everything P2-P3 brings, at once.
func _fill_the_yard(scene: Node) -> void:
	var upgrades: UpgradeProgress = scene.get_upgrades()
	var wallet: Wallet = scene.get_wallet()
	wallet.credit(500, "perf", "perf")
	for ware: String in ["yard_entrance", "tool_crowbar", "upgrade_carry_basket", "upgrade_handcart"]:
		upgrades.purchase(ware, wallet)
	scene.get_placed().place("magnet_collector", Vector2i(69, -27), 0)
	upgrades.purchase("upgrade_strong_magnet", wallet)
	(scene.get_world_object("station_order_desk") as OrderDesk).refresh_deliveries(upgrades)
	scene.get_story().set_flag(StoryDirector.FLAG_RESTORED)
	scene.get_node("Scrappy").apply_save_state({"state": "active", "follow": true})
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	for index: int in 3:
		deliveries.deliver_next()
	scene.get_worker().on_delivery_arrived()
	scene.get_worker().on_delivery_arrived()
	scene.get_worker().hire()
	# Stand where the camera sees the gate, the pallet and the counter.
	scene.get_node("Player").place(Vector3(9.0, 0.1, -5.0), 2.4)


func _seconds(seconds: float) -> void:
	await create_timer(seconds).timeout
