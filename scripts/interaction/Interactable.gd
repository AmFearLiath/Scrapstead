class_name Interactable
extends StaticBody3D
## Small shared interaction contract of all interaction targets
## (docs/p0-interaction-controller.md, sections 4, 8 and 9).
##
## The PlayerInteractor decides WHICH target is addressed; the target decides
## WHETHER and HOW its action works. Subclasses override the virtual methods
## below. This is deliberately not a generic interaction framework.
##
## Result dictionaries returned by `interact()`:
##   success      bool    whether the action was performed
##   message_key  String  localization key of the feedback (may be empty)
##   message_args Dictionary  named placeholders for the message
##   panel        String  optional: UI panel the scene should open ("inspect", ...)
##   panel_data   Dictionary  optional data for that panel

## Emitted when availability or prompt content changed (e.g. after pickup).
signal interaction_state_changed(target: Interactable)

const HIGHLIGHT_COLOR: Color = Color(0.878, 0.663, 0.231, 1.0)

## Stable, language independent placement ID (not the object type).
@export var object_id: String = ""
## Localization key of the display name.
@export var name_key: String = ""
## Localization key of the main action shown in the prompt.
@export var action_key: String = "ui.action.use"
## Radius of the ground highlight ring.
@export var highlight_radius: float = 0.6

var _highlight: MeshInstance3D
var _highlight_tween: Tween

static var _highlight_material: StandardMaterial3D


func _ready() -> void:
	if object_id.is_empty():
		push_error("Interactable '%s' has no object_id." % get_path())
	_create_highlight()


## Whether this target can currently be offered at all (exists, not consumed).
func is_interaction_available() -> bool:
	return visible and not object_id.is_empty()


## Point used for range and selection measurements.
func get_interaction_point() -> Vector3:
	var marker: Node3D = get_node_or_null("InteractionPoint")
	return marker.global_position if marker != null else global_position


## Localized display name for the prompt.
func get_display_name() -> String:
	return tr(name_key)


## Localization key of the main action.
func get_action_key() -> String:
	return action_key


## Optional extra line for the prompt (e.g. value or requirement); localized.
func get_prompt_detail(_context: InteractionContext) -> String:
	return ""


## Seconds the action key must be held; 0 = instant action.
func get_hold_duration() -> float:
	return 0.0


## Checks gameplay preconditions right before the action.
## Returns {"ok": bool, "message_key": String, "message_args": Dictionary}.
func check_requirements(_context: InteractionContext) -> Dictionary:
	return {"ok": true, "message_key": "", "message_args": {}}


## Performs the action. Must not change state when it fails.
func interact(_context: InteractionContext) -> Dictionary:
	return make_result(false, "ui.interaction.unavailable")


## Plain-data state for the save snapshot. Empty = initial state.
func get_save_state() -> Dictionary:
	return {}


## Applies a saved state. Unknown or missing fields keep the initial state.
func apply_save_state(_state: Dictionary) -> void:
	pass


## Visual-only highlight; never changes gameplay state.
func set_highlighted(highlighted: bool) -> void:
	if _highlight == null:
		return
	_highlight.visible = highlighted
	if _highlight_tween != null:
		_highlight_tween.kill()
		_highlight_tween = null
	if highlighted:
		_highlight.scale = Vector3.ONE
		_highlight_tween = create_tween().set_loops()
		_highlight_tween.tween_property(_highlight, "scale", Vector3(1.12, 1.0, 1.12), 0.45).set_trans(Tween.TRANS_SINE)
		_highlight_tween.tween_property(_highlight, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_SINE)


## Helper to build a result dictionary.
static func make_result(success: bool, message_key: String = "", message_args: Dictionary = {}) -> Dictionary:
	return {"success": success, "message_key": message_key, "message_args": message_args}


func _create_highlight() -> void:
	if _highlight_material == null:
		_highlight_material = StandardMaterial3D.new()
		_highlight_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_highlight_material.albedo_color = HIGHLIGHT_COLOR
		_highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_highlight_material.albedo_color.a = 0.9
		_highlight_material.no_depth_test = false
	var ring := TorusMesh.new()
	ring.inner_radius = highlight_radius
	ring.outer_radius = highlight_radius + 0.09
	ring.rings = 32
	ring.ring_segments = 6
	_highlight = MeshInstance3D.new()
	_highlight.name = "HighlightRing"
	_highlight.mesh = ring
	_highlight.material_override = _highlight_material
	_highlight.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_highlight.visible = false
	add_child(_highlight)
	_highlight.global_position = Vector3(get_interaction_point().x, global_position.y + 0.04,
		get_interaction_point().z)
