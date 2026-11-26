extends Node3D
## Coordinator of the Old Yard gameplay scene (docs/p0-implementation-readiness.md,
## sections 3.5 and 6; P1 additions in docs/p1-gameplay-loop.md).
##
## Restores player, world objects, wallet, carried items and upgrades from
## GameSession data, wires the components explicitly, routes interaction
## results to the HUD and creates the data snapshot on save requests.
## Performs no file I/O.

@export_group("Scene")
@export var player: CharacterBody3D
@export var player_start: Marker3D
@export var camera_rig: Node3D
@export var world_objects_root: Node3D
@export_group("HUD")
@export var interaction_prompt: Control
@export var feedback_toast: Control
@export var inspect_panel: Control
@export var sell_panel: Control
@export var catalog_panel: Control
@export var pause_menu: Control
@export var economy_hud: Control
@export var controls_hint: Label
@export var debug_overlay: Control
@export_group("Presentation")
## World effects (dust, flying items, coins); optional.
@export var fx: Node3D
## Scene sound effects (scripts/audio/SoundFx.gd); optional.
@export var sound_fx: Node
@export_group("Story")
## Scrappy (scenes/scrappy/Scrappy.tscn); optional so P1 test scenes still run.
@export var scrappy: CharacterBody3D
@export var story_director: StoryDirector
@export var letter_panel: Control
@export var task_notes: Control
@export var speech_bubble: Control
@export_group("Data")
@export var item_catalog: ItemCatalog
@export var upgrade_catalog: UpgradeCatalog
@export var balance: PrototypeBalance

var _interactor: Node
var _animator: Node
var _hold_loop: AudioStreamPlayer
var _context := InteractionContext.new()
var _wallet: Wallet
var _inventory: CarryInventory
var _upgrades: UpgradeProgress
var _story: StoryState
var _letter_from_pause: bool = false
var _staging: bool = false
## Stable object ID -> Interactable placed in this scene.
var _objects: Dictionary = {}
var _modal_open: bool = false
var _restore_notes: PackedStringArray = []


func _ready() -> void:
	_interactor = player.get_node("PlayerInteractor")
	_animator = player.get_node_or_null("PlayerAnimator")
	player.set_input_enabled(false)
	for problem: String in item_catalog.validate():
		push_error("OldYard: item catalog: " + problem)
	# Steps 1-2: static content is loaded; read the validated session state.
	_register_world_objects()
	var state: Dictionary = GameSession.get_current_state()
	_create_economy(state)
	_story = StoryState.new(state.get("story", {}))
	# Steps 3-4: player, object states and carried items.
	_restore_player(state.get("player", {}))
	_restore_world_objects(state.get("world_objects", {}))
	_restore_inventory(state.get("inventory", []))
	# Steps 5-7: camera snaps to the anchor, player gets its movement reference.
	camera_rig.set_follow_target(player.get_node("CameraAnchor"))
	camera_rig.activate()
	player.set_movement_camera(camera_rig.get_camera())
	# Step 8: interaction wiring.
	_context.player = player
	_context.inventory = _inventory
	_context.wallet = _wallet
	_context.item_catalog = item_catalog
	_context.upgrades = _upgrades
	_context.story = _story
	_interactor.setup(player.get_node("InteractionDetector"), player, player.get_facing_direction,
		interaction_prompt, _context)
	_interactor.interaction_finished.connect(_on_interaction_finished)
	_connect_stations()
	_setup_story(state.get("scrappy", {}))
	# Step 9: HUD and diagnostics.
	economy_hud.setup(_wallet, _inventory, _upgrades)
	_setup_presentation()
	inspect_panel.closed.connect(_close_modal)
	sell_panel.closed.connect(_on_sell_panel_closed)
	catalog_panel.action_result.connect(_show_result)
	catalog_panel.closed.connect(_close_modal)
	pause_menu.resume_requested.connect(_close_pause_menu)
	pause_menu.save_requested.connect(func() -> void: save_game())
	pause_menu.save_and_exit_requested.connect(_on_save_and_exit)
	pause_menu.exit_without_saving_requested.connect(GameSession.return_to_main_menu)
	if pause_menu.has_signal("letter_requested"):
		pause_menu.letter_requested.connect(_on_letter_requested)
	debug_overlay.setup(player, camera_rig, _interactor, _debug_extra_lines)
	GameSession.save_completed.connect(_on_save_completed)
	_update_controls_hint()
	# Step 10: release input once physics has seen the restored positions.
	await get_tree().physics_frame
	_set_gameplay_input(true)
	if letter_panel != null and GameSession.intro_enabled and not _story.has_flag(StoryDirector.FLAG_LETTER_READ):
		open_letter()
	elif story_director != null and not GameSession.intro_enabled:
		story_director.on_letter_closed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") and not _modal_open:
		get_viewport().set_input_as_handled()
		_open_pause_menu()
	elif event.is_action_pressed("drop_item") and not _modal_open:
		get_viewport().set_input_as_handled()
		drop_last_item()
	elif event.is_action_pressed("debug_save") and OS.is_debug_build() and not _modal_open:
		get_viewport().set_input_as_handled()
		save_game()
	elif event.is_action_pressed("debug_toggle_overlay"):
		get_viewport().set_input_as_handled()
		debug_overlay.toggle()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and controls_hint != null:
		_update_controls_hint()


