class_name ScrappyHeadSite
extends Interactable
## Scrappy's half-buried head at the edge of the large scrap heap (P2). Freeing
## it is a hold action without tools, so the discovery never sits behind a
## purchase. The head becomes a key item (never sellable).

@export_range(0.5, 10.0) var dig_seconds: float = 2.0
## Visual removed once the head is taken.
@export var buried_visual: Node3D

@export_group("Beeping")
## Distance within which the dormant head can be heard beeping.
@export var beep_range: float = 11.0
## Seconds between two beeps (with a little randomness).
@export var beep_interval: float = 7.0

## Emitted when the head beeps; volume_db already accounts for the distance.
## The scene plays the sound (no audio in gameplay objects).
signal beeped(volume_db: float)

var _taken: bool = false
var _listener: Node3D
var _beep_timer: float = 3.0


## The node whose distance decides whether the beep is audible (the player).
func set_listener(listener: Node3D) -> void:
	_listener = listener


func _process(delta: float) -> void:
	if _taken or _listener == null:
		return
	var distance: float = _listener.global_position.distance_to(global_position)
	if distance > beep_range:
		_beep_timer = minf(_beep_timer, 2.0)
		return
	_beep_timer -= delta
	if _beep_timer <= 0.0:
		_beep_timer = beep_interval + randf_range(-1.5, 1.5)
		beeped.emit(lerpf(-4.0, -24.0, distance / beep_range))


func is_taken() -> bool:
	return _taken


func is_interaction_available() -> bool:
	return super() and not _taken


func get_hold_duration() -> float:
	return dig_seconds


func get_prompt_detail(_context: InteractionContext) -> String:
	return tr("story.head_site.detail")


func interact(context: InteractionContext) -> Dictionary:
	if _taken or context == null or context.story == null:
		return make_result(false, "ui.interaction.unavailable")
	_set_taken(true)
	context.story.add_key_item(StoryState.KEY_SCRAPPY_HEAD)
	context.story.set_flag("found_head")
	var result: Dictionary = make_result(true)
	result["panel"] = "inspect"
	result["panel_data"] = {"title": tr("story.head_found.title"), "body": tr("story.head_found.body")}
	return result


func get_save_state() -> Dictionary:
	return {"taken": true} if _taken else {}


func apply_save_state(state: Dictionary) -> void:
	_set_taken(bool(state.get("taken", false)))


func _set_taken(value: bool) -> void:
	_taken = value
	if buried_visual != null:
		buried_visual.visible = not value
	collision_layer = 0 if value else 4
	interaction_state_changed.emit(self)
