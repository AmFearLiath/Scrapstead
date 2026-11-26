extends TestSuite
## Neighbors' scrap deliveries at the drop-off spot (procurement path 2,
## docs/deliveries.md): unlocked by the entrance, paced, saved, never a farm.

const YARD: String = "res://scenes/world/OldYardTest.tscn"

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


func _unlock(scene: Node) -> void:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(definition.price, "test-entrance", "test")
	check(scene.get_upgrades().purchase("yard_entrance", scene.get_wallet()) == UpgradeProgress.PurchaseResult.OK,
		"entrance bought")


func _pick_up(scene: Node, item: ScrapItem) -> void:
	var result: Dictionary = item.interact(scene._context)
	check(result.get("success", false), "picked up %s" % item.object_id)


func _sell_all(scene: Node) -> int:
	var station: SellStation = scene.get_world_object("station_sell_counter") as SellStation
	station.interact(scene._context)
	var result: Dictionary = station.confirm_sale(station.create_quote())
	await wait_process_frames(2)
	return int(result.get("message_args", {}).get("total", 0))


func test_table_is_valid_and_only_delivers_common_scrap_and_devices() -> void:
	var table: DeliveryTable = load("res://data/deliveries/neighbor_deliveries.tres")
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	var problems: PackedStringArray = table.validate(catalog)
	check(problems.is_empty(), "table valid: %s" % ", ".join(problems))
	var total: int = 0
	for entry: Dictionary in table.entries:
		for item_id: String in entry["items"]:
			var definition: ItemDefinition = catalog.get_definition(item_id)
			total += definition.sell_value
			check(definition.category in ["loose_scrap", "device", "bulk_scrap"], "%s is common scrap, a broken device or a heavy piece" % item_id)
			check(definition.carry_size <= 2 or definition.category == "bulk_scrap", "%s fits a basket" % item_id)
		for key: String in [entry["sender"], entry["note"]]:
			for locale: String in ["de", "en"]:
				TranslationServer.set_locale(locale)
				check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")
	var per_minute: float = float(total) / table.entries.size() / table.interval_seconds * 60.0
	check(per_minute > 2.0 and per_minute < 8.0, "modest income: %.1f Cr/min" % per_minute)


func test_nothing_arrives_before_the_entrance_is_spruced_up() -> void:
	var scene: Node = await _new_game()
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	check(deliveries != null, "drop-off spot in the yard")
	check(not deliveries.is_unlocked(), "locked at the start")
	deliveries._process(10000.0)
	check(deliveries.get_live_items().is_empty(), "no delivery while locked")
	_unlock(scene)
	check(deliveries.is_unlocked(), "unlocked by the entrance")
	check_near(deliveries.get_seconds_until_next(), 25.0, 0.5, "first delivery soon after")


func test_delivery_spawns_real_items_that_can_be_sold_and_then_vanish() -> void:
	var scene: Node = await _new_game()
	_unlock(scene)
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	var arrived: Array = []
	deliveries.delivery_arrived.connect(func(entry: Dictionary, _items: Array) -> void: arrived.append(entry))
	deliveries._process(30.0)
	await wait_physics_frames(2)
	check_eq(arrived.size(), 1, "one delivery after the first delay")
	var items: Array[ScrapItem] = deliveries.get_live_items()
	check_eq(items.size(), 3, "first entry delivers three items")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.delivery_waiting")), "note points at the gate")
	for item: ScrapItem in items:
		check(scene.get_world_object(item.object_id) == item, "%s registered" % item.object_id)
		check(item.global_position.distance_to(deliveries.global_position) < 1.6, "lies on the pallet")
	for item: ScrapItem in items:
		_pick_up(scene, item)
	check(not scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.delivery_waiting")),
		"note gone once everything is picked up")
	var balance_before: int = scene.get_wallet().get_balance()
	await _sell_all(scene)
	check_eq(scene.get_wallet().get_balance() - balance_before, 12, "Mrs Pohl's scrap sells for 12 Cr")
	await wait_process_frames(2)
	check(deliveries.get_live_items().is_empty(), "sold deliveries leave the world")
	for item_id: String in ["delivery_1", "delivery_2", "delivery_3"]:
		check(scene.get_world_object(item_id) == null, "%s unregistered" % item_id)
	check(not scene.create_snapshot()["world_objects"].has("delivery_1"), "nothing left in the save")


