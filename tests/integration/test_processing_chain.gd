extends TestSuite
## The processing chain (docs/processing-chain.md): the sorting machine puts
## mixed scrap into steel, copper & electronics and wood bins, each bin feeds
## its own press over a conveyor, and Juri feeds machines instead of selling
## raw scrap and fetches the finished bales himself.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const CANS_ENTRY: int = 2

var _session: Node
var _credits: int = 0


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
	scene.get_deliveries()._timer = 100000.0
	return scene


func _credit(scene: Node, amount: int) -> void:
	_credits += 1
	scene.get_wallet().credit(amount, "chain-test-%d" % _credits, "test")


## Places a machine on the first free anchor in rings around `near`.
func _place_near(scene: Node, placeable_id: String, near: Vector2i, accept: Callable = Callable()) -> String:
	var placed: PlacedObjects = scene.get_placed()
	var definition: PlaceableDefinition = placed.catalog.get_definition(placeable_id)
	for distance: int in range(0, 22):
		for dx: int in range(-distance, distance + 1):
			for dy: int in range(-distance, distance + 1):
				if maxi(absi(dx), absi(dy)) != distance:
					continue
				var anchor: Vector2i = near + Vector2i(dx, dy)
				if not placed.check_placement(definition, anchor, 0)["ok"]:
					continue
				_credit(scene, placed.get_price(definition))
				var result: Dictionary = placed.place(placeable_id, anchor, 0)
				if not result["ok"]:
					continue
				if not accept.is_valid() or accept.call(result["uid"]):
					return result["uid"]
				placed.remove(result["uid"])
	check(false, "found a place for %s" % placeable_id)
	return ""


func _world_items(scene: Node, item_id: String) -> Array[ScrapItem]:
	var items: Array[ScrapItem] = []
	for target: Variant in scene._objects.values():
		var item: ScrapItem = target as ScrapItem
		if item != null and item.get_state() == ScrapItem.State.IN_WORLD and item.get_item_id() == item_id:
			items.append(item)
	return items


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


func test_sorter_data_is_valid_and_translated() -> void:
	var profile: SorterProfile = load("res://data/machines/sorter.tres")
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	check(profile.validate(catalog).is_empty(), "profile valid: %s" % ", ".join(profile.validate(catalog)))
	var placeable: PlaceableDefinition = load("res://data/placeables/sorter.tres")
	var channels: Array = []
	for port: Dictionary in placeable.ports:
		if port["kind"] == "out":
			channels.append(port["channel"])
	channels.sort()
	check_eq(channels, ["copper", "steel", "wood"], "one output per material")
	for item_id: String in ["device_broken_radio", "device_broken_toaster", "find_brass_figurine", "sealed_crate",
			"bale_steel", "bulk_metal_beam"]:
		check(not profile.accepts(item_id), "%s is not sorted" % item_id)
	var keys: PackedStringArray = [profile.name_key, profile.description_key, "machine.sorter.hopper",
		"placeable.sorter.description", "ui.sorter.detail", "ui.sorter.fed", "ui.sorter.nothing_to_feed",
		"ui.sorter.hopper_full", "build.problem.sorter_not_empty"]
	for status: String in ["working", "waiting", "bin_full", "off"]:
		keys.append("ui.sorter.status." + status)
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for key: String in keys:
			check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")