## Builds the snapshot of all persistent runtime values and hands it to
## GameSession. Returns whether the save succeeded.
func save_game() -> bool:
	return GameSession.request_save(create_snapshot())


## Plain-data snapshot; no nodes or resources are serialized.
func create_snapshot() -> Dictionary:
	var position_value: Vector3 = player.global_position
	var objects: Dictionary = {}
	for object_id: String in _objects:
		var object_state: Dictionary = _objects[object_id].get_save_state()
		if not object_state.is_empty():
			objects[object_id] = object_state
	return {
		"player": {
			"position": [snappedf(position_value.x, 0.001), snappedf(position_value.y, 0.001),
				snappedf(position_value.z, 0.001)],
			"facing": snappedf(player.get_facing_yaw(), 0.0001),
		},
		"world_objects": objects,
		"wallet": _wallet.to_save_data(),
		"inventory": _inventory.to_save_data(),
		"upgrades": _upgrades.to_save_data(),
		"story": _story.to_save_data(),
		"scrappy": scrappy.get_save_state() if scrappy != null else {"state": "dormant", "follow": true},
	}


## Drops the most recently picked up item in front of the player.
func drop_last_item() -> bool:
	var object_id: String = _inventory.get_last_object_id()
	if object_id.is_empty():
		feedback_toast.show_message(tr("ui.inventory.nothing_to_drop"), false)
		return false
	var item: ScrapItem = _objects.get(object_id) as ScrapItem
	if item == null or not _inventory.remove(object_id):
		return false
	item.drop_at(_free_drop_position(), player.get_facing_yaw())
	_dust(item.global_position, 5, 0.12)
	_sound("thud", -4.0)
	feedback_toast.show_message(tr("ui.inventory.dropped").format({"name": item.get_display_name()}))
	return true


## Registered interactable for a stable ID (used by tests and diagnostics).
func get_world_object(object_id: String) -> Interactable:
	return _objects.get(object_id)


## Notes collected while restoring (unknown IDs, fallbacks).
func get_restore_notes() -> PackedStringArray:
	return _restore_notes


## Runtime systems, exposed read-only for tests and diagnostics.
func get_wallet() -> Wallet:
	return _wallet


func get_inventory() -> CarryInventory:
	return _inventory


func get_upgrades() -> UpgradeProgress:
	return _upgrades


func get_story() -> StoryState:
	return _story


## Opens Walt's letter as a modal sheet.
func open_letter() -> void:
	if letter_panel == null:
		return
	_open_modal()
	_sound("paper")
	letter_panel.open()


