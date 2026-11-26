extends TestSuite
## Gameplay actions trigger the expected sounds (presentation hooks).

const YARD: String = "res://scenes/world/OldYardTest.tscn"

var _played: Array = []


func before_each() -> void:
	tree.root.get_node("SaveService").delete_save()
	_played.clear()


func after_each() -> void:
	Input.action_release("interact")


func _record(sound_name: String) -> void:
	_played.append(sound_name)


func test_pickup_refusal_sale_and_hold_sounds() -> void:
	tree.root.get_node("GameSession").start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	scene.get_node("SoundFx").played.connect(_record)
	var player: CharacterBody3D = scene.get_node("Player")
	var bolt: Interactable = scene.get_world_object("scrap_rusted_bolt_01")
	player.place(bolt.get_interaction_point() + Vector3(0, 0.1, 0.25), PI)
	await wait_physics_frames(4)
	send_action("interact", true)
	send_action("interact", false)
	await tree.create_timer(0.8).timeout  # the item flight takes 0.42 s of real time
	check(_played.has("clink"), "bolt pickup clinks")
	check(_played.has("basket"), "item lands in the basket")
	var crate: Interactable = scene.get_world_object("source_storage_crate_01")
	player.place(crate.get_interaction_point() + Vector3(0, 0.1, 0.25), PI)
	await wait_physics_frames(4)
	send_action("interact", true)
	send_action("interact", false)
	await wait_physics_frames(3)
	check(_played.has("nope"), "refusal without crowbar bonks")
	var heap: Interactable = scene.get_world_object("source_small_scrap_pile_01")
	player.place(heap.get_interaction_point() + Vector3(0, 0.1, 0.25), PI)
	await wait_physics_frames(4)
	send_action("interact", true)
	await wait_physics_frames(20)
	check(_played.has("rummage"), "searching rummages")
	send_action("interact", false)
	await wait_physics_frames(3)
	var counter: Interactable = scene.get_world_object("station_sell_counter")
	player.place(counter.get_interaction_point() + Vector3(0, 0.1, 0.25), PI)
	await wait_physics_frames(4)
	send_action("interact", true)
	send_action("interact", false)
	await wait_physics_frames(2)
	check(_played.has("bell"), "opening the counter rings the bell")
	scene.get_node("HUD/SellPanel").get_node("%ConfirmButton").pressed.emit()
	await wait_physics_frames(2)
	check(_played.has("kaching"), "sale ka-chings")
	check(_played.has("click"), "buttons click")
