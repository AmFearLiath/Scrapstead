extends SceneTree
## Headless test runner.
##   godot --headless --path . -s res://tests/run_tests.gd [-- --filter=<text>]
## Runs every suite in tests/unit and tests/integration and exits with code 1
## if any check failed.

const SUITE_DIRECTORIES: PackedStringArray = ["res://tests/unit", "res://tests/integration"]

var _filter: String = ""


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--filter="):
			_filter = argument.trim_prefix("--filter=")
	_run.call_deferred()


func _run() -> void:
	# Isolate tests from the player's real save game and settings.
	var save_service: Node = root.get_node("SaveService")
	save_service.save_directory = "user://test_run/saves"
	save_service.settings_directory = "user://test_run"
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
				suite._current_test = label
				await suite.before_each()
				await suite.call(method_name)
				await suite.after_each()
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
