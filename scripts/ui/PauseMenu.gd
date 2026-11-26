extends Control
## In-game menu (Esc): resume, re-read Walt's letter, check Walt's list, save, save and return to the main menu, or
## return without saving. Only forwards the choice; the scene controller and
## GameSession perform it.

signal resume_requested
signal save_requested
signal save_and_exit_requested
signal exit_without_saving_requested
signal letter_requested
signal tasks_requested
signal settings_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _save_button: Button = %SaveButton
@onready var _save_exit_button: Button = %SaveExitButton
@onready var _exit_button: Button = %ExitButton
@onready var _letter_button: Button = %LetterButton
@onready var _tasks_button: Button = %TasksButton
@onready var _settings_button: Button = %SettingsButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(func() -> void: resume_requested.emit())
	_save_button.pressed.connect(func() -> void: save_requested.emit())
	_save_exit_button.pressed.connect(func() -> void: save_and_exit_requested.emit())
	_exit_button.pressed.connect(func() -> void: exit_without_saving_requested.emit())
	_letter_button.pressed.connect(func() -> void: letter_requested.emit())
	_tasks_button.pressed.connect(func() -> void: tasks_requested.emit())
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())


func open() -> void:
	show()
	_resume_button.grab_focus()


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		resume_requested.emit()
