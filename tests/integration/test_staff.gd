extends TestSuite
## The first employee (P3a, docs/first-employee.md): Juri shows up after the
## first deliveries, is hired for a visible fee, carries pallet scrap to the
## counter for a wage, can be paused and dismissed and survives a restart.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
## Game seconds a full pallet may take at most (two trips plus slack).
const WORK_TIMEOUT: float = 60.0

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


## Entrance bought, two deliveries arrived (Juri waits at the gate).
func _yard_with_juri(scene: Node, credits: int = 40) -> YardWorker:
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(definition.price + credits, "test-setup", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	deliveries.deliver_next()
	deliveries.deliver_next()
	return scene.get_worker()


func _clear_pallet(scene: Node) -> void:
	for item: ScrapItem in scene.get_deliveries().get_live_items():
		if item.get_state() == ScrapItem.State.IN_WORLD:
			item.set_state(ScrapItem.State.SOLD)
	await wait_process_frames(2)


## Runs physics (sped up) until `condition` holds or the timeout passes.
func _work_until(condition: Callable, game_seconds: float = WORK_TIMEOUT) -> bool:
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


func test_profile_is_valid_and_every_line_is_translated() -> void:
	var profile: EmployeeProfile = load("res://data/employees/juri.tres")
	check(profile.validate().is_empty(), "profile valid: %s" % ", ".join(profile.validate()))
	check(profile.wage_per_item < 2, "wage below the cheapest allowed scrap, never a loss per piece")
	var keys: PackedStringArray = [profile.name_key, profile.role_key, profile.description_key]
	for event: String in YardWorker.LINE_COUNTS:
		for index: int in range(1, int(YardWorker.LINE_COUNTS[event]) + 1):
			keys.append("%s.%s.%d" % [profile.line_prefix, event, index])
	for status: String in ["working", "waiting", "blocked", "paused"]:
		keys.append("ui.staff.status." + status)
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for key: String in keys:
			check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")


func test_juri_shows_up_at_the_gate_after_two_deliveries() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = scene.get_worker()
	check(worker != null, "worker in the yard")
	check_eq(worker.get_presence(), YardWorker.Presence.ABSENT, "nobody there at the start")
	check(not worker.visible, "invisible while absent")
	check_eq(worker.collision_layer, 0, "never blocks the player")
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(definition.price, "test-setup", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	scene.get_deliveries().deliver_next()
	check_eq(worker.get_presence(), YardWorker.Presence.ABSENT, "not after the first delivery")
	scene.get_deliveries().deliver_next()
	check_eq(worker.get_presence(), YardWorker.Presence.AVAILABLE, "waits at the gate after the second")
	check(worker.visible, "visible now")
	check(worker.global_position.distance_to(worker.wait_spot.global_position) < 0.1, "at the wait spot")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.staff_available")), "note points at him")
	var talk: YardWorkerTalk = worker.get_node("Talk")
	check(talk.is_interaction_available(), "can be talked to")
	check_eq(talk.interact(scene._context).get("panel"), "staff", "opens the staff panel")


func test_hiring_costs_the_fee_once_and_fails_cleanly_without_money() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene, 0)
	var wallet: Wallet = scene.get_wallet()
	if wallet.get_balance() > 0:
		wallet.debit(wallet.get_balance(), "test-empty", "test")
	var refused: Dictionary = worker.hire()
	check(not refused["success"], "cannot hire without the fee")
	check_eq(refused["message_key"], "ui.staff.cannot_afford", "says why")
	check_eq(worker.get_presence(), YardWorker.Presence.AVAILABLE, "still waiting")
	wallet.credit(25, "test-money", "test")
	var result: Dictionary = worker.hire()
	check(result["success"], "hired")
	check_eq(wallet.get_balance(), 25 - worker.profile.hire_fee, "fee booked once")
	check_eq(wallet.get_ledger()[-1]["reason"], "ui.ledger.staff_hire", "ledger names the hiring")
	check(worker.is_hired(), "is hired")
	check(not worker.hire()["success"], "cannot be hired twice")
	check(not scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.staff_available")), "note gone")


func test_juri_carries_the_pallet_to_the_counter_and_takes_his_wage() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	await _clear_pallet(scene)
	worker.hire()
	var wallet: Wallet = scene.get_wallet()
	var balance_before: int = wallet.get_balance()
	var sales: Array = []
	worker.sold.connect(func(count: int, total: int, wage: int) -> void: sales.append([count, total, wage]))
	var deliveries: ScrapDeliveries = scene.get_deliveries()
	var items: Array[ScrapItem] = deliveries.deliver_next()
	var value: int = 0
	for item: ScrapItem in items:
		value += item.definition.sell_value
	await wait_physics_frames(2)
	check_eq(worker.get_status(), YardWorker.STATUS_WORKING, "starts working")
	check(not scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.delivery_waiting")),
		"no reminder while Juri is on it")
	var done: bool = await _work_until(func() -> bool:
		return deliveries.get_live_items().is_empty() and worker.get_carried_items().is_empty())
	check(done, "pallet cleared and sold within %d s" % WORK_TIMEOUT)
	var wages: int = items.size() * worker.profile.wage_per_item
	check_eq(wallet.get_balance() - balance_before, value - wages, "sale minus wage booked")
	check_eq(worker.get_stats()["items"], items.size(), "all pieces counted")
	check_eq(worker.get_stats()["wages"], wages, "wages counted")
	check(sales.size() >= 2, "two trips for %d pieces" % items.size())
	check_eq(worker.get_squeeze_count(), 0, "route is free, he never had to squeeze past")
	check(scene.get_inventory().is_empty(), "the player's basket was never touched")
	await _work_until(func() -> bool: return worker.get_status() == YardWorker.STATUS_WAITING, 20.0)
	check_eq(worker.get_status(), YardWorker.STATUS_WAITING, "waits for the next delivery")


func test_pause_stops_the_work_and_resume_continues() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	await _clear_pallet(scene)
	worker.hire()
	check(worker.toggle_pause()["success"], "paused")
	check_eq(worker.get_status(), YardWorker.STATUS_PAUSED, "status shows the break")
	scene.get_deliveries().deliver_next()
	await _work_until(func() -> bool: return false, 6.0)
	check(worker.get_carried_items().is_empty(), "nothing picked up during the break")
	check_eq(scene.get_deliveries().get_waiting_count(), 3, "pallet untouched")
	check(scene.get_node("HUD/TaskNotes").get_notes().has(tr("note.delivery_waiting")),
		"reminder is back while he pauses")
	worker.toggle_pause()
	var picked: bool = await _work_until(func() -> bool: return not worker.get_carried_items().is_empty(), 20.0)
	check(picked, "back to work after the break")


func test_juri_leaves_valuable_things_on_the_pallet_alone() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	await _clear_pallet(scene)
	worker.hire()
	var figurine: ScrapItem = scene.get_world_object("find_brass_figurine_01") as ScrapItem
	figurine.drop_at(scene.get_deliveries().global_position + Vector3(0.2, 0.13, 0.1), 0.0)
	var remarks: Array = []
	worker.remark.connect(func(key: String) -> void: remarks.append(key))
	await _work_until(func() -> bool: return false, 6.0)
	check_eq(figurine.get_state(), ScrapItem.State.IN_WORLD, "figurine stays")
	check(remarks.has("staff.juri.refuses.1"), "he says why")
	var can: ScrapItem = scene.get_world_object("scrap_empty_can_01") as ScrapItem
	can.drop_at(scene.get_deliveries().global_position + Vector3(-0.3, 0.13, 0.0), 0.0)
	var sold: bool = await _work_until(func() -> bool: return can.get_state() == ScrapItem.State.SOLD)
	check(sold, "scrap the player leaves on the pallet is sold for them")


func test_dismissing_returns_carried_items_and_he_waits_at_the_gate() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	await _clear_pallet(scene)
	worker.hire()
	scene.get_deliveries().deliver_next()
	await _work_until(func() -> bool: return not worker.get_carried_items().is_empty(), 20.0)
	var carried: Array[ScrapItem] = worker.get_carried_items()
	check(not carried.is_empty(), "carrying something")
	var balance: int = scene.get_wallet().get_balance()
	check(worker.dismiss()["success"], "dismissed")
	check_eq(worker.get_presence(), YardWorker.Presence.AVAILABLE, "waits to be rehired")
	check_eq(scene.get_wallet().get_balance(), balance, "no money moved")
	for item: ScrapItem in carried:
		check_eq(item.get_state(), ScrapItem.State.IN_WORLD, "%s back in the yard" % item.object_id)
		var offset: Vector3 = item.global_position - scene.get_deliveries().global_position
		check(Vector2(offset.x, offset.z).length() < worker.profile.work_radius, "back on the pallet")
	var back: bool = await _work_until(func() -> bool:
		return worker.global_position.distance_to(worker.wait_spot.global_position) < 0.4, 20.0)
	check(back, "walks back to the gate")


func test_employee_survives_save_and_continue_mid_trip() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	await _clear_pallet(scene)
	worker.hire()
	scene.get_deliveries().deliver_next()
	await _work_until(func() -> bool: return not worker.get_carried_items().is_empty(), 20.0)
	var carried_id: String = worker.get_carried_items()[0].object_id
	var stats: Dictionary = worker.get_stats()
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	worker = scene.get_worker()
	check(worker.is_hired(), "still employed")
	check(worker.is_carrying(carried_id), "still carrying %s" % carried_id)
	check(not scene.get_inventory().contains(carried_id), "not moved into the player's basket")
	check(scene.get_restore_notes().is_empty(), "no repairs needed: %s" % ", ".join(scene.get_restore_notes()))
	check_eq(worker.get_stats(), stats, "stats kept")
	var sold: bool = await _work_until(func() -> bool: return scene.get_world_object(carried_id) == null)
	check(sold, "finishes the trip after loading")


func test_old_version_4_save_migrates_and_broken_employee_data_is_rejected() -> void:
	var service: Node = tree.root.get_node("SaveService")
	var data: Dictionary = _session.create_initial_state()
	data["save_version"] = 4
	data.erase("employee")
	DirAccess.make_dir_recursive_absolute(service.save_directory)
	var file := FileAccess.open(service.get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var result: Dictionary = service.load_game()
	check(result["ok"], "v4 save loads")
	check_eq(result["data"].get("employee"), {}, "nobody hired yet")
	data["save_version"] = 5
	data["employee"] = {"carrying": [3]}
	check(not service.validate_save_data(data), "broken carried list rejected")
	data["employee"] = {"stats": {"items": "many"}}
	check(not service.validate_save_data(data), "broken stats rejected")


func test_staff_panel_hires_pauses_and_asks_before_dismissing() -> void:
	var scene: Node = await _new_game()
	var worker: YardWorker = _yard_with_juri(scene)
	var talk: YardWorkerTalk = worker.get_node("Talk")
	scene._on_interaction_finished(talk.object_id, talk.interact(scene._context))
	var panel: Control = scene.get_node("HUD/StaffPanel")
	check(panel.visible, "panel opens")
	check(scene._modal_open, "gameplay input paused while open")
	var primary: Button = panel.get_node("%PrimaryButton")
	var dismiss: Button = panel.get_node("%DismissButton")
	check(not dismiss.visible, "no dismiss button before hiring")
	check(primary.text.contains(str(worker.profile.hire_fee)), "hire button shows the fee: %s" % primary.text)
	primary.pressed.emit()
	check(worker.is_hired(), "hired from the panel")
	check(dismiss.visible, "dismiss offered once hired")
	check(panel.get_node("%Stats").visible, "stats shown")
	primary.pressed.emit()
	check(worker.is_paused(), "paused from the panel")
	dismiss.pressed.emit()
	check(worker.is_hired(), "first press only asks")
	check_eq(dismiss.text, tr("ui.staff.dismiss_confirm"), "asks for confirmation")
	dismiss.pressed.emit()
	check_eq(worker.get_presence(), YardWorker.Presence.AVAILABLE, "second press dismisses")
	check(not panel.visible, "panel closed")
	check(not scene._modal_open, "gameplay input back")
