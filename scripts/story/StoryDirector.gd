class_name StoryDirector
extends Node
## Scene-local story coordinator for P2 (docs/p2-arrival-and-scrappy.md).
##
## Derives the suggestion notes from story flags, decides when Scrappy says
## something (rules in ScrappyLines: chance, cooldown, once, global quiet gap)
## and plays the wake-up sequence. Owns no gameplay rules: it only reacts to
## events the scene reports and never changes inventory, wallet or objects.

## A line started (localization key). Diagnostics and tests.
signal line_spoken(line_key: String)
## An entry of Walt's list was just completed (not emitted when loading).
signal task_completed(entry: Dictionary, all_done: bool)

const FLAG_LETTER_READ := "letter_read"
const FLAG_FIRST_PICKUP := "first_pickup"
const FLAG_FIRST_SALE := "first_sale"
const FLAG_FIRST_PURCHASE := "first_purchase"
const FLAG_FOUND_HEAD := "found_head"
const FLAG_FOUND_CORE := "found_core"
const FLAG_RESTORED := "scrappy_restored"
const FLAG_FIRST_HIRE := "first_hire"
const ENTRANCE_WARE := "yard_entrance"
const MAGNET_WARE := "machine_magnet_collector"
const MAX_NOTES := 2
const MAX_QUEUE := 4

@export var lines: ScrappyLines
## Walt's list: the short main task sequence (P4).
@export var task_list: TaskList
## Random seed; fixed so tests and recordings behave reproducibly.
@export var seed_value: int = 7

var _story: StoryState
var _scrappy: Node3D
var _animator: Node
var _bubble: Control
var _notes: Control
var _sound_fx: Node
var _upgrades: UpgradeProgress
var _player: Node3D
var _deliveries: ScrapDeliveries
var _worker: YardWorker
var _magnet: MagnetCollector
var _placed: PlacedObjects
var _rng := RandomNumberGenerator.new()
var _time: float = 0.0
var _quiet_until: float = 0.0
var _cooldown_until: Dictionary = {}
var _last_variant: Dictionary = {}
var _queue: Array[String] = []
var _speaking: bool = false
var _idle_timer: float = 0.0
var _memory_check: float = 0.0
var _last_line: String = ""
## Task IDs known to be done; null until the first check (no announcements then).
var _done_tasks: Variant = null


func setup(story: StoryState, scrappy: Node3D, bubble: Control, notes: Control, sound_fx: Node,
		upgrades: UpgradeProgress, player: Node3D) -> void:
	_rng.seed = seed_value
	_story = story
	_scrappy = scrappy
	_animator = scrappy.get_node_or_null("Animator") if scrappy != null else null
	_bubble = bubble
	_notes = notes
	_sound_fx = sound_fx
	_upgrades = upgrades
	_player = player
	if _bubble != null:
		_bubble.finished.connect(_on_line_finished)
	_story.changed.connect(refresh_notes)
	if _upgrades != null:
		_upgrades.upgrade_purchased.connect(func(_definition: UpgradeDefinition) -> void: refresh_notes())
	refresh_notes()


## Optional: the drop-off spot, so the notes can point at waiting deliveries.
func bind_deliveries(deliveries: ScrapDeliveries) -> void:
	_deliveries = deliveries
	refresh_notes()


## Optional: the yard helper, so the notes can point at him (P3a).
func bind_worker(worker: YardWorker) -> void:
	_worker = worker
	if _worker != null:
		_worker.presence_changed.connect(func(_presence: YardWorker.Presence) -> void: refresh_notes())
		_worker.status_changed.connect(func(_status: String) -> void: refresh_notes())
	refresh_notes()


## Optional: the magnetic collector, so a full crate shows up in the notes.
func bind_magnet(magnet: MagnetCollector) -> void:
	_magnet = magnet
	if _magnet != null and not _magnet.status_changed.is_connected(_on_magnet_status):
		_magnet.status_changed.connect(_on_magnet_status)
	refresh_notes()


func _on_magnet_status(_status: String) -> void:
	refresh_notes()


## Optional: placed objects, for Walt's list ("placed:<id>" entries).
func bind_placed(placed: PlacedObjects) -> void:
	_placed = placed
	if _placed != null:
		_placed.changed.connect(refresh_notes)
	refresh_notes()


func _magnet_full() -> bool:
	return _magnet != null and is_instance_valid(_magnet) and _magnet.get_status() == MagnetCollector.STATUS_BIN_FULL


## Most recently started line key (tests, diagnostics).
func get_last_line() -> String:
	return _last_line


func is_speaking() -> bool:
	return _speaking


# --- Notes --------------------------------------------------------------------

