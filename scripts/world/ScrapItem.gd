class_name ScrapItem
extends Interactable
## A collectible piece of scrap placed in the yard (P1). Its type data comes
## from an ItemDefinition; this node only owns the world state of this one
## placement: lying in the yard, carried by the player, sold, consumed by
## processing (P1b), or not yet produced (processing output placeholder).

enum State { IN_WORLD, CARRIED, SOLD, PROCESSED, PENDING }

const STATE_NAMES: PackedStringArray = ["in_world", "carried", "sold", "processed", "pending"]

@export var definition: ItemDefinition
## Processing outputs start as not-yet-produced placements (P1b).
@export var starts_pending: bool = false

var _state: State = State.IN_WORLD
var _initial_state: State = State.IN_WORLD
## Set once the object was moved away from its authored placement (dropped).
var _moved: bool = false


func _ready() -> void:
	if definition == null:
		push_error("ScrapItem '%s' has no ItemDefinition." % object_id)
	else:
		if name_key.is_empty():
			name_key = definition.name_key
		_ensure_model()
	super()
	if starts_pending:
		_initial_state = State.PENDING
		set_state(State.PENDING)


func get_item_id() -> String:
	return definition.id if definition != null else ""


func get_state() -> State:
	return _state


func is_interaction_available() -> bool:
	return super() and _state == State.IN_WORLD and definition != null


func get_prompt_detail(context: InteractionContext) -> String:
	var detail: String = tr("ui.item.detail").format({
		"category": tr(definition.get_category_key()),
		"value": definition.sell_value,
		"size": definition.carry_size,
	})
	if context != null and context.inventory != null and not context.inventory.can_add(definition.id):
		detail += "  ·  " + tr("ui.inventory.full_short")
	return detail


func check_requirements(context: InteractionContext) -> Dictionary:
	if context == null or context.inventory == null:
		return {"ok": false, "message_key": "ui.interaction.unavailable", "message_args": {}}
	if not context.inventory.can_add(definition.id):
		return {"ok": false, "message_key": "ui.inventory.no_space", "message_args": {
			"name": get_display_name(), "free": context.inventory.get_free_slots(),
			"size": definition.carry_size}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	if not is_interaction_available():
		return make_result(false, "ui.interaction.unavailable")
	if not context.inventory.add(object_id, definition.id):
		return make_result(false, "ui.inventory.no_space", {"name": get_display_name(),
			"free": context.inventory.get_free_slots(), "size": definition.carry_size})
	set_state(State.CARRIED)
	return make_result(true, "ui.interaction.picked_up", {"name": get_display_name()})


func get_inspection(context: InteractionContext) -> Dictionary:
	return {"title": get_display_name(),
		"body": get_prompt_detail(context) + "\n\n" + tr(definition.description_key)}


## Makes a prepared (pending) placement appear in the yard with a small pop.
func reveal() -> void:
	set_state(State.IN_WORLD)
	var visual_root: Node3D = get_node_or_null("VisualRoot")
	if visual_root != null and is_inside_tree():
		visual_root.scale = Vector3.ONE * 0.2
		create_tween().tween_property(visual_root, "scale", Vector3.ONE, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Puts the object back into the world at a new position (drop).
func drop_at(world_position: Vector3, yaw: float) -> void:
	global_position = world_position
	rotation.y = yaw
	_moved = true
	set_state(State.IN_WORLD)


## Changes the world state and its presentation.
func set_state(new_state: State) -> void:
	_state = new_state
	var present: bool = _state == State.IN_WORLD
	visible = present
	# Leaving the interactable layer makes the detector report the exit.
	collision_layer = 4 if present else 0
	interaction_state_changed.emit(self)


func get_save_state() -> Dictionary:
	if _state == _initial_state and not _moved:
		return {}
	var data: Dictionary = {"state": STATE_NAMES[_state]}
	if _state == State.IN_WORLD:
		data["position"] = [snappedf(global_position.x, 0.001), snappedf(global_position.y, 0.001),
			snappedf(global_position.z, 0.001)]
		data["yaw"] = snappedf(rotation.y, 0.0001)
	return data


func apply_save_state(state: Dictionary) -> void:
	var index: int = STATE_NAMES.find(str(state.get("state", "in_world")))
	if index == -1:
		push_warning("ScrapItem '%s': unknown state, keeping initial state." % object_id)
		return
	var position_data: Variant = state.get("position")
	if index == State.IN_WORLD and typeof(position_data) == TYPE_ARRAY and position_data.size() == 3:
		drop_at(Vector3(position_data[0], position_data[1], position_data[2]), float(state.get("yaw", 0.0)))
	else:
		set_state(index as State)


## Generic item scenes get their placeholder model from the definition.
func _ensure_model() -> void:
	var visual_root: Node3D = get_node_or_null("VisualRoot")
	if visual_root != null and visual_root.get_child_count() == 0 and definition.model != null:
		var model: Node3D = definition.model.instantiate()
		model.name = "PlaceholderModel"
		visual_root.add_child(model)
