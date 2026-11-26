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
## He took a device apart at the station (presentation, story).
signal dismantled(input: ScrapItem, outputs: Array)
## A one-liner (localization key) for his speech bubble.
signal remark(line_key: String)

enum Presence { ABSENT, AVAILABLE, HIRED }
enum Task { IDLE, TO_ITEM, PICKING, TO_COUNTER, SELLING, TO_REST, TO_STATION, DISMANTLING, TO_CART, TO_CART_RETURN }

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
	"resumed": 2, "dismissed": 1, "refuses": 1, "dismantles": 2, "needs_cart": 1, "takes_cart": 2}

@export var profile: EmployeeProfile
## Where he waits to be hired, by the gate.
@export var wait_spot: Marker3D
## Where he waits for work once hired.
@export var rest_spot: Marker3D
## Marker3D children in walking order from the drop-off spot to the counter.
@export var route_root: Node3D
## Where he stands to sell (in front of the counter).
@export var counter_spot: Marker3D
@export_group("Dismantling")
## Station he takes broken devices to; optional.
@export var dismantle_station: DismantleStation
## Marker3D children from the main route towards the station, in order.
@export var station_route_root: Node3D
## Where he stands at the station.
@export var station_spot: Marker3D
@export_group("Cart")
## Marker3D children from the main route towards the cart's parking spot.
@export var cart_route_root: Node3D
## Where he picks up and returns the cart.
@export var cart_spot: Marker3D
## The bought cart standing at its parking spot (hidden while he uses it).
@export var cart_display: Node3D
## Cart model he pushes (instanced in front of him while in use).
@export var cart_scene: PackedScene

## Read by the presentation-only PlayerAnimator.
var move_speed: float = 2.4

var _presence: Presence = Presence.ABSENT
var _paused: bool = false
## Player's rule: take broken devices to the station before selling them.
var _dismantle_devices: bool = true
var _upgrades: UpgradeProgress
## He is pushing the cart.
var _has_cart: bool = false
var _cart_visual: Node3D
## A heavy item waits on the pallet but the yard owns no cart.
var _missing_cart: bool = false
## Waypoint graph: positions and neighbour lists (built on first use).
var _nodes: Array[Vector3] = []
var _edges: Array = []
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
var _stats: Dictionary = {"trips": 0, "items": 0, "revenue": 0, "wages": 0, "dismantled": 0}
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


## Optional: lets him use bought tools (the cart).
func set_upgrades(upgrades: UpgradeProgress) -> void:
	_upgrades = upgrades


func has_cart() -> bool:
	return _has_cart


## True while a heavy item waits that he could only move with a cart.
func is_missing_cart() -> bool:
	return _missing_cart and _presence == Presence.HIRED


func is_heavy(item: ScrapItem) -> bool:
	return item != null and item.definition != null and item.definition.carry_size >= profile.heavy_carry_size


func _owns_cart() -> bool:
	return _upgrades != null and _upgrades.is_owned(profile.cart_upgrade) and cart_spot != null


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
	if _task in [Task.TO_ITEM, Task.PICKING, Task.TO_COUNTER, Task.SELLING, Task.TO_STATION, Task.DISMANTLING,
			Task.TO_CART, Task.TO_CART_RETURN]:
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


## Whether broken devices are dismantled before they are sold.
func is_dismantling_devices() -> bool:
	return _dismantle_devices


## True when the yard has a station he could take devices to.
func can_dismantle() -> bool:
	return dismantle_station != null and station_spot != null