## Current suggestion keys (at most two): story first, then the business.
func compute_note_keys() -> PackedStringArray:
	var keys: PackedStringArray = []
	if _story == null:
		return keys
	var restored: bool = _story.has_flag(FLAG_RESTORED)
	if not restored:
		var head: bool = _story.has_key_item(StoryState.KEY_SCRAPPY_HEAD)
		var core: bool = _story.has_key_item(StoryState.KEY_SCRAPPY_CORE)
		if head and core:
			keys.append("note.repair_scrappy")
		elif head:
			keys.append("note.need_core")
		elif core:
			keys.append("note.core_where")
		elif _story.has_flag(FLAG_FIRST_SALE):
			keys.append("note.heap_beep")
	if not _story.has_flag(FLAG_FIRST_PICKUP):
		keys.append("note.look_around")
	elif not _story.has_flag(FLAG_FIRST_SALE):
		keys.append("note.sell")
	elif not _story.has_flag(FLAG_FIRST_PURCHASE):
		keys.append("note.catalog")
	if _magnet_full():
		keys.append("note.magnet_full")
	if restored and _upgrades != null and not _upgrades.is_owned(ENTRANCE_WARE):
		keys.append("note.entrance")
	var staff_on_it: bool = _worker != null and _worker.is_hired() and not _worker.is_paused()
	if _worker != null and _worker.get_presence() == YardWorker.Presence.AVAILABLE \
			and not _story.has_flag(FLAG_FIRST_HIRE):
		keys.append("note.staff_available")
	if _worker != null and not _worker.get_missing_tool().is_empty():
		keys.append("note.staff_needs_" + _worker.get_missing_tool())
	if _deliveries != null and _deliveries.get_waiting_count() > 0 and not staff_on_it:
		keys.append("note.delivery_waiting")
	while keys.size() > MAX_NOTES:
		keys.remove_at(keys.size() - 1)
	return keys


## Walt's list with completion: [{"entry": Dictionary, "done": bool}].
func get_task_states() -> Array:
	var states: Array = []
	if task_list == null:
		return states
	for entry: Dictionary in task_list.entries:
		states.append({"entry": entry, "done": TaskList.is_done(entry, _story, _upgrades, _placed)})
	return states


## Announces entries that became done since the last check.
func _check_tasks() -> void:
	if task_list == null or _story == null:
		return
	var done: Dictionary = {}
	for state: Dictionary in get_task_states():
		if state["done"]:
			done[state["entry"]["id"]] = true
	if _done_tasks != null:
		for state: Dictionary in get_task_states():
			var id: String = state["entry"]["id"]
			if state["done"] and not (_done_tasks as Dictionary).has(id):
				task_completed.emit(state["entry"], done.size() == task_list.entries.size())
	_done_tasks = done


func refresh_notes() -> void:
	_check_tasks()
	if _notes == null:
		return
	var texts: PackedStringArray = []
	if _story.has_flag(FLAG_LETTER_READ):
		for key: String in compute_note_keys():
			texts.append(tr(key))
	_notes.set_notes(texts)
	var names: PackedStringArray = []
	for item_id: String in _story.get_key_items():
		names.append(tr("key_item.%s.name" % item_id))
	_notes.set_key_items(names)


# --- Events from the scene ----------------------------------------------------

func on_letter_closed() -> void:
	_story.set_flag(FLAG_LETTER_READ)
	refresh_notes()


func on_item_picked_up(definition: ItemDefinition) -> void:
	_story.set_flag(FLAG_FIRST_PICKUP)
	if definition != null and definition.sell_value >= 12:
		say_event("pickup_valuable")
	else:
		say_event("pickup")


func on_basket_full() -> void:
	say_event("basket_full")


func on_sale(total: int) -> void:
	_story.set_flag(FLAG_FIRST_SALE)
	say_event("sale_big" if total >= 40 else "sale")


func on_purchase(definition: UpgradeDefinition) -> void:
	var first: bool = _story.set_flag(FLAG_FIRST_PURCHASE)
	if definition.id == ENTRANCE_WARE:
		say_event("entrance", true)
	elif definition.id == MAGNET_WARE:
		return
	else:
		say_event("purchase", true)
		if first and _upgrades != null and not _upgrades.is_owned(ENTRANCE_WARE):
			say_event("suggest_entrance", true)


## Neighbors dropped off scrap at the gate.
func on_delivery() -> void:
	if not say_event("delivery_first", true):
		say_event("delivery")
	refresh_notes()


## The player hired the yard helper.
func on_staff_hired() -> void:
	_story.set_flag(FLAG_FIRST_HIRE)
	say_event("staff_hired", true)
	refresh_notes()


