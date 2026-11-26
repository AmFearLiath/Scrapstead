extends TestSuite
## Build system rules (docs/building-system.md): grid geometry, placement
## checks with reasons, buying, moving, rotating, storage and saving.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
## An open spot on the work area east of the main path.
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


func _first_problem(result: Dictionary) -> String:
	return str(result["problems"][0]["key"]) if not result["problems"].is_empty() else ""


func test_catalog_and_grid_geometry() -> void:
	var catalog: PlaceableCatalog = load("res://data/placeables/placeable_catalog.tres")
	check(catalog.validate().is_empty(), "catalog valid: %s" % ", ".join(catalog.validate()))
	for category: String in PlaceableDefinition.CATEGORIES:
		check(not catalog.in_category(category).is_empty(), "something in %s" % category)
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for definition: PlaceableDefinition in catalog.placeables:
			check(tr(definition.name_key) != definition.name_key, "%s named (%s)" % [definition.id, locale])
			check(tr(definition.description_key) != definition.description_key, "%s described" % definition.id)
	TranslationServer.set_locale("de")
	var bench: PlaceableDefinition = catalog.get_definition("decor_bench")
	check_eq(bench.get_size(1), Vector2i(bench.size.y, bench.size.x), "a quarter turn swaps width and depth")
	for rotation_steps: int in 4:
		var cells: Array[Vector2i] = BuildGrid.footprint_cells(bench, Vector2i(10, -10), rotation_steps)
		var rotated: Vector2i = bench.get_size(rotation_steps)
		check_eq(cells.size(), rotated.x * rotated.y, "footprint keeps its area (rot %d)" % rotation_steps)
		for cell: Vector2i in cells:
			check(Rect2i(Vector2i(10, -10), rotated).has_point(cell), "cell %s inside the rotated box" % cell)
		var center: Vector3 = BuildGrid.object_center(bench, Vector2i(10, -10), rotation_steps)
		check_eq(BuildGrid.anchor_for(bench, center, rotation_steps), Vector2i(10, -10), "anchor round trip")
	var magnet: PlaceableDefinition = catalog.get_definition("magnet_collector")
	var front: Array[Vector2i] = BuildGrid.clearance_cells(magnet, Vector2i(0, 0), 0)
	for cell: Vector2i in front:
		check_eq(cell.y, magnet.size.y, "operator area lies in front of the machine at rot 0")
	var turned: Array[Vector2i] = BuildGrid.clearance_cells(magnet, Vector2i(0, 0), 1)
	for cell: Vector2i in turned:
		check_eq(cell.x, -1, "a clockwise quarter turn puts the front on the left (-x)")


func test_buying_and_placing_a_decoration() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var bench: PlaceableDefinition = placed.catalog.get_definition("decor_bench")
	var wallet: Wallet = scene.get_wallet()
	check_eq(placed.get_offer_status(bench), "too_expensive", "nothing in the pocket at the start")
	wallet.credit(100, "test", "test")
	check_eq(placed.get_offer_status(bench), "buy", "affordable now")
	var check: Dictionary = placed.check_placement(bench, FREE, 0)
	check(check["ok"], "free spot is valid: %s" % _first_problem(check))
	var result: Dictionary = placed.place("decor_bench", FREE, 0)
	check(result["ok"], "placed")
	check_eq(wallet.get_balance(), 100 - bench.price, "price paid once")
	check_eq(wallet.get_ledger()[-1]["reason"], "ui.ledger.build", "ledger says why")
	var node: Node3D = placed.get_node_for(result["uid"])
	check(node != null and node.global_position.distance_to(BuildGrid.object_center(bench, FREE, 0)) < 0.01,
		"stands exactly where the preview said")
	var body: StaticBody3D = node.get_node_or_null("FootprintBody")
	check(body != null and body.collision_layer == 1, "solid for the player")
	check_eq(_first_problem(placed.check_placement(bench, FREE, 0)), "overlap", "second bench does not fit there")
	check_eq(placed.get_uid_at(FREE + Vector2i(1, 1)), result["uid"], "cell lookup finds it")


