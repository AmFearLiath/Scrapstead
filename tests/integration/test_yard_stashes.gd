extends TestSuite
## Searchable yard fixtures (block 4, docs/yard-stashes.md): tyre stacks, the
## car wreck, shelves, crates, the container and the scrap heaps can be
## searched again and again, some need a tool, and they refill slowly while
## playing.

const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _session: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_session.intro_enabled = false
	tree.root.get_node("SaveService").delete_save()


func after_each() -> void:
	tree.root.get_tree().paused = false
	tree.root.get_node("SaveService").delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	scene.get_deliveries()._timer = 100000.0
	return scene


func _buy(scene: Node, ware_id: String) -> void:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition(ware_id)
	scene.get_wallet().credit(definition.price, "test-" + ware_id, "test")
	check(scene.get_upgrades().purchase(ware_id, scene.get_wallet()) == UpgradeProgress.PurchaseResult.OK,
		"%s bought" % ware_id)


## Puts the player right in front of a stash and returns its body.
func _stand_at(scene: Node, stash_id: String) -> YardStash:
	var body: YardStash = scene.yard_stashes.get_body(stash_id)
	var player: Node3D = scene.get_node("Player")
	player.place(body.global_position + Vector3(0, 0.1, 3.5), PI)
	await wait_physics_frames(2)
	return body


func test_table_is_valid_translated_and_covers_the_yard() -> void:
	var table: StashTable = load("res://data/stashes/yard_stashes.tres")
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	check(table.stashes.size() >= 10, "%d stashes" % table.stashes.size())
	var tools: Dictionary = {}
	for definition: StashDefinition in table.stashes:
		check(definition.validate(catalog).is_empty(), "%s valid: %s" % [definition.id, ", ".join(definition.validate(catalog))])
		tools[definition.required_tool] = true
		for item_id: String in definition.loot_items:
			var item: ItemDefinition = catalog.get_definition(item_id)
			check(item != null and item.contents.is_empty(), "%s: %s is a plain find" % [definition.id, item_id])
		for locale: String in ["de", "en"]:
			TranslationServer.set_locale(locale)
			for key: String in [definition.name_key, definition.action_key, definition.empty_key] + Array(definition.result_keys):
				check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")
	check(tools.has("") and tools.has("crowbar") and tools.has("hoist"), "bare hands, crowbar and hoist stashes")
	for name: String in ["tyres", "car_wreck", "shelf", "container", "scrap_heap_large", "crates_open"]:
		check(table.get_definition(name) != null, "%s is searchable" % name)
	var scene: Node = await _new_game()
	for definition: StashDefinition in table.stashes:
		check(scene.yard_stashes.get_body(definition.id) != null, "%s has an interaction body" % definition.id)


func test_search_finds_pieces_uses_charges_and_refills() -> void:
	var scene: Node = await _new_game()
	var stashes: YardStashes = scene.yard_stashes
	var body: YardStash = await _stand_at(scene, "tyres")
	var definition: StashDefinition = body.definition
	check_eq(stashes.get_charges("tyres"), definition.capacity, "starts full")
	check(body.get_interaction_point().distance_to(body.global_position) > 0.3, "interaction point on the near side")
	check(body.get_prompt_detail(scene._context) != "", "prompt shows the charges")
	var found_total: int = 0
	for search: int in definition.capacity:
		var result: Dictionary = body.interact(scene._context)
		check(result["success"], "search %d works" % (search + 1))
		check(tr(result["message_key"]) != result["message_key"], "flavor line translated")
		found_total += int(result["message_args"]["count"])
	check(found_total >= definition.capacity * definition.min_items, "found %d pieces" % found_total)
	check_eq(stashes.get_live_items().size(), found_total, "pieces lie in the yard")
	for item: ScrapItem in stashes.get_live_items():
		check(scene.get_world_object(item.object_id) == item, "%s registered" % item.object_id)
		check(item.get_state() == ScrapItem.State.IN_WORLD, "%s can be picked up" % item.object_id)
		check(item.global_position.distance_to(body.get_interaction_point()) < 1.6, "%s near the player" % item.object_id)
	check_eq(stashes.get_charges("tyres"), 0, "searched empty")
	var empty: Dictionary = body.interact(scene._context)
	check(not empty["success"] and empty["message_key"] == definition.empty_key, "empty stash says so")
	check(stashes.get_seconds_until_refill("tyres") > 0.0, "refill pending")
	stashes.advance(definition.refill_seconds - 1.0)
	check_eq(stashes.get_charges("tyres"), 0, "not quite yet")
	stashes.advance(2.0)
	check_eq(stashes.get_charges("tyres"), 1, "one search back after the refill time")
	stashes.advance(definition.refill_seconds * 10.0)
	check_eq(stashes.get_charges("tyres"), definition.capacity, "never more than the capacity")