## Something was built; Scrappy has opinions about some of it.
func on_placed(placeable_id: String) -> void:
	say_event("built_" + placeable_id, true)


## The first machine was delivered and set up.
func on_machine_installed() -> void:
	say_event("machine_installed", true)


func on_staff_dismissed() -> void:
	say_event("staff_dismissed", true)


func on_refused() -> void:
	say_event("refuse")


func on_searched() -> void:
	say_event("search")


func on_dismantled() -> void:
	say_event("dismantle")


func on_follow_toggled(following: bool) -> void:
	say_event("follow" if following else "wait", true)


func on_explored(_target: Node3D) -> void:
	say_event("explore")


## The three wake-up lines in order (after the repair).
func play_wake_sequence() -> void:
	_queue.clear()
	say_event("wake", true)


# --- Speaking -----------------------------------------------------------------

## Tries to comment on an event. Returns whether a line was started or queued.
func say_event(event: String, force_queue: bool = false) -> bool:
	if lines == null or _scrappy == null or not _scrappy.is_active():
		return false
	var rule: Dictionary = lines.get_rule(event)
	if rule.is_empty():
		return false
	var priority: bool = force_queue or bool(rule.get("priority", false))
	if _time < float(_cooldown_until.get(event, -1.0)):
		return false
	if not priority:
		if _speaking or _time < _quiet_until:
			return false
		if _rng.randf() > float(rule.get("chance", 1.0)):
			return false
	var keys: PackedStringArray = _pick_keys(event, rule)
	if keys.is_empty():
		return false
	_cooldown_until[event] = _time + float(rule.get("cooldown", 0.0))
	for key: String in keys:
		if _queue.size() < MAX_QUEUE:
			_queue.append(key)
	if not _speaking:
		_speak_next()
	return true


func _pick_keys(event: String, rule: Dictionary) -> PackedStringArray:
	var count: int = int(rule.get("count", 0))
	var once: bool = bool(rule.get("once", false))
	var result: PackedStringArray = []
	if bool(rule.get("sequence", false)):
		for index: int in range(1, count + 1):
			var key: String = "scrappy.%s.%d" % [event, index]
			if not once or not _story.was_spoken(key):
				result.append(key)
		return result
	var options: Array[int] = []
	for index: int in range(1, count + 1):
		if once and _story.was_spoken("scrappy.%s.%d" % [event, index]):
			continue
		if count > 1 and index == int(_last_variant.get(event, 0)):
			continue
		options.append(index)
	if options.is_empty():
		return result
	var chosen: int = options[_rng.randi_range(0, options.size() - 1)]
	_last_variant[event] = chosen
	result.append("scrappy.%s.%d" % [event, chosen])
	return result


func _speak_next() -> void:
	if _queue.is_empty():
		_speaking = false
		return
	var key: String = _queue.pop_front()
	_speaking = true
	_last_line = key
	_story.mark_spoken(key)
	if _animator != null:
		_animator.set_talking(true)
	if _sound_fx != null:
		_sound_fx.play("scrappy_chirp", -6.0, 0.12)
	if _bubble != null:
		_bubble.setup(get_viewport().get_camera_3d(), _scrappy.get_node_or_null("SpeechAnchor"))
		_bubble.say(tr(key))
	else:
		get_tree().create_timer(2.0).timeout.connect(_on_line_finished)
	line_spoken.emit(key)


func _on_line_finished() -> void:
	if _animator != null:
		_animator.set_talking(false)
	_quiet_until = _time + (lines.global_gap_seconds if lines != null else 8.0)
	if _queue.is_empty():
		_speaking = false
	else:
		get_tree().create_timer(0.35).timeout.connect(_speak_next)


# --- Idle lines and memories --------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	if lines == null or _scrappy == null or not _scrappy.is_active() or _player == null:
		return
	_idle_timer += delta
	if _idle_timer >= lines.idle_interval_seconds:
		_idle_timer = 0.0
		say_event("idle")
	_memory_check -= delta
	if _memory_check <= 0.0:
		_memory_check = 0.5
		_check_memories()


func _check_memories() -> void:
	if _speaking:
		return
	for memory: Dictionary in lines.memories:
		var key: String = memory.get("line", "")
		if key.is_empty() or _story.was_spoken(key):
			continue
		var at: Vector3 = memory.get("position", Vector3.ZERO)
		var radius: float = float(memory.get("radius", 2.0))
		var flat := Vector3(_scrappy.global_position.x, 0.0, _scrappy.global_position.z)
		var player_flat := Vector3(_player.global_position.x, 0.0, _player.global_position.z)
		if flat.distance_to(at) <= radius and player_flat.distance_to(at) <= radius + 2.0:
			_queue.append(key)
			_speak_next()
			return
