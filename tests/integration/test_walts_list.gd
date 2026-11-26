extends TestSuite
## Walt's list (P4, docs/p4-vertical-slice.md): the short main task sequence,
## derived from existing state, announced once per entry, shown from the
## pause menu and correct after loading.

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
	return scene


func _done_ids(director: StoryDirector) -> Array:
	var ids: Array = []
	for state: Dictionary in director.get_task_states():
		if state["done"]:
			ids.append(state["entry"]["id"])
	return ids


func test_list_is_valid_and_translated() -> void:
	var list: TaskList = load("res://data/story/walts_list.tres")
	check(list.validate().is_empty(), "list valid: %s" % ", ".join(list.validate()))
	check(list.entries.size() >= 5 and list.entries.size() <= 8, "short: %d entries" % list.entries.size())
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for entry: Dictionary in list.entries:
			for key: String in [entry["title"], entry["comment"]]:
				check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")


func test_entries_tick_off_once_and_survive_loading() -> void:
	var scene: Node = await _new_game()
	var director: StoryDirector = scene.get_node("StoryDirector")
	check_eq(_done_ids(director), ["letter"], "only the letter counts without the intro")
	var completed: Array = []
	director.task_completed.connect(func(entry: Dictionary, all_done: bool) -> void:
		completed.append([entry["id"], all_done]))
	scene.get_story().set_flag(StoryDirector.FLAG_FIRST_SALE)
	check_eq(completed, [["first_sale", false]], "first sale announced")
	scene.get_story().set_flag(StoryDirector.FLAG_FIRST_SALE)
	director.refresh_notes()
	check_eq(completed.size(), 1, "announced only once")
	var definition: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(definition.price, "test", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	check(completed.has(["entrance", false]), "buying the entrance ticks it off")
	check(scene.save_game(), "save")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	director = scene.get_node("StoryDirector")
	var after_load: Array = []
	director.task_completed.connect(func(entry: Dictionary, _all: bool) -> void: after_load.append(entry["id"]))
	director.refresh_notes()
	check(after_load.is_empty(), "nothing re-announced after loading")
	var ids: Array = _done_ids(director)
	check(ids.has("first_sale") and ids.has("entrance") and ids.has("letter"), "state restored: %s" % [ids])
	check(not ids.has("scrappy"), "open entries stay open")


func test_last_entry_completes_the_list() -> void:
	var scene: Node = await _new_game()
	var director: StoryDirector = scene.get_node("StoryDirector")
	var last: Array = []
	director.task_completed.connect(func(entry: Dictionary, all_done: bool) -> void:
		if all_done:
			last.append(entry["id"]))
	var story: StoryState = scene.get_story()
	for flag: String in [StoryDirector.FLAG_FIRST_SALE, StoryDirector.FLAG_FIRST_PURCHASE, StoryDirector.FLAG_RESTORED,
			StoryDirector.FLAG_FIRST_HIRE]:
		story.set_flag(flag)
	var entrance: UpgradeDefinition = scene.get_upgrades().get_catalog().get_definition("yard_entrance")
	scene.get_wallet().credit(entrance.price + 60, "test", "test")
	scene.get_upgrades().purchase("yard_entrance", scene.get_wallet())
	check(scene.get_placed().place("magnet_collector", Vector2i(69, -27), 0)["ok"], "machine set up")
	check_eq(last, ["machine"], "the last entry completes the list")


func test_pause_menu_opens_the_list_and_returns() -> void:
	var scene: Node = await _new_game()
	scene._open_pause_menu()
	var pause_menu: Control = scene.get_node("HUD/PauseMenu")
	pause_menu.get_node("%TasksButton").pressed.emit()
	await wait_process_frames(2)
	var panel: Control = scene.get_node("HUD/TaskListPanel")
	check(panel.visible, "list opens")
	check(not pause_menu.visible, "pause menu steps aside")
	var rows: Node = panel.get_node("%TaskRows")
	check_eq(rows.get_child_count(), 7, "seven entries")
	check_eq(rows.get_child(0).get_child(0).name, "Done", "letter ticked")
	check_eq(rows.get_child(1).get_child(0).name, "Open", "first sale still open")
	check_eq(panel.get_node("%Footer").text, tr("ui.tasks.progress").format({"done": 1, "total": 7}), "progress line")
	panel.close()
	check(pause_menu.visible, "back in the pause menu")
	scene._close_pause_menu()


func test_settings_can_be_changed_during_play() -> void:
	var scene: Node = await _new_game()
	var previous: float = _session.get_setting(_session.SETTING_MUSIC_VOLUME)
	scene._open_pause_menu()
	var pause_menu: Control = scene.get_node("HUD/PauseMenu")
	pause_menu.get_node("%SettingsButton").pressed.emit()
	await wait_process_frames(2)
	var panel: Control = scene.get_node("HUD/SettingsPanel")
	check(panel.visible and not pause_menu.visible, "settings open from the pause menu")
	panel.get_node("%MusicSlider").value = 0.3
	check_near(_session.get_setting(_session.SETTING_MUSIC_VOLUME), 0.3, 0.001, "music volume applied")
	var bus: int = AudioServer.get_bus_index(&"Music")
	check(bus >= 0 and AudioServer.get_bus_volume_db(bus) < -5.0, "music bus turned down")
	panel.close()
	check(pause_menu.visible, "back in the pause menu")
	scene._close_pause_menu()
	_session.set_setting(_session.SETTING_MUSIC_VOLUME, previous)
