extends TestSuite
## P2: Walt's letter, notes, Scrappy's head and core, the repair, Scrappy's
## behaviour and persistence (docs/p2-arrival-and-scrappy.md).

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const LOCALES: PackedStringArray = ["de", "en"]

var _session: Node


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_session.intro_enabled = false
	tree.root.get_node("SaveService").delete_save()


func after_each() -> void:
	Input.action_release("interact")
	_session.intro_enabled = false
	tree.get_root().get_tree().paused = false
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


func _restore_scrappy(scene: Node) -> void:
	scene.get_story().add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	scene.get_story().add_key_item(StoryState.KEY_SCRAPPY_CORE)
	await _approach(scene, "station_workbench")
	await _hold(3.3)
	await tree.create_timer(3.0).timeout


func test_letter_opens_on_new_game_and_from_pause_menu() -> void:
	_session.intro_enabled = true
	var scene: Node = await _new_game()
	var letter: Control = scene.get_node("HUD/LetterPanel")
	check(letter.visible, "letter shown on a new game")
	check(letter.get_node("%Body").text.length() > 200, "letter text filled from localization")
	check(not scene.get_node("HUD/TaskNotes").visible, "no notes before the letter is read")
	letter.get_node("%CloseButton").pressed.emit()
	await wait_physics_frames(2)
	check(scene.get_story().has_flag("letter_read"), "reading is remembered")
	check(scene.get_node("Player/PlayerInteractor").is_enabled(), "input released after the letter")
	check(scene.get_node("HUD/TaskNotes").visible, "notes appear after the letter")
	scene._open_pause_menu()
	scene.get_node("HUD/PauseMenu").get_node("%LetterButton").pressed.emit()
	await wait_process_frames(2)
	check(letter.visible and not scene.get_node("HUD/PauseMenu").visible, "letter re-readable from the pause menu")
	letter.close()
	await wait_process_frames(2)
	check(scene.get_node("HUD/PauseMenu").visible, "closing returns to the pause menu")
	scene._close_pause_menu()


func test_notes_follow_the_story_and_stay_at_two() -> void:
	var scene: Node = await _new_game()
	var director: StoryDirector = scene.get_node("StoryDirector")
	var story: StoryState = scene.get_story()
	check_eq(director.compute_note_keys(), PackedStringArray(["note.look_around"]), "start: look around")
	story.set_flag("first_pickup")
	check_eq(director.compute_note_keys(), PackedStringArray(["note.sell"]), "after a pickup: sell")
	story.add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	check_eq(director.compute_note_keys(), PackedStringArray(["note.need_core", "note.sell"]), "head: needs core")
	story.add_key_item(StoryState.KEY_SCRAPPY_CORE)
	story.set_flag("first_sale")
	story.set_flag("first_purchase")
	check_eq(director.compute_note_keys(), PackedStringArray(["note.repair_scrappy"]), "both parts: repair")
	var notes: Control = scene.get_node("HUD/TaskNotes")
	check_eq(notes.get_key_items().size(), 2, "key items listed under 'special'")
	story.remove_key_item(StoryState.KEY_SCRAPPY_HEAD)
	story.remove_key_item(StoryState.KEY_SCRAPPY_CORE)
	story.set_flag("scrappy_restored")
	check_eq(director.compute_note_keys(), PackedStringArray(["note.entrance"]), "after the repair: entrance")


func test_head_is_dug_out_once_and_is_a_key_item() -> void:
	var scene: Node = await _new_game()
	var site: Interactable = await _approach(scene, "story_scrappy_head")
	check(site.get_hold_duration() >= 1.5, "digging out is a hold action")
	check(site.check_requirements(scene._context)["ok"], "no tool required")
	await _hold(2.4)
	check(scene.get_story().has_key_item("scrappy_head"), "head became a key item")
	check_eq(scene.get_inventory().get_used_slots(), 0, "key items use no basket slots")
	check(scene.get_node("HUD/InspectPanel").visible, "discovery is shown")
	check(not site.is_interaction_available(), "head site is empty afterwards")
	var snapshot: Dictionary = scene.create_snapshot()
	check(snapshot["story"]["key_items"].has("scrappy_head"), "key item in the snapshot")
	check_eq(snapshot["world_objects"].get("story_scrappy_head"), {"taken": true}, "site state saved")
	scene.get_node("HUD/InspectPanel").close()


