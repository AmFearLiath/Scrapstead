extends TestSuite
## The first machine (P3b, docs/first-machine.md): the small magnetic collector
## lifts iron from Walt's finite nail heap (or loose iron nearby) into its
## crate, stops when the crate is full, never creates more than the heap holds
## and survives a restart.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const WARE: String = "machine_magnet_collector"

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


func _buy(scene: Node, ware_id: String) -> Dictionary:
	var desk: OrderDesk = scene.get_world_object("station_order_desk") as OrderDesk
	if desk == null:
		for target: Variant in scene._objects.values():
			if target is OrderDesk:
				desk = target
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition(ware_id)
	scene.get_wallet().credit(definition.price, "test-" + ware_id, "test")
	desk.interact(scene._context)
	return desk.buy(ware_id)


func _installed(scene: Node) -> MagnetCollector:
	var result: Dictionary = _buy(scene, WARE)
	check(result["success"], "magnet bought: %s" % result.get("message_key"))
	return scene.get_magnet()


func test_profile_is_valid_translated_and_pays_off_modestly() -> void:
	var profile: MachineProfile = load("res://data/machines/magnet_collector.tres")
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	check(profile.validate(catalog).is_empty(), "profile valid: %s" % ", ".join(profile.validate(catalog)))
	var heap_value: int = 0
	for index: int in profile.heap_size:
		heap_value += catalog.get_definition(profile.get_heap_item(index)).sell_value
	var ware: UpgradeDefinition = load("res://data/upgrades/machine_magnet_collector.tres")
	check(heap_value > ware.price, "the heap is worth more than the machine (%d > %d Cr)" % [heap_value, ware.price])
	var per_minute: float = float(heap_value) / profile.heap_size / profile.upgraded_cycle_seconds * 60.0
	check(per_minute < 15.0, "even upgraded it stays a side income: %.1f Cr/min" % per_minute)
	for item_id: String in ["scrap_copper_pipe", "scrap_wood_offcut", "find_brass_figurine"]:
		check(not profile.magnetic_items.has(item_id), "%s is not magnetic" % item_id)
	var keys: PackedStringArray = [profile.name_key, profile.description_key, "machine.reserved_sign",
		"machine.heap_sign", "note.magnet_full", "scrappy.machine_installed.1"]
	for status: String in ["working", "off", "bin_full", "empty"]:
		keys.append("ui.machine.status." + status)
	for ware_id: String in [WARE, "upgrade_strong_magnet"]:
		for suffix: String in ["name", "description", "effect", "bought"]:
			keys.append("upgrade.%s.%s" % [ware_id, suffix])
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for key: String in keys:
			check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")


func test_nothing_happens_before_the_machine_is_bought() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = scene.get_magnet()
	check(magnet != null, "machine pad in the yard")
	check(not magnet.is_installed(), "not installed at the start")
	check(magnet.get_node("ReservedPad").visible, "reserved pad shows where it goes")
	check(not magnet.get_node("Machine").visible, "no machine yet")
	check_eq(magnet.get_node("Machine/Body").collision_layer, 0, "no invisible obstacle")
	check(not magnet.get_node("Machine/Controls").is_interaction_available(), "controls not offered")
	magnet._process(1000.0)
	check(magnet.collect_once() == null, "collects nothing")
	check_eq(magnet.get_heap_remaining(), magnet.profile.heap_size, "heap untouched")
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("upgrade_strong_magnet")
	scene.get_wallet().credit(definition.price, "test", "test")
	check(scene.get_upgrades().purchase("upgrade_strong_magnet", scene.get_wallet())
		== UpgradeProgress.PurchaseResult.MISSING_REQUIREMENT, "stronger magnet needs the machine")


