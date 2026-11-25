extends TestSuite
## P1b: optional dismantling of the broken radio vs. direct sale.

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


func _approach(scene: Node, object_id: String) -> void:
	var point: Vector3 = scene.get_world_object(object_id).get_interaction_point()
	scene.get_node("Player").place(Vector3(point.x, 0.1, point.z + 0.9), PI)
	await wait_physics_frames(4)
	check(scene.get_node("Player/PlayerInteractor").get_current_target() == scene.get_world_object(object_id),
		"%s selected" % object_id)


func _hold(seconds: float) -> void:
	send_action("interact", true)
	await wait_physics_frames(int(seconds * Engine.physics_ticks_per_second))
	send_action("interact", false)
	await wait_physics_frames(2)


func _sell(scene: Node) -> void:
	await _approach(scene, "station_sell_counter")
	await _hold(0.05)
	scene.get_node("HUD/SellPanel").get_node("%ConfirmButton").pressed.emit()
	await wait_physics_frames(2)


func test_dismantle_needs_the_input() -> void:
	var scene: Node = await _new_game()
	var station: DismantleStation = scene.get_world_object("station_dismantle_table")
	await _approach(scene, "station_dismantle_table")
	await _hold(station.profile.seconds + 0.3)
	check(scene.get_inventory().is_empty(), "nothing produced without radio")
	check_eq(scene.get_world_object("device_broken_radio_01_copper_wire").get_state(), ScrapItem.State.PENDING,
		"outputs stay pending")


func test_dismantle_yields_more_than_direct_sale() -> void:
	var scene: Node = await _new_game()
	var station: DismantleStation = scene.get_world_object("station_dismantle_table")
	check(station.profile.get_output_value() > station.profile.input_item.sell_value, "processing adds value")
	check(station.profile.outputs.size() <= 2, "at most two outputs")
	await _approach(scene, "device_broken_radio_01")
	await _hold(0.05)
	check(scene.get_inventory().contains("device_broken_radio_01"), "radio carried")
	await _approach(scene, "station_dismantle_table")
	await _hold(1.0)
	check(scene.get_inventory().contains("device_broken_radio_01"), "interrupted dismantling changes nothing")
	await _hold(station.profile.seconds + 0.3)
	var inventory: CarryInventory = scene.get_inventory()
	check(not inventory.contains("device_broken_radio_01"), "radio consumed")
	check(inventory.contains("device_broken_radio_01_copper_wire"), "copper wire produced")
	check(inventory.contains("device_broken_radio_01_electronic_parts"), "electronic parts produced")
	check_eq(scene.get_world_object("device_broken_radio_01").get_state(), ScrapItem.State.PROCESSED, "radio processed")
	await _hold(station.profile.seconds + 0.3)
	check_eq(inventory.get_entries().size(), 2, "no duplication on second attempt")
	await _sell(scene)
	check_eq(scene.get_wallet().get_balance(), station.profile.get_output_value(), "outputs sold for 16")
	# Persistence of processed state.
	check(scene.save_game(), "save")
	check(_session.continue_game(), "continue")
	var restored: Node = await wait_for_scene(YARD)
	await wait_physics_frames(2)
	check_eq(restored.get_world_object("device_broken_radio_01").get_state(), ScrapItem.State.PROCESSED,
		"radio stays processed")
	check_eq(restored.get_world_object("device_broken_radio_01_copper_wire").get_state(), ScrapItem.State.SOLD,
		"output stays sold")


func test_direct_sale_of_radio_remains_possible() -> void:
	var scene: Node = await _new_game()
	await _approach(scene, "device_broken_radio_01")
	await _hold(0.05)
	await _sell(scene)
	check_eq(scene.get_wallet().get_balance(), 12, "radio sold directly")
	check_eq(scene.get_world_object("device_broken_radio_01_copper_wire").get_state(), ScrapItem.State.PENDING,
		"no outputs without processing")
