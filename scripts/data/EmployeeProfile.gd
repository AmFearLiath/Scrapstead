class_name EmployeeProfile
extends Resource
## Data of a recruitable yard helper (P3a, docs/first-employee.md): who they
## are, what they cost and how fast they work. One fixed role profile, no
## skill tree, no needs simulation.

@export var id: String = ""
@export var name_key: String = ""
@export var role_key: String = ""
@export var description_key: String = ""
## Paid once when hiring (gloves). Never refunded.
@export var hire_fee: int = 10
## Wage per item the employee sells. Taken from that sale's proceeds only,
## so the employee can never cost money the yard has not earned.
@export var wage_per_item: int = 1
## Item categories the employee is allowed to carry and sell.
@export var allowed_categories: PackedStringArray = ["loose_scrap"]
## Category of broken devices he takes to the dismantling station first
## (if the player allows it); carried alone, one per trip.
@export var device_category: String = "device"
## Items of this carry size or more are heavy: he moves them only with a
## cart from the catalog, alone, and fetches the cart himself first.
@export var heavy_carry_size: int = 3
## Catalog ware that provides the cart for heavy items.
@export var cart_upgrade: String = "upgrade_handcart"
## Factor on a station's processing time ("good on his feet, less so with tools").
@export var tool_time_factor: float = 1.5
## Items per trip.
@export var carry_capacity: int = 2
@export var move_speed: float = 2.4
@export var pick_seconds: float = 0.6
@export var sell_seconds: float = 0.9
## Items within this distance of the drop-off spot belong to the work area.
@export var work_radius: float = 1.7
## Arrivals at the drop-off spot before the person shows up at the gate.
@export var appear_after_deliveries: int = 2
## Prefix of the localized one-liners ("<prefix>.<event>.<n>").
@export var line_prefix: String = ""
## Seconds between two idle remarks.
@export var idle_line_seconds: float = 45.0


func validate() -> PackedStringArray:
	var problems: PackedStringArray = []
	if id.is_empty() or name_key.is_empty():
		problems.append("employee needs an id and a name")
	if hire_fee < 0 or wage_per_item < 0:
		problems.append("%s: negative costs" % id)
	if carry_capacity < 1 or move_speed <= 0.0:
		problems.append("%s: cannot carry or move" % id)
	return problems
