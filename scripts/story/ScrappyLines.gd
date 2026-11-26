class_name ScrappyLines
extends Resource
## Selection rules for Scrappy's lines (P2). The lines themselves are
## localization keys `scrappy.<event>.<n>` (n starts at 1).
##
## `events` maps an event name to a rule dictionary:
##   count     int    number of variants
##   chance    float  probability that the event is commented at all (0..1)
##   cooldown  float  seconds before the same event may speak again
##   once      bool   every variant is said at most once per save game
##   sequence  bool   all variants are said in order (wake-up)
##   priority  bool   may interrupt the global quiet gap
##
## `memories` lists protected Walt memories triggered by proximity:
##   {"line": key, "position": Vector3, "radius": float}

@export var events: Dictionary = {}
@export var memories: Array[Dictionary] = []
## Minimum quiet time between two unprompted lines.
@export var global_gap_seconds: float = 8.0
## Lines while idling: seconds between two attempts.
@export var idle_interval_seconds: float = 45.0


func get_rule(event: String) -> Dictionary:
	return events.get(event, {})


## Problems in the data (empty list = valid). Used by tests.
func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	for event: String in events:
		var rule: Dictionary = events[event]
		if int(rule.get("count", 0)) <= 0:
			problems.append("event '%s' has no variants" % event)
	for memory: Dictionary in memories:
		if not memory.has("line") or not memory.has("position"):
			problems.append("memory without line or position")
	return problems
