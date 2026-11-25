class_name SalvageableScrap
extends ScrapItem
## A larger scrap object that is stuck under debris (P1 salvage). Before it
## can be carried it must be pried loose with a hold action. Precondition:
## enough free carry slots for its size, shown in the prompt. After salvaging,
## it behaves like any other carried item (it can be dropped and picked up
## again without a second salvage).

## Seconds the interact key must be held to pry the object loose.
@export_range(0.5, 10.0) var salvage_seconds: float = 2.5
## Debris node that is removed when salvaged.
@export var debris: Node3D
## Visual node shaken while salvaging.
@export var shake_target: Node3D

var _salvaged: bool = false
var _shake_tween: Tween
var _shake_origin: Vector3


func is_salvaged() -> bool:
	return _salvaged


func get_action_key() -> String:
	return "ui.action.salvage" if not _salvaged else action_key


func get_hold_duration() -> float:
	return salvage_seconds if not _salvaged else 0.0


func get_prompt_detail(context: InteractionContext) -> String:
	if _salvaged:
		return super(context)
	var detail: String = tr("ui.salvage.requirement").format({"size": definition.carry_size,
		"value": definition.sell_value})
	if context != null and context.inventory != null and not context.inventory.can_add(definition.id):
		detail += "  ·  " + tr("ui.inventory.full_short")
	return detail


func check_requirements(context: InteractionContext) -> Dictionary:
	if _salvaged or context == null or context.inventory == null:
		return super(context)
	if not context.inventory.can_add(definition.id):
		return {"ok": false, "message_key": "ui.salvage.no_space", "message_args": {
			"size": definition.carry_size, "free": context.inventory.get_free_slots()}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	if _salvaged:
		return super(context)
	if not is_interaction_available() or not context.inventory.add(object_id, definition.id):
		return make_result(false, "ui.salvage.no_space", {"size": definition.carry_size,
			"free": context.inventory.get_free_slots()})
	_stop_shake()
	_set_salvaged(true)
	set_state(State.CARRIED)
	return make_result(true, "ui.salvage.done", {"name": get_display_name(),
		"value": definition.sell_value})


## Hold feedback: the stuck object rattles while being pried loose.
func on_hold_started() -> void:
	if shake_target == null:
		return
	_stop_shake()
	_shake_origin = shake_target.position
	_shake_tween = create_tween().set_loops()
	_shake_tween.tween_property(shake_target, "position", _shake_origin + Vector3(0.04, 0.02, 0), 0.05)
	_shake_tween.tween_property(shake_target, "position", _shake_origin + Vector3(-0.04, 0, 0.03), 0.05)


func on_hold_cancelled() -> void:
	_stop_shake()


func get_save_state() -> Dictionary:
	var data: Dictionary = super()
	if _salvaged:
		if data.is_empty():
			data = {"state": STATE_NAMES[get_state()]}
		data["salvaged"] = true
	return data


func apply_save_state(state: Dictionary) -> void:
	_set_salvaged(bool(state.get("salvaged", false)))
	super(state)


func _set_salvaged(value: bool) -> void:
	_salvaged = value
	if debris != null:
		debris.visible = not value
	interaction_state_changed.emit(self)


func _stop_shake() -> void:
	if _shake_tween != null:
		_shake_tween.kill()
		_shake_tween = null
		if shake_target != null:
			shake_target.position = _shake_origin
