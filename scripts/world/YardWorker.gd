class_name YardWorker
extends CharacterBody3D
## The first employee (P3a, docs/first-employee.md): carries scrap from the
## drop-off spot to the sell counter and sells it there for a small wage.
##
## One role, one work area, one task. The player hires, pauses or dismisses
## him; he picks the concrete next item himself. He has no collision layer,
## so he can never block the player, and he squeezes past anything that
## holds him up for more than a moment, so he never blocks for long.
##
## Money only moves through the Wallet: the sale is credited, the wage is
## debited from that same sale. Animation never books anything.

signal presence_changed(presence: Presence)
signal status_changed(status: String)
## An item went into his crate (presentation: sound, fly effect).
signal picked_up(item: ScrapItem)
## A trip was sold at the counter.
signal sold(count: int, total: int, wage: int)
## A one-liner (localization key) for his speech bubble.
signal remark(line_key: String)

enum Presence { ABSENT, AVAILABLE, HIRED }
enum Task { IDLE, TO_ITEM, PICKING, TO_COUNTER, SELLING, TO_REST }

const PRESENCE_NAMES: PackedStringArray = ["absent", "available", "hired"]
const STATUS_WORKING := "working"
const STATUS_WAITING := "waiting"
const STATUS_BLOCKED := "blocked"
const STATUS_PAUSED := "paused"
## Seconds without progress before he counts as blocked.
const BLOCKED_AFTER := 0.9
## Seconds without progress before he squeezes past to his next waypoint.
const SQUEEZE_AFTER := 2.4
const STATUS_COLORS: Dictionary = {"working": Color(0.62, 0.85, 0.5), "waiting": Color(0.949, 0.902, 0.812),
	"blocked": Color(0.95, 0.45, 0.35), "paused": Color(0.88, 0.66, 0.23)}
## Event -> number of authored variants ("<line_prefix>.<event>.<n>").
const LINE_COUNTS: Dictionary = {"appear": 1, "hired": 1, "idle": 4, "first_sale": 1, "paused": 2,
	"resumed": 2, "dismissed": 1, "refuses": 1}

@export var profile: EmployeeProfile
## Where he waits to be hired, by the gate.
@export var wait_spot: Marker3D
## Where he waits for work once hired.
@export var rest_spot: Marker3D
## Marker3D children in walking order from the drop-off spot to the counter.
@export var route_root: Node3D
## Where he stands to sell (in front of the counter).
@export var counter_spot: Marker3D

## Read by the presentation-only PlayerAnimator.
var move_speed: float = 2.4

var _presence: Presence = Presence.ABSENT
var _paused: bool = false
var _task: Task = Task.IDLE
var _wallet: Wallet
var _objects: Dictionary = {}
var _drop_off: Node3D
var _carrying: Array[ScrapItem] = []
var _target: ScrapItem
var _path: Array[Vector3] = []
var _arrive_distance: float = 0.25
var _timer: float = 0.0
var _stuck_timer: float = 0.0
var _blocked: bool = false
var _seen: int = 0
var _stats: Dictionary = {"trips": 0, "items": 0, "revenue": 0, "wages": 0}
var _status: String = ""
var _idle_timer: float = 0.0
var _refused: Dictionary = {}
var _squeezes: int = 0
var _last_position: Vector3 = Vector3.INF
var _rng := RandomNumberGenerator.new()
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _visual_root: Node3D = $VisualRoot


func _ready() -> void:
	_rng.seed = 1912
	if profile != null:
		move_speed = profile.move_speed
	_apply_presence()


## `objects` is the scene's live registry (object ID -> Interactable).
func setup(wallet: Wallet, objects: Dictionary, drop_off: Node3D) -> void:
	_wallet = wallet
	_objects = objects
	_drop_off = drop_off


func get_presence() -> Presence:
	return _presence


func is_hired() -> bool:
	return _presence == Presence.HIRED


func is_paused() -> bool:
	return _paused


