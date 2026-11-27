extends TestSuite
## The scrap press and conveyor links (docs/scrap-press.md, machine-links.md):
## bolts and cans become steel bales; the magnetic collector's crate can be
## connected to the press hopper, the route is found automatically, belts
## block building but not walking, links follow moved machines, can be undone
## and survive a restart.

const YARD: String = "res://scenes/world/OldYardTest.tscn"
const MAGNET_ANCHOR := Vector2i(69, -27)

var _session: Node
var _credits: int = 0


func before_each() -> void:
	_session = tree.root.get_node("GameSession")
	_session.intro_enabled = false
	tree.root.get_node("SaveService").delete_save()


func after_each() -> void:
	tree.root.get_node("SaveService").delete_save()


func _new_game() -> Node:
	_session.start_new_game()
	var scene: Node = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	scene.get_deliveries()._timer = 100000.0
	return scene


func _place(scene: Node, placeable_id: String, anchor: Vector2i, rotation_steps: int = 0) -> String:
	var placed: PlacedObjects = scene.get_placed()
	_credits += 1
	scene.get_wallet().credit(placed.get_price(placed.catalog.get_definition(placeable_id)), "test-%d" % _credits, "test")
	var result: Dictionary = placed.place(placeable_id, anchor, rotation_steps)
	check(result["ok"], "%s placed: %s" % [placeable_id, result.get("message_key")])
	return result.get("uid", "")


## Places the press somewhere free near the magnet where a belt fits.
func _place_press_near(scene: Node, magnet_uid: String) -> String:
	var placed: PlacedObjects = scene.get_placed()
	var definition: PlaceableDefinition = placed.catalog.get_definition("scrap_press")
	for distance: int in range(2, 16):
		for dx: int in range(-distance, distance + 1):
			for dy: int in [-distance, distance]:
				var anchor: Vector2i = MAGNET_ANCHOR + Vector2i(dx, dy)
				if placed.check_placement(definition, anchor, 0)["ok"]:
					var uid: String = _place(scene, "scrap_press", anchor)
					if placed.links.check_link(magnet_uid, uid)["ok"]:
						return uid
					placed.remove(uid)
	check(false, "found a place for the press")
	return ""


func _press(scene: Node, uid: String) -> ScrapPress:
	return scene.get_placed().get_node_for(uid) as ScrapPress


func test_data_is_valid_and_translated() -> void:
	var profile: PressProfile = load("res://data/machines/scrap_press.tres")
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	check(profile.validate(catalog).is_empty(), "profile valid: %s" % ", ".join(profile.validate(catalog)))
	check_eq(profile.groups.size(), 3, "steel, copper & electronics, wood")
	for group: MaterialGroup in profile.groups:
		var bale: ItemDefinition = catalog.get_definition(group.bale_item)
		var average: float = 0.0
		for item_id: String in group.items:
			average += catalog.get_definition(item_id).sell_value
		average /= group.items.size()
		var loose: float = average * group.pieces_per_bale
		check(bale.sell_value >= loose * 1.25, "%s bale pays a premium: %d vs %.1f loose" % [group.id, bale.sell_value, loose])
		check(bale.sell_value <= loose * 1.6, "%s premium stays modest" % group.id)
		check(bale.carry_size < group.pieces_per_bale, "%s bale saves basket room" % group.id)
		check(tr(group.name_key) != group.name_key, "%s named" % group.id)
	var placeable: PlaceableDefinition = load("res://data/placeables/scrap_press.tres")
	check_eq(placeable.max_count, 3, "up to three presses")
	var kinds: Array = []
	for port: Dictionary in placeable.ports:
		kinds.append(port["kind"])
	check(kinds.has("in") and kinds.has("out"), "press has input and output ports")
	var keys: PackedStringArray = [profile.name_key, profile.description_key, "item.bale_steel.name",
		"item.bale_steel.description", "item.bale_copper.name", "item.bale_wood.name", "build.tool.connect",
		"build.info.connect_pick", "build.info.connect_target", "build.info.connect_ok", "build.info.remove_link",
		"build.linked", "build.unlinked", "build.link_blocked", "ui.press.detail", "ui.press.fed",
		"ui.press.nothing_to_feed", "ui.press.rule", "ui.press.hopper_empty", "build.problem.press_not_empty"]
	for status: String in ["working", "waiting", "tray_full", "off"]:
		keys.append("ui.press.status." + status)
	for key: String in ["link_same", "link_no_output", "link_no_input", "link_output_used", "link_input_used",
			"link_incompatible", "link_no_route"]:
		keys.append("build.problem." + key)
	for locale: String in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for key: String in keys:
			check(tr(key) != key, "%s translated (%s)" % [key, locale])
	TranslationServer.set_locale("de")