func test_bought_machine_fills_its_crate_from_the_heap() -> void:
	var scene: Node = await _new_game()
	var installed: Array = []
	scene.get_magnet().installed.connect(func() -> void: installed.append(true))
	var magnet: MagnetCollector = _installed(scene)
	check_eq(installed.size(), 1, "installation announced")
	check(magnet.get_node("Machine").visible and not magnet.get_node("ReservedPad").visible, "machine stands")
	check_eq(magnet.get_node("Machine/Body").collision_layer, 1, "solid now")
	check_eq(magnet.get_status(), MagnetCollector.STATUS_WORKING, "starts working")
	check_near(magnet.get_cycle_seconds(), 20.0, 0.01, "one piece every 20 s")
	magnet._process(19.0)
	check_eq(magnet.get_bin_count(), 0, "nothing before the cycle ends")
	magnet._process(1.5)
	check_eq(magnet.get_bin_count(), 1, "first piece in the crate")
	check_eq(magnet.get_heap_remaining(), magnet.profile.heap_size - 1, "taken from the heap")
	var item: ScrapItem = magnet.get_live_items()[0]
	check_eq(item.get_item_id(), magnet.profile.get_heap_item(0), "the heap's next piece")
	check(scene.get_world_object(item.object_id) == item, "registered in the yard")
	check(item.get_node("..") == magnet and item.is_interaction_available(), "can be picked up")
	var value: int = item.definition.sell_value
	check(item.interact(scene._context)["success"], "player picks it up")
	check_eq(magnet.get_bin_count(), 0, "crate empty again")
	var station: SellStation = scene.get_world_object("station_sell_counter") as SellStation
	var before: int = scene.get_wallet().get_balance()
	station.interact(scene._context)
	station.confirm_sale(station.create_quote())
	await wait_process_frames(2)
	check_eq(scene.get_wallet().get_balance() - before, value, "sells normally")
	check(magnet.get_live_items().is_empty(), "sold piece left the world")


func test_full_crate_stops_the_machine_until_emptied() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	for index: int in magnet.profile.bin_capacity:
		magnet.collect_once()
	check_eq(magnet.get_bin_count(), magnet.profile.bin_capacity, "crate full")
	check_eq(magnet.get_status(), MagnetCollector.STATUS_BIN_FULL, "status says so")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.magnet_full")), "note points at the crate")
	var heap: int = magnet.get_heap_remaining()
	magnet._process(1000.0)
	check(magnet.collect_once() == null, "nothing more fits")
	check_eq(magnet.get_heap_remaining(), heap, "heap untouched while full")
	var positions: Array = []
	for item: ScrapItem in magnet.get_live_items():
		for other: Vector3 in positions:
			check(item.global_position.distance_to(other) > 0.25, "pieces do not overlap")
		positions.append(item.global_position)
	magnet.get_live_items()[0].interact(scene._context)
	check_eq(magnet.get_status(), MagnetCollector.STATUS_WORKING, "works again once there is room")
	check(magnet.collect_once() != null, "fills the free slot")


func test_loose_iron_in_the_work_area_is_taken_first_and_copper_is_ignored() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	var heap_center: Vector3 = magnet.heap_center.global_position
	var bolt: ScrapItem = scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem
	var pipe: ScrapItem = scene.get_world_object("scrap_copper_pipe_01") as ScrapItem
	bolt.drop_at(heap_center + Vector3(1.0, 0.1, 0.5), 0.0)
	pipe.drop_at(heap_center + Vector3(0.5, 0.1, 0.2), 0.0)
	var heap: int = magnet.get_heap_remaining()
	check_eq(magnet.peek_next_item_id(), "scrap_rusted_bolt", "the magnet aims for the loose bolt")
	check(magnet.collect_once() == bolt, "the very same bolt is lifted, not a copy")
	check_eq(magnet.get_heap_remaining(), heap, "heap untouched")
	check(bolt.global_position.distance_to(magnet.bin.global_position) < MagnetCollector.BIN_RADIUS, "now in the crate")
	check_eq(bolt.get_state(), ScrapItem.State.IN_WORLD, "still a normal item")
	magnet.collect_once()
	check_eq(pipe.get_state(), ScrapItem.State.IN_WORLD, "copper stays put")
	check(pipe.global_position.distance_to(heap_center) < 1.0, "copper not moved")
	check(scene.create_snapshot()["world_objects"].has(bolt.object_id), "moved bolt is saved with its new place")