## "working", "waiting", "blocked" or "paused"; empty unless hired.
func get_status() -> String:
	if _presence != Presence.HIRED:
		return ""
	if _paused:
		return STATUS_PAUSED
	if _blocked:
		return STATUS_BLOCKED
	if _task in [Task.TO_ITEM, Task.PICKING, Task.TO_COUNTER, Task.SELLING]:
		return STATUS_WORKING
	return STATUS_WAITING


## Totals since the first hire: trips, items, revenue, wages (all ints).
func get_stats() -> Dictionary:
	return _stats.duplicate()


## How often he had to squeeze past an obstacle (route quality, tests).
func get_squeeze_count() -> int:
	return _squeezes


func get_carried_items() -> Array[ScrapItem]:
	return _carrying.duplicate()


func is_carrying(object_id: String) -> bool:
	for item: ScrapItem in _carrying:
		if is_instance_valid(item) and item.object_id == object_id:
			return true
	return false


func get_display_name() -> String:
	return tr(profile.name_key) if profile != null else ""


# --- Player decisions ---------------------------------------------------------

## Hires him for the profile's fee. Fails without change if unaffordable.
func hire() -> Dictionary:
	if _presence != Presence.AVAILABLE or _wallet == null:
		return Interactable.make_result(false, "ui.interaction.unavailable")
	var args: Dictionary = {"name": get_display_name(), "fee": profile.hire_fee}
	if profile.hire_fee > 0:
		if not _wallet.can_afford(profile.hire_fee):
			return Interactable.make_result(false, "ui.staff.cannot_afford", args)
		_wallet.debit(profile.hire_fee, _wallet.next_transaction_id("staff_hire"), "ui.ledger.staff_hire")
	_set_presence(Presence.HIRED)
	_paused = false
	_say("hired")
	_next_task()
	return Interactable.make_result(true, "ui.staff.hired", args)


## Pauses or resumes the work. He keeps what he carries.
func toggle_pause() -> Dictionary:
	if _presence != Presence.HIRED:
		return Interactable.make_result(false, "ui.interaction.unavailable")
	_paused = not _paused
	_path.clear()
	_blocked = false
	_say("paused" if _paused else "resumed")
	if not _paused:
		_next_task()
	else:
		_task = Task.IDLE
	return Interactable.make_result(true, "ui.staff.paused" if _paused else "ui.staff.resumed",
		{"name": get_display_name()})


## Ends the employment. Carried items go back onto the drop-off spot and he
## waits at the gate again, in case the player changes their mind.
func dismiss() -> Dictionary:
	if _presence != Presence.HIRED:
		return Interactable.make_result(false, "ui.interaction.unavailable")
	_return_carried_items()
	_paused = false
	_blocked = false
	_set_presence(Presence.AVAILABLE)
	_say("dismissed")
	_next_task()
	return Interactable.make_result(true, "ui.staff.dismissed", {"name": get_display_name()})


## Called by the scene for every new arrival at the drop-off spot.
func on_delivery_arrived() -> void:
	_seen += 1
	if _presence == Presence.ABSENT and profile != null and _seen >= profile.appear_after_deliveries:
		global_position = wait_spot.global_position if wait_spot != null else global_position
		_face_marker(wait_spot)
		reset_physics_interpolation()
		_set_presence(Presence.AVAILABLE)
		_say("appear")


# --- Save -----------------------------------------------------------------------

func get_save_state() -> Dictionary:
	var data: Dictionary = {"presence": PRESENCE_NAMES[_presence], "seen": _seen, "paused": _paused,
		"stats": _stats.duplicate()}
	if _presence != Presence.ABSENT:
		data["position"] = [snappedf(global_position.x, 0.001), snappedf(global_position.y, 0.001),
			snappedf(global_position.z, 0.001)]
		data["yaw"] = snappedf(_visual_root.rotation.y, 0.0001)
	var ids: Array = []
	for item: ScrapItem in _carrying:
		if is_instance_valid(item):
			ids.append(item.object_id)
	data["carrying"] = ids
	return data


