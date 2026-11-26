extends TestSuite
## Heavy deliveries need a tool: Juri moves the delivered steel beam only with
## the bought handcart, which he fetches from its parking spot himself and
## brings back afterwards (docs/first-employee.md, section 4b).

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const BEAM_ENTRY: int = 8

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


func _prepare(scene: Node, with_cart: bool) -> YardWorker:
	_buy(scene, "yard_entrance")
	if with_cart:
		_buy(scene, "upgrade_carry_basket")
		_buy(scene, "upgrade_handcart")
		var desk: OrderDesk = scene.get_world_object("station_order_desk") as OrderDesk
		desk.refresh_deliveries(scene.get_upgrades())
	scene.get_wallet().credit(20, "test-fee", "test")
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	for item: ScrapItem in deliveries.get_live_items():
		item.set_state(ScrapItem.State.SOLD)
	deliveries._next_entry = BEAM_ENTRY
	var worker: YardWorker = scene.get_worker()
	worker.hire()
	return worker


func _beam(scene: Node) -> ScrapItem:
	var items: Array[ScrapItem] = scene.get_deliveries().deliver_next()
	check(items.size() == 1 and items[0].get_item_id() == "bulk_metal_beam", "Benno delivers a steel beam")
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


func test_without_a_cart_the_beam_stays_and_the_note_says_why() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, false)
	await wait_process_frames(2)
	var remarks: Array = []
	worker.remark.connect(func(key: String) -> void: remarks.append(key))
	var beam: ScrapItem = _beam(scene)
	var can: ScrapItem = scene.get_world_object("scrap_empty_can_01") as ScrapItem
	can.drop_at(scene.get_deliveries().global_position + Vector3(-0.4, 0.13, 0.2), 0.0)
	var sold_can: bool = await _work_until(func() -> bool: return can.get_state() == ScrapItem.State.SOLD, 60.0)
	check(sold_can, "other scrap is still handled")
	check_eq(beam.get_state(), ScrapItem.State.IN_WORLD, "the beam stays on the pallet")
	check(worker.is_missing_cart(), "he knows what he is missing")
	check_eq(remarks.count("staff.juri.needs_cart.1"), 1, "says so once")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.staff_needs_cart")), "note asks for a handcart")
	check(not worker.has_cart(), "no cart to take")
	check(beam.interact(scene._context)["success"], "the player can still carry it")
	await wait_physics_frames(2)
	await _work_until(func() -> bool: return false, 2.0)
	check(not worker.is_missing_cart(), "nothing missing once the beam is gone")


func test_juri_fetches_the_handcart_moves_the_beam_and_parks_the_cart() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true)
	await wait_process_frames(2)
	var display: Node3D = worker.cart_display
	check(display.visible, "bought handcart parked by the office")
	var wallet: Wallet = scene.get_wallet()
	var before: int = wallet.get_balance()
	var beam: ScrapItem = _beam(scene)
	var value: int = beam.definition.sell_value
	var took: bool = await _work_until(func() -> bool: return worker.has_cart())
	check(took, "fetches the cart")
	check(not display.visible, "the parked cart is gone while he uses it")
	check(worker.global_position.distance_to(worker.cart_spot.global_position) < 0.6, "took it at its spot")
	var sold: bool = await _work_until(func() -> bool: return worker.get_stats()["trips"] >= 1)
	check(sold, "beam sold")
	check_eq(wallet.get_balance() - before, value - worker.profile.wage_per_item, "20 Cr minus 1 Cr wage")
	var parked: bool = await _work_until(func() -> bool: return not worker.has_cart())
	check(parked, "brings the cart back")
	check(display.visible, "cart parked again")
	check_eq(worker.get_squeeze_count(), 0, "the way to the cart is free")


func test_cart_survives_a_restart_and_goes_back_on_dismissal() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _prepare(scene, true)
	await wait_process_frames(2)
	var beam_id: String = _beam(scene).object_id
	await _work_until(func() -> bool: return worker.is_carrying(beam_id))
	check(worker.has_cart() and worker.is_carrying(beam_id), "beam on the cart")
	check(scene.save_game(), "save with the cart in use")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	worker = scene.get_worker()
	check(worker.has_cart(), "still pushing the cart")
	check(not worker.cart_display.visible, "parked cart still hidden")
	check(worker.is_carrying(beam_id), "beam still on it")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	worker.dismiss()
	check(not worker.has_cart(), "cart returned on dismissal")
	check(worker.cart_display.visible, "parked again")
	var beam: ScrapItem = scene.get_world_object(beam_id) as ScrapItem
	check_eq(beam.get_state(), ScrapItem.State.IN_WORLD, "beam back on the pallet")