func test_red_toolbox_gives_the_core_exactly_once() -> void:
	var scene: Node = await _new_game()
	var box: Interactable = await _approach(scene, "story_red_toolbox")
	scene.get_node("Player/PlayerInteractor")._execute(box)
	await wait_physics_frames(2)
	check(scene.get_story().has_key_item("scrappy_core"), "core found")
	scene.get_node("HUD/InspectPanel").close()
	scene.get_story().remove_key_item("scrappy_core")
	await wait_physics_frames(2)
	scene.get_node("Player/PlayerInteractor")._execute(box)
	await wait_physics_frames(2)
	check(not scene.get_story().has_key_item("scrappy_core"), "opening again gives no second core")
	scene.get_node("HUD/InspectPanel").close()


func test_key_items_cannot_be_sold() -> void:
	var scene: Node = await _new_game()
	scene.get_story().add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	var counter: Interactable = await _approach(scene, "station_sell_counter")
	scene.get_node("Player/PlayerInteractor")._execute(counter)
	await wait_physics_frames(2)
	check(not scene.get_node("HUD/SellPanel").visible, "nothing sellable: no sell panel")
	check(scene.get_story().has_key_item(StoryState.KEY_SCRAPPY_HEAD), "head kept")


func test_workbench_only_repairs_with_both_parts_and_once() -> void:
	var scene: Node = await _new_game()
	var bench: RepairBench = await _approach(scene, "station_workbench")
	check_eq(bench.get_action_key(), "ui.action.inspect", "without parts the bench is only inspected")
	scene.get_story().add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	check_eq(bench.get_action_key(), "ui.action.inspect", "the head alone is not enough")
	await _restore_scrappy(scene)
	var scrappy: Node = scene.get_node("Scrappy")
	check(scrappy.is_active() and scrappy.visible, "Scrappy wakes up")
	check(scene.get_story().has_flag("scrappy_restored"), "restoration flag set")
	check(scene.get_story().get_key_items().is_empty(), "parts were used")
	check_eq(bench.get_action_key(), "ui.action.inspect", "no second repair")
	check(not scene.get_node("GameplayCamera").is_focusing(), "camera back on the player")
	check(scene.get_node("Player/PlayerInteractor").is_enabled(), "input released after the staging")
	var director: StoryDirector = scene.get_node("StoryDirector")
	check(director.get_last_line().begins_with("scrappy.wake."), "Scrappy speaks when waking")


func test_scrappy_follows_waits_and_never_blocks() -> void:
	var scene: Node = await _new_game()
	await _restore_scrappy(scene)
	var scrappy: CharacterBody3D = scene.get_node("Scrappy")
	check_eq(scrappy.collision_layer, 0, "Scrappy is no physical obstacle")
	var player: CharacterBody3D = scene.get_node("Player")
	player.place(Vector3(20, 0.1, -10), PI)
	await tree.create_timer(2.5).timeout
	var distance: float = scrappy.global_position.distance_to(player.global_position)
	check(distance < 4.0, "Scrappy catches up (distance %.1f)" % distance)
	var talk: ScrappyInteraction = scrappy.get_node("Talk")
	talk.interact(scene._context)
	check(not scrappy.is_following(), "talking toggles to waiting")
	await tree.create_timer(0.8).timeout
	var resting: Vector3 = scrappy.global_position
	player.place(Vector3(14, 0.1, -6), PI)
	await tree.create_timer(1.5).timeout
	check(scrappy.global_position.distance_to(resting) < 0.3, "waiting Scrappy stays put")
	var saved: Dictionary = scene.create_snapshot()["scrappy"]
	check_eq(saved["follow"], false, "follow mode saved")
	check_eq(saved["state"], "active", "active state saved")
	talk.interact(scene._context)
	check(scrappy.is_following(), "toggles back to following")