func _create_economy(state: Dictionary) -> void:
	var wallet_data: Dictionary = state.get("wallet", {})
	_wallet = Wallet.new(int(wallet_data.get("balance", balance.starting_credits)),
		int(wallet_data.get("sequence", 0)), wallet_data.get("ledger", []), balance.ledger_size)
	_upgrades = UpgradeProgress.new(upgrade_catalog, state.get("upgrades", []))
	for upgrade_id: Variant in state.get("upgrades", []):
		if not _upgrades.is_owned(str(upgrade_id)):
			_note("unknown upgrade id '%s' ignored" % upgrade_id)
	_inventory = CarryInventory.new(item_catalog, _carry_capacity())
	_upgrades.upgrade_purchased.connect(
		func(_definition: UpgradeDefinition) -> void: _inventory.set_capacity(_carry_capacity()))


func _carry_capacity() -> int:
	return balance.base_carry_capacity + _upgrades.get_bonus(UpgradeDefinition.STAT_CARRY_CAPACITY)


func _connect_stations() -> void:
	for target: Interactable in _objects.values():
		if target is SellStation:
			(target as SellStation).sale_completed.connect(_on_sale_completed)
		elif target is DismantleStation:
			(target as DismantleStation).set_world_objects(_objects)
		elif target is OrderDesk:
			(target as OrderDesk).refresh_deliveries(_upgrades)
			(target as OrderDesk).ware_bought.connect(_on_ware_bought)
		elif target is RepairBench:
			(target as RepairBench).bind_context(_context)
			(target as RepairBench).scrappy_restored.connect(_on_scrappy_restored)


func _register_world_objects() -> void:
	for node: Node in world_objects_root.find_children("*", "Interactable", true, false):
		var target := node as Interactable
		if _objects.has(target.object_id):
			push_error("OldYard: duplicate object_id '%s'." % target.object_id)
			continue
		_objects[target.object_id] = target


func _restore_player(player_state: Dictionary) -> void:
	var start: Vector3 = player_start.global_position
	var facing: float = player_start.global_rotation.y
	if player_state.has("position"):
		var saved: Array = player_state["position"]
		start = Vector3(saved[0], saved[1], saved[2])
		facing = float(player_state.get("facing", facing))
	player.fallback_spawn = player_start.global_position
	if not player.place(start, facing):
		_note("player position outside the plot, using spawn")


func _restore_world_objects(saved_objects: Dictionary) -> void:
	for object_id: String in saved_objects:
		if not _objects.has(object_id):
			_note("unknown object id '%s' ignored" % object_id)
			continue
		_objects[object_id].apply_save_state(saved_objects[object_id])


## Carried items must match world objects in state "carried". Mismatches are
## repaired towards a consistent state and noted instead of crashing.
func _restore_inventory(saved_ids: Array) -> void:
	for object_id: Variant in saved_ids:
		var item: ScrapItem = _objects.get(str(object_id)) as ScrapItem
		if item == null or not _inventory.restore(item.object_id, item.get_item_id()):
			_note("inventory entry '%s' ignored" % object_id)
			continue
		if item.get_state() != ScrapItem.State.CARRIED:
			item.set_state(ScrapItem.State.CARRIED)
	for target: Interactable in _objects.values():
		var item := target as ScrapItem
		if item != null and item.get_state() == ScrapItem.State.CARRIED and not _inventory.contains(item.object_id):
			_note("'%s' was carried but not in the inventory, returned to the yard" % item.object_id)
			item.set_state(ScrapItem.State.IN_WORLD)


func _note(text: String) -> void:
	_restore_notes.append(text)
	if OS.is_debug_build():
		push_warning("OldYard restore: " + text)


func _set_gameplay_input(enabled: bool) -> void:
	player.set_input_enabled(enabled)
	_interactor.set_enabled(enabled)


func _on_interaction_finished(target_id: String, result: Dictionary) -> void:
	_present_interaction(target_id, result)
	_report_story_event(target_id, result)
	_show_result(result)
	var data: Dictionary = result.get("panel_data", {})
	match result.get("panel", ""):
		"inspect":
			_open_modal()
			inspect_panel.open(data.get("title", ""), data.get("body", ""))
		"sell":
			_open_modal()
			sell_panel.open(data["station"])
		"catalog":
			_open_modal()
			catalog_panel.open(data["station"])