func test_full_drop_off_spot_holds_back_the_next_delivery() -> void:
	var scene: Node = await _new_game()
	_unlock(scene)
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries._process(30.0)
	check_eq(deliveries.get_waiting_count(), 3, "first delivery waiting")
	deliveries._process(1000.0)
	check_eq(deliveries.get_live_items().size(), 3, "no second delivery while scrap is still lying around")
	check_near(deliveries.get_seconds_until_next(), ScrapDeliveries.BLOCKED_RETRY_SECONDS, 0.01, "retries later")
	var items: Array[ScrapItem] = deliveries.get_live_items()
	_pick_up(scene, items[0])
	_pick_up(scene, items[1])
	deliveries._process(ScrapDeliveries.BLOCKED_RETRY_SECONDS + 1.0)
	check_eq(deliveries.get_live_items().size(), 6, "next delivery once the spot is mostly cleared")
	var ids: Dictionary = {}
	for item: ScrapItem in deliveries.get_live_items():
		check(not ids.has(item.object_id), "unique id %s" % item.object_id)
		ids[item.object_id] = true
	var lying: Array = deliveries.get_live_items().filter(
		func(item: ScrapItem) -> bool: return item.get_state() == ScrapItem.State.IN_WORLD)
	for a: int in lying.size():
		for b: int in range(a + 1, lying.size()):
			check(lying[a].global_position.distance_to(lying[b].global_position) > 0.3, "items do not overlap")


func test_entries_follow_the_authored_order_and_repeat() -> void:
	var scene: Node = await _new_game()
	_unlock(scene)
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	var senders: Array = []
	deliveries.delivery_arrived.connect(func(entry: Dictionary, _items: Array) -> void:
		senders.append(entry["sender"]))
	var count: int = deliveries.table.entries.size()
	for index: int in count + 1:
		deliveries.deliver_next()
	check_eq(senders[0], deliveries.table.entries[0]["sender"], "starts with the first entry")
	check_eq(senders[count], senders[0], "cycles back to the start")


func test_deliveries_survive_save_and_continue() -> void:
	var scene: Node = await _new_game()
	_unlock(scene)
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries._process(30.0)
	var items: Array[ScrapItem] = deliveries.get_live_items()
	_pick_up(scene, items[0])
	scene.get_node("Player").place(Vector3(9.0, 0.1, -4.0), PI)
	await wait_physics_frames(2)
	scene.drop_last_item()
	var dropped_at: Vector3 = items[0].global_position
	var dropped_id: String = items[0].object_id
	_pick_up(scene, items[1])
	var carried_id: String = items[1].object_id
	var waiting_id: String = items[2].object_id
	deliveries._process(40.0)
	var timer_before: float = deliveries.get_seconds_until_next()
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	deliveries = scene.get_deliveries()
	check_eq(deliveries.get_live_items().size(), 3, "delivered items restored")
	var dropped: ScrapItem = scene.get_world_object(dropped_id) as ScrapItem
	check(dropped != null and dropped.global_position.distance_to(dropped_at) < 0.05, "moved item keeps its place")
	check(scene.get_inventory().contains(carried_id), "carried delivery still in the basket")
	var waiting: ScrapItem = scene.get_world_object(waiting_id) as ScrapItem
	check(waiting != null and waiting.get_state() == ScrapItem.State.IN_WORLD, "waiting item still on the pallet")
	check_near(deliveries.get_seconds_until_next(), timer_before, 0.5, "timer continues, no offline time")
	await _sell_all(scene)
	check(scene.get_world_object(carried_id) == null, "restored delivery can be sold")


func test_scrappy_comments_the_first_delivery_once() -> void:
	var scene: Node = await _new_game()
	scene.get_story().set_flag(StoryDirector.FLAG_RESTORED)
	scene.get_node("Scrappy").apply_save_state({"state": "active", "follow": true})
	_unlock(scene)
	var director: StoryDirector = scene.get_node("StoryDirector")
	var spoken: Array = []
	director.line_spoken.connect(func(key: String) -> void: spoken.append(key))
	scene.get_deliveries().deliver_next()
	await wait_process_frames(2)
	check(spoken.has("scrappy.delivery_first.1"), "first delivery is celebrated")
	check(scene.get_story().was_spoken("scrappy.delivery_first.1"), "remembered as said")


func test_old_version_3_save_migrates_without_deliveries() -> void:
	var service: Node = tree.root.get_node("SaveService")
	var data: Dictionary = _session.create_initial_state()
	data["save_version"] = 3
	data.erase("deliveries")
	DirAccess.make_dir_recursive_absolute(service.save_directory)
	var file := FileAccess.open(service.get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var result: Dictionary = service.load_game()
	check(result["ok"], "v3 save loads")
	check_eq(result["data"].get("deliveries"), {}, "empty delivery state added")
	data["save_version"] = 4
	data["deliveries"] = {"items": [{"id": 5}]}
	check(not service.validate_save_data(data), "broken delivery entry rejected")
