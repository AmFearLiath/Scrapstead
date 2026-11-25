extends Control
## Compact HUD hint for the active interaction target. Shows what the
## PlayerInteractor provides; it sends no gameplay commands
## (docs/p0-implementation-readiness.md, section 3.9).

@onready var _target_name: Label = %TargetName
@onready var _action_label: Label = %ActionLabel
@onready var _input_hint: Label = %InputHint
@onready var _detail: Label = %Detail
@onready var _hold_progress: ProgressBar = %HoldProgress


func _ready() -> void:
	hide_prompt()


## Shows name, action and key of the target plus an optional detail line.
func show_target(target_name: String, action_text: String, input_hint: String, detail: String,
		is_hold_action: bool) -> void:
	_target_name.text = target_name
	_action_label.text = action_text
	_input_hint.text = input_hint
	_detail.text = detail
	_detail.visible = not detail.is_empty()
	_hold_progress.visible = is_hold_action
	_hold_progress.value = 0.0
	visible = true


## Hides the prompt when no valid target exists.
func hide_prompt() -> void:
	visible = false
	_hold_progress.value = 0.0


## Progress of a hold action between 0 and 1.
func set_hold_progress(progress: float) -> void:
	_hold_progress.value = progress
