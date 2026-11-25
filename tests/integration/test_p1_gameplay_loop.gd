extends TestSuite
## P1 acceptance sequence: collect -> salvage -> sell -> credits -> upgrade ->
## use the upgrade -> collect again -> save -> continue (docs/p1-gameplay-loop.md).

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


## Walks (teleports) next to an object and checks that it is the selected target.
func _approach(scene: Node, object_id: String) -> Interactable:
	var target: Interactable = scene.get_world_object(object_id)
	var point: Vector3 = target.get_interaction_point()
	scene.get_node("Player").place(Vector3(point.x, 0.1, point.z + 0.9), PI)
	await wait_physics_frames(4)
	check(scene.get_node("Player/PlayerInteractor").get_current_target() == target, "%s selected" % object_id)
	return target


func _press_interact() -> void:
	send_action("interact", true)
	send_action("interact", false)
	await wait_physics_frames(2)


func _pick(scene: Node, object_id: String) -> void:
	await _approach(scene, object_id)
	await _press_interact()


func _hold_interact(seconds: float) -> void:
	send_action("interact", true)
	await wait_physics_frames(int(seconds * Engine.physics_ticks_per_second))
	send_action("interact", false)
	await wait_physics_frames(2)


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


func test_full_p1_loop_with_save_and_continue() -> void:
	var scene: Node = await _new_game()
	var wallet: Wallet = scene.get_wallet()
	var inventory: CarryInventory = scene.get_inventory()
	check_eq(wallet.get_balance(), 0, "start with 0 credits")
	check_eq(inventory.get_capacity(), 4, "start capacity 4")
	# 1) Collect four loose items until the basket is full.
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_wire_coil_01", "scrap_rusted_bolt_02"]:
		await _pick(scene, object_id)
		check(inventory.contains(object_id), "%s carried" % object_id)
	check_eq(inventory.get_used_slots(), 4, "basket full")
	check(scene.get_node("HUD/EconomyHud/CarryPanel/Rows/Header/CarryValue").text.begins_with("4"), "HUD shows 4/4")
	# 2) Full basket: further pickup is refused without state change.
	await _pick(scene, "scrap_empty_can_02")
	check(not inventory.contains("scrap_empty_can_02"), "full basket refuses pickup")
	check(scene.get_world_object("scrap_empty_can_02").is_interaction_available(), "refused item stays in yard")
	# 3) Salvage needs free slots: refused while full.
	var beam: SalvageableScrap = await _approach(scene, "bulk_metal_beam_01")
	await _hold_interact(3.0)
	check(not beam.is_salvaged(), "salvage refused with full basket")
	# 4) Sell: quote, credits, items sold, no double booking.
	var quote: Dictionary = await _sell_everything(scene)
	check_eq(quote["total"], 3 + 2 + 7 + 3, "quote total from data values")
	check_eq(wallet.get_balance(), 15, "credits booked")
	check(inventory.is_empty(), "inventory emptied")
	check_eq(scene.get_world_object("scrap_rusted_bolt_01").get_state(), ScrapItem.State.SOLD, "item marked sold")
	var station: SellStation = scene.get_world_object("station_sell_counter")
	check(not station.confirm_sale(quote)["success"], "same quote cannot be booked twice")
	check_eq(wallet.get_balance(), 15, "balance unchanged by replay")
	# 5) Salvage: an interrupted hold changes nothing, a full hold salvages.
	await _approach(scene, "bulk_metal_beam_01")
	await _hold_interact(1.0)
	check(not beam.is_salvaged(), "interrupted hold does not salvage")
	await _hold_interact(beam.salvage_seconds + 0.3)
	check(beam.is_salvaged(), "beam salvaged")
	check(inventory.contains("bulk_metal_beam_01"), "beam carried")
	check_eq(inventory.get_used_slots(), 3, "beam uses 3 slots")
	# 6) Sell the beam, reach the upgrade price.
	await _sell_everything(scene)
	check_eq(wallet.get_balance(), 35, "beam sold for 20")
	# 7) Buy the upgrade at the workbench.
	await _approach(scene, "station_workbench")
	await _press_interact()
	var upgrade_panel: Control = scene.get_node("HUD/UpgradePanel")
	check(upgrade_panel.visible, "upgrade panel open")
	var buy_button: Button = upgrade_panel.get_node("%Offers").find_children("*", "Button", true, false)[0]
	check(not buy_button.disabled, "upgrade affordable")
	buy_button.pressed.emit()
	await wait_process_frames(2)
	check_eq(wallet.get_balance(), 5, "upgrade price debited")
	check_eq(inventory.get_capacity(), 8, "capacity increased immediately")
	var second_button: Button = upgrade_panel.get_node("%Offers").find_children("*", "Button", true, false)[0]
	check(second_button.disabled, "owned upgrade cannot be bought again")
	upgrade_panel.close()
	await wait_physics_frames(2)
	# 8) Use the upgrade: more than four slots in one trip now.
	for object_id: String in ["scrap_empty_can_02", "scrap_wire_coil_02"]:
		await _pick(scene, object_id)
	check(inventory.contains("scrap_wire_coil_02"), "collect again after upgrade")
	# 9) Drop and pick up again.
	check(scene.drop_last_item(), "drop works")
	var dropped: ScrapItem = scene.get_world_object("scrap_wire_coil_02")
	check(dropped.is_interaction_available(), "dropped item back in yard")
	await _pick(scene, "scrap_wire_coil_02")
	check(inventory.contains("scrap_wire_coil_02"), "dropped item picked again")
	check(scene.drop_last_item(), "drop again for persistence check")
	var dropped_position: Vector3 = dropped.global_position
	# 10) Save via the pause menu, return to menu, continue.
	send_action("pause_menu")
	await wait_process_frames(2)
	check(tree.paused, "pause menu pauses the game")
	scene.get_node("HUD/PauseMenu").get_node("%SaveExitButton").pressed.emit()
	var menu: Node = await wait_for_scene(MENU)
	check(menu != null, "back in main menu after save & exit")
	check(not tree.paused, "tree unpaused")
	check(_session.continue_game(), "continue")
	var restored: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	check_eq(restored.get_wallet().get_balance(), 5, "credits restored")
	check_eq(restored.get_inventory().get_capacity(), 8, "upgrade effect restored")
	check(restored.get_upgrades().is_owned("upgrade_carry_basket"), "upgrade restored")
	check(restored.get_inventory().contains("scrap_empty_can_02"), "carried item restored")
	check_eq(restored.get_inventory().get_entries().size(), 1, "exactly one carried item")
	check_eq(restored.get_world_object("bulk_metal_beam_01").get_state(), ScrapItem.State.SOLD, "beam stays sold")
	check_eq(restored.get_world_object("scrap_rusted_bolt_01").get_state(), ScrapItem.State.SOLD, "bolt stays sold")
	var restored_drop: ScrapItem = restored.get_world_object("scrap_wire_coil_02")
	check(restored_drop.is_interaction_available(), "dropped item in yard after load")
	check(restored_drop.global_position.distance_to(dropped_position) < 0.01, "dropped position restored")
	# 11) The loop keeps working after continuing.
	await _pick(restored, "scrap_wire_coil_02")
	await _sell_everything(restored)
	check_eq(restored.get_wallet().get_balance(), 5 + 2 + 7, "selling works after continue")


func test_stale_quote_is_rejected() -> void:
	var scene: Node = await _new_game()
	await _pick(scene, "scrap_rusted_bolt_01")
	await _approach(scene, "station_sell_counter")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/SellPanel")
	var quote: Dictionary = panel._quote.duplicate(true)
	panel._close({})
	await wait_physics_frames(2)
	# Inventory changes after the quote was made.
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


func test_upgrade_unaffordable_is_refused() -> void:
	var scene: Node = await _new_game()
	var station: UpgradeStation = scene.get_world_object("station_workbench")
	await _approach(scene, "station_workbench")
	await _press_interact()
	var panel: Control = scene.get_node("HUD/UpgradePanel")
	var button: Button = panel.get_node("%Offers").find_children("*", "Button", true, false)[0]
	check(button.disabled, "buy disabled without credits")
	var result: Dictionary = station.buy("upgrade_carry_basket")
	check(not result["success"], "direct purchase refused")
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
	check_eq(scene.get_world_object("scrap_rusted_bolt_01").get_state(), ScrapItem.State.CARRIED, "world state matches")
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
