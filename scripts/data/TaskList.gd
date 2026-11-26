class_name TaskList
extends Resource
## Walt's short to-do list (P4, docs/p4-vertical-slice.md): the main task
## sequence of the slice. Every entry is derived from existing state, so the
## list needs no save data of its own.
##
## Entry: {"id": String, "title": String key, "comment": String key,
##         "condition": "flag:<story flag>" or "owns:<catalog ware>"}

@export var entries: Array[Dictionary] = []


## Whether an entry's condition holds for the given state.
static func is_done(entry: Dictionary, story: StoryState, upgrades: UpgradeProgress) -> bool:
	var condition: String = str(entry.get("condition", ""))
	if condition.begins_with("flag:"):
		return story != null and story.has_flag(condition.trim_prefix("flag:"))
	if condition.begins_with("owns:"):
		return upgrades != null and upgrades.is_owned(condition.trim_prefix("owns:"))
	return false


func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		var id: String = str(entry.get("id", ""))
		if id.is_empty() or seen.has(id):
			problems.append("task without unique id: '%s'" % id)
		seen[id] = true
		var condition: String = str(entry.get("condition", ""))
		if not (condition.begins_with("flag:") or condition.begins_with("owns:")):
			problems.append("%s: unknown condition '%s'" % [id, condition])
		for key: String in ["title", "comment"]:
			if str(entry.get(key, "")).is_empty():
				problems.append("%s: missing %s" % [id, key])
	return problems