func _show_result(result: Dictionary) -> void:
	var message_key: String = result.get("message_key", "")
	if not message_key.is_empty():
		feedback_toast.show_message(tr(message_key).format(result.get("message_args", {})),
			result.get("success", false))


func _on_sale_completed(object_ids: Array, total: int) -> void:
	_sound("kaching")
	if sound_fx != null:
		sound_fx.play_burst("coins", 2, 0.25, -4.0)
	if fx != null:
		var counter: Interactable = _first_of_type("SellStation")
		if counter != null:
			fx.coins(counter.get_interaction_point(), 4 + total / 3)
	for object_id: Variant in object_ids:
		var item: ScrapItem = _objects.get(str(object_id)) as ScrapItem
		if item != null:
			item.set_state(ScrapItem.State.SOLD)
	if story_director != null:
		story_director.on_sale(total)


func _on_sell_panel_closed(result: Dictionary) -> void:
	_show_result(result)
	_close_modal()


func _open_modal() -> void:
	_modal_open = true
	_set_gameplay_input(false)


func _close_modal() -> void:
	_modal_open = false
	_set_gameplay_input(true)


func _open_pause_menu() -> void:
	_open_modal()
	get_tree().paused = true
	pause_menu.open()


func _close_pause_menu() -> void:
	pause_menu.close()
	get_tree().paused = false
	_close_modal()


func _on_save_and_exit() -> void:
	if save_game():
		GameSession.return_to_main_menu()


func _on_save_completed(success: bool, message_key: String) -> void:
	feedback_toast.show_message(tr(message_key), success)


## Position in front of the player that is not inside level geometry.
func _free_drop_position() -> Vector3:
	var base := Vector3(player.global_position.x, 0.0, player.global_position.z)
	var candidate: Vector3 = base + player.get_facing_direction() * 0.8
	var query := PhysicsPointQueryParameters3D.new()
	query.position = candidate + Vector3(0, 0.4, 0)
	query.collision_mask = 1
	if not get_world_3d().direct_space_state.intersect_point(query, 1).is_empty():
		return base
	return candidate


func _update_controls_hint() -> void:
	var move_keys: String = "%s%s%s%s" % [InputHints.key_name(&"move_up"), InputHints.key_name(&"move_left"),
		InputHints.key_name(&"move_down"), InputHints.key_name(&"move_right")]
	controls_hint.text = tr("ui.hud.controls").format({"move": move_keys,
		"interact": InputHints.key_name(&"interact"), "drop": InputHints.key_name(&"drop_item"),
		"menu": InputHints.key_name(&"pause_menu")})


func _debug_extra_lines() -> String:
	return "Credits: %d  Carry: %d/%d  Upgrades: %s\nRestore notes: %s" % [
		_wallet.get_balance(), _inventory.get_used_slots(), _inventory.get_capacity(),
		", ".join(_upgrades.to_save_data()),
		", ".join(_restore_notes) if not _restore_notes.is_empty() else "-"]


# --- Presentation (animation and effects; no gameplay rules) -----------------

func _setup_presentation() -> void:
	_interactor.hold_started.connect(_on_hold_started)
	_interactor.hold_ended.connect(_on_hold_ended)
	if _animator != null:
		_animator.setup(player, _interactor, player.get_node("VisualRoot/PlaceholderModel"))
		_animator.footstep.connect(_on_footstep)
		_inventory.changed.connect(_update_basket_load)
		_update_basket_load()


func _on_footstep(at: Vector3) -> void:
	_dust(at, 2, 0.07)
	_sound("step", -9.0)


func _update_basket_load() -> void:
	if _animator != null:
		_animator.set_load(float(_inventory.get_used_slots()) / float(_inventory.get_capacity()))


