extends SceneTree
## Headless test runner.
##   godot --headless --path . -s res://tests/run_tests.gd [-- --filter=<text>]
## Runs every suite in tests/unit and tests/integration and exits with code 1
## if any check failed.

const SUITE_DIRECTORIES: PackedStringArray = ["res://tests/unit", "res://tests/integration"]

var _filter: String = ""
var _error_logger := ScriptErrorLogger.new()


## Counts script errors (not engine errors that tests provoke on purpose).
class ScriptErrorLogger extends Logger:
	var script_errors: PackedStringArray = []
	var _mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, _code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == Logger.ERROR_TYPE_SCRIPT:
			_mutex.lock()
			script_errors.append("%s (%s:%d %s)" % [rationale, file.get_file(), line, function])
			_mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass


func _initialize() -> void:
	OS.add_logger(_error_logger)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--filter="):
			_filter = argument.trim_prefix("--filter=")
	_run.call_deferred()


func _run() -> void:
	# Isolate tests from the player's real save game and settings.
	var save_service: Node = root.get_node("SaveService")
	save_service.save_directory = "user://test_run/saves"
	save_service.settings_directory = "user://test_run"
	root.get_node("GameSession").intro_enabled = false
	var total: int = 0
	var failed: int = 0
	var report: PackedStringArray = []
	for directory: String in SUITE_DIRECTORIES:
		for file_name: String in _list_suites(directory):
			var suite: TestSuite = load(directory.path_join(file_name)).new()
			suite.tree = self
			for method: Dictionary in suite.get_method_list():
				var method_name: String = method["name"]
				if not method_name.begins_with("test_"):
					continue
				var label: String = "%s::%s" % [file_name.get_basename(), method_name]
				if not _filter.is_empty() and not label.contains(_filter):
					continue
				total += 1
				var failures_before: int = suite.failures.size()
				_error_logger.script_errors.clear()
				suite._current_test = label
				await suite.before_each()
				await suite.call(method_name)
				await suite.after_each()
				for script_error: String in _error_logger.script_errors:
					suite.failures.append("%s: script error: %s" % [label, script_error])
				var passed: bool = suite.failures.size() == failures_before
				if not passed:
					failed += 1
				print("[%s] %s" % ["PASS" if passed else "FAIL", label])
			for failure: String in suite.failures:
				report.append(failure)
	print("")
	for line: String in report:
		print("  FAILURE ", line)
	print("Tests: %d, passed: %d, failed: %d" % [total, total - failed, failed])
	quit(1 if failed > 0 or total == 0 else 0)


func _list_suites(directory: String) -> PackedStringArray:
	var files: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(directory):
		if file_name.ends_with(".gd"):
			files.append(file_name)
	files.sort()
	return files