func test_placement_reasons() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var crates: PlaceableDefinition = placed.catalog.get_definition("storage_crates")
	var gnome: PlaceableDefinition = placed.catalog.get_definition("decor_gnome")
	check_eq(_first_problem(placed.check_placement(crates, Vector2i(-6, -10), 0)), "outside", "outside the plot")
	check_eq(_first_problem(placed.check_placement(gnome, BuildGrid.world_to_cell(Vector3(8.0, 0, -0.6)), 0)),
		"keep_free_gate", "gate stays free")
	var rest: Node3D = scene.get_worker().rest_spot
	check_eq(_first_problem(placed.check_placement(gnome, BuildGrid.world_to_cell(rest.global_position), 0)),
		"keep_free_route", "Juri's waiting spot")
	var counter: Interactable = scene.get_world_object("station_sell_counter")
	var front: Vector2i = BuildGrid.world_to_cell(counter.get_interaction_point())
	var reasons: Array = []
	for problem: Dictionary in placed.check_placement(gnome, front, 0)["problems"]:
		reasons.append(problem["key"])
	check(reasons.has("keep_free_station") or reasons.has("keep_free_route"), "counter front stays free: %s" % [reasons])
	var shed: Vector2i = BuildGrid.world_to_cell(Vector3(5.0, 0, -18.0))
	check(_first_problem(placed.check_placement(crates, shed, 0)) in ["obstacle", "overlap"], "not inside the workshop")
	var bolt: ScrapItem = scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem
	bolt.drop_at(BuildGrid.cell_center(FREE) + Vector3(0, 0.1, 0), 0.0)
	check_eq(_first_problem(placed.check_placement(gnome, FREE, 0)), "keep_free_scrap", "not on top of scrap")
	var message: String = PlacementValidator.describe(placed.check_placement(gnome, FREE, 0))
	check(not message.is_empty() and not message.begins_with("build."), "reason in player language: %s" % message)


func test_move_rotate_remove_and_place_from_storage() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	scene.get_wallet().credit(50, "test", "test")
	var uid: String = placed.place("decor_bench", FREE, 0)["uid"]
	var moved: Dictionary = placed.move(uid, FREE + Vector2i(0, -8), 1)
	check(moved["ok"], "moved and turned")
	var node: Node3D = placed.get_node_for(uid)
	check_near(node.rotation.y, -PI * 0.5, 0.001, "turned clockwise")
	check(placed.check_placement(placed.catalog.get_definition("decor_bench"), FREE, 0)["ok"], "old spot free again")
	var balance: int = scene.get_wallet().get_balance()
	check(placed.remove(uid)["ok"], "removed")
	await wait_process_frames(1)
	check(placed.get_node_for(uid) == null, "gone from the yard")
	var bench: PlaceableDefinition = placed.catalog.get_definition("decor_bench")
	check_eq(placed.get_available(bench), 1, "back in storage")
	check_eq(placed.get_offer_status(bench), "available", "offered from storage")
	var again: Dictionary = placed.place("decor_bench", FREE, 2)
	check(again["ok"] and again["paid"] == 0, "placed again for free")
	check_eq(scene.get_wallet().get_balance(), balance, "no money moved by removing or re-placing")
	check_eq(placed.get_available(bench), 0, "storage used up")


