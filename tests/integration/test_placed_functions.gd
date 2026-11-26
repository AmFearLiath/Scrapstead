extends TestSuite
## Placed objects do something (docs/building-system.md): floodlights switch,
## storage stores, gravel paths are faster, Juri rests on a bench and Scrappy
## has opinions about decorations.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const FREE := Vector2i(50, -34)

var _session: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_session.intro_enabled = false
	tree.root.get_node("SaveService").delete_save()
	Engine.time_scale = 1.0


func after_each() -> void:
	Engine.time_scale = 1.0
	tree.root.get_node("SaveService").delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	scene.get_wallet().credit(300, "test", "test")
	return scene


func _continue() -> Node:
	_session.continue_game()
	await wait_process_frames(2)
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	return scene


func test_floodlight_switches_and_remembers() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var uid: String = placed.place("decor_floodlight", FREE, 0)["uid"]
	var light: PlacedFloodlight = placed.get_node_for(uid) as PlacedFloodlight
	check(light != null and light.is_on(), "new floodlight is on")
	check(light.get_node("Light").visible, "the spot light shines")
	var switch: FloodlightSwitch = light.get_node("Switch")
	check(switch.is_interaction_available(), "switch can be used")
	check_eq(switch.get_action_key(), "ui.action.light_off", "offers switching off")
	check(switch.interact(scene._context)["success"], "switched")
	check(not light.is_on() and not light.get_node("Light").visible, "dark now")
	check(scene.save_game(), "save")
	scene = await _continue()
	light = scene.get_placed().get_node_for(uid) as PlacedFloodlight
	check(light != null and not light.is_on(), "still off after loading")


func test_storage_stores_and_gives_back() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var uid: String = placed.place("storage_barrels", FREE, 0)["uid"]
	var storage: PlacedStorage = placed.get_node_for(uid).get_node("Storage")
	check_eq(storage.capacity, 4, "barrels hold four pieces")
	scene.get_upgrades().purchase("upgrade_carry_basket", scene.get_wallet())
	var ids: Array = []
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_wire_coil_01",
			"scrap_rusted_bolt_02", "scrap_empty_can_02"]:
		var item: ScrapItem = scene.get_world_object(object_id) as ScrapItem
		check(item.interact(scene._context)["success"], "picked up %s" % object_id)
		ids.append(object_id)
	check_eq(storage.get_action_key(), "ui.action.store", "offers storing")
	var result: Dictionary = storage.interact(scene._context)
	check(result["success"], "stored")
	check_eq(storage.get_stored_ids().size(), 4, "four fit")
	check_eq(scene.get_inventory().get_used_slots(), 1, "the fifth stays in the basket")
	var stored: ScrapItem = scene.get_world_object(ids[0]) as ScrapItem
	check_eq(stored.get_state(), ScrapItem.State.STORED, "stored items are put away")
	check(not stored.visible and not stored.is_interaction_available(), "and not lying around")
	check(not storage.check_requirements(scene._context)["ok"], "full now")
	check_eq(placed.remove(uid)["message_key"], "build.problem.storage_not_empty", "full storage cannot be removed")
	check(storage.get_prompt_detail(scene._context).contains("4/4"), "prompt shows the fill")
	check(scene.save_game(), "save with stored items")
	scene = await _continue()
	storage = scene.get_placed().get_node_for(uid).get_node("Storage")
	check_eq(storage.get_stored_ids().size(), 4, "contents survive loading")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	scene.drop_last_item()
	check(scene.get_inventory().is_empty(), "hands empty")
	check_eq(storage.get_action_key(), "ui.action.take_out", "offers taking out")
	check(storage.interact(scene._context)["success"], "taken out")
	check_eq(scene.get_inventory().get_used_slots(), 4, "everything back in the basket")
	check(storage.get_stored_ids().is_empty(), "storage empty")
	check(scene.get_placed().remove(uid)["ok"], "empty storage can go back to the shed")


func test_gravel_paths_make_you_faster() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var player: CharacterBody3D = scene.get_node("Player")
	placed.place("paths_gravel", FREE, 0)
	var on_path: Vector3 = BuildGrid.object_center(placed.catalog.get_definition("paths_gravel"), FREE, 0)
	player.place(on_path + Vector3(0, 0.1, 0), 0.0)
	await wait_physics_frames(3)
	check_near(player.speed_factor, PlacedObjects.PATH_SPEED_FACTOR, 0.001, "faster on gravel")
	player.place(on_path + Vector3(3.0, 0.1, 0), 0.0)
	await wait_physics_frames(3)
	check_near(player.speed_factor, 1.0, 0.001, "normal speed off the path")
	check(not placed.check_placement(placed.catalog.get_definition("decor_gnome"), FREE, 0)["ok"],
		"paths still take their cells")


func test_juri_rests_on_a_bench() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var bench_cell := Vector2i(-1, -1)
	for candidate: Vector2i in [Vector2i(2, -22), Vector2i(2, -26), Vector2i(16, -16), Vector2i(40, -38)]:
		if placed.check_placement(placed.catalog.get_definition("decor_bench"), candidate, 0)["ok"]:
			bench_cell = candidate
			break
	check(placed.place("decor_bench", bench_cell, 0)["ok"], "bench near the gate")
	var bench: Node3D = placed.get_nodes_of("decor_bench")[0]
	var upgrades: UpgradeProgress = scene.get_upgrades()
	upgrades.purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._timer = 100000.0
	var worker: YardWorker = scene.get_worker()
	worker.hire()
	Engine.time_scale = 4.0
	for frame: int in 600:
		await tree.physics_frame
		if worker.get_status() == YardWorker.STATUS_WAITING and worker._task == YardWorker.Task.IDLE:
			break
	Engine.time_scale = 1.0
	var seat: Vector3 = bench.global_position + bench.global_basis.z * 0.75
	check(worker.global_position.distance_to(seat) < 0.6, "Juri waits at the bench (%.2f m away)"
		% worker.global_position.distance_to(seat))


func test_scrappy_comments_on_the_gnome() -> void:
	var scene: Node = await _new_game()
	scene.get_story().set_flag(StoryDirector.FLAG_RESTORED)
	scene.get_node("Scrappy").apply_save_state({"state": "active", "follow": true})
	var spoken: Array = []
	scene.get_node("StoryDirector").line_spoken.connect(func(key: String) -> void: spoken.append(key))
	scene.get_placed().place("decor_gnome", FREE, 0)
	await wait_process_frames(2)
	check(spoken.has("scrappy.built_decor_gnome.1"), "Scrappy likes the gnome")
	for key: String in ["scrappy.built_decor_gnome.1", "scrappy.built_decor_bench.1", "ui.storage.detail",
			"ui.light.switched_on"]:
		for locale: String in ["de", "en"]:
			TranslationServer.set_locale(locale)
			check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")
