extends TestSuite
## P1 acceptance sequence (version 0.2, docs/p1-gameplay-loop.md section 14):
## collect -> sell -> buy a tool -> search sources -> buy the hoist -> salvage
## -> buy the basket -> use the bigger basket -> save -> continue.

const MENU: String = "res://scenes/menu/MainMenu.tscn"
const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _session: Node
var _save: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_save = tree.root.get_node("SaveService")
	_save.save_directory = "user://test_run/saves"
	_save.delete_save()
	Input.action_release("interact")


func after_each() -> void:
	Input.action_release("interact")
	if tree.paused:
		tree.paused = false
	_save.delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	return scene


## Teleports next to an object's interaction point and checks the selection.
func _approach(scene: Node, object_id: String) -> Interactable:
	var target: Interactable = scene.get_world_object(object_id)
	var point: Vector3 = target.get_interaction_point()
	scene.get_node("Player").place(Vector3(point.x, 0.1, point.z + 0.25), PI)
	await wait_physics_frames(4)
	check(scene.get_node("Player/PlayerInteractor").get_current_target() == target, "%s selected" % object_id)
	return target


func _press_interact() -> void:
	send_action("interact", true)
	send_action("interact", false)
	await wait_physics_frames(2)


func _hold_interact(seconds: float) -> void:
	send_action("interact", true)
	await wait_physics_frames(int(seconds * Engine.physics_ticks_per_second))
	send_action("interact", false)
	await wait_physics_frames(2)


func _pick(scene: Node, object_id: String) -> void:
	await _approach(scene, object_id)
	await _press_interact()
	check(scene.get_inventory().contains(object_id), "%s carried" % object_id)


func _search(scene: Node, source_id: String) -> void:
	var source: SearchSource = await _approach(scene, source_id)
	await _hold_interact(source.search_seconds + 0.3)
	check(source.is_searched(), "%s searched" % source_id)


func _sell_everything(scene: Node) -> Dictionary:
	await _approach(scene, "station_sell_counter")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/SellPanel")
	check(panel.visible, "sell panel open")
	var quote: Dictionary = panel._quote.duplicate(true)
	panel.get_node("%ConfirmButton").pressed.emit()
	await wait_physics_frames(2)
	check(not panel.visible, "sell panel closed after confirm")
	return quote


func _order(scene: Node, ware_id: String) -> void:
	await _approach(scene, "station_order_desk")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/CatalogPanel")
	check(panel.visible, "catalog open")
	var desk: OrderDesk = scene.get_world_object("station_order_desk")
	var index: int = 0
	for offer: Dictionary in desk.get_offers():
		if offer["definition"].id == ware_id:
			break
		index += 1
	var button: Button = _catalog_buttons(panel)[index]
	check(not button.disabled, "%s orderable" % ware_id)
	button.pressed.emit()
	await wait_process_frames(2)
	check(scene.get_upgrades().is_owned(ware_id), "%s owned" % ware_id)
	panel.close()
	await wait_physics_frames(2)


func _catalog_buttons(panel: Control) -> Array[Node]:
	return panel.get_node("%Offers").find_children("*", "Button", true, false)


