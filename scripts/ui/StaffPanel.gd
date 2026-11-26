extends Control
## Staff panel (P3a): who the helper is, what he costs, what he does right
## now and what he has earned so far. Hire, pause/resume and dismiss are
## executed by YardWorker; the panel only shows the results.

signal action_result(result: Dictionary)
signal closed

@onready var _title: Label = %Title
@onready var _role: Label = %Role
@onready var _description: Label = %Description
@onready var _terms: Label = %Terms
@onready var _status: Label = %Status
@onready var _stats: Label = %Stats
@onready var _primary_button: Button = %PrimaryButton
@onready var _dismiss_button: Button = %DismissButton
@onready var _close_button: Button = %CloseButton

var _worker: YardWorker
var _confirm_dismiss: bool = false


func _ready() -> void:
	hide()
	_close_button.pressed.connect(close)
	_primary_button.pressed.connect(_on_primary_pressed)
	_dismiss_button.pressed.connect(_on_dismiss_pressed)


func open(worker: YardWorker) -> void:
	_worker = worker
	_confirm_dismiss = false
	if not _worker.status_changed.is_connected(_on_status_changed):
		_worker.status_changed.connect(_on_status_changed)
	_rebuild()
	show()
	_primary_button.grab_focus()


func close() -> void:
	if not visible:
		return
	hide()
	if _worker != null and _worker.status_changed.is_connected(_on_status_changed):
		_worker.status_changed.disconnect(_on_status_changed)
	_worker = null
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		close()


func _rebuild() -> void:
	var profile: EmployeeProfile = _worker.profile
	var hired: bool = _worker.is_hired()
	_title.text = _worker.get_display_name()
	_role.text = tr(profile.role_key)
	_description.text = tr(profile.description_key)
	_terms.text = tr("ui.staff.terms").format({"fee": profile.hire_fee, "wage": profile.wage_per_item,
		"capacity": profile.carry_capacity})
	_status.visible = hired
	_stats.visible = hired
	_dismiss_button.visible = hired
	if hired:
		_status.text = tr("ui.staff.status_line").format({"status": tr("ui.staff.status." + _worker.get_status())})
		var stats: Dictionary = _worker.get_stats()
		_stats.text = tr("ui.staff.stats").format({"trips": stats["trips"], "items": stats["items"],
			"revenue": stats["revenue"], "wages": stats["wages"], "net": stats["revenue"] - stats["wages"]})
		_primary_button.text = tr("ui.staff.resume" if _worker.is_paused() else "ui.staff.pause")
		_dismiss_button.text = tr("ui.staff.dismiss_confirm" if _confirm_dismiss else "ui.staff.dismiss")
	else:
		_primary_button.text = tr("ui.staff.hire").format({"fee": profile.hire_fee})
	_primary_button.disabled = false


func _on_primary_pressed() -> void:
	if _worker == null:
		return
	_confirm_dismiss = false
	var result: Dictionary = _worker.toggle_pause() if _worker.is_hired() else _worker.hire()
	action_result.emit(result)
	if _worker != null:
		_rebuild()


func _on_dismiss_pressed() -> void:
	if _worker == null or not _worker.is_hired():
		return
	if not _confirm_dismiss:
		_confirm_dismiss = true
		_rebuild()
		return
	action_result.emit(_worker.dismiss())
	close()


func _on_status_changed(_status_name: String) -> void:
	if visible and _worker != null:
		_rebuild()