## Call after the world object states were applied (carried items exist and
## are in state "carried") and before the player's basket is checked.
func apply_save_state(data: Dictionary) -> void:
	_seen = int(data.get("seen", 0))
	var saved_stats: Variant = data.get("stats", {})
	if typeof(saved_stats) == TYPE_DICTIONARY:
		for key: String in _stats:
			_stats[key] = int(saved_stats.get(key, 0))
	var presence: int = PRESENCE_NAMES.find(str(data.get("presence", "absent")))
	if presence == -1:
		presence = Presence.ABSENT
	if presence == Presence.ABSENT and profile != null and _seen >= profile.appear_after_deliveries:
		presence = Presence.AVAILABLE
	_presence = presence as Presence
	_paused = bool(data.get("paused", false)) and _presence == Presence.HIRED
	var saved_position: Variant = data.get("position")
	if typeof(saved_position) == TYPE_ARRAY and saved_position.size() == 3:
		global_position = Vector3(saved_position[0], saved_position[1], saved_position[2])
		_visual_root.rotation.y = float(data.get("yaw", 0.0))
	elif _presence != Presence.ABSENT and wait_spot != null:
		global_position = wait_spot.global_position
	reset_physics_interpolation()
	_carrying.clear()
	for object_id: Variant in data.get("carrying", []):
		var item: ScrapItem = _objects.get(str(object_id)) as ScrapItem
		if item != null and item.get_state() == ScrapItem.State.CARRIED:
			_carrying.append(item)
	if _presence != Presence.HIRED:
		_return_carried_items()
	_apply_presence()
	_next_task()


