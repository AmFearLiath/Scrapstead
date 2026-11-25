extends Control
## Read-only diagnostics for development builds (docs/p0-system-integration.md,
## section 11). Shows values of explicitly passed references; changes nothing.
## Debug text is developer-facing and intentionally not localized.

const REFRESH_SECONDS: float = 0.1

@onready var _player_position_label: Label = %PlayerPositionLabel
@onready var _player_velocity_label: Label = %PlayerVelocityLabel
@onready var _interaction_state_label: Label = %InteractionStateLabel
@onready var _camera_state_label: Label = %CameraStateLabel
@onready var _session_save_state_label: Label = %SessionSaveStateLabel
@onready var _extra_state_label: Label = %ExtraStateLabel

var _player: Node3D
var _camera_rig: Node
var _interactor: Node
var _extra_provider: Callable
var _timer: Timer


func _ready() -> void:
	visible = false
	_timer = Timer.new()
	_timer.wait_time = REFRESH_SECONDS
	_timer.timeout.connect(_refresh)
	add_child(_timer)


## Explicit read-only sources. `extra_provider` returns additional lines.
func setup(player: Node3D, camera_rig: Node, interactor: Node, extra_provider: Callable = Callable()) -> void:
	_player = player
	_camera_rig = camera_rig
	_interactor = interactor
	_extra_provider = extra_provider


## Shows or hides the overlay; only available in debug builds.
func toggle() -> void:
	visible = OS.is_debug_build() and not visible
	if visible:
		_refresh()
		_timer.start()
	else:
		_timer.stop()


func _refresh() -> void:
	if is_instance_valid(_player):
		var p: Vector3 = _player.global_position
		_player_position_label.text = "Player pos: (%.2f, %.2f, %.2f)" % [p.x, p.y, p.z]
		var movement: Dictionary = _player.get_debug_data()
		var direction: Vector3 = movement["direction"]
		_player_velocity_label.text = "Speed: %.2f m/s  dir: (%.2f, %.2f)  floor: %s" % [
			movement["horizontal_speed"], direction.x, direction.z, movement["on_floor"]]
	if is_instance_valid(_interactor):
		var interaction: Dictionary = _interactor.get_debug_data()
		_interaction_state_label.text = "Target: %s  dist: %.2f  candidates: %d  %s\nLast: %s" % [
			interaction["target_id"], interaction["distance"], interaction["candidates"],
			interaction["reason"], interaction["last_result"]]
	if is_instance_valid(_camera_rig):
		var camera: Dictionary = _camera_rig.get_debug_data()
		_camera_state_label.text = "Camera: target=%s zoom=%.2f->%.2f follow=%.2f" % [
			camera["has_target"], camera["zoom"], camera["target_zoom"], camera["follow_distance"]]
	_session_save_state_label.text = GameSession.get_debug_status()
	_extra_state_label.text = _extra_provider.call() if _extra_provider.is_valid() else ""
