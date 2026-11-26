extends Node
## Persistence service (autoload "SaveService").
##
## Sole owner of file I/O. Reads and writes the versioned JSON save game and the
## separate settings file in the Godot user data directory. It validates the
## save schema but makes no gameplay decisions, loads no scenes and never calls
## GameSession back (see docs/p0-system-integration.md, section 4.2).
##
## All public methods return structured result dictionaries:
## { "ok": bool, "error": ErrorCode, "message_key": String, "data": Dictionary }

## Current save schema version. Other versions are rejected, never silently
## migrated. Version 1 was the P0 schema; version 2 adds wallet, inventory and
## upgrades (P1), version 3 story and Scrappy (P2), version 4 the neighbors'
## scrap deliveries, version 5 the first employee (P3a), version 6 the first
## machine (P3b).
const SAVE_VERSION: int = 6
## Oldest version that can be migrated explicitly (see _migrate()).
const OLDEST_MIGRATABLE_VERSION: int = 2
const SAVE_FILE_NAME: String = "slot_0.json"
const SETTINGS_FILE_NAME: String = "settings.json"
const DEFAULT_SAVE_DIRECTORY: String = "user://saves"
const DEFAULT_SETTINGS_DIRECTORY: String = "user://"

enum ErrorCode {
	NONE,
	NOT_FOUND,
	READ_FAILED,
	CORRUPT,
	UNSUPPORTED_VERSION,
	INVALID_DATA,
	WRITE_FAILED,
}

const _MESSAGE_KEYS: Dictionary = {
	ErrorCode.NONE: "ui.save.ok",
	ErrorCode.NOT_FOUND: "ui.save.error.not_found",
	ErrorCode.READ_FAILED: "ui.save.error.read_failed",
	ErrorCode.CORRUPT: "ui.save.error.corrupt",
	ErrorCode.UNSUPPORTED_VERSION: "ui.save.error.unsupported_version",
	ErrorCode.INVALID_DATA: "ui.save.error.invalid_data",
	ErrorCode.WRITE_FAILED: "ui.save.error.write_failed",
}

## Directory of the save slot. Only changed by automated tests.
var save_directory: String = DEFAULT_SAVE_DIRECTORY
## Directory of the settings file. Only changed by automated tests.
var settings_directory: String = DEFAULT_SETTINGS_DIRECTORY


## Returns true only if a save file exists, parses and validates for this version.
func has_valid_save() -> bool:
	return load_game()["ok"]


## Reads, parses and validates the save game.
func load_game() -> Dictionary:
	var path: String = get_save_path()
	if not FileAccess.file_exists(path):
		return _result(ErrorCode.NOT_FOUND)
	var text: String = FileAccess.get_file_as_string(path)
	if text.is_empty() and FileAccess.get_open_error() != OK:
		return _result(ErrorCode.READ_FAILED)
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _result(ErrorCode.CORRUPT)
	var data: Dictionary = _migrate(json.data)
	var version_error: ErrorCode = _check_version(data)
	if version_error != ErrorCode.NONE:
		return _result(version_error)
	if not validate_save_data(data):
		return _result(ErrorCode.INVALID_DATA)
	return _result(ErrorCode.NONE, _normalize(data))


## Validates and writes the given save data. Writes to a temporary file first
## and replaces the previous save only after a complete write.
func save_game(data: Dictionary) -> Dictionary:
	if int(data.get("save_version", -1)) != SAVE_VERSION or not validate_save_data(data):
		return _result(ErrorCode.INVALID_DATA)
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(save_directory)
	if dir_error != OK and not DirAccess.dir_exists_absolute(save_directory):
		return _result(ErrorCode.WRITE_FAILED)
	var final_path: String = get_save_path()
	var temp_path: String = final_path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return _result(ErrorCode.WRITE_FAILED)
	var stored: bool = file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if not stored:
		DirAccess.remove_absolute(temp_path)
		return _result(ErrorCode.WRITE_FAILED)
	if FileAccess.file_exists(final_path) and DirAccess.remove_absolute(final_path) != OK:
		DirAccess.remove_absolute(temp_path)
		return _result(ErrorCode.WRITE_FAILED)
	if DirAccess.rename_absolute(temp_path, final_path) != OK:
		return _result(ErrorCode.WRITE_FAILED)
	return _result(ErrorCode.NONE)