func test_sorter_feeds_three_presses_over_three_belts() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var sorter_uid: String = _place_near(scene, "sorter", Vector2i(60, -45))
	var sorter: SortingMachine = placed.get_node_for(sorter_uid) as SortingMachine
	check(sorter != null and sorter.is_installed(), "sorting machine set up")
	var presses: Dictionary = {}
	# Like a player would: each press out in the direction of its bin.
	var directions: Dictionary = {"steel": Vector3.LEFT, "copper": Vector3.BACK, "wood": Vector3.RIGHT}
	for channel: String in ["steel", "copper", "wood"]:
		var uid: String = _place_near(scene, "scrap_press", Vector2i(60, -45), func(candidate: String) -> bool:
			var offset: Vector3 = placed.get_node_for(candidate).global_position - sorter.global_position
			return offset.dot(directions[channel]) > 2.4 and absf(offset.dot(directions[channel].cross(Vector3.UP))) < 2.0 				and placed.links.check_link(sorter_uid, candidate, -1, channel)["ok"])
		var linked: Dictionary = placed.links.link(sorter_uid, uid, -1, channel)
		check(linked["ok"], "%s bin connected: %s" % [channel, linked["message_key"]])
		presses[channel] = placed.get_node_for(uid)
	check_eq(placed.links.get_links().size(), 3, "three belts")
	check_eq(placed.links.check_link(sorter_uid, (presses["steel"] as Node3D).name, -1, "steel")["key"],
		"link_output_used", "each bin feeds only one belt")
	# Mixed scrap into the sorter.
	var fed: Array = []
	for item_id: String in ["scrap_rusted_bolt", "scrap_wire_coil", "scrap_empty_can", "scrap_copper_pipe"]:
		for item: ScrapItem in _world_items(scene, item_id):
			if sorter.accept_item(item):
				fed.append(item_id)
	check(fed.size() >= 4, "%d pieces in the hopper" % fed.size())
	check(not sorter.can_accept("device_broken_radio"), "radios must be dismantled first")
	var sorted: int = 0
	while sorter.sort_once() != null:
		sorted += 1
	check_eq(sorted, fed.size(), "everything sorted")
	check(sorter.get_bin_count("steel") > 0 and sorter.get_bin_count("copper") > 0, "steel and copper bins filled")
	for item: ScrapItem in sorter.get_output_items("steel"):
		check(MaterialGroup.new() != null and (presses["steel"] as ScrapPress).profile.group_for(item.get_item_id()).id == "steel",
			"%s lies in the steel bin" % item.get_item_id())
	for link: Dictionary in placed.links.get_links():
		while placed.links.send_once(link["id"]) != "":
			pass
	check_eq(sorter.get_bin_count("steel"), 0, "steel bin emptied by its belt")
	check_eq(sorter.get_bin_count("copper"), 0, "copper bin emptied by its belt")
	check_eq((presses["steel"] as ScrapPress).get_group_counts().keys(), ["steel"], "only steel in the steel press")
	check_eq((presses["copper"] as ScrapPress).get_group_counts().keys(), ["copper"], "only copper in the copper press")
	check_eq((presses["wood"] as ScrapPress).get_hopper_count(), 0, "nothing for the wood press yet")
	# Save and load keeps sorter queue, bins and the three links.
	var steel_press: ScrapPress = presses["steel"]
	var copper_waiting: int = (presses["copper"] as ScrapPress).get_hopper_count()
	sorter.accept_item(_world_items(scene, "scrap_wood_offcut")[0] if not _world_items(scene, "scrap_wood_offcut").is_empty() else null)
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	placed = scene.get_placed()
	check_eq(placed.links.get_links().size(), 3, "three belts restored")
	var channels: Array = []
	for link: Dictionary in placed.links.get_links():
		channels.append(link["channel"])
		check(not link["blocked"], "belt %s running" % link["channel"])
	channels.sort()
	check_eq(channels, ["copper", "steel", "wood"], "channels kept")
	var restored_copper: int = 0
	for node: Node3D in placed.get_nodes_of("scrap_press"):
		if (node as ScrapPress).get_group_counts().has("copper"):
			restored_copper = (node as ScrapPress).get_hopper_count()
	check_eq(restored_copper, copper_waiting, "press hoppers restored")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))


func test_juri_feeds_the_press_and_sells_bales() -> void:
	var scene: Node = await _new_game()
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	_credit(scene, definition.price + 40)
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = CANS_ENTRY
	deliveries._timer = 100000.0
	var worker: YardWorker = scene.get_worker()
	check(worker.hire().get("success", false), "Juri hired")
	var near: Vector2i = BuildGrid.world_to_cell(deliveries.global_position) + Vector2i(4, -8)
	var press_uid: String = _place_near(scene, "scrap_press", near)
	var press: ScrapPress = scene.get_placed().get_node_for(press_uid) as ScrapPress
	var cans: Array[ScrapItem] = deliveries.deliver_next()
	check_eq(cans.size(), 3, "Lotte's three cans arrive")
	var revenue_before: int = int(worker.get_stats()["revenue"])
	check(await _work_until(func() -> bool: return press.get_hopper_count() >= 3, 150.0),
		"Juri puts the cans into the press (hopper %d)" % press.get_hopper_count())
	check_eq(int(worker.get_stats()["revenue"]), revenue_before, "he did not sell the raw cans")
	check(int(worker.get_stats()["fed"]) >= 3, "feeding counted")
	# Three more steel pieces make a bale; Juri fetches and sells it.
	for item_id: String in ["scrap_rusted_bolt", "scrap_empty_can"]:
		for item: ScrapItem in _world_items(scene, item_id):
			if press.get_hopper_count() < 6 and item.object_id.begins_with("scrap_"):
				press.accept_item(item)
	check_eq(press.get_hopper_count(), 6, "six steel pieces waiting")
	var bale: ScrapItem = press.press_once()
	check(bale != null, "bale pressed")
	check(await _work_until(func() -> bool: return int(worker.get_stats()["revenue"]) >= revenue_before + 22, 150.0),
		"Juri fetched the bale and sold it")