func test_full_p1_loop_with_save_and_continue() -> void:
	var scene: Node = await _new_game()
	var wallet: Wallet = scene.get_wallet()
	var inventory: CarryInventory = scene.get_inventory()
	check_eq(wallet.get_balance(), 0, "start with 0 credits")
	check_eq(inventory.get_capacity(), 4, "start capacity 4")
	# 1) Collect four loose items until the basket is full; a fifth is refused.
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_wire_coil_01", "scrap_rusted_bolt_02"]:
		await _pick(scene, object_id)
	check_eq(inventory.get_used_slots(), 4, "basket full")
	await _approach(scene, "scrap_empty_can_02")
	await _press_interact()
	check(not inventory.contains("scrap_empty_can_02"), "full basket refuses pickup")
	# 2) The beam needs a hoist: refused without one.
	var beam: SalvageableScrap = await _approach(scene, "bulk_metal_beam_01")
	await _hold_interact(3.0)
	check(not beam.is_salvaged(), "beam refused without hoist")
	# 3) Sell, no double booking.
	var quote: Dictionary = await _sell_everything(scene)
	check_eq(quote["total"], 15, "first sale")
	check_eq(wallet.get_balance(), 15, "credits booked")
	var station: SellStation = scene.get_world_object("station_sell_counter")
	check(not station.confirm_sale(quote)["success"], "same quote cannot be booked twice")
	# 4) Order the crowbar, open the nailed crate.
	await _order(scene, "tool_crowbar")
	check_eq(wallet.get_balance(), 3, "crowbar paid")
	check(scene.get_node("DeliveryArea/tool_crowbar").visible, "crowbar delivered outside the office")
	await _search(scene, "source_storage_crate_01")
	for object_id: String in ["scrap_rusted_bolt_04", "scrap_rusted_bolt_05", "scrap_rusted_bolt_06", "scrap_wire_coil_04"]:
		await _pick(scene, object_id)
	await _sell_everything(scene)
	check_eq(wallet.get_balance(), 3 + 16, "crate contents sold")
	# 5) Search sources without tools.
	await _search(scene, "source_small_scrap_pile_01")
	await _search(scene, "source_old_toolbox_01")
	for object_id: String in ["scrap_rusted_bolt_03", "scrap_empty_can_03", "scrap_wood_offcut_01", "find_brass_figurine_01"]:
		await _pick(scene, object_id)
	await _sell_everything(scene)
	check_eq(wallet.get_balance(), 19 + 22, "heap and figurine sold")
	# 6) Handcart is locked until the basket exists; buy the hoist.
	var desk: OrderDesk = scene.get_world_object("station_order_desk")
	for offer: Dictionary in desk.get_offers():
		if offer["definition"].id == "upgrade_handcart":
			check_eq(offer["status"], "locked", "handcart needs the basket first")
	await _order(scene, "tool_hoist")
	check_eq(wallet.get_balance(), 16, "hoist paid")
	# 7) Salvage the beam with the hoist and sell it.
	await _approach(scene, "bulk_metal_beam_01")
	await _hold_interact(1.0)
	check(not beam.is_salvaged(), "interrupted hold does not salvage")
	await _hold_interact(beam.salvage_seconds + 0.3)
	check(beam.is_salvaged(), "beam salvaged with hoist")
	check_eq(inventory.get_used_slots(), 3, "beam uses 3 slots")
	await _sell_everything(scene)
	check_eq(wallet.get_balance(), 36, "beam sold for 20")
	# 8) Buy the basket: capacity doubles immediately.
	await _order(scene, "upgrade_carry_basket")
	check_eq(wallet.get_balance(), 6, "basket paid")
	check_eq(inventory.get_capacity(), 8, "capacity increased immediately")
	# 9) Use the bigger basket: six items in one trip.
	await _search(scene, "source_rusted_drum_01")
	for object_id: String in ["scrap_empty_can_04", "scrap_empty_can_05", "scrap_copper_pipe_01",
			"scrap_empty_can_02", "scrap_wire_coil_02", "scrap_wire_coil_03"]:
		await _pick(scene, object_id)
	check_eq(inventory.get_used_slots(), 6, "more than four items in one trip")
	# 10) Drop and pick up again.
	check(scene.drop_last_item(), "drop works")
	var dropped: ScrapItem = scene.get_world_object("scrap_wire_coil_03")
	check(dropped.is_interaction_available(), "dropped item back in yard")
	var dropped_position: Vector3 = dropped.global_position
	# 11) Save via the pause menu, return to menu, continue.
	send_action("pause_menu")
	await wait_process_frames(2)
	check(tree.paused, "pause menu pauses the game")
	scene.get_node("HUD/PauseMenu").get_node("%SaveExitButton").pressed.emit()
	var menu: Node = await wait_for_scene(MENU)
	check(menu != null, "back in main menu after save & exit")
	check(_session.continue_game(), "continue")
	var restored: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	check_eq(restored.get_wallet().get_balance(), 6, "credits restored")
	check_eq(restored.get_inventory().get_capacity(), 8, "basket restored")
	check(restored.get_upgrades().has_tool("crowbar") and restored.get_upgrades().has_tool("hoist"), "tools restored")
	check(restored.get_node("DeliveryArea/tool_hoist").visible, "delivered goods visible after load")
	check(not restored.get_node("DeliveryArea/upgrade_handcart").visible, "handcart not delivered")
	check_eq(restored.get_inventory().get_used_slots(), 5, "carried load restored")
	check(restored.get_world_object("source_storage_crate_01").is_searched(), "searched crate stays searched")
	check_eq(restored.get_world_object("bulk_metal_beam_01").get_state(), ScrapItem.State.SOLD, "beam stays sold")
	var restored_drop: ScrapItem = restored.get_world_object("scrap_wire_coil_03")
	check(restored_drop.is_interaction_available(), "dropped item in yard after load")
	check(restored_drop.global_position.distance_to(dropped_position) < 0.01, "dropped position restored")
	# 12) The loop keeps working after continuing.
	await _sell_everything(restored)
	check_eq(restored.get_wallet().get_balance(), 6 + 2 + 2 + 6 + 2 + 7, "selling works after continue")


