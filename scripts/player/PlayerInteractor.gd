extends Node
## Interaction control of the player (docs/p0-interaction-controller.md).
##
## Collects candidates reported by the InteractionDetector, validates them,
## selects exactly one active target (distance first, facing second, with a
## small hysteresis), drives highlight and prompt, handles the `interact` input
## (including hold actions) and re-validates the target right before executing.
## It performs no gameplay rules of its own.

## Emitted when the active target changed (null = none).
signal target_changed(target: Interactable)
## Emitted after an action attempt with the target's result dictionary.
signal interaction_finished(target_id: String, result: Dictionary)

## Maximum horizontal distance between player and interaction point.
@export var interaction_range: float = 1.9
## Score bonus (in metres) for targets in front of the player.
@export var facing_weight: float = 0.4
## Score bonus (in metres) that keeps the current target when scores are close.
@export var selection_hysteresis: float = 0.25

var _detector: Area3D
var _player: Node3D
var _prompt: Control
var _context: InteractionContext
var _facing_provider: Callable
var _candidates: Array[Interactable] = []
var _current: Interactable
var _enabled: bool = false
var _hold_target: Interactable
var _hold_elapsed: float = 0.0
var _last_result_text: String = "-"
var _last_score_reason: String = "-"


## Explicit wiring by the scene controller (initialization step 8).
## `facing_provider` returns the player's horizontal facing as Vector3.
func setup(detector: Area3D, player: Node3D, facing_provider: Callable, prompt: Control,
		context: InteractionContext) -> void:
	_detector = detector
	_player = player
	_facing_provider = facing_provider
	_prompt = prompt
	_context = context
	if _prompt == null and OS.is_debug_build():
		push_warning("PlayerInteractor: no prompt assigned; interactions work without HUD hint.")
	_detector.body_entered.connect(_on_body_entered)
	_detector.body_exited.connect(_on_body_exited)
	for body: Node3D in _detector.get_overlapping_bodies():
		_on_body_entered(body)


## Interaction input is only accepted after initialization and while no modal
## panel is open.
func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	_cancel_hold()
	if not enabled:
		_set_current(null)
	else:
		_refresh_selection()


## Currently selected target or null.
func get_current_target() -> Interactable:
	return _current if is_instance_valid(_current) else null


## Read-only diagnostics for the debug overlay.
func get_debug_data() -> Dictionary:
	var target: Interactable = get_current_target()
	return {
		"candidates": _candidates.size(),
		"target_id": target.object_id if target != null else "-",
		"distance": _distance_to(target) if target != null else -1.0,
		"reason": _last_score_reason,
		"hold": _hold_elapsed,
		"last_result": _last_result_text,
	}


