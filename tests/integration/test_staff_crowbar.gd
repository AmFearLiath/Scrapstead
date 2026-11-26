extends TestSuite
## Nailed crates open with the crowbar right where they lie, by the player or
## by Juri, who fetches the crowbar from its rack himself. The toaster is a
## second device for the dismantling table (docs/first-employee.md, 4c).

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const CRATE_ENTRY: int = 10
const TOASTER_ENTRY: int = 11

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
	return scene


func _buy(scene: Node, ware_id: String) -> void:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition(ware_id)
	scene.get_wallet().credit(definition.price, "test-" + ware_id, "test")
	check(scene.get_upgrades().purchase(ware_id, scene.get_wallet()) == UpgradeProgress.PurchaseResult.OK,
		"%s bought" % ware_id)


func _prepare(scene: Node, crowbar: bool, hire: bool, entry: int) -> YardWorker:
	_buy(scene, "yard_entrance")
	if crowbar:
		_buy(scene, "tool_crowbar")
		(scene.get_world_object("station_order_desk") as OrderDesk).refresh_deliveries(scene.get_upgrades())
	scene.get_wallet().credit(20, "test-fee", "test")
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = entry
	# No regular deliveries in between: the tests count credits exactly.
	deliveries._timer = 100000.0
	var worker: YardWorker = scene.get_worker()
	if hire:
		worker.hire()
	return worker


func _deliver(scene: Node, item_id: String) -> ScrapItem:
	for item: ScrapItem in scene.get_deliveries().deliver_next():
		if item.get_item_id() == item_id:
			return item
	check(false, "%s delivered" % item_id)
	return null


func _work_until(condition: Callable, game_seconds: float = 120.0) -> bool:
	Engine.time_scale = 4.0
	var waited: float = 0.0
	while waited < game_seconds:
		if condition.call():
			Engine.time_scale = 1.0
			return true
		await tree.physics_frame
		waited += 4.0 / Engine.physics_ticks_per_second
	Engine.time_scale = 1.0
	return condition.call()


func test_player_pries_a_crate_open_where_it_lies() -> void:
	var scene: Node = await _new_game()
	_prepare(scene, false, false, CRATE_ENTRY)
	await wait_process_frames(2)
	var crate: ScrapItem = _deliver(scene, "sealed_crate")
	check(not crate.can_be_opened(), "no crowbar yet")
	check_eq(crate.get_action_key(), "ui.action.pick_up", "without a crowbar it is just a crate to carry")
	check(crate.get_prompt_detail(scene._context).contains(tr("tool.crowbar.name")), "prompt mentions the crowbar")
	_buy(scene, "tool_crowbar")
	check(crate.can_be_opened(), "opens once the yard owns a crowbar")
	check_eq(crate.get_action_key(), "ui.action.pry_open", "action changes")
	check(crate.get_hold_duration() > 1.0, "prying takes a moment")
	var centre: Vector3 = crate.global_position
	var crate_id: String = crate.object_id
	var result: Dictionary = crate.interact(scene._context)
	check(result["success"], "pried open")
	check(scene.get_inventory().is_empty(), "nothing went into the basket")
	await wait_process_frames(2)
	check(scene.get_world_object(crate_id) == null, "crate consumed")
	var contents: Array = []
	for item: ScrapItem in scene.get_deliveries().get_live_items():
		check(item.global_position.distance_to(centre) < 0.6, "%s lies where the crate was" % item.get_item_id())
		contents.append(item.get_item_id())
	contents.sort()
	check_eq(contents, ["scrap_copper_pipe", "scrap_rusted_bolt", "scrap_wire_coil"], "three pieces inside")
	var pipe_position: Vector3 = Vector3.ZERO
	var pipe_id: String = ""
	for item: ScrapItem in scene.get_deliveries().get_live_items():
		if item.get_item_id() == "scrap_copper_pipe":
			pipe_position = item.global_position
			pipe_id = item.object_id
	check(scene.save_game(), "save after opening")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	var pipe: ScrapItem = scene.get_world_object(pipe_id) as ScrapItem
	check(pipe != null and pipe.global_position.distance_to(pipe_position) < 0.05, "contents keep their place")
	check(scene.get_world_object(crate_id) == null, "the crate stays opened")


func test_without_a_crowbar_juri_leaves_the_crate_and_says_why() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, false, true, CRATE_ENTRY)
	await wait_process_frames(2)
	var remarks: Array = []
	worker.remark.connect(func(key: String) -> void: remarks.append(key))
	var crate: ScrapItem = _deliver(scene, "sealed_crate")
	await _work_until(func() -> bool: return false, 8.0)
	check_eq(crate.get_state(), ScrapItem.State.IN_WORLD, "crate stays shut on the pallet")
	check_eq(worker.get_missing_tool(), YardWorker.TOOL_CROWBAR, "he knows he needs the crowbar")
	check(remarks.has("staff.juri.needs_crowbar.1"), "and says so")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.staff_needs_crowbar")), "note asks for a crowbar")


func test_juri_fetches_the_crowbar_opens_the_crate_and_sells_the_contents() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true, true, CRATE_ENTRY)
	await wait_process_frames(2)
	var rack: Node3D = worker.crowbar_display
	check(rack.visible, "crowbar on its rack")
	var before: int = scene.get_wallet().get_balance()
	var crate: ScrapItem = _deliver(scene, "sealed_crate")
	var crate_id: String = crate.object_id
	var took: bool = await _work_until(func() -> bool: return worker.get_tool() == YardWorker.TOOL_CROWBAR)
	check(took, "fetches the crowbar")
	check(not rack.visible, "rack empty while he uses it")
	var opened: bool = await _work_until(func() -> bool: return scene.get_world_object(crate_id) == null)
	check(opened, "pries the crate open")
	check_eq(worker.get_stats()["opened"], 1, "counted")
	var sold: bool = await _work_until(func() -> bool: return (scene.get_deliveries().get_live_items().is_empty()
		and worker.get_carried_items().is_empty()))
	check(sold, "sells what was inside")
	var value: int = 6 + 7 + 3
	check_eq(scene.get_wallet().get_balance() - before, value - 3 * worker.profile.wage_per_item,
		"pipe, coil and bolt minus three wages")
	var parked: bool = await _work_until(func() -> bool: return worker.get_tool().is_empty())
	check(parked, "puts the crowbar back")
	check(rack.visible, "crowbar back on its rack")
	check_eq(worker.get_squeeze_count(), 0, "the way to the rack is free")


func test_toaster_is_dismantled_by_juri_for_more() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, false, true, TOASTER_ENTRY)
	await wait_process_frames(2)
	var station: DismantleStation = scene.get_world_object("station_dismantle_table")
	var toaster_profile: ProcessingProfile = station.get_profile_for("device_broken_toaster")
	check(toaster_profile != null, "the table knows the toaster")
	check(toaster_profile.get_output_value() > 6, "dismantling adds value")
	var before: int = scene.get_wallet().get_balance()
	_deliver(scene, "device_broken_toaster")
	var done: bool = await _work_until(func() -> bool: return (worker.get_stats()["dismantled"] >= 1
		and scene.get_deliveries().get_live_items().is_empty() and worker.get_carried_items().is_empty()), 180.0)
	check(done, "toaster dismantled and everything sold")
	var expected: int = toaster_profile.get_output_value() + 2 - 3 * worker.profile.wage_per_item
	check_eq(scene.get_wallet().get_balance() - before, expected, "wire, bolt and the can minus wages")