func test_press_by_hand_makes_bales_per_material() -> void:
	var scene: Node = await _new_game()
	var uid: String = _place(scene, "scrap_press", Vector2i(30, -40))
	if uid.is_empty():
		return
	var press: ScrapPress = _press(scene, uid)
	check_eq(press.get_status(), ScrapPress.STATUS_WAITING, "waits for scrap")
	var hopper: PressControls = press.get_node("Machine/Hopper")
	var refused: Dictionary = hopper.interact(scene._context)
	check(not refused["success"] and refused["message_key"] == "ui.press.nothing_to_feed", "empty basket refused")
	for object_id: String in ["scrap_rusted_bolt_01", "scrap_empty_can_01", "scrap_rusted_bolt_02", "scrap_wire_coil_01"]:
		var item: ScrapItem = scene.get_world_object(object_id) as ScrapItem
		check(item.interact(scene._context)["success"], "picked up %s" % object_id)
	var result: Dictionary = hopper.interact(scene._context)
	check(result["success"] and int(result["message_args"]["count"]) == 4, "four pieces fed")
	check(scene.get_inventory().is_empty(), "basket emptied")
	check_eq((scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem).get_state(), ScrapItem.State.PROCESSED,
		"fed piece consumed")
	check_eq(press.get_group_counts(), {"steel": 3, "copper": 1}, "pieces counted per material")
	check(not press.can_accept("device_broken_radio"), "devices are not pressed")
	check(not press.can_accept("bale_steel"), "bales are not pressed again")
	check(press.accept_item(scene.get_world_object("scrap_empty_can_02") as ScrapItem), "can accepted")
	check(press.accept_item(scene.get_world_object("scrap_rusted_bolt_03") as ScrapItem), "bolt accepted")
	check(press.press_once() == null, "five steel pieces are not a bale yet")
	var magnet_uid: String = _place(scene, "magnet_collector", MAGNET_ANCHOR)
	var extra: ScrapItem = (scene.get_placed().get_node_for(magnet_uid) as MagnetCollector).collect_once()
	check(press.accept_item(extra), "sixth steel piece accepted")
	check_eq(press.get_status(), ScrapPress.STATUS_WORKING, "pressing")
	var bale: ScrapItem = press.press_once()
	check(bale != null and bale.get_item_id() == "bale_steel", "a steel bale")
	check_eq(press.get_group_counts(), {"copper": 1}, "the copper piece waits for its own bale")
	check(scene.get_world_object(bale.object_id) == bale, "bale registered")
	check(bale.object_id.begins_with("press_" + uid), "bale id unique per press")
	check(press.get_removal_problem() != "", "can't store the press with a bale on the tray")
	var bale_id: String = bale.object_id
	check(bale.interact(scene._context)["success"], "bale picked up")
	var station: SellStation = scene.get_world_object("station_sell_counter") as SellStation
	station.interact(scene._context)
	var sale: Dictionary = station.confirm_sale(station.create_quote())
	await wait_process_frames(2)
	check_eq(int(sale["message_args"]["total"]), 22, "bale sells for 22 Cr")
	check(scene.get_world_object(bale_id) == null, "sold bale leaves the world")


func test_conveyor_links_magnet_to_press() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var magnet_uid: String = _place(scene, "magnet_collector", MAGNET_ANCHOR)
	var magnet: MagnetCollector = placed.get_node_for(magnet_uid) as MagnetCollector
	var press_uid: String = _place_press_near(scene, magnet_uid)
	var press: ScrapPress = _press(scene, press_uid)
	check_eq(placed.links.check_link(press_uid, magnet_uid)["key"], "link_no_input", "magnet has no input")
	check_eq(placed.links.check_link(magnet_uid, magnet_uid)["key"], "link_same", "no self links")
	var result: Dictionary = placed.links.link(magnet_uid, press_uid)
	check(result["ok"], "linked: %s" % result["message_key"])
	var link: Dictionary = placed.links.get_link(result["link_id"])
	var cells: Array = link["cells"]
	check(not cells.is_empty(), "route found (%d cells)" % cells.size())
	check(placed.links.get_link_at(cells[0]) == link["id"], "belt found by cell")
	check(not placed.navigation.is_solid(cells[0]), "belts are walkable")
	var decor: PlaceableDefinition = placed.catalog.get_definition("decor_gnome")
	var on_belt: Dictionary = placed.check_placement(decor, cells[cells.size() / 2], 0)
	check(not on_belt["ok"], "nothing can be built on a belt")
	check_eq(placed.links.link(magnet_uid, press_uid)["ok"], false, "output used only once")
	for index: int in 6:
		magnet.collect_once()
	check_eq(magnet.get_bin_count(), 6, "crate full")
	for index: int in 6:
		check(placed.links.send_once(link["id"]) != "", "piece %d sent" % (index + 1))
	check_eq(magnet.get_bin_count(), 0, "crate emptied by the belt")
	check_eq(press.get_hopper_count(), 6, "hopper filled (pieces still riding count)")
	check_eq(placed.links.send_once(link["id"]), "", "nothing left to send")
	check(press.press_once() == null, "nothing is pressed before the pieces arrive")
	press._advance_incoming(60.0)
	check(press.press_once() != null, "bale pressed from belt scrap once it arrived")
	# Waiting in real time: the belt keeps sending by itself.
	magnet.collect_once()
	placed.links._links[link["id"]]["timer"] = 0.01
	await wait_process_frames(3)
	check_eq(press.get_hopper_count(), 1, "belt works on its own")


