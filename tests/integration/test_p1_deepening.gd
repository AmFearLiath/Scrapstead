extends TestSuite
## P1 deepening: tools, search sources, catalog rules, inspection, workbench.

const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _session: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	tree.root.get_node("SaveService").delete_save()


func after_each() -> void:
	Input.action_release("interact")
	tree.root.get_node("SaveService").delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	return scene


func _approach(scene: Node, object_id: String) -> Interactable:
	var target: Interactable = scene.get_world_object(object_id)
	var point: Vector3 = target.get_interaction_point()
	scene.get_node("Player").place(Vector3(point.x, 0.1, point.z + 0.25), PI)
	await wait_physics_frames(4)
	check(scene.get_node("Player/PlayerInteractor").get_current_target() == target, "%s selected" % object_id)
	return target


func _hold(seconds: float) -> void:
	send_action("interact", true)
	await wait_physics_frames(int(seconds * Engine.physics_ticks_per_second))
	send_action("interact", false)
	await wait_physics_frames(2)


func _grant(scene: Node, ware_id: String) -> void:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition(ware_id)
	scene.get_wallet().credit(definition.price, "test-" + ware_id, "test")
	scene.get_upgrades().purchase(ware_id, scene.get_wallet())


func test_contents_stay_hidden_until_searched() -> void:
	var scene: Node = await _new_game()
	for object_id: String in ["scrap_rusted_bolt_03", "find_brass_figurine_01", "scrap_wire_coil_04", "scrap_copper_pipe_01"]:
		var item: ScrapItem = scene.get_world_object(object_id)
		check_eq(item.get_state(), ScrapItem.State.PENDING, "%s pending" % object_id)
		check(not item.visible and not item.is_interaction_available(), "%s hidden" % object_id)


func test_crate_needs_crowbar_heap_does_not() -> void:
	var scene: Node = await _new_game()
	var messages: Array = []
	scene.get_node("Player/PlayerInteractor").interaction_finished.connect(
		func(_id: String, result: Dictionary) -> void: messages.append(result.get("message_key", "")))
	var crate: SearchSource = await _approach(scene, "source_storage_crate_01")
	await _hold(crate.search_seconds + 0.3)
	check(not crate.is_searched(), "crate refuses bare hands")
	check(messages.has("ui.search.missing_tool.crowbar"), "missing tool explained")
	check_eq(scene.get_world_object("scrap_wire_coil_04").get_state(), ScrapItem.State.PENDING, "contents still hidden")
	var heap: SearchSource = await _approach(scene, "source_small_scrap_pile_01")
	await _hold(heap.search_seconds + 0.3)
	check(heap.is_searched(), "heap searched by hand")
	check(scene.get_world_object("scrap_wood_offcut_01").is_interaction_available(), "heap contents revealed")
	check(not heap.is_interaction_available(), "heap can only be searched once")
	_grant(scene, "tool_crowbar")
	await _approach(scene, "source_storage_crate_01")
	await _hold(crate.search_seconds + 0.3)
	check(crate.is_searched(), "crate opens with crowbar")
	check(scene.get_world_object("scrap_wire_coil_04").is_interaction_available(), "crate contents revealed")


func test_beam_needs_hoist() -> void:
	var scene: Node = await _new_game()
	var beam: SalvageableScrap = await _approach(scene, "bulk_metal_beam_01")
	await _hold(beam.salvage_seconds + 0.3)
	check(not beam.is_salvaged(), "no salvage without hoist")
	_grant(scene, "tool_crowbar")
	await _approach(scene, "bulk_metal_beam_01")
	await _hold(beam.salvage_seconds + 0.3)
	check(not beam.is_salvaged(), "a crowbar is not a hoist")
	_grant(scene, "tool_hoist")
	await _approach(scene, "bulk_metal_beam_01")
	await _hold(beam.salvage_seconds + 0.3)
	check(beam.is_salvaged(), "hoist frees the beam")


func test_handcart_requires_basket_and_stacks() -> void:
	var scene: Node = await _new_game()
	var upgrades: UpgradeProgress = scene.get_upgrades()
	scene.get_wallet().credit(200, "test-funds", "test")
	check_eq(upgrades.purchase("upgrade_handcart", scene.get_wallet()), UpgradeProgress.PurchaseResult.MISSING_REQUIREMENT,
		"handcart locked")
	check_eq(scene.get_wallet().get_balance(), 200, "nothing paid for a locked ware")
	check_eq(upgrades.purchase("upgrade_carry_basket", scene.get_wallet()), UpgradeProgress.PurchaseResult.OK, "basket")
	check_eq(upgrades.purchase("upgrade_handcart", scene.get_wallet()), UpgradeProgress.PurchaseResult.OK, "handcart")
	check_eq(scene.get_inventory().get_capacity(), 12, "4 + 4 + 4 slots")
	check_eq(scene.get_wallet().get_balance(), 200 - 30 - 40, "prices from data")


func test_searched_sources_and_revealed_items_persist() -> void:
	var scene: Node = await _new_game()
	var heap: SearchSource = await _approach(scene, "source_small_scrap_pile_01")
	await _hold(heap.search_seconds + 0.3)
	await _approach(scene, "scrap_wood_offcut_01")
	await _hold(0.05)
	check(scene.get_inventory().contains("scrap_wood_offcut_01"), "revealed item picked")
	check(scene.save_game(), "save")
	check(_session.continue_game(), "continue")
	var restored: Node = await wait_for_scene(YARD)
	await wait_physics_frames(2)
	check(restored.get_world_object("source_small_scrap_pile_01").is_searched(), "heap stays searched")
	check(restored.get_inventory().contains("scrap_wood_offcut_01"), "revealed item still carried")
	check(restored.get_world_object("scrap_rusted_bolt_03").is_interaction_available(), "revealed item still in yard")
	check_eq(restored.get_world_object("scrap_wire_coil_04").get_state(), ScrapItem.State.PENDING,
		"unopened crate contents stay hidden")


func test_inspection_shows_info_without_changing_state() -> void:
	var scene: Node = await _new_game()
	var item: ScrapItem = await _approach(scene, "scrap_wire_coil_01")
	check(scene.get_node("HUD/InteractionPrompt/PanelContainer/Rows/HBoxContainer/InspectHint").visible,
		"prompt offers inspection")
	send_action("inspect_target")
	await wait_physics_frames(2)
	var panel: Control = scene.get_node("HUD/InspectPanel")
	check(panel.visible, "inspect panel open")
	var body: String = panel.get_node("%Body").text
	check(body.contains("7") and body.contains(tr("item.scrap_wire_coil.description")), "value and description shown")
	check(item.is_interaction_available() and scene.get_inventory().is_empty(), "inspection changes nothing")
	send_action("inspect_target")
	await wait_physics_frames(2)
	check(not panel.visible, "inspect panel closes with the same key")


func test_workbench_is_inspect_only() -> void:
	var scene: Node = await _new_game()
	var bench: Interactable = await _approach(scene, "station_workbench")
	check_eq(bench.get_action_key(), "ui.action.inspect", "workbench only offers inspection")
	await _hold(0.05)
	check(scene.get_node("HUD/InspectPanel").visible, "workbench shows its note")
	check(scene.get_node("HUD/InspectPanel").get_node("%Body").text == tr("station.workbench.description"),
		"crafting is announced honestly, not faked")