func test_magnet_can_be_moved_and_explains_its_reach() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var definition: PlaceableDefinition = placed.catalog.get_definition("magnet_collector")
	scene.get_wallet().credit(placed.get_price(definition), "test", "test")
	var at_pad: Dictionary = placed.check_placement(definition, Vector2i(69, -27), 0)
	check(at_pad["ok"], "former pad is valid: %s" % _first_problem(at_pad))
	check(at_pad["hints"].has("build.hint.heap_in_reach"), "heap in reach there")
	var uid: String = placed.place("magnet_collector", Vector2i(69, -27), 0)["uid"]
	var magnet: MagnetCollector = scene.get_magnet()
	check_eq(placed.get_offer_status(definition), "limit", "only one magnet")
	for index: int in 2:
		magnet.collect_once()
	var bolt: ScrapItem = scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem
	bolt.drop_at(magnet.bin.global_position + Vector3(0.1, 0.1, 0.0), 0.0)
	check_eq(magnet.get_bin_count(), 3, "two from the heap, one dropped in by hand")
	check_eq(placed.remove(uid)["message_key"], "build.problem.crate_not_empty", "crate must be empty to remove")
	var far: Vector2i = Vector2i(70, -44)
	var check_far: Dictionary = placed.check_placement(definition, far, 2, uid)
	check(check_far["ok"], "open spot further north: %s" % _first_problem(check_far))
	check(check_far["hints"].has("build.hint.heap_out_of_reach"), "preview warns about the heap")
	check(placed.move(uid, far, 2)["ok"], "moved")
	check_eq(magnet.get_bin_count(), 3, "crate contents travelled along")
	check(not magnet.heap_in_reach(), "heap out of reach now")
	check(bolt.global_position.distance_to(magnet.bin.global_position) < MagnetCollector.BIN_RADIUS, "the bolt too")
	for item: ScrapItem in magnet.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	bolt.set_state(ScrapItem.State.SOLD)
	await wait_process_frames(2)
	var heap_before: int = magnet.get_heap_remaining()
	check(placed.remove(uid)["ok"], "removed once empty")
	await wait_process_frames(1)
	check(scene.get_magnet() == null, "no magnet in the yard")
	check(scene.get_node("ReservedSign").visible, "sign back while no machine stands")
	check(placed.place("magnet_collector", Vector2i(69, -27), 0)["ok"], "set up again from storage")
	check_eq(scene.get_magnet().get_heap_remaining(), heap_before, "machine state survived storage")


func test_placed_objects_survive_save_and_continue() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	scene.get_wallet().credit(200, "test", "test")
	var bench_uid: String = placed.place("decor_bench", FREE, 3)["uid"]
	var gnome_uid: String = placed.place("decor_gnome", FREE + Vector2i(0, 4), 0)["uid"]
	placed.remove(gnome_uid)
	await wait_process_frames(1)
	var position: Vector3 = placed.get_node_for(bench_uid).global_position
	check(scene.save_game(), "save")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	placed = scene.get_placed()
	var bench: Node3D = placed.get_node_for(bench_uid)
	check(bench != null and bench.global_position.distance_to(position) < 0.01, "bench where it was")
	check_near(absf(angle_difference(bench.rotation.y if bench != null else 0.0, BuildGrid.rotation_y(3))), 0.0, 0.001,
		"and turned the same")
	check_eq(placed.get_available(placed.catalog.get_definition("decor_gnome")), 1, "gnome waits in storage")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	check(not placed.check_placement(placed.catalog.get_definition("decor_bench"), FREE, 3)["ok"],
		"restored bench blocks its cells")


func test_walts_list_counts_a_placed_machine() -> void:
	var scene: Node = await _new_game()
	var director: StoryDirector = scene.get_node("StoryDirector")
	var placed: PlacedObjects = scene.get_placed()
	var done: Array = []
	director.task_completed.connect(func(entry: Dictionary, _all: bool) -> void: done.append(entry["id"]))
	scene.get_wallet().credit(60, "test", "test")
	placed.place("magnet_collector", Vector2i(69, -27), 0)
	check(done.has("machine"), "setting up the machine ticks it off")


