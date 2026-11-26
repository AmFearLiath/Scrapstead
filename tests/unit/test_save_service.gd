extends TestSuite
## SaveService: versioned JSON, validation and error handling.

var _service: Node


func before_each() -> void:
	_service = tree.root.get_node("SaveService")
	_service.save_directory = "user://test_run/saves"
	_service.delete_save()


func after_each() -> void:
	_service.save_directory = "user://test_run/saves"
	_service.delete_save()


func _valid_data() -> Dictionary:
	return tree.root.get_node("GameSession").create_initial_state()


func test_missing_save_is_not_valid() -> void:
	check(not _service.has_valid_save(), "no file must not count as valid save")
	check_eq(_service.load_game()["error"], _service.ErrorCode.NOT_FOUND, "missing file error code")


func test_round_trip() -> void:
	var data: Dictionary = _valid_data()
	data["player"] = {"position": [1.5, 0.1, 2.25], "facing": 0.5}
	data["world_objects"] = {"obj_a": {"picked_up": true}}
	var saved: Dictionary = _service.save_game(data)
	check(saved["ok"], "save should succeed")
	check(_service.has_valid_save(), "saved file should be valid")
	var loaded: Dictionary = _service.load_game()
	check(loaded["ok"], "load should succeed")
	check_eq(loaded["data"]["world_objects"], data["world_objects"], "world objects survive round trip")
	check_eq(loaded["data"]["save_version"], _service.SAVE_VERSION, "version is an int after load")
	check(not FileAccess.file_exists(_service.get_save_path() + ".tmp"), "no temp file left behind")


func test_corrupt_json_is_rejected() -> void:
	_write_raw("{ this is not json")
	check(not _service.has_valid_save(), "corrupt file must not be valid")
	check_eq(_service.load_game()["error"], _service.ErrorCode.CORRUPT, "corrupt error code")


func test_unsupported_version_is_rejected_and_not_overwritten() -> void:
	var data: Dictionary = _valid_data()
	data["save_version"] = 999
	_write_raw(JSON.stringify(data))
	var result: Dictionary = _service.load_game()
	check_eq(result["error"], _service.ErrorCode.UNSUPPORTED_VERSION, "unsupported version code")
	check(FileAccess.get_file_as_string(_service.get_save_path()).contains("999"), "file left untouched")


func test_invalid_structure_is_rejected() -> void:
	var data: Dictionary = _valid_data()
	data.erase("player")
	_write_raw(JSON.stringify(data))
	check_eq(_service.load_game()["error"], _service.ErrorCode.INVALID_DATA, "missing player rejected")
	data = _valid_data()
	data["player"] = {"position": [1, 2]}
	_write_raw(JSON.stringify(data))
	check_eq(_service.load_game()["error"], _service.ErrorCode.INVALID_DATA, "short position rejected")


func test_save_rejects_invalid_data() -> void:
	var result: Dictionary = _service.save_game({"save_version": _service.SAVE_VERSION})
	check(not result["ok"], "invalid data must not be written")
	check(not FileAccess.file_exists(_service.get_save_path()), "no file written for invalid data")


func test_write_failure_is_reported() -> void:
	# A regular file blocks the directory path, so the save cannot be created.
	var blocker := FileAccess.open("user://test_run/blocker", FileAccess.WRITE)
	blocker.store_string("x")
	blocker.close()
	_service.save_directory = "user://test_run/blocker/saves"
	var result: Dictionary = _service.save_game(_valid_data())
	check(not result["ok"], "write must fail")
	check_eq(result["error"], _service.ErrorCode.WRITE_FAILED, "write failure code")
	DirAccess.remove_absolute("user://test_run/blocker")


func _write_raw(text: String) -> void:
	DirAccess.make_dir_recursive_absolute(_service.save_directory)
	var file := FileAccess.open(_service.get_save_path(), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_version_2_save_is_migrated_to_current_version() -> void:
	var data: Dictionary = _valid_data()
	data["save_version"] = 2
	data.erase("story")
	data.erase("scrappy")
	data["wallet"] = {"balance": 17, "sequence": 3, "ledger": []}
	_write_raw(JSON.stringify(data))
	var result: Dictionary = _service.load_game()
	check(result["ok"], "v2 save loads after migration")
	var migrated: Dictionary = result.get("data", {})
	check_eq(migrated.get("save_version"), _service.SAVE_VERSION, "version raised to current")
	check_eq(migrated.get("story", {}).get("flags"), [], "empty story added")
	check_eq(migrated.get("scrappy", {}).get("state"), "dormant", "Scrappy starts dormant")
	check_eq(migrated.get("deliveries"), {}, "no deliveries yet")
	check_eq(int(migrated["wallet"]["balance"]), 17, "existing data kept")


func test_version_1_save_is_still_rejected() -> void:
	var data: Dictionary = _valid_data()
	data["save_version"] = 1
	_write_raw(JSON.stringify(data))
	check_eq(_service.load_game()["error"], _service.ErrorCode.UNSUPPORTED_VERSION, "v1 not migratable")


func test_invalid_story_data_is_rejected() -> void:
	var data: Dictionary = _valid_data()
	data["story"] = {"flags": [1, 2], "key_items": [], "spoken_once": []}
	_write_raw(JSON.stringify(data))
	check_eq(_service.load_game()["error"], _service.ErrorCode.INVALID_DATA, "non-string flags rejected")
