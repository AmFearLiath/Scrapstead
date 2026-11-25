class_name TestSuite
extends RefCounted
## Minimal base class for the headless test runner (tests/run_tests.gd).
## Test methods start with `test_` and may use `await`.

var tree: SceneTree
var failures: PackedStringArray = []
var _current_test: String = ""


## Called before each test. Override for per-test setup (may await).
func before_each() -> void:
	pass


## Called after each test. Override for cleanup (may await).
func after_each() -> void:
	pass


func check(condition: bool, message: String) -> bool:
	if not condition:
		failures.append("%s: %s" % [_current_test, message])
	return condition


func check_eq(actual: Variant, expected: Variant, message: String) -> bool:
	return check(actual == expected, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func check_near(actual: float, expected: float, tolerance: float, message: String) -> bool:
	return check(absf(actual - expected) <= tolerance,
		"%s (expected %.3f ± %.3f, got %.3f)" % [message, expected, tolerance, actual])


func wait_physics_frames(count: int) -> void:
	for index: int in count:
		await tree.physics_frame


func wait_process_frames(count: int) -> void:
	for index: int in count:
		await tree.process_frame


## Waits until the current scene is a freshly loaded scene with the given path.
func wait_for_scene(path: String, max_frames: int = 120) -> Node:
	for index: int in max_frames:
		await tree.process_frame
		var scene: Node = tree.current_scene
		if scene != null and scene.scene_file_path == path and scene.is_node_ready():
			return scene
	return null


## Sends an action press (and optional release) through the input pipeline.
func send_action(action: StringName, pressed: bool = true) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()