## Re-evaluates the selection, e.g. after inventory or wallet changes that
## affect prompt texts.
func refresh() -> void:
	_refresh_selection(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _enabled:
		_update_prompt()


func _physics_process(delta: float) -> void:
	if not _enabled or _candidates.is_empty():
		return
	_refresh_selection()
	if _hold_target != null:
		_update_hold(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		var target: Interactable = get_current_target()
		if target == null:
			return
		if target.get_hold_duration() > 0.0:
			_start_hold(target)
		else:
			_execute(target)
	elif event.is_action_released("interact") and _hold_target != null:
		_cancel_hold()


func _on_body_entered(body: Node3D) -> void:
	if body is Interactable and not _candidates.has(body):
		var target := body as Interactable
		_candidates.append(target)
		if not target.interaction_state_changed.is_connected(_on_target_state_changed):
			target.interaction_state_changed.connect(_on_target_state_changed)
	elif not (body is Interactable) and OS.is_debug_build():
		push_warning("PlayerInteractor: ignoring body without interaction contract: %s" % body.name)


func _on_body_exited(body: Node3D) -> void:
	var index: int = _candidates.find(body)
	if index != -1:
		_candidates.remove_at(index)
		if body.interaction_state_changed.is_connected(_on_target_state_changed):
			body.interaction_state_changed.disconnect(_on_target_state_changed)
	if body == _current:
		_refresh_selection()


func _on_target_state_changed(_target: Interactable) -> void:
	_refresh_selection(true)


## Selection steps: drop invalid, drop out of range, score by distance, use
## facing for close calls, keep the current target on near ties, stable order.
func _refresh_selection(force_prompt_update: bool = false) -> void:
	_prune_invalid_candidates()
	var best: Interactable
	var best_score: float = INF
	var facing: Vector3 = _facing_provider.call() if _facing_provider.is_valid() else Vector3.ZERO
	for target: Interactable in _candidates:
		if not target.is_interaction_available():
			continue
		var distance: float = _distance_to(target)
		if distance > interaction_range:
			continue
		var score: float = distance
		var to_target: Vector3 = target.get_interaction_point() - _player.global_position
		to_target.y = 0.0
		if to_target.length_squared() > 0.0001 and facing != Vector3.ZERO:
			score -= facing_weight * maxf(0.0, facing.dot(to_target.normalized()))
		if target == _current:
			score -= selection_hysteresis
		if score < best_score - 0.0001 or (absf(score - best_score) <= 0.0001 and best != null
				and target.object_id < best.object_id):
			best = target
			best_score = score
	if best != null:
		_last_score_reason = "score=%.2f of %d" % [best_score, _candidates.size()]
	if best != _current:
		_set_current(best)
	elif force_prompt_update:
		_update_prompt()


func _prune_invalid_candidates() -> void:
	for index: int in range(_candidates.size() - 1, -1, -1):
		if not is_instance_valid(_candidates[index]) or not _candidates[index].is_inside_tree():
			_candidates.remove_at(index)


func _set_current(target: Interactable) -> void:
	if is_instance_valid(_current):
		_current.set_highlighted(false)
	_current = target
	if _hold_target != null and _hold_target != target:
		_cancel_hold()
	if is_instance_valid(_current):
		_current.set_highlighted(true)
	_update_prompt()
	target_changed.emit(get_current_target())


func _update_prompt() -> void:
	if _prompt == null:
		return
	var target: Interactable = get_current_target()
	if target == null:
		_prompt.hide_prompt()
		return
	_prompt.show_target(target.get_display_name(), tr(target.get_action_key()), _input_hint(),
		target.get_prompt_detail(_context), target.get_hold_duration() > 0.0)


func _start_hold(target: Interactable) -> void:
	var requirements: Dictionary = target.check_requirements(_context)
	if not requirements["ok"]:
		_finish(target, Interactable.make_result(false, requirements["message_key"], requirements["message_args"]))
		return
	_hold_target = target
	_hold_elapsed = 0.0
	if target.has_method("on_hold_started"):
		target.on_hold_started()


func _update_hold(delta: float) -> void:
	if not _is_target_usable(_hold_target):
		_cancel_hold()
		return
	_hold_elapsed += delta
	var duration: float = _hold_target.get_hold_duration()
	if _prompt != null:
		_prompt.set_hold_progress(clampf(_hold_elapsed / duration, 0.0, 1.0))
	if _hold_elapsed >= duration:
		var target: Interactable = _hold_target
		_hold_target = null
		_hold_elapsed = 0.0
		_execute(target)


func _cancel_hold() -> void:
	if is_instance_valid(_hold_target) and _hold_target.has_method("on_hold_cancelled"):
		_hold_target.on_hold_cancelled()
	_hold_target = null
	_hold_elapsed = 0.0
	if _prompt != null:
		_prompt.set_hold_progress(0.0)


## Re-validation right before the action: the stored reference alone is never
## trusted.
func _execute(target: Interactable) -> void:
	if not _is_target_usable(target):
		_finish(target, Interactable.make_result(false, "ui.interaction.unavailable"))
		return
	var requirements: Dictionary = target.check_requirements(_context)
	if not requirements["ok"]:
		_finish(target, Interactable.make_result(false, requirements["message_key"], requirements["message_args"]))
		return
	_finish(target, target.interact(_context))


func _finish(target: Interactable, result: Dictionary) -> void:
	var target_id: String = target.object_id if is_instance_valid(target) else "-"
	_last_result_text = "%s: %s" % [target_id, "ok" if result.get("success", false) else "rejected"]
	interaction_finished.emit(target_id, result)
	# A listener may have opened a modal panel and disabled interaction.
	if _enabled:
		_refresh_selection(true)


func _is_target_usable(target: Interactable) -> bool:
	return (is_instance_valid(target) and target.is_inside_tree() and _candidates.has(target)
		and target.is_interaction_available() and _distance_to(target) <= interaction_range)


func _distance_to(target: Interactable) -> float:
	var offset: Vector3 = target.get_interaction_point() - _player.global_position
	offset.y = 0.0
	return offset.length()


func _input_hint() -> String:
	return tr("ui.prompt.key_hint").format({"key": InputHints.key_name(&"interact")})