## Schema check for required fields and basic types. Gameplay consistency
## (e.g. whether an object ID exists in a scene) is not judged here.
func validate_save_data(data: Dictionary) -> bool:
	if typeof(data.get("scene_id")) != TYPE_STRING or String(data["scene_id"]).is_empty():
		return false
	if typeof(data.get("player")) != TYPE_DICTIONARY:
		return false
	var player: Dictionary = data["player"]
	if player.has("position") and not _is_vector3_array(player["position"]):
		return false
	if player.has("facing") and not _is_number(player["facing"]):
		return false
	if typeof(data.get("world_objects")) != TYPE_DICTIONARY:
		return false
	for object_id: Variant in data["world_objects"]:
		if typeof(object_id) != TYPE_STRING or typeof(data["world_objects"][object_id]) != TYPE_DICTIONARY:
			return false
	if typeof(data.get("wallet")) != TYPE_DICTIONARY:
		return false
	var wallet: Dictionary = data["wallet"]
	if wallet.has("balance") and (not _is_number(wallet["balance"]) or float(wallet["balance"]) < 0.0):
		return false
	if wallet.has("sequence") and (not _is_number(wallet["sequence"]) or float(wallet["sequence"]) < 0.0):
		return false
	if wallet.has("ledger") and typeof(wallet["ledger"]) != TYPE_ARRAY:
		return false
	if not _is_string_array(data.get("inventory")) or not _is_string_array(data.get("upgrades")):
		return false
	if typeof(data.get("story")) != TYPE_DICTIONARY or typeof(data.get("scrappy")) != TYPE_DICTIONARY:
		return false
	var story: Dictionary = data["story"]
	for key: String in ["flags", "key_items", "spoken_once"]:
		if not _is_string_array(story.get(key, [])):
			return false
	var scrappy: Dictionary = data["scrappy"]
	if scrappy.has("position") and not _is_vector3_array(scrappy["position"]):
		return false
	if typeof(data.get("deliveries")) != TYPE_DICTIONARY:
		return false
	var deliveries: Dictionary = data["deliveries"]
	for key: String in ["timer", "next_entry", "counter"]:
		if deliveries.has(key) and not _is_number(deliveries[key]):
			return false
	if deliveries.has("items"):
		if typeof(deliveries["items"]) != TYPE_ARRAY:
			return false
		for entry: Variant in deliveries["items"]:
			if typeof(entry) != TYPE_DICTIONARY or typeof(entry.get("id")) != TYPE_STRING \
					or typeof(entry.get("item")) != TYPE_STRING:
				return false
	return _is_valid_employee(data.get("employee")) and _is_valid_machines(data.get("machines"))


## Machines by ID: {"on": bool, "timer", "heap_taken", "counter": numbers, "items": [{id, item, slot}]}.
func _is_valid_machines(value: Variant) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	for machine_id: Variant in value:
		var machine: Variant = value[machine_id]
		if typeof(machine_id) != TYPE_STRING or typeof(machine) != TYPE_DICTIONARY:
			return false
		for key: String in ["timer", "heap_taken", "counter"]:
			if machine.has(key) and not _is_number(machine[key]):
				return false
		if machine.has("on") and typeof(machine["on"]) != TYPE_BOOL:
			return false
		if machine.has("items"):
			if typeof(machine["items"]) != TYPE_ARRAY:
				return false
			for entry: Variant in machine["items"]:
				if typeof(entry) != TYPE_DICTIONARY or typeof(entry.get("id")) != TYPE_STRING \
						or typeof(entry.get("item")) != TYPE_STRING:
					return false
	return true


