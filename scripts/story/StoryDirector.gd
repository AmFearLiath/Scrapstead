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

const FLAG_LETTER_READ := "letter_read"
const FLAG_FIRST_PICKUP := "first_pickup"
const FLAG_FIRST_SALE := "first_sale"
const FLAG_FIRST_PURCHASE := "first_purchase"
const FLAG_FOUND_HEAD := "found_head"
const FLAG_FOUND_CORE := "found_core"
const FLAG_RESTORED := "scrappy_restored"
const ENTRANCE_WARE := "yard_entrance"
const MAX_NOTES := 2
const MAX_QUEUE := 4

@export var lines: ScrappyLines
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
	if restored and _upgrades != null and not _upgrades.is_owned(ENTRANCE_WARE):
		keys.append("note.entrance")
	if _deliveries != null and _deliveries.get_waiting_count() > 0:
		keys.append("note.delivery_waiting")
	while keys.size() > MAX_NOTES:
		keys.remove_at(keys.size() - 1)
	return keys


func refresh_notes() -> void:
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
	else:
		say_event("purchase", true)
		if first and _upgrades != null and not _upgrades.is_owned(ENTRANCE_WARE):
			say_event("suggest_entrance", true)


## Neighbors dropped off scrap at the gate.
func on_delivery() -> void:
	if not say_event("delivery_first", true):
		say_event("delivery")
	refresh_notes()


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