func test_stale_quote_is_rejected() -> void:
	var scene: Node = await _new_game()
	await _pick(scene, "scrap_rusted_bolt_01")
	await _approach(scene, "station_sell_counter")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/SellPanel")
	var quote: Dictionary = panel._quote.duplicate(true)
	panel._close({})
	await wait_physics_frames(2)
	scene.get_inventory().restore("scrap_wire_coil_01", "scrap_wire_coil")
	var station: SellStation = scene.get_world_object("station_sell_counter")
	var result: Dictionary = station.confirm_sale(quote)
	check(not result["success"], "stale quote rejected")
	check_eq(result["message_key"], "ui.sell.stale", "stale reason")
	check_eq(scene.get_wallet().get_balance(), 0, "no credits from stale quote")


func test_sell_with_empty_basket_is_refused() -> void:
	var scene: Node = await _new_game()
	await _approach(scene, "station_sell_counter")
	await _press_interact()
	check(not scene.get_node("HUD/SellPanel").visible, "no panel without items")
	check_eq(scene.get_wallet().get_balance(), 0, "no credits")


func test_unaffordable_ware_is_refused() -> void:
	var scene: Node = await _new_game()
	var desk: OrderDesk = scene.get_world_object("station_order_desk")
	await _approach(scene, "station_order_desk")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/CatalogPanel")
	for button: Node in _catalog_buttons(panel):
		check((button as Button).disabled, "nothing orderable without credits")
	check(not desk.buy("upgrade_carry_basket")["success"], "direct purchase refused")
	check(not desk.buy("upgrade_handcart")["success"], "locked ware refused")
	check_eq(scene.get_inventory().get_capacity(), 4, "capacity unchanged")
	check_eq(scene.get_wallet().get_balance(), 0, "no negative balance")
	panel.close()


func test_inconsistent_save_is_repaired() -> void:
	var data: Dictionary = _session.create_initial_state()
	data["wallet"] = {"balance": 7, "sequence": 3, "ledger": []}
	data["inventory"] = ["scrap_rusted_bolt_01", "ghost_item"]
	data["world_objects"] = {"scrap_empty_can_01": {"state": "carried"}}
	data["upgrades"] = ["ghost_upgrade"]
	check(_save.save_game(data)["ok"], "prepared save written")
	check(_session.continue_game(), "continue")
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(2)
	check_eq(scene.get_wallet().get_balance(), 7, "credits loaded")
	check(scene.get_inventory().contains("scrap_rusted_bolt_01"), "valid carried item restored")
	check(not scene.get_inventory().contains("ghost_item"), "unknown inventory id dropped")
	check_eq(scene.get_world_object("scrap_empty_can_01").get_state(), ScrapItem.State.IN_WORLD,
		"carried-without-inventory item returned to yard")
	check_eq(scene.get_restore_notes().size(), 3, "three repairs noted: %s" % ", ".join(scene.get_restore_notes()))


func test_negative_credit_save_is_rejected() -> void:
	var data: Dictionary = _session.create_initial_state()
	data["wallet"] = {"balance": -10}
	DirAccess.make_dir_recursive_absolute(_save.save_directory)
	var file := FileAccess.open(_save.get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	check(not _session.has_valid_save(), "negative balance makes the save invalid")