func test_scrappy_survives_save_and_continue() -> void:
	var scene: Node = await _new_game()
	await _restore_scrappy(scene)
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	check(scene.get_node("Scrappy").is_active(), "Scrappy active after loading")
	check(scene.get_story().has_flag("scrappy_restored"), "flag restored")
	check(not scene.get_node("StoryDirector").get_last_line().begins_with("scrappy.wake."),
		"no wake-up lines after loading")


func test_director_rules_cooldown_and_once() -> void:
	var scene: Node = await _new_game()
	await _restore_scrappy(scene)
	var director: StoryDirector = scene.get_node("StoryDirector")
	var story: StoryState = scene.get_story()
	check(story.was_spoken("scrappy.wake.1"), "one-time lines are remembered")
	director.play_wake_sequence()
	check(not director.get_last_line().is_empty(), "director still knows its last line")
	var spoken: Array = []
	director.line_spoken.connect(func(key: String) -> void: spoken.append(key))
	for index: int in 5:
		director.on_follow_toggled(true)
	check(spoken.size() <= 2, "cooldown/queue keeps chatter bounded (%d)" % spoken.size())
	check(not spoken.any(func(key: String) -> bool: return key.begins_with("scrappy.wake.")),
		"wake-up lines are never repeated")


func test_dormant_scrappy_says_nothing() -> void:
	var scene: Node = await _new_game()
	var director: StoryDirector = scene.get_node("StoryDirector")
	check(not director.say_event("purchase", true), "no lines before the repair")
	check(not scene.get_node("Scrappy").visible, "dormant Scrappy is hidden")


func test_entrance_ware_shows_at_the_gate() -> void:
	var scene: Node = await _new_game()
	var entrance: Node3D = scene.get_node("DeliveryArea/yard_entrance")
	check(not entrance.visible, "entrance plain at the start")
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	check(definition != null and definition.price > 0, "entrance is a catalog ware")
	scene.get_wallet().credit(definition.price, "test-entrance", "test")
	var desk: OrderDesk = scene.get_world_object("station_order_desk")
	desk.interact(scene._context)
	check(desk.buy("yard_entrance").get("success", false), "entrance bought")
	scene.get_node("HUD/CatalogPanel").close()
	await wait_physics_frames(2)
	check(entrance.visible, "entrance improvement delivered")


func test_lines_and_story_texts_exist_in_all_locales() -> void:
	var lines: ScrappyLines = load("res://data/story/scrappy_lines.tres")
	check(lines.validate().is_empty(), "line rules valid: %s" % ", ".join(lines.validate()))
	var keys: PackedStringArray = []
	for event: String in lines.events:
		for index: int in range(1, int(lines.events[event]["count"]) + 1):
			keys.append("scrappy.%s.%d" % [event, index])
	for memory: Dictionary in lines.memories:
		keys.append(memory["line"])
	for note: String in ["note.look_around", "note.sell", "note.catalog", "note.need_core", "note.core_where",
			"note.repair_scrappy", "note.entrance", "story.letter.body", "key_item.scrappy_head.name",
			"key_item.scrappy_core.name"]:
		keys.append(note)
	var previous: String = TranslationServer.get_locale()
	for locale: String in LOCALES:
		TranslationServer.set_locale(locale)
		var missing: PackedStringArray = []
		for key: String in keys:
			if tree.root.tr(key) == key:
				missing.append(key)
		check(missing.is_empty(), "%s: missing %s" % [locale, ", ".join(missing)])
	TranslationServer.set_locale(previous)