# --- Work loop ------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _presence == Presence.ABSENT:
		return
	var target_velocity := Vector3.ZERO
	if _task == Task.TO_REST and _presence == Presence.HIRED and not _paused and _find_item() != null:
		_next_task()
	match _task:
		Task.TO_ITEM, Task.TO_COUNTER, Task.TO_REST:
			target_velocity = _follow_path(delta)
			if _path.is_empty():
				_arrived()
		Task.PICKING:
			_timer -= delta
			if _timer <= 0.0:
				_finish_pick()
		Task.SELLING:
			_timer -= delta
			if _timer <= 0.0:
				_finish_sale()
		Task.IDLE:
			_idle(delta)
	var horizontal := Vector3(velocity.x, 0, velocity.z).move_toward(target_velocity, 12.0 * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravity * delta
	move_and_slide()
	_face(delta, horizontal)
	_update_status()


## Decides what to do next; only ever called when the last step finished.
func _next_task() -> void:
	_last_position = global_position
	_path.clear()
	_blocked = false
	_stuck_timer = 0.0
	_target = null
	if _presence == Presence.AVAILABLE:
		_walk_to(_marker_position(wait_spot), Task.TO_REST)
		return
	if _presence != Presence.HIRED or _paused:
		_task = Task.IDLE
		return
	if _carrying.size() < profile.carry_capacity:
		var item: ScrapItem = _find_item()
		if item != null:
			_target = item
			_arrive_distance = 0.55
			_path = _route_towards_drop_off(item.global_position)
			_task = Task.TO_ITEM
			return
	if not _carrying.is_empty():
		_arrive_distance = 0.2
		_path = _route_towards_counter()
		_task = Task.TO_COUNTER
		return
	_walk_to(_marker_position(rest_spot), Task.TO_REST)


func _walk_to(point: Vector3, task: Task) -> void:
	_arrive_distance = 0.2
	_path = _route_towards_drop_off(point)
	_task = task


func _arrived() -> void:
	match _task:
		Task.TO_ITEM:
			if _is_workable(_target):
				_task = Task.PICKING
				_timer = profile.pick_seconds
			else:
				_next_task()
		Task.TO_COUNTER:
			_task = Task.SELLING
			_timer = profile.sell_seconds
		Task.TO_REST:
			_task = Task.IDLE
			_idle_timer = 0.0
			_face_marker(wait_spot if _presence == Presence.AVAILABLE else rest_spot)


func _finish_pick() -> void:
	if _is_workable(_target) and _carrying.size() < profile.carry_capacity:
		_target.set_state(ScrapItem.State.CARRIED)
		_carrying.append(_target)
		picked_up.emit(_target)
	_next_task()


func _finish_sale() -> void:
	var count: int = 0
	var total: int = 0
	var items: Array[ScrapItem] = []
	for item: ScrapItem in _carrying:
		if is_instance_valid(item) and item.get_state() == ScrapItem.State.CARRIED:
			items.append(item)
			total += item.definition.sell_value
			count += 1
	_carrying.clear()
	if count > 0 and total > 0 and _wallet != null:
		var wage: int = mini(profile.wage_per_item * count, total)
		_wallet.credit(total, _wallet.next_transaction_id("staff_sale"), "ui.ledger.staff_sale")
		if wage > 0:
			_wallet.debit(wage, _wallet.next_transaction_id("staff_wage"), "ui.ledger.staff_wage")
		for item: ScrapItem in items:
			item.set_state(ScrapItem.State.SOLD)
		_stats["trips"] += 1
		_stats["items"] += count
		_stats["revenue"] += total
		_stats["wages"] += wage
		if _stats["trips"] == 1:
			_say("first_sale")
		sold.emit(count, total, wage)
	_next_task()


func _idle(delta: float) -> void:
	if _presence != Presence.HIRED:
		return
	if not _paused:
		if _find_item() != null:
			_next_task()
			return
	_idle_timer += delta
	if profile != null and _idle_timer >= profile.idle_line_seconds:
		_idle_timer = 0.0
		if not _paused:
			_say("idle")


## Nearest allowed item lying in the work area, or null.
func _find_item() -> ScrapItem:
	if _drop_off == null or profile == null:
		return null
	var best: ScrapItem
	var best_distance: float = INF
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if not _is_workable(item):
			continue
		if item.definition.category != profile.allowed_category:
			if not _refused.has(item.object_id):
				_refused[item.object_id] = true
				_say("refuses")
			continue
		var distance: float = item.global_position.distance_to(global_position)
		if distance < best_distance:
			best = item
			best_distance = distance
	return best


func _is_workable(item: ScrapItem) -> bool:
	if item == null or not is_instance_valid(item) or item.definition == null:
		return false
	if item.get_state() != ScrapItem.State.IN_WORLD or _drop_off == null:
		return false
	var offset: Vector3 = item.global_position - _drop_off.global_position
	offset.y = 0.0
	return offset.length() <= profile.work_radius


func _return_carried_items() -> void:
	var index: int = 0
	for item: ScrapItem in _carrying:
		if not is_instance_valid(item):
			continue
		var centre: Vector3 = _drop_off.global_position if _drop_off != null else global_position
		var angle: float = TAU * float(index) / 5.0 + 0.4
		item.drop_at(centre + Vector3(cos(angle), 0.0, sin(angle)) * 0.45 + Vector3(0, 0.13, 0), angle)
		index += 1
	_carrying.clear()


# --- Movement -------------------------------------------------------------------

func _follow_path(delta: float) -> Vector3:
	if _path.is_empty():
		return Vector3.ZERO
	var to_point: Vector3 = _path[0] - global_position
	to_point.y = 0.0
	var tolerance: float = _arrive_distance if _path.size() == 1 else 0.35
	if to_point.length() <= tolerance:
		_path.remove_at(0)
		_stuck_timer = 0.0
		_blocked = false
		return Vector3.ZERO
	var moved: Vector3 = global_position - _last_position
	moved.y = 0.0
	_last_position = global_position
	if moved.length() < move_speed * delta * 0.25:
		_stuck_timer += delta
	else:
		_stuck_timer = maxf(0.0, _stuck_timer - delta * 2.0)
	_blocked = _stuck_timer >= BLOCKED_AFTER
	if _stuck_timer >= SQUEEZE_AFTER:
		# Never stuck for good: squeeze past to the next waypoint.
		_squeezes += 1
		global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
		reset_physics_interpolation()
		_stuck_timer = 0.0
		_blocked = false
		_path.remove_at(0)
		return Vector3.ZERO
	return to_point.normalized() * minf(move_speed, to_point.length() * 4.0 + 0.6)


func _route_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	if route_root != null:
		for child: Node in route_root.get_children():
			if child is Marker3D:
				points.append((child as Marker3D).global_position)
	points.append(_marker_position(counter_spot))
	return points


## Remaining route to the counter, starting at the nearest route point.
func _route_towards_counter() -> Array[Vector3]:
	var points: Array[Vector3] = _route_points()
	var start: int = _nearest_index(points)
	return points.slice(start)


## Route back to the drop-off spot (if coming from the counter), then the point.
func _route_towards_drop_off(point: Vector3) -> Array[Vector3]:
	var path: Array[Vector3] = []
	if _is_nearer_to_counter():
		var points: Array[Vector3] = _route_points()
		points.reverse()
		path = points.slice(_nearest_index(points))
	path.append(point)
	return path


func _is_nearer_to_counter() -> bool:
	if _drop_off == null or counter_spot == null:
		return false
	return global_position.distance_to(counter_spot.global_position) \
		< global_position.distance_to(_drop_off.global_position)


func _nearest_index(points: Array[Vector3]) -> int:
	var best: int = 0
	var best_distance: float = INF
	for index: int in points.size():
		var distance: float = points[index].distance_to(global_position)
		if distance < best_distance:
			best = index
			best_distance = distance
	return best


func _marker_position(marker: Node3D) -> Vector3:
	return marker.global_position if marker != null else global_position


func _face(delta: float, horizontal: Vector3) -> void:
	var target_yaw: float = _visual_root.rotation.y
	if horizontal.length() > 0.3:
		target_yaw = atan2(horizontal.x, horizontal.z)
	elif _task in [Task.PICKING] and is_instance_valid(_target):
		var to_target: Vector3 = _target.global_position - global_position
		target_yaw = atan2(to_target.x, to_target.z)
	elif _task == Task.SELLING and counter_spot != null:
		target_yaw = counter_spot.global_rotation.y
	else:
		return
	_visual_root.rotation.y = lerp_angle(_visual_root.rotation.y, target_yaw, 1.0 - exp(-9.0 * delta))


func _face_marker(marker: Node3D) -> void:
	if marker != null:
		_visual_root.rotation.y = marker.global_rotation.y


# --- State helpers --------------------------------------------------------------

func _set_presence(presence: Presence) -> void:
	_presence = presence
	_apply_presence()
	presence_changed.emit(_presence)


func _apply_presence() -> void:
	visible = _presence != Presence.ABSENT
	var talk: CollisionObject3D = get_node_or_null("Talk") as CollisionObject3D
	if talk != null:
		talk.collision_layer = 0 if _presence == Presence.ABSENT else 4
		(talk as Interactable).interaction_state_changed.emit(talk)
	_update_status()
	_refresh_label()


func _update_status() -> void:
	var status: String = get_status()
	if status != _status:
		_status = status
		_refresh_label()
		status_changed.emit(status)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_label()


## Small status sign above his head (presentation only).
func _refresh_label() -> void:
	var label: Label3D = get_node_or_null("StatusLabel") as Label3D
	if label == null:
		return
	match _presence:
		Presence.AVAILABLE:
			label.text = tr("ui.staff.label_available")
			label.modulate = Color(0.949, 0.902, 0.812)
		Presence.HIRED:
			label.text = tr("ui.staff.status." + _status)
			label.modulate = STATUS_COLORS.get(_status, Color.WHITE)
		_:
			label.text = ""


func _say(event: String) -> void:
	if profile == null or profile.line_prefix.is_empty():
		return
	var count: int = int(LINE_COUNTS.get(event, 0))
	if count <= 0:
		return
	remark.emit("%s.%s.%d" % [profile.line_prefix, event, _rng.randi_range(1, count)])
