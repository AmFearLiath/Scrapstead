extends Node3D
## Presentation-only world effects (docs/world-art-assets.md): dust puffs,
## items flying into the basket, coins popping from the counter. Effects are
## short-lived nodes driven by tweens; they never touch gameplay state.

const DUST_COLOR: Color = Color("c8b38c")
const COIN_COLOR: Color = Color("e0a93b")
const SPARK_COLOR: Color = Color("ffd36b")

var _dust_material: ShaderMaterial
var _coin_material: ShaderMaterial
var _spark_material: StandardMaterial3D
var _dust_mesh: SphereMesh
var _coin_mesh: CylinderMesh
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var toon: Shader = load("res://assets/shaders/toon.gdshader")
	_dust_material = ShaderMaterial.new()
	_dust_material.shader = toon
	_dust_material.set_shader_parameter("albedo", DUST_COLOR)
	_coin_material = ShaderMaterial.new()
	_coin_material.shader = toon
	_coin_material.set_shader_parameter("albedo", COIN_COLOR)
	_coin_material.next_pass = load("res://assets/materials/outline.tres")
	_spark_material = StandardMaterial3D.new()
	_spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_spark_material.albedo_color = SPARK_COLOR
	_dust_mesh = SphereMesh.new()
	_dust_mesh.radius = 0.5
	_dust_mesh.height = 1.0
	_dust_mesh.radial_segments = 8
	_dust_mesh.rings = 4
	_coin_mesh = CylinderMesh.new()
	_coin_mesh.top_radius = 0.07
	_coin_mesh.bottom_radius = 0.07
	_coin_mesh.height = 0.025
	_coin_mesh.radial_segments = 12


## Soft dust puffs around a point on the ground.
func dust(world_position: Vector3, amount: int = 6, size: float = 0.16) -> void:
	for index: int in amount:
		var puff := MeshInstance3D.new()
		puff.mesh = _dust_mesh
		puff.material_override = _dust_material
		puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(puff)
		var angle: float = TAU * float(index) / float(amount) + _rng.randf_range(-0.3, 0.3)
		var direction := Vector3(cos(angle), 0, sin(angle))
		puff.global_position = world_position + direction * 0.1 + Vector3(0, 0.05, 0)
		puff.scale = Vector3.ONE * size * 0.4
		var tween: Tween = puff.create_tween().set_parallel()
		tween.tween_property(puff, "global_position",
			puff.global_position + direction * _rng.randf_range(0.25, 0.5) + Vector3(0, _rng.randf_range(0.1, 0.3), 0),
			0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(puff, "scale", Vector3.ONE * size, 0.2).set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(puff, "scale", Vector3.ONE * 0.01, 0.3).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(puff.queue_free)


## Flies a copy of an item's visual in an arc to a moving target, then calls
## `on_arrival`. The original item is already hidden by its own state change.
func fly_to(visual: Node3D, target: Callable, on_arrival: Callable = Callable()) -> void:
	if visual == null or not target.is_valid():
		return
	var copy: Node3D = visual.duplicate()
	add_child(copy)
	copy.global_transform = visual.global_transform
	copy.visible = true
	var tween: Tween = copy.create_tween()
	tween.tween_method(_fly_step.bind(copy, copy.global_position, copy.scale, target), 0.0, 1.0, 0.42) 		.set_ease(Tween.EASE_IN_OUT)
	# Arrival first: the tween belongs to the copy and dies with it.
	if on_arrival.is_valid():
		tween.tween_callback(on_arrival)
	tween.tween_callback(copy.queue_free)


func _fly_step(t: float, copy: Node3D, start: Vector3, start_scale: Vector3, target: Callable) -> void:
	var end: Vector3 = target.call()
	copy.global_position = start.lerp(end, t) + Vector3(0, sin(t * PI) * 0.9, 0)
	copy.rotation.y += 0.25
	copy.scale = start_scale * lerpf(1.0, 0.45, t)


## Coins popping up and falling back, e.g. after a sale.
func coins(world_position: Vector3, count: int) -> void:
	for index: int in clampi(count, 3, 24):
		var coin := MeshInstance3D.new()
		coin.mesh = _coin_mesh
		coin.material_override = _coin_material
		add_child(coin)
		coin.global_position = world_position + Vector3(0, 1.1, 0)
		var direction := Vector3(_rng.randf_range(-1, 1), 0, _rng.randf_range(-1, 1)).normalized()
		var arc := Vector3(_rng.randf_range(0.2, 0.7), _rng.randf_range(0.6, 1.2), 0)
		var tween: Tween = coin.create_tween()
		tween.tween_interval(index * 0.03)
		tween.tween_method(_coin_step.bind(coin, coin.global_position, direction, arc), 0.0, 1.0, 0.7)
		tween.tween_property(coin, "scale", Vector3.ONE * 0.01, 0.15)
		tween.tween_callback(coin.queue_free)


## arc.x = horizontal distance, arc.y = height.
func _coin_step(t: float, coin: Node3D, start: Vector3, direction: Vector3, arc: Vector3) -> void:
	coin.global_position = start + direction * arc.x * t + Vector3(0, sin(t * PI) * arc.y - t * 0.9, 0)
	coin.rotation = Vector3(t * 9.0, t * 6.0, 0)


## Bright little sparks jumping out of a point (welding, repairs).
func sparks(world_position: Vector3, count: int = 14) -> void:
	for index: int in count:
		var spark := MeshInstance3D.new()
		spark.mesh = _dust_mesh
		spark.material_override = _spark_material
		spark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(spark)
		spark.global_position = world_position
		spark.scale = Vector3.ONE * _rng.randf_range(0.035, 0.07)
		var angle: float = _rng.randf() * TAU
		var direction := Vector3(cos(angle), _rng.randf_range(0.6, 1.4), sin(angle)) * _rng.randf_range(0.6, 1.3)
		var duration: float = _rng.randf_range(0.3, 0.55)
		var tween: Tween = spark.create_tween()
		tween.tween_method(_spark_step.bind(spark, world_position, direction), 0.0, 1.0, duration)
		tween.tween_callback(spark.queue_free)


func _spark_step(t: float, spark: Node3D, start: Vector3, direction: Vector3) -> void:
	if not is_instance_valid(spark):
		return
	spark.global_position = start + direction * t + Vector3(0, -1.6 * t * t, 0)
	spark.scale = spark.scale.lerp(Vector3.ONE * 0.005, 0.08)