func test_magnet_leaves_sorted_pieces_alone() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	_credit(scene, 60)
	var magnet_uid: String = placed.place("magnet_collector", Vector2i(69, -27), 0)["uid"]
	var magnet: MagnetCollector = placed.get_node_for(magnet_uid) as MagnetCollector
	# The sorting machine right next to the magnet, its steel bin in reach.
	var sorter_uid: String = _place_near(scene, "sorter", Vector2i(69, -27), func(candidate: String) -> bool:
		var bin: Node3D = placed.get_node_for(candidate).get_node("BinSteel")
		var offset: Vector3 = bin.global_position - magnet.get_work_center()
		offset.y = 0.0
		return offset.length() < magnet.profile.work_radius - 0.3)
	var sorter: SortingMachine = placed.get_node_for(sorter_uid) as SortingMachine
	var bolt: ScrapItem = scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem
	check(sorter.accept_item(bolt), "bolt into the sorter")
	var sorted: ScrapItem = sorter.sort_once()
	check(sorted != null and sorter.get_bin_count("steel") == 1, "bolt lies in the steel bin")
	check(sorter.holds_output(sorted), "the sorter holds it as output")
	check(magnet._find_loose_piece() != sorted, "the magnet does not fish in the sorter's bin")
	var collected: ScrapItem = magnet.collect_once()
	check(collected != sorted, "the magnet takes from its heap instead")
	check_eq(sorter.get_bin_count("steel"), 1, "the sorted bolt stays where it is")


func test_juri_starts_the_chain_at_a_connected_sorter() -> void:
	var scene: Node = await _new_game()
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	_credit(scene, definition.price + 40)
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = 1
	deliveries._timer = 100000.0
	var worker: YardWorker = scene.get_worker()
	check(worker.hire().get("success", false), "Juri hired")
	var placed: PlacedObjects = scene.get_placed()
	var near: Vector2i = BuildGrid.world_to_cell(deliveries.global_position) + Vector2i(6, -12)
	var sorter_uid: String = _place_near(scene, "sorter", near)
	var sorter: SortingMachine = placed.get_node_for(sorter_uid) as SortingMachine
	check(not scene._chain_machines().has(sorter), "without belts the sorter is not offered to Juri")
	var press_uid: String = _place_near(scene, "scrap_press", near, func(candidate: String) -> bool:
		return placed.links.check_link(sorter_uid, candidate, -1, "steel")["ok"])
	check(placed.links.link(sorter_uid, press_uid, -1, "steel")["ok"], "steel bin feeds the press")
	check(scene._chain_machines().has(sorter), "with a belt it is the start of the chain")
	var fed: Array = []
	sorter.piece_fed.connect(func(item_id: String) -> void: fed.append(item_id))
	var mixed: Array[ScrapItem] = deliveries.deliver_next()
	check_eq(mixed.size(), 3, "Krull brings wire, a can and wood")
	check(await _work_until(func() -> bool: return fed.size() >= 3, 150.0),
		"Juri puts the mixed delivery into the sorter (%s)" % ", ".join(fed))
	var press: ScrapPress = placed.get_node_for(press_uid) as ScrapPress
	var refed: Array = []
	sorter.piece_fed.connect(func(item_id: String) -> void: refed.append(item_id))
	# The steel can rides the belt; copper and wood lie in unconnected bins:
	# Juri fetches them and brings them to the press, never back to the sorter.
	check(await _work_until(func() -> bool:
		var counts: Dictionary = press.get_group_counts()
		return counts.has("steel") and counts.has("copper") and counts.has("wood"), 200.0),
		"all three materials reach the press: %s" % press.get_group_counts())
	check_eq(refed, [], "nothing went back into the sorter")
	check_eq(sorter.get_hopper_count(), 0, "sorter hopper empty")
