extends TestSuite
## Dismantling beyond the authored radio: the station takes any broken radio,
## and Juri takes delivered radios there before selling them, so the yard and
## he both earn more (docs/first-employee.md, section 4).

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const RADIO_ENTRY: int = 4

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


## Entrance bought, Juri waits at the gate, pallet cleared, next delivery is a radio.
func _prepare(scene: Node, hire: bool) -> YardWorker:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(definition.price + 40, "test-setup", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = RADIO_ENTRY
	var worker: YardWorker = scene.get_worker()
	if hire:
		worker.hire()
	return worker


func _radio(scene: Node) -> ScrapItem:
	var items: Array[ScrapItem] = scene.get_deliveries().deliver_next()
	check_eq(items.size(), 1, "Mrs Pohl's polka radio arrives")
	check_eq(items[0].get_item_id(), "device_broken_radio", "it is a broken radio")
	return items[0]


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


func test_player_dismantles_a_delivered_radio_into_fresh_parts() -> void:
	var scene: Node = await _new_game()
	await wait_process_frames(1)
	_prepare(scene, false)
	await wait_process_frames(2)
	var radio: ScrapItem = _radio(scene)
	check(radio.interact(scene._context)["success"], "player picks up the radio")
	var station: DismantleStation = scene.get_world_object("station_dismantle_table")
	var output_value: int = station.profile.get_output_value()
	check(station.check_requirements(scene._context)["ok"], "station accepts any radio")
	var result: Dictionary = station.interact(scene._context)
	check(result["success"], "dismantled")
	check_eq(radio.get_state(), ScrapItem.State.PROCESSED, "radio consumed")
	var outputs: Array = []
	for entry: Dictionary in scene.get_inventory().get_entries():
		outputs.append(entry["object_id"])
	check_eq(outputs, ["dismantled_1", "dismantled_2"], "two fresh parts in the basket")
	check_eq(scene.get_world_object("device_broken_radio_01_copper_wire").get_state(), ScrapItem.State.PENDING,
		"the authored radio's parts stay reserved for it")
	check(scene.save_game(), "save with fresh parts")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	check(scene.get_inventory().contains("dismantled_1") and scene.get_inventory().contains("dismantled_2"),
		"fresh parts restored in the basket")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	var counter: SellStation = scene.get_world_object("station_sell_counter") as SellStation
	var before: int = scene.get_wallet().get_balance()
	counter.interact(scene._context)
	counter.confirm_sale(counter.create_quote())
	await wait_process_frames(2)
	check_eq(scene.get_wallet().get_balance() - before, output_value, "parts sell for 16")
	check(scene.get_world_object("dismantled_1") == null, "sold parts leave the world")
	check(not scene.create_snapshot()["world_objects"].has("dismantled_1"), "and the save")


func test_juri_takes_a_radio_to_the_table_and_both_earn_more() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true)
	await wait_process_frames(2)
	var wallet: Wallet = scene.get_wallet()
	var before: int = wallet.get_balance()
	var radio: ScrapItem = _radio(scene)
	var radio_value: int = radio.definition.sell_value
	var station: DismantleStation = scene.get_world_object("station_dismantle_table")
	var at_table: bool = await _work_until(func() -> bool: return worker._task == YardWorker.Task.DISMANTLING)
	check(at_table, "Juri walks to the dismantling table")
	check_eq(worker.get_carried_items(), [radio] as Array[ScrapItem], "carrying the radio alone")
	var done: bool = await _work_until(func() -> bool: return worker.get_stats()["trips"] >= 1)
	check(done, "dismantled and sold")
	check_eq(worker.get_stats()["dismantled"], 1, "one device dismantled")
	var wage: int = station.profile.outputs.size() * worker.profile.wage_per_item
	check_eq(wallet.get_balance() - before, station.profile.get_output_value() - wage, "16 Cr minus his 2 Cr wage")
	check(station.profile.get_output_value() - wage > radio_value - worker.profile.wage_per_item,
		"more for the yard than selling the radio as it is")
	check(wage > worker.profile.wage_per_item, "and more for Juri")
	check_eq(worker.get_squeeze_count(), 0, "the route to the table is free")


func test_without_the_rule_juri_sells_the_radio_as_it_is() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true)
	await wait_process_frames(2)
	check(worker.toggle_dismantling()["success"] and not worker.is_dismantling_devices(), "rule switched off")
	var before: int = scene.get_wallet().get_balance()
	var radio: ScrapItem = _radio(scene)
	var radio_value: int = radio.definition.sell_value
	var sold: bool = await _work_until(func() -> bool: return worker.get_stats()["trips"] >= 1)
	check(sold, "sold directly")
	check_eq(worker.get_stats()["dismantled"], 0, "nothing dismantled")
	check_eq(scene.get_wallet().get_balance() - before, radio_value - worker.profile.wage_per_item,
		"12 Cr minus 1 Cr wage")


func test_devices_travel_alone_and_survive_a_restart_mid_trip() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true)
	await wait_process_frames(2)
	worker.toggle_pause()
	var radio: ScrapItem = _radio(scene)
	var can: ScrapItem = scene.get_world_object("scrap_empty_can_01") as ScrapItem
	can.drop_at(scene.get_deliveries().global_position + Vector3(0.3, 0.13, 0.3), 0.0)
	worker.global_position = radio.global_position + Vector3(0.3, 0, 0.3)
	worker.toggle_pause()
	var picked: bool = await _work_until(func() -> bool: return not worker.get_carried_items().is_empty(), 30.0)
	check(picked, "picked something up")
	await _work_until(func() -> bool: return worker._task != YardWorker.Task.PICKING, 5.0)
	var carried: Array[ScrapItem] = worker.get_carried_items()
	check(carried.size() == 1, "one piece at a time when a device is involved")
	await _work_until(func() -> bool: return worker.get_carried_items().has(radio), 60.0)
	await _work_until(func() -> bool: return worker._task == YardWorker.Task.TO_STATION, 30.0)
	var radio_id: String = radio.object_id
	check(worker.is_carrying(radio_id), "on the way to the table with the radio")
	check(scene.save_game(), "save mid-trip")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	worker = scene.get_worker()
	check(worker.is_carrying(radio_id), "still carrying the radio")
	check(worker.is_dismantling_devices(), "rule kept")
	var done: bool = await _work_until(func() -> bool: return worker.get_stats()["dismantled"] >= 1)
	check(done, "continues to the table after loading")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