func _present_interaction(target_id: String, result: Dictionary) -> void:
	var target: Interactable = _objects.get(target_id)
	if not result.get("success", false):
		if not str(result.get("message_key", "")).is_empty():
			_sound("nope", -4.0)
		return
	match result.get("panel", ""):
		"sell":
			_sound("bell")
			return
		"catalog":
			_sound("page")
			return
		"inspect":
			_sound("paper")
			return
	if target == null:
		return
	if target is ScrapItem and (target as ScrapItem).get_state() == ScrapItem.State.CARRIED:
		_sound((target as ScrapItem).definition.pickup_sound)
		if _animator != null:
			_animator.play_pickup()
		if fx != null:
			var basket: Callable = _animator.get_basket_position if _animator != null else player.get_global_position
			fx.fly_to(target.get_node("VisualRoot"), basket, _on_item_arrived)
		if target is SalvageableScrap:
			_dust(target.global_position, 12, 0.3)
			_sound("creak")
	elif target is SearchSource:
		_dust(target.get_interaction_point(), 8, 0.2)
		if sound_fx != null:
			sound_fx.play_burst("pop", (target as SearchSource).contents.size(), 0.09)
	elif target is DismantleStation:
		_dust(target.get_interaction_point(), 8, 0.2)
		_sound("clink")
		if sound_fx != null:
			sound_fx.play_burst("pop", 2, 0.12)
	elif target.has_method("is_on"):
		_sound("switch")


func _on_item_arrived() -> void:
	if _animator != null:
		_animator.bump_basket()
	_sound("basket", -3.0)


func _on_ware_bought(definition: UpgradeDefinition) -> void:
	_sound("phone")
	if story_director != null:
		story_director.on_purchase(definition)
	get_tree().create_timer(0.9).timeout.connect(_deliver.bind(definition.id))


func _deliver(ware_id: String) -> void:
	_sound("jingle")
	var delivery: Node3D = get_node_or_null("DeliveryArea/" + ware_id)
	if delivery != null:
		_dust(delivery.global_position, 10, 0.22)
		_sound("delivery")


func _on_hold_started(target: Interactable) -> void:
	_stop_hold_loop()
	var loop_name: String = ""
	if target is SearchSource:
		loop_name = "rummage"
	elif target is SalvageableScrap:
		loop_name = "hoist"
	elif target is DismantleStation:
		loop_name = "screw"
	if sound_fx != null and not loop_name.is_empty():
		_hold_loop = sound_fx.start_loop(loop_name, -2.0)


func _on_hold_ended(_target: Interactable) -> void:
	_stop_hold_loop()


func _stop_hold_loop() -> void:
	if sound_fx != null and _hold_loop != null:
		sound_fx.stop_loop(_hold_loop)
	_hold_loop = null


func _sound(sound_name: String, volume_db: float = 0.0) -> void:
	if sound_fx != null:
		sound_fx.play(sound_name, volume_db)


func _dust(at: Vector3, amount: int, size: float) -> void:
	if fx != null:
		fx.dust(Vector3(at.x, 0.0, at.z), amount, size)


func _first_of_type(type_name: String) -> Interactable:
	for target: Interactable in _objects.values():
		if target.get_script() != null and target.get_script().get_global_name() == type_name:
			return target
	return null


# --- Story (P2: letter, notes, Scrappy) --------------------------------------

func _setup_story(scrappy_state: Dictionary) -> void:
	if scrappy != null:
		scrappy.setup(player, _explore_candidates)
		var talk: ScrappyInteraction = scrappy.get_node("Talk") as ScrappyInteraction
		talk.bind(scrappy, player)
		talk.follow_toggled.connect(_on_follow_toggled)
		scrappy.get_node("Animator").setup(scrappy, scrappy.get_node("VisualRoot/Model"))
		scrappy.explored.connect(_on_scrappy_explored)
		if _story.has_flag(StoryDirector.FLAG_RESTORED):
			scrappy.apply_save_state(scrappy_state if not scrappy_state.is_empty() else {"state": "active"})
			if not scrappy.is_active():
				_note("scrappy was restored but saved dormant, woken at the player")
				scrappy.apply_save_state({"state": "active", "follow": scrappy_state.get("follow", true)})
		else:
			scrappy.set_dormant()
	for target: Interactable in _objects.values():
		if target is ScrappyHeadSite:
			(target as ScrappyHeadSite).set_listener(player)
			(target as ScrappyHeadSite).beeped.connect(func(volume_db: float) -> void: _sound("head_beep", volume_db))
	if story_director != null:
		story_director.setup(_story, scrappy, speech_bubble, task_notes, sound_fx, _upgrades, player)
	if letter_panel != null:
		letter_panel.closed.connect(_on_letter_closed)