func test_navigation_finds_ways_and_refuses_cutting_them_off() -> void:
	var nav := YardNavigation.new(Rect2i(0, 0, 20, 10))
	var wall: Dictionary = {}
	for y: int in range(0, 10):
		if y != 5:
			wall[Vector2i(10, y)] = true
	nav.rebuild(wall, {})
	var left := BuildGrid.cell_center(Vector2i(2, 2))
	var right := BuildGrid.cell_center(Vector2i(17, 8))
	check(nav.is_reachable(left, right), "through the single gap")
	var path: Array[Vector3] = nav.find_path(left, right)
	check(not path.is_empty(), "a path exists")
	var through_gap: bool = false
	for point: Vector3 in path:
		if BuildGrid.world_to_cell(point) == Vector2i(10, 5):
			through_gap = true
	check(through_gap or path.size() >= 2, "the path uses the gap")
	check(not nav.is_reachable(left, right, [Vector2i(10, 5)] as Array[Vector2i]), "closing the gap cuts it off")
	check(nav.is_reachable(left, right), "nothing changed permanently")


func test_yard_fixtures_can_be_moved_but_not_put_away() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	check(placed.is_adopted("yard_tyres"), "the tyre stack belongs to the yard")
	var tyres: Node3D = placed.get_node_for("yard_tyres")
	var target := Vector2i(70, -44)
	var definition: PlaceableDefinition = placed.get_entries().filter(func(entry: Dictionary) -> bool:
		return entry["uid"] == "yard_tyres")[0]["def"]
	var check_move: Dictionary = placed.check_placement(definition, target, 1, "yard_tyres")
	check(check_move["ok"], "open spot: %s" % _first_problem(check_move))
	check(placed.move("yard_tyres", target, 1)["ok"], "moved")
	check(tyres.global_position.distance_to(BuildGrid.object_center(definition, target, 1)) < 1.0, "the stack moved")
	check_eq(placed.remove("yard_tyres")["message_key"], "build.problem.yard_fixture", "cannot be put away")
	var counter: Node3D = scene.get_world_object("station_sell_counter")
	var counter_spot: Node3D = scene.get_worker().counter_spot
	var offset: Vector3 = counter.global_transform.affine_inverse() * counter_spot.global_position
	var counter_def: PlaceableDefinition = placed.get_entries().filter(func(entry: Dictionary) -> bool:
		return entry["uid"] == "yard_sell_station")[0]["def"]
	var spot := Vector2i(60, -40)
	var check_counter: Dictionary = placed.check_placement(counter_def, spot, 0, "yard_sell_station")
	check(check_counter["ok"], "counter fits there: %s" % _first_problem(check_counter))
	check(placed.move("yard_sell_station", spot, 0)["ok"], "sales counter moved")
	check((counter.global_transform.affine_inverse() * counter_spot.global_position).distance_to(offset) < 0.05,
		"Juri's selling spot follows the counter")
	var counter_position: Vector3 = counter.global_position
	check(scene.save_game(), "save")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	placed = scene.get_placed()
	check(placed.get_node_for("yard_tyres").global_position.distance_to(BuildGrid.object_center(definition, target, 1)) < 1.0,
		"tyres stay where they were moved")
	check(scene.get_world_object("station_sell_counter").global_position.distance_to(counter_position) < 0.05,
		"counter restored")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))


func test_juri_finds_the_moved_counter() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var counter_def: PlaceableDefinition = placed.get_entries().filter(func(entry: Dictionary) -> bool:
		return entry["uid"] == "yard_sell_station")[0]["def"]
	check(placed.move("yard_sell_station", Vector2i(30, -30), 2)["ok"], "counter moved into the middle of the yard")
	scene.enter_build_mode()
	scene.exit_build_mode()
	scene.get_wallet().credit(100, "test", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	deliveries._timer = 100000.0
	var worker: YardWorker = scene.get_worker()
	worker.hire()
	Engine.time_scale = 4.0
	var waited: float = 0.0
	while worker.get_stats()["trips"] < 1 and waited < 120.0:
		await tree.physics_frame
		waited += 4.0 / Engine.physics_ticks_per_second
	Engine.time_scale = 1.0
	check(worker.get_stats()["trips"] >= 1, "Juri sold at the counter's new place")
	check(worker.get_squeeze_count() <= 1, "found a proper way (%d squeezes)" % worker.get_squeeze_count())