func test_links_follow_moves_undo_and_survive_loading() -> void:
	var scene: Node = await _new_game()
	var placed: PlacedObjects = scene.get_placed()
	var build: BuildMode = scene.get_node("BuildMode")
	var magnet_uid: String = _place(scene, "magnet_collector", MAGNET_ANCHOR)
	var press_uid: String = _place_press_near(scene, magnet_uid)
	scene.enter_build_mode()
	await wait_process_frames(2)
	build.set_tool(BuildMode.TOOL_CONNECT)
	build.aim_at(placed.get_node_for(magnet_uid).global_position)
	check(build.confirm()["ok"], "source picked")
	check_eq(build.get_link_from(), magnet_uid, "remembers the source")
	build.aim_at(placed.get_node_for(press_uid).global_position)
	check(build.get_last_check().get("ok", false), "preview shows a free route")
	var linked: Dictionary = build.confirm()
	check(linked["ok"], "connected with the tool")
	check_eq(placed.links.get_links().size(), 1, "one link")
	build.undo()
	check_eq(placed.links.get_links().size(), 0, "undo removes the belt")
	build.redo()
	check_eq(placed.links.get_links().size(), 1, "redo builds it again")
	var link_id: int = placed.links.find_link(magnet_uid, press_uid)
	var before: Array = placed.links.get_link(link_id)["cells"].duplicate()
	# Move the press one cell further away: the belt follows.
	var entry: Dictionary = {}
	for candidate: Dictionary in placed.get_entries():
		if candidate["uid"] == press_uid:
			entry = candidate
	var moved: bool = false
	for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(2, 0)]:
		if placed.move(press_uid, entry["anchor"] + step, entry["rot"])["ok"]:
			moved = true
			break
	check(moved, "press moved")
	var after: Dictionary = placed.links.get_link(link_id)
	check(not after["blocked"] and after["cells"] != before, "belt re-routed after the move")
	# Remove tool on a belt cell removes the link.
	build.set_tool(BuildMode.TOOL_REMOVE)
	build.aim_at(BuildGrid.cell_center(after["cells"][0]))
	check_eq(build.get_hover_link(), link_id, "belt under the cursor")
	check(build.confirm()["ok"], "belt removed")
	check_eq(placed.links.get_links().size(), 0, "no link left")
	build.undo()
	check_eq(placed.links.get_links().size(), 1, "undo brings the belt back")
	scene.exit_build_mode()
	var press: ScrapPress = _press(scene, press_uid)
	press.accept_item(scene.get_world_object("scrap_rusted_bolt_01") as ScrapItem)
	check(scene.save_game(), "save succeeds")
	_session.continue_game()
	await wait_process_frames(2)
	scene = await wait_for_scene(YARD)
	await wait_physics_frames(3)
	placed = scene.get_placed()
	check_eq(placed.links.get_links().size(), 1, "link restored")
	var restored: Dictionary = placed.links.get_links()[0]
	check(restored["from"] == magnet_uid and restored["to"] == press_uid and not restored["blocked"], "same machines, running")
	check_eq(_press(scene, press_uid).get_hopper_count(), 1, "hopper content restored")
	check(scene.get_restore_notes().is_empty(), "no repairs: %s" % ", ".join(scene.get_restore_notes()))
	# Storing a machine drops its links.
	var magnet: MagnetCollector = placed.get_node_for(magnet_uid) as MagnetCollector
	check(magnet.get_bin_count() == 0, "crate empty")
	check(placed.remove(magnet_uid)["ok"], "magnet stored")
	await wait_process_frames(2)
	check_eq(placed.links.get_links().size(), 0, "link gone with the machine")