## Things Scrappy may wander to and look at: loose finds and unsearched sources.
func _explore_candidates() -> Array:
	var result: Array = []
	for target: Interactable in _objects.values():
		if not target.is_interaction_available():
			continue
		if target is ScrapItem and (target as ScrapItem).get_state() == ScrapItem.State.IN_WORLD:
			result.append(target)
		elif target is SearchSource:
			result.append(target)
	return result


func _report_story_event(target_id: String, result: Dictionary) -> void:
	if story_director == null:
		return
	var target: Interactable = _objects.get(target_id)
	if not result.get("success", false):
		if not str(result.get("message_key", "")).is_empty():
			story_director.on_refused()
		return
	if target is ScrapItem and (target as ScrapItem).get_state() == ScrapItem.State.CARRIED:
		story_director.on_item_picked_up((target as ScrapItem).definition)
		if _inventory.get_used_slots() >= _inventory.get_capacity():
			story_director.on_basket_full()
	elif target is SearchSource:
		story_director.on_searched()
	elif target is DismantleStation:
		story_director.on_dismantled()
	elif target is ScrappyHeadSite or target is RedToolbox:
		_dust(target.get_interaction_point(), 10, 0.22)
		_sound("creak" if target is ScrappyHeadSite else "clink")


func _on_letter_closed() -> void:
	_sound("paper")
	if story_director != null:
		story_director.on_letter_closed()
	if _letter_from_pause:
		_letter_from_pause = false
		pause_menu.open()
	else:
		_close_modal()


func _on_letter_requested() -> void:
	_letter_from_pause = true
	pause_menu.close()
	letter_panel.open()


func _on_follow_toggled(following: bool) -> void:
	_sound("scrappy_chirp", -4.0)
	scrappy.get_node("Animator").hop()
	if story_director != null:
		story_director.on_follow_toggled(following)


func _on_scrappy_explored(target: Node3D) -> void:
	if story_director != null:
		story_director.on_explored(target)


## Staging of the repair: camera closes in, sparks, Scrappy wakes and talks.
func _on_scrappy_restored() -> void:
	if scrappy == null:
		return
	_staging = true
	_set_gameplay_input(false)
	var bench: Interactable = _first_of_type("RepairBench")
	var spot: Vector3 = Vector3(10.5, 0.0, -13.0)
	if bench != null:
		spot = bench.global_position + bench.global_basis.z * 1.2
	scrappy.global_position = spot
	camera_rig.focus_on(scrappy, 8.5)
	_sound("spark")
	for index: int in 4:
		get_tree().create_timer(0.25 * index).timeout.connect(_repair_sparks.bind(spot))
	await get_tree().create_timer(1.2).timeout
	_sound("scrappy_wake")
	var to_player: Vector3 = player.global_position - spot
	scrappy.activate(spot, atan2(to_player.x, to_player.z))
	scrappy.get_node("Animator").hop()
	_dust(spot, 10, 0.2)
	if story_director != null:
		story_director.play_wake_sequence()
	await get_tree().create_timer(1.4).timeout
	camera_rig.end_focus()
	_staging = false
	if not _modal_open:
		_set_gameplay_input(true)


func _repair_sparks(at: Vector3) -> void:
	if fx != null and fx.has_method("sparks"):
		fx.sparks(at + Vector3(0, 0.5, 0), 12)
	_sound("spark", -6.0)