func test_tools_are_required_where_it_makes_sense() -> void:
	var scene: Node = await _new_game()
	var wreck: YardStash = await _stand_at(scene, "car_wreck")
	check(wreck.get_prompt_detail(scene._context).contains(tr("tool.crowbar.name")), "wreck asks for the crowbar")
	var refused: Dictionary = wreck.interact(scene._context)
	check(not refused["success"] and refused["message_key"] == "ui.search.missing_tool.crowbar", "refused without crowbar")
	check_eq(scene.yard_stashes.get_charges("car_wreck"), wreck.definition.capacity, "no charge used")
	_buy(scene, "tool_crowbar")
	check(wreck.interact(scene._context)["success"], "crowbar opens the wreck")
	var engine: YardStash = await _stand_at(scene, "engine_block")
	check(not engine.interact(scene._context)["success"], "engine block needs the hoist")
	_buy(scene, "tool_hoist")
	check(engine.interact(scene._context)["success"], "hoist lifts the engine block")


func test_charges_timer_and_found_pieces_survive_loading() -> void:
	var scene: Node = await _new_game()
	var body: YardStash = await _stand_at(scene, "scrap_heap_large")
	body.interact(scene._context)
	var stashes: YardStashes = scene.yard_stashes
	stashes.advance(30.0)
	var charges: int = stashes.get_charges("scrap_heap_large")
	var until: float = stashes.get_seconds_until_refill("scrap_heap_large")
	var ids: Array = []
	for item: ScrapItem in stashes.get_live_items():
		ids.append(item.object_id)
	var first: ScrapItem = stashes.get_live_items()[0]
	first.interact(scene._context)
	check(scene.get_inventory().contains(first.object_id), "first piece in the basket")
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	stashes = scene.yard_stashes
	check_eq(stashes.get_charges("scrap_heap_large"), charges, "charges restored")
	check_near(stashes.get_seconds_until_refill("scrap_heap_large"), until, 0.6, "refill timer continues")
	check_eq(stashes.get_live_items().size(), ids.size(), "found pieces restored")
	check(scene.get_inventory().contains(ids[0]), "carried piece still in the basket")
	var station: SellStation = scene.get_world_object("station_sell_counter") as SellStation
	station.interact(scene._context)
	station.confirm_sale(station.create_quote())
	await wait_process_frames(2)
	check(scene.get_world_object(ids[0]) == null, "sold piece leaves the world")
	check_eq(stashes.get_live_items().size(), ids.size() - 1, "and the stash list")


func test_moved_fixture_takes_its_stash_along() -> void:
	var scene: Node = await _new_game()
	var body: YardStash = scene.yard_stashes.get_body("tyres")
	var fixture: Node3D = body.get_parent()
	var before: Vector3 = body.global_position
	fixture.global_position += Vector3(2.0, 0, 0)
	check(body.global_position.distance_to(before + Vector3(2.0, 0, 0)) < 0.01, "stash body moves with the fixture")