func test_never_more_than_the_heap_holds() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	magnet.apply_save_state({"heap_taken": magnet.profile.heap_size - 1, "counter": 0})
	check(magnet.collect_once() != null, "last piece from the heap")
	check_eq(magnet.get_heap_remaining(), 0, "heap empty")
	check(magnet.collect_once() == null, "nothing out of thin air")
	check_eq(magnet.get_status(), MagnetCollector.STATUS_EMPTY, "says there is nothing left")
	check(not magnet.get_node("Heap").visible or magnet.get_heap_remaining() == 0, "heap state consistent")
	var created: int = 0
	for target: Variant in scene._objects.values():
		if target is ScrapItem and (target as ScrapItem).object_id.begins_with(MagnetCollector.OBJECT_PREFIX):
			created += 1
	check_eq(created, 1, "exactly one piece created")


func test_switch_off_and_stronger_magnet() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	var controls: MagnetControls = magnet.get_node("Machine/Controls")
	check(controls.is_interaction_available(), "controls offered")
	var result: Dictionary = controls.interact(scene._context)
	check(result["success"] and not magnet.is_switched_on(), "switched off")
	check_eq(magnet.get_status(), MagnetCollector.STATUS_OFF, "status off")
	magnet._process(100.0)
	check_eq(magnet.get_bin_count(), 0, "nothing while off")
	controls.interact(scene._context)
	check_eq(magnet.get_status(), MagnetCollector.STATUS_WORKING, "back on")
	check(_buy(scene, "upgrade_strong_magnet")["success"], "stronger magnet bought")
	check_near(magnet.get_cycle_seconds(), 12.0, 0.01, "faster cycle")
	check(magnet._timer <= 12.0, "running cycle shortened to the new speed")


func test_animation_follows_the_cycle() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	var cable: Node3D = magnet.get_node("Machine/Model/Turret/Boom/Cable")
	magnet._timer = magnet.get_cycle_seconds() * 0.57
	await wait_process_frames(2)
	check(cable.scale.y > 1.0, "magnet lowered onto the heap (cable %.2f)" % cable.scale.y)
	magnet._timer = magnet.get_cycle_seconds() * 0.25
	await wait_process_frames(2)
	var proxy: Node3D = magnet.get_node("Machine/Model/Turret/Boom/Magnet/Proxy")
	check(proxy.get_child_count() > 0, "a piece hangs on the magnet while moving")
	check_eq(magnet.get_bin_count(), 0, "animation alone created nothing")


func test_machine_survives_save_and_continue() -> void:
	var scene: Node = await _new_game()
	var magnet: MagnetCollector = _installed(scene)
	for index: int in 3:
		magnet.collect_once()
	var items: Array[ScrapItem] = magnet.get_live_items()
	var carried_id: String = items[0].object_id
	items[0].interact(scene._context)
	magnet.toggle()
	magnet._timer = 7.5
	var heap: int = magnet.get_heap_remaining()
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	magnet = scene.get_magnet()
	check(magnet.is_installed(), "still installed")
	check(not magnet.is_switched_on(), "still switched off")
	check_eq(magnet.get_heap_remaining(), heap, "heap stock kept")
	check_eq(magnet.get_bin_count(), 2, "crate contents restored")
	check(scene.get_inventory().contains(carried_id), "carried piece still in the basket")
	check_near(magnet._timer, 7.5, 0.01, "cycle timer kept")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	magnet.toggle()
	var next: ScrapItem = magnet.collect_once()
	check(next != null and scene.get_world_object(next.object_id) == next, "continues with fresh ids")
	check(next.object_id != carried_id, "no id reused")


func test_old_version_5_save_migrates_and_broken_machine_data_is_rejected() -> void:
	var service: Node = tree.root.get_node("SaveService")
	var data: Dictionary = _session.create_initial_state()
	data["save_version"] = 5
	data.erase("machines")
	DirAccess.make_dir_recursive_absolute(service.save_directory)
	var file := FileAccess.open(service.get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var result: Dictionary = service.load_game()
	check(result["ok"], "v5 save loads")
	check_eq(result["data"].get("machines"), {}, "no machine yet")
	data["save_version"] = 6
	data["machines"] = {"magnet_collector": {"items": [{"id": "magnet_1"}]}}
	check(not service.validate_save_data(data), "broken crate entry rejected")
	data["machines"] = {"magnet_collector": {"on": "yes"}}
	check(not service.validate_save_data(data), "broken switch rejected")