## Toggles the dismantling rule. Returns a result for the panel.
func toggle_dismantling() -> Dictionary:
	_dismantle_devices = not _dismantle_devices
	return Interactable.make_result(true, "ui.staff.dismantle_on" if _dismantle_devices else "ui.staff.dismantle_off",
		{"name": get_display_name()})


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
	_set_cart(false)
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
		"dismantle": _dismantle_devices, "cart": _has_cart, "stats": _stats.duplicate()}
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
	_dismantle_devices = bool(data.get("dismantle", true))
	_set_cart(bool(data.get("cart", false)) and _presence == Presence.HIRED)
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
		Task.TO_ITEM, Task.TO_COUNTER, Task.TO_REST, Task.TO_STATION, Task.TO_CART, Task.TO_CART_RETURN:
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
		Task.DISMANTLING:
			_timer -= delta
			if _timer <= 0.0:
				_finish_dismantling()
		Task.IDLE:
			_idle(delta)
	var horizontal := Vector3(velocity.x, 0, velocity.z).move_toward(target_velocity, 12.0 * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravity * delta
	move_and_slide()
	_face(delta, horizontal)
	if _has_cart and cart_display != null and cart_display.visible:
		# The catalog shows bought wares; the cart is with him right now.
		cart_display.visible = false
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
	var device: ScrapItem = _carried_device()
	if device != null and _wants_dismantling(device):
		_arrive_distance = 0.2
		_path = _path_to(station_spot.global_position)
		_task = Task.TO_STATION
		return
	if device == null and not _carries_heavy() and _carrying.size() < profile.carry_capacity:
		var item: ScrapItem = _find_item(not _carrying.is_empty())
		if item != null and is_heavy(item) and not _has_cart:
			_arrive_distance = 0.25
			_path = _path_to(cart_spot.global_position)
			_task = Task.TO_CART
			_say("takes_cart")
			return
		if item != null:
			_target = item
			_arrive_distance = 0.55 if not _has_cart else 0.9
			_path = _path_to(item.global_position)
			_task = Task.TO_ITEM
			return
	if not _carrying.is_empty():
		_arrive_distance = 0.2
		_path = _path_to(_marker_position(counter_spot))
		_task = Task.TO_COUNTER
		return
	if _has_cart:
		_arrive_distance = 0.25
		_path = _path_to(cart_spot.global_position)
		_task = Task.TO_CART_RETURN
		return
	_walk_to(_marker_position(rest_spot), Task.TO_REST)


func _walk_to(point: Vector3, task: Task) -> void:
	_arrive_distance = 0.2
	_path = _path_to(point)
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
		Task.TO_CART:
			_set_cart(true)
			_next_task()
		Task.TO_CART_RETURN:
			_set_cart(false)
			_next_task()
		Task.TO_STATION:
			_task = Task.DISMANTLING
			_timer = dismantle_station.profile.seconds * profile.tool_time_factor
			_say("dismantles")
		Task.TO_REST:
			_task = Task.IDLE
			_idle_timer = 0.0
			_face_marker(wait_spot if _presence == Presence.AVAILABLE else rest_spot)


func _finish_pick() -> void:
	if _is_workable(_target) and _carrying.size() < profile.carry_capacity:
		_target.set_state(ScrapItem.State.CARRIED)
		_carrying.append(_target)
		picked_up.emit(_target)
		_update_cart_load()
	_next_task()


## Swaps the carried device for the station's outputs.
func _finish_dismantling() -> void:
	var device: ScrapItem = _carried_device()
	if device != null and dismantle_station != null:
		var outputs: Array[ScrapItem] = dismantle_station.dismantle_for_staff(device)
		if not outputs.is_empty():
			_carrying.erase(device)
			_carrying.append_array(outputs)
			_stats["dismantled"] += 1
			dismantled.emit(device, outputs)
	_next_task()


func _set_missing_cart(missing: bool) -> void:
	if missing == _missing_cart:
		return
	_missing_cart = missing
	if missing:
		_say("needs_cart")
	status_changed.emit(_status)


func _carries_heavy() -> bool:
	for item: ScrapItem in _carrying:
		if is_instance_valid(item) and is_heavy(item):
			return true
	return false


## Takes or parks the cart (state and the visible model).
func _set_cart(with_cart: bool) -> void:
	_has_cart = with_cart
	if cart_display != null:
		cart_display.visible = not with_cart and _owns_cart()
	if with_cart and _cart_visual == null and cart_scene != null:
		_cart_visual = cart_scene.instantiate()
		_cart_visual.name = "PushedCart"
		_visual_root.add_child(_cart_visual)
		_cart_visual.position = Vector3(0, 0, 0.85)
		_cart_visual.rotation.y = PI
	if _cart_visual != null:
		_cart_visual.visible = with_cart
	_update_cart_load()


## Heavy load lies visibly on the cart (presentation only).
func _update_cart_load() -> void:
	if _cart_visual == null:
		return
	var load_root: Node3D = _cart_visual.get_node_or_null("Load") as Node3D
	if load_root == null:
		load_root = Node3D.new()
		load_root.name = "Load"
		_cart_visual.add_child(load_root)
		load_root.position = Vector3(0, 0.55, 0)
	for child: Node in load_root.get_children():
		child.queue_free()
	for item: ScrapItem in _carrying:
		if is_instance_valid(item) and is_heavy(item) and item.definition.model != null:
			load_root.add_child(item.definition.model.instantiate())


func _carried_device() -> ScrapItem:
	for item: ScrapItem in _carrying:
		if is_instance_valid(item) and item.definition.category == profile.device_category:
			return item
	return null


func _wants_dismantling(device: ScrapItem) -> bool:
	return _dismantle_devices and can_dismantle() and dismantle_station.accepts(device)


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
	_update_cart_load()
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


## Nearest allowed item lying in the work area, or null. Devices travel
## alone, so they are skipped while he already carries something.
func _find_item(skip_devices: bool = false) -> ScrapItem:
	if _drop_off == null or profile == null:
		return null
	var best: ScrapItem
	var best_distance: float = INF
	var missing_cart: bool = false
	for target: Variant in _objects.values():
		var item: ScrapItem = target as ScrapItem
		if not _is_workable(item):
			continue
		if not profile.allowed_categories.has(item.definition.category):
			if not _refused.has(item.object_id):
				_refused[item.object_id] = true
				_say("refuses")
			continue
		if is_heavy(item) and not _owns_cart():
			missing_cart = true
			continue
		if skip_devices and (item.definition.category == profile.device_category or is_heavy(item)):
			continue
		var distance: float = item.global_position.distance_to(global_position)
		if distance < best_distance:
			best = item
			best_distance = distance
	_set_missing_cart(missing_cart)
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


## Waypoint graph: the main route (drop-off -> counter) as a chain, the
## station route as a branch joined at the nearest main waypoint.
func _build_graph() -> void:
	_nodes.clear()
	_edges.clear()
	var main: Array[Vector3] = _marker_points(route_root)
	main.append(_marker_position(counter_spot))
	_add_chain(main, -1)
	if station_route_root != null and station_spot != null:
		var branch: Array[Vector3] = _marker_points(station_route_root)
		branch.append(station_spot.global_position)
		var join: int = _nearest_node(branch[0], 0, main.size())
		_add_chain(branch, join)
	if cart_route_root != null and cart_spot != null:
		var cart_branch: Array[Vector3] = _marker_points(cart_route_root)
		cart_branch.append(cart_spot.global_position)
		_add_chain(cart_branch, _nearest_node(cart_branch[0], 0, main.size()))


func _add_chain(points: Array[Vector3], join: int) -> void:
	var previous: int = join
	for point: Vector3 in points:
		_nodes.append(point)
		_edges.append([])
		var index: int = _nodes.size() - 1
		if previous >= 0:
			_edges[index].append(previous)
			_edges[previous].append(index)
		previous = index


func _marker_points(root: Node3D) -> Array[Vector3]:
	var points: Array[Vector3] = []
	if root != null:
		for child: Node in root.get_children():
			if child is Marker3D:
				points.append((child as Marker3D).global_position)
	return points


func _nearest_node(point: Vector3, from: int = 0, to: int = -1) -> int:
	var best: int = from
	var best_distance: float = INF
	for index: int in range(from, _nodes.size() if to < 0 else to):
		var distance: float = _nodes[index].distance_to(point)
		if distance < best_distance:
			best = index
			best_distance = distance
	return best


## Waypoints from the node nearest to him to the node nearest to the target,
## then the target itself. Short hops skip the graph.
func _path_to(target: Vector3) -> Array[Vector3]:
	if _nodes.is_empty():
		_build_graph()
	var path: Array[Vector3] = []
	if _nodes.is_empty() or global_position.distance_to(target) < 2.5:
		path.append(target)
		return path
	var start: int = _nearest_node(global_position)
	var goal: int = _nearest_node(target)
	var parents: Dictionary = {start: -1}
	var queue: Array[int] = [start]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == goal:
			break
		for next: int in _edges[current]:
			if not parents.has(next):
				parents[next] = current
				queue.append(next)
	var chain: Array[Vector3] = []
	var node: int = goal
	while node != -1 and parents.has(node):
		chain.push_front(_nodes[node])
		node = parents[node]
	path.append_array(chain)
	path.append(target)
	return path


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
	elif _task == Task.DISMANTLING and station_spot != null:
		target_yaw = station_spot.global_rotation.y
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