func _is_valid_employee(value: Variant) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	var employee: Dictionary = value
	if employee.has("presence") and typeof(employee["presence"]) != TYPE_STRING:
		return false
	if employee.has("position") and not _is_vector3_array(employee["position"]):
		return false
	if employee.has("carrying") and not _is_string_array(employee["carrying"]):
		return false
	for key: String in ["seen", "yaw"]:
		if employee.has(key) and not _is_number(employee[key]):
			return false
	if employee.has("stats"):
		if typeof(employee["stats"]) != TYPE_DICTIONARY:
			return false
		for stat: Variant in employee["stats"].values():
			if not _is_number(stat):
				return false
	return true


## Absolute path of the active save slot.
func get_save_path() -> String:
	return save_directory.path_join(SAVE_FILE_NAME)


## Removes the save slot. Used by automated tests only.
func delete_save() -> void:
	if FileAccess.file_exists(get_save_path()):
		DirAccess.remove_absolute(get_save_path())


## Loads the player settings. Missing or broken files yield an empty dictionary.
func load_settings() -> Dictionary:
	var path: String = settings_directory.path_join(SETTINGS_FILE_NAME)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveService: settings file is unreadable and will be ignored.")
		return {}
	return parsed


## Persists the player settings.
func save_settings(settings: Dictionary) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(settings_directory)
	var file := FileAccess.open(settings_directory.path_join(SETTINGS_FILE_NAME), FileAccess.WRITE)
	if file == null:
		return _result(ErrorCode.WRITE_FAILED)
	file.store_string(JSON.stringify(settings, "\t"))
	file.close()
	return _result(ErrorCode.NONE)


## Localization key describing an error code.
func get_message_key(code: ErrorCode) -> String:
	return _MESSAGE_KEYS.get(code, "ui.save.error.invalid_data")


func _check_version(data: Dictionary) -> ErrorCode:
	if not _is_number(data.get("save_version")):
		return ErrorCode.INVALID_DATA
	if int(data["save_version"]) != SAVE_VERSION:
		return ErrorCode.UNSUPPORTED_VERSION
	return ErrorCode.NONE


## JSON numbers arrive as floats; whole-number fields are converted back.
func _normalize(data: Dictionary) -> Dictionary:
	var normalized: Dictionary = data.duplicate(true)
	normalized["save_version"] = int(normalized["save_version"])
	var wallet: Dictionary = normalized["wallet"]
	for key: String in ["balance", "sequence"]:
		if wallet.has(key):
			wallet[key] = int(wallet[key])
	return normalized


func _result(code: ErrorCode, data: Dictionary = {}) -> Dictionary:
	return {
		"ok": code == ErrorCode.NONE,
		"error": code,
		"message_key": get_message_key(code),
		"data": data,
	}


func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT


func _is_vector3_array(value: Variant) -> bool:
	if typeof(value) != TYPE_ARRAY or value.size() != 3:
		return false
	for component: Variant in value:
		if not _is_number(component):
			return false
	return true


func _is_string_array(value: Variant) -> bool:
	if typeof(value) != TYPE_ARRAY:
		return false
	for entry: Variant in value:
		if typeof(entry) != TYPE_STRING:
			return false
	return true


## Explicit, documented migrations. Each step upgrades exactly one version;
## unknown or too old versions are left untouched and rejected later.
func _migrate(data: Dictionary) -> Dictionary:
	if not _is_number(data.get("save_version")):
		return data
	var migrated: Dictionary = data.duplicate(true)
	if int(migrated["save_version"]) == 2:
		# v2 -> v3 (P2): story progress and Scrappy did not exist yet.
		migrated["story"] = {"flags": [], "key_items": [], "spoken_once": []}
		migrated["scrappy"] = {"state": "dormant", "follow": true}
		migrated["save_version"] = 3
	if int(migrated["save_version"]) == 3:
		# v3 -> v4: no deliveries had arrived yet.
		migrated["deliveries"] = {}
		migrated["save_version"] = 4
	if int(migrated["save_version"]) == 4:
		# v4 -> v5 (P3a): nobody had been hired yet.
		migrated["employee"] = {}
		migrated["save_version"] = 5
	if int(migrated["save_version"]) == 5:
		# v5 -> v6 (P3b): no machine had been bought yet.
		migrated["machines"] = {}
		migrated["save_version"] = 6
	return migrated
