class_name SearchSource
extends Interactable
## A container or heap that can be searched once (P1 deepening, catalog
## section 4.4). Its contents are authored, not random: prepared ScrapItem
## placements start pending and pop out in front of the source when it is
## searched. Some sources need a tool (e.g. a crowbar for nailed crates).

## Tool ID required to open the source; empty = bare hands.
@export var required_tool: String = ""
@export_range(0.3, 10.0) var search_seconds: float = 1.5
## Localization key of the message shown after searching (flavor).
@export var result_key: String = ""
## Prepared contents (ScrapItems with starts_pending = true).
@export var contents: Array[ScrapItem] = []
## Visual shown while closed / after searching.
@export var closed_visual: Node3D
@export var open_visual: Node3D

var _searched: bool = false


func _ready() -> void:
	super()
	_apply_visual()


func is_searched() -> bool:
	return _searched


func is_interaction_available() -> bool:
	return super() and not _searched


func get_hold_duration() -> float:
	return search_seconds


func get_prompt_detail(context: InteractionContext) -> String:
	if not _has_tool(context):
		return tr("ui.search.needs_tool").format({"tool": tr(UpgradeProgress.tool_name_key(required_tool))})
	return tr("ui.search.detail")


func check_requirements(context: InteractionContext) -> Dictionary:
	if not _has_tool(context):
		return {"ok": false, "message_key": "ui.search.missing_tool." + required_tool,
			"message_args": {"name": get_display_name()}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	var requirements: Dictionary = check_requirements(context)
	if _searched or not requirements["ok"]:
		return make_result(false, requirements.get("message_key", "ui.interaction.unavailable"))
	_set_searched(true)
	for item: ScrapItem in contents:
		if item != null and item.get_state() == ScrapItem.State.PENDING:
			item.reveal()
	return make_result(true, result_key, {"count": contents.size()})


func get_save_state() -> Dictionary:
	return {"searched": true} if _searched else {}


func apply_save_state(state: Dictionary) -> void:
	_set_searched(bool(state.get("searched", false)))


func _set_searched(value: bool) -> void:
	_searched = value
	_apply_visual()
	interaction_state_changed.emit(self)


func _apply_visual() -> void:
	if closed_visual != null:
		closed_visual.visible = not _searched
	if open_visual != null:
		open_visual.visible = _searched


func _has_tool(context: InteractionContext) -> bool:
	return required_tool.is_empty() or (context != null and context.upgrades != null
		and context.upgrades.has_tool(required_tool))
