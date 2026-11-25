extends SceneTree
## Development tool: generates the Old Yard blockout and the placeholder
## models as scene files, so the geometry stays reproducible and reviewable.
##
## Run from the project root:
##   godot --headless --path . -s res://tools/build_blockout.gd
##
## Generated files (do not edit by hand, change this script instead):
##   scenes/world/YardBlockout.tscn
##   assets/objects/*.tscn
##
## Coordinates in this script follow docs/p0-gameplay-blockout.md (layout
## coordinates): origin at the south-west corner, +X = east, +Z = north,
## 1 unit = 1 m, plot 48 x 36 m. Godot is right-handed with -Z as "forward",
## so the yard is written with world Z = -layout Z (north = -Z). Without this
## mapping the yard would be mirrored. See docs/decision-log.md.

const PLOT_W: float = 48.0
const PLOT_D: float = 36.0
const LAYER_WORLD: int = 1

## Flat ground surfaces get no ink outline.
const NO_OUTLINE: PackedStringArray = ["ground", "ground_outside", "gravel", "concrete", "paint_line"]

var _materials: Dictionary = {}
var _toon_shader: Shader = load("res://assets/shaders/toon.gdshader")
var _outline_material: Material = load("res://assets/materials/outline.tres")
var _rng := RandomNumberGenerator.new()
## True while building the yard: layout coordinates are mirrored to world Z.
var _mirror_z: bool = false


func _init() -> void:
	_rng.seed = 7_31_2026
	_build_materials()
	var ok: bool = true
	_mirror_z = true
	ok = _save(_build_yard(), "res://scenes/world/YardBlockout.tscn") and ok
	_mirror_z = false
	ok = _save(_build_bolt(), "res://assets/objects/scrap_rusted_bolt.tscn") and ok
	ok = _save(_build_can(), "res://assets/objects/scrap_empty_can.tscn") and ok
	ok = _save(_build_wire_coil(), "res://assets/objects/scrap_wire_coil.tscn") and ok
	ok = _save(_build_radio(), "res://assets/objects/device_broken_radio.tscn") and ok
	ok = _save(_build_copper_spool(), "res://assets/objects/mat_copper_wire.tscn") and ok
	ok = _save(_build_electronic_parts(), "res://assets/objects/mat_electronic_parts.tscn") and ok
	ok = _save(_build_dismantle_table(), "res://assets/objects/dismantle_table.tscn") and ok
	ok = _save(_build_floodlight(), "res://assets/objects/floodlight.tscn") and ok
	ok = _save(_build_wood_offcut(), "res://assets/objects/scrap_wood_offcut.tscn") and ok
	ok = _save(_build_copper_pipe(), "res://assets/objects/scrap_copper_pipe.tscn") and ok
	ok = _save(_build_brass_figurine(), "res://assets/objects/find_brass_figurine.tscn") and ok
	ok = _save(_build_equipment_crowbar(), "res://assets/objects/equipment_crowbar.tscn") and ok
	ok = _save(_build_equipment_hoist(), "res://assets/objects/equipment_hoist.tscn") and ok
	ok = _save(_build_equipment_handcart(), "res://assets/objects/equipment_handcart.tscn") and ok
	print("build_blockout: ", "done" if ok else "FAILED")
	quit(0 if ok else 1)


# --- Materials ---------------------------------------------------------------

func _build_materials() -> void:
	_mat("ground", Color("8c7a5b"))
	_mat("ground_outside", Color("6e6448"))
	_mat("gravel", Color("b5a27c"))
	_mat("concrete", Color("a09a8c"))
	_mat("paint_line", Color("e0a93b"))
	_mat("wood", Color("7a5a3c"))
	_mat("wood_light", Color("a4805a"))
	_mat("wood_dark", Color("4e3a28"))
	_mat("corrugated", Color("7f8c8f"), 0.55, 0.6)
	_mat("wall_teal", Color("5f7c7a"))
	_mat("roof_rust", Color("b35a2a"))
	_mat("brick", Color("9a5b45"))
	_mat("steel", Color("8a8f92"), 0.5, 0.7)
	_mat("steel_dark", Color("4c5357"), 0.6, 0.6)
	_mat("rust", Color("9a4a22"), 0.85, 0.3)
	_mat("rust_light", Color("c8642d"), 0.8, 0.3)
	_mat("copper", Color("c77b45"), 0.35, 0.9)
	_mat("mustard", Color("e0a93b"))
	_mat("teal", Color("3e8a86"))
	_mat("cream", Color("f2e6cf"))
	_mat("red", Color("b8402f"))
	_mat("skin", Color("e8c29a"))
	_mat("dark", Color("2b211b"))
	_mat("tyre", Color("2e2b29"), 0.95)
	_mat("glass", Color("bfe0e6"), 0.1, 0.0)
	_mat("plant", Color("6f8a4a"))
	_mat("brass", Color("c9a248"), 0.35, 0.85)
	_mat("toolbox", Color("6d7f5e"), 0.7, 0.2)
	var lens := StandardMaterial3D.new()
	lens.albedo_color = Color("fff3c4")
	lens.emission_enabled = true
	lens.emission = Color("ffe9a8")
	lens.emission_energy_multiplier = 0.0
	lens.resource_local_to_scene = true
	_materials["lens"] = lens


func _mat(key: String, color: Color, _roughness: float = 0.9, _metallic: float = 0.0) -> void:
	# All blockout geometry uses the shared toon shader (docs/world-art-assets.md).
	var material := ShaderMaterial.new()
	material.shader = _toon_shader
	material.set_shader_parameter("albedo", color)
	if not NO_OUTLINE.has(key):
		material.next_pass = _outline_material
	_materials[key] = material


# --- Primitive helpers -------------------------------------------------------

## Adds a box whose bottom-center sits at `base`.
func _box(parent: Node3D, node_name: String, base: Vector3, size: Vector3, material_key: String,
		collide: bool = false, yaw_deg: float = 0.0, extra_rotation: Vector3 = Vector3.ZERO) -> Node3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var shape := BoxShape3D.new()
	shape.size = size
	return _place(parent, node_name, base + Vector3(0, size.y * 0.5, 0), mesh, shape if collide else null,
		material_key, yaw_deg, extra_rotation)


## Adds an upright cylinder whose bottom-center sits at `base`.
func _cyl(parent: Node3D, node_name: String, base: Vector3, radius: float, height: float,
		material_key: String, collide: bool = false, segments: int = 12,
		extra_rotation: Vector3 = Vector3.ZERO) -> Node3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	var shape: CylinderShape3D = null
	if collide:
		shape = CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
	return _place(parent, node_name, base + Vector3(0, height * 0.5, 0), mesh, shape, material_key, 0.0,
		extra_rotation)


func _place(parent: Node3D, node_name: String, center: Vector3, mesh: Mesh, shape: Shape3D,
		material_key: String, yaw_deg: float, extra_rotation: Vector3) -> Node3D:
	var rotation := _mirror_rotation(Vector3(deg_to_rad(extra_rotation.x),
		deg_to_rad(yaw_deg + extra_rotation.y), deg_to_rad(extra_rotation.z)))
	center = _mirror(center)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _materials[material_key]
	if shape == null:
		mesh_instance.name = node_name
		mesh_instance.position = center
		mesh_instance.rotation = rotation
		_attach(parent, mesh_instance)
		return mesh_instance
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	body.position = center
	body.rotation = rotation
	_attach(parent, body)
	mesh_instance.name = "Mesh"
	_attach(body, mesh_instance)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	_attach(body, collision)
	return body


func _group(parent: Node, node_name: String, position: Vector3 = Vector3.ZERO, yaw_deg: float = 0.0) -> Node3D:
	var node := Node3D.new()
	node.name = node_name
	node.position = _mirror(position)
	node.rotation = _mirror_rotation(Vector3(0, deg_to_rad(yaw_deg), 0))
	_attach(parent, node)
	return node


## Instances an imported model (e.g. a Blender .glb) under `parent`.
func _model(parent: Node3D, node_name: String, path: String) -> Node3D:
	var instance: Node3D = load(path).instantiate()
	instance.name = node_name
	_attach(parent, instance)
	return instance


## Adds an invisible collision box (bottom-center at `base`).
func _barrier(parent: Node3D, node_name: String, base: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	body.position = _mirror(base + Vector3(0, size.y * 0.5, 0))
	_attach(parent, body)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	_attach(body, collision)


## Layout -> world position (see header).
func _mirror(value: Vector3) -> Vector3:
	return Vector3(value.x, value.y, -value.z) if _mirror_z else value


## Mirroring across the XY plane negates rotations about X and Y.
func _mirror_rotation(value: Vector3) -> Vector3:
	return Vector3(-value.x, -value.y, value.z) if _mirror_z else value


func _attach(parent: Node, child: Node) -> void:
	parent.add_child(child)
	var root: Node = parent if parent.owner == null else parent.owner
	child.owner = root


func _save(root: Node, path: String) -> bool:
	_set_owner_recursive(root, root)
	var packed := PackedScene.new()
	var error: Error = packed.pack(root)
	if error == OK:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
		error = ResourceSaver.save(packed, path)
	root.free()
	if error != OK:
		push_error("build_blockout: could not save %s (%s)" % [path, error_string(error)])
		return false
	print("  wrote ", path)
	return true


func _set_owner_recursive(node: Node, root: Node) -> void:
	for child: Node in node.get_children():
		child.owner = root
		# Instanced scenes keep their own internals.
		if child.scene_file_path.is_empty():
			_set_owner_recursive(child, root)


# --- Old Yard ----------------------------------------------------------------

func _build_yard() -> Node3D:
	var root := Node3D.new()
	root.name = "YardBlockout"
	var ground := _group(root, "Ground")
	var boundaries := _group(root, "Boundaries")
	var walls := _group(root, "Walls")
	var obstacles := _group(root, "Obstacles")
	var markings := _group(root, "Markings")
	_build_ground(ground, markings)
	_build_boundaries(boundaries)
	_build_walls(walls)
	_build_obstacles(obstacles)
	return root


func _build_ground(ground: Node3D, markings: Node3D) -> void:
	_box(ground, "Plot", Vector3(PLOT_W * 0.5, -0.3, PLOT_D * 0.5), Vector3(PLOT_W, 0.3, PLOT_D), "ground", true)
	_box(ground, "Surroundings", Vector3(PLOT_W * 0.5, -0.32, PLOT_D * 0.5), Vector3(PLOT_W + 60, 0.3, PLOT_D + 60),
		"ground_outside")
	# Main path 3 m: gate -> sales area -> workshop front -> open work area.
	_box(markings, "MainPathGate", Vector3(8, 0, 6.25), Vector3(3, 0.02, 12.5), "gravel")
	_box(markings, "MainPathEast", Vector3(24, 0, 12), Vector3(34, 0.02, 3), "gravel")
	# Side paths 2 m to storage zone A and scrap yard B.
	_box(markings, "SidePathStorage", Vector3(19, 0, 18.5), Vector3(2, 0.021, 13), "gravel")
	_box(markings, "SidePathNorth", Vector3(26, 0, 24), Vector3(16, 0.021, 2), "gravel")
	# Reserved machine pad in zone D (later magnet collector, P3b).
	_pad_outline(markings, Vector3(36, 0, 12.5), Vector2(5, 4))
	# Concrete apron in front of the sales counter.
	_box(markings, "SalesApron", Vector3(11.5, 0, 5.5), Vector3(6, 0.025, 5), "concrete")


func _pad_outline(parent: Node3D, center: Vector3, size: Vector2) -> void:
	var t: float = 0.12
	_box(parent, "PadN", center + Vector3(0, 0, size.y * 0.5), Vector3(size.x, 0.03, t), "paint_line")
	_box(parent, "PadS", center - Vector3(0, 0, size.y * 0.5), Vector3(size.x, 0.03, t), "paint_line")
	_box(parent, "PadE", center + Vector3(size.x * 0.5, 0, 0), Vector3(t, 0.03, size.y), "paint_line")
	_box(parent, "PadW", center - Vector3(size.x * 0.5, 0, 0), Vector3(t, 0.03, size.y), "paint_line")


func _build_boundaries(boundaries: Node3D) -> void:
	# North and east fences are tall (behind the play area from the camera);
	# south and west fences are low so they do not hide the yard.
	_fence_run(boundaries, "FenceNorth", Vector3(0, 0, PLOT_D), Vector3(PLOT_W, 0, PLOT_D), 2.0)
	_fence_run(boundaries, "FenceEast", Vector3(PLOT_W, 0, 0), Vector3(PLOT_W, 0, PLOT_D), 2.0)
	_fence_run(boundaries, "FenceWest", Vector3(0, 0, 0), Vector3(0, 0, PLOT_D), 0.9)
	_fence_run(boundaries, "FenceSouthWest", Vector3(0, 0, 0), Vector3(5.5, 0, 0), 0.9)
	_fence_run(boundaries, "FenceSouthEast", Vector3(10.5, 0, 0), Vector3(PLOT_W, 0, 0), 0.9)
	# Gate: two posts and an opened gate leaf; the opening itself is blocked
	# invisibly because leaving the plot is not part of the prototype.
	_box(boundaries, "GatePostWest", Vector3(5.5, 0, 0), Vector3(0.3, 2.2, 0.3), "steel_dark", true)
	_box(boundaries, "GatePostEast", Vector3(10.5, 0, 0), Vector3(0.3, 2.2, 0.3), "steel_dark", true)
	_box(boundaries, "GateLeaf", Vector3(4.2, 0, -1.3), Vector3(2.6, 1.4, 0.08), "steel", false, 70.0)
	_box(boundaries, "GateSign", Vector3(8, 2.0, 0), Vector3(5.3, 0.5, 0.12), "rust_light")
	_barrier(boundaries, "BarrierSouth", Vector3(PLOT_W * 0.5, 0, -0.35), Vector3(PLOT_W + 2, 3, 0.5))
	_barrier(boundaries, "BarrierNorth", Vector3(PLOT_W * 0.5, 0, PLOT_D + 0.35), Vector3(PLOT_W + 2, 3, 0.5))
	_barrier(boundaries, "BarrierWest", Vector3(-0.35, 0, PLOT_D * 0.5), Vector3(0.5, 3, PLOT_D + 2))
	_barrier(boundaries, "BarrierEast", Vector3(PLOT_W + 0.35, 0, PLOT_D * 0.5), Vector3(0.5, 3, PLOT_D + 2))


func _fence_run(parent: Node3D, node_name: String, from: Vector3, to: Vector3, height: float) -> void:
	var run := _group(parent, node_name)
	var length: float = from.distance_to(to)
	var direction: Vector3 = (to - from).normalized()
	var yaw: float = rad_to_deg(atan2(direction.x, direction.z)) + 90.0
	var panel_count: int = maxi(1, int(round(length / 4.0)))
	var panel_length: float = length / panel_count
	for index: int in panel_count:
		var center: Vector3 = from + direction * (panel_length * (index + 0.5))
		var material_key: String = "corrugated" if (index % 3 != 1) else "wood"
		var panel_height: float = height * (0.92 + 0.08 * float((index * 7) % 3))
		_box(run, "Panel%d" % index, center, Vector3(panel_length - 0.05, panel_height, 0.08), material_key, false, yaw)
		_box(run, "Post%d" % index, from + direction * (panel_length * index), Vector3(0.14, height + 0.2, 0.14),
			"wood_dark")


func _build_walls(walls: Node3D) -> void:
	# Office / workshop shed, zone C (9 x 6 m) and sales kiosk, zone E: modelled
	# in Blender (tools/blender/build_props.py); collision stays simple here.
	var shed := _group(walls, "WorkshopShed", Vector3(8.5, 0, 18))
	_model(shed, "Model", "res://assets/models/workshop_shed.glb")
	_barrier(shed, "Collision", Vector3.ZERO, Vector3(9.1, 3.2, 6.1))
	var kiosk := _group(walls, "SalesKiosk", Vector3(14.5, 0, 6))
	_model(kiosk, "Model", "res://assets/models/sales_kiosk.glb")
	_barrier(kiosk, "Collision", Vector3.ZERO, Vector3(3.0, 2.6, 4.0))
	# Free-standing brick wall segment between workshop and storage (4 m).
	_box(walls, "WallSegment", Vector3(6, 0, 24), Vector3(4, 1.8, 0.4), "brick", true)
	# Posts / girders forming a 1.5 m pinch point along the storage side path.
	for index: int in 4:
		_box(walls, "Girder%d" % index, Vector3(21.0, 0, 14.5 + index * 1.75), Vector3(0.25, 2.4, 0.25),
			"steel_dark", true)


func _build_obstacles(obstacles: Node3D) -> void:
	# Zone A - old storage: crates, barrels, a shelf, a small scrap pile.
	var storage := _group(obstacles, "StorageZoneA")
	_crate_stack(storage, "Crates1", Vector3(4, 0, 30), 3)
	_crate_stack(storage, "Crates2", Vector3(8.5, 0, 32.5), 2)
	_box(storage, "Shelf", Vector3(13.5, 0, 34.2), Vector3(3, 2.2, 1), "wood_dark", true)
	for index: int in 3:
		_box(storage, "ShelfBoard%d" % index, Vector3(13.5, 0.5 + index * 0.6, 34.1), Vector3(2.8, 0.06, 0.8),
			"wood_light")
	for index: int in 4:
		_cyl(storage, "Barrel%d" % index, Vector3(14.5 + (index % 2) * 0.9, 0, 28 + (index / 2) * 0.9), 0.4, 1.1,
			"rust" if index % 2 == 0 else "teal", true)
	_scrap_heap(storage, "SmallScrapPile", Vector3(9.5, 0, 27.5), Vector2(3, 3), 1.2, 10)
	# Zone B - wild scrap yard: large heap, small heap, a car shell, engine block.
	var yard := _group(obstacles, "ScrapYardB")
	_scrap_heap(yard, "LargeScrapHeap", Vector3(34, 0, 28.5), Vector2(5, 4), 2.4, 26)
	_scrap_heap(yard, "SmallScrapHeap", Vector3(42, 0, 23.5), Vector2(3, 3), 1.4, 12)
	_car_shell(yard, Vector3(26.5, 0, 31))
	_box(yard, "EngineBlock", Vector3(40.5, 0, 31.5), Vector3(1.4, 0.9, 1.0), "steel_dark", true, 20.0)
	_box(yard, "Container", Vector3(44.5, 0, 31), Vector3(2.5, 2.6, 6.0), "rust_light", true)
	# Zone D - open work area: pallets near the reserved machine pad.
	var work := _group(obstacles, "WorkAreaD")
	_box(work, "Pallet1", Vector3(28, 0, 16.5), Vector3(1.2, 0.15, 1.0), "wood_light", true)
	_box(work, "Pallet2", Vector3(28, 0.15, 16.5), Vector3(1.2, 0.15, 1.0), "wood_light", false, 8.0)
	_box(work, "Tyres", Vector3(42.5, 0, 8), Vector3(0.9, 0.3, 0.9), "tyre", true)
	_cyl(work, "TyreStack", Vector3(43.8, 0, 9.3), 0.45, 0.9, "tyre", true, 14)
	# Walt's self-driving wheelbarrow, parked and "thinking" next to the side path.
	var barrow := _group(obstacles, "WaltsWheelbarrow", Vector3(16.2, 0, 22.8), -110.0)
	_model(barrow, "Model", "res://assets/models/deco_wheelbarrow.glb")
	_barrier(barrow, "Collision", Vector3(0.1, 0, 0), Vector3(2.0, 1.0, 0.9))
	# Zone E - entrance decoration (no collision for tiny items).
	var entrance := _group(obstacles, "EntranceE")
	_cyl(entrance, "Planter", Vector3(3, 0, 9), 0.5, 0.5, "wood_dark", true)
	_cyl(entrance, "Shrub", Vector3(3, 0.5, 9), 0.45, 0.5, "plant")


func _crate_stack(parent: Node3D, node_name: String, base: Vector3, count: int) -> void:
	var stack := _group(parent, node_name, base)
	for index: int in count:
		var offset := Vector3(float(index % 2) * 1.15, 0, float(index / 2) * 1.15)
		_box(stack, "Crate%d" % index, offset, Vector3(1.1, 1.0, 1.1), "wood", true, float(index * 9))
	if count > 1:
		_box(stack, "CrateTop", Vector3(0.5, 1.0, 0.2), Vector3(0.9, 0.8, 0.9), "wood_light", false, 25.0)


func _scrap_heap(parent: Node3D, node_name: String, center: Vector3, footprint: Vector2, height: float,
		pieces: int) -> void:
	var heap := _group(parent, node_name, center)
	# One collision volume for the whole heap keeps movement predictable.
	_barrier(heap, "Collision", Vector3.ZERO, Vector3(footprint.x * 0.85, height, footprint.y * 0.85))
	_box(heap, "Core", Vector3.ZERO, Vector3(footprint.x * 0.8, height * 0.55, footprint.y * 0.8), "rust")
	var keys: Array[String] = ["rust", "steel", "rust_light", "steel_dark", "corrugated", "wood"]
	for index: int in pieces:
		var t: float = float(index) / float(pieces)
		var radius: float = (1.0 - t * 0.7) * 0.5
		var angle: float = _rng.randf() * TAU
		var offset := Vector3(cos(angle) * footprint.x * radius, height * t * 0.75, sin(angle) * footprint.y * radius)
		var size := Vector3(_rng.randf_range(0.4, 1.4), _rng.randf_range(0.15, 0.6), _rng.randf_range(0.3, 1.1))
		var tilt := Vector3(_rng.randf_range(-25, 25), 0, _rng.randf_range(-25, 25))
		_box(heap, "Piece%d" % index, offset, size, keys[index % keys.size()], false, _rng.randf_range(0, 180), tilt)


func _car_shell(parent: Node3D, base: Vector3) -> void:
	var car := _group(parent, "CarShell", base, 12.0)
	_box(car, "Body", Vector3.ZERO + Vector3(0, 0.25, 0), Vector3(1.8, 0.8, 4.0), "teal", false)
	_box(car, "Cabin", Vector3(0, 1.05, -0.2), Vector3(1.6, 0.65, 2.0), "teal")
	_box(car, "Windscreen", Vector3(0, 1.08, 0.82), Vector3(1.5, 0.55, 0.05), "glass", false, 0.0, Vector3(-25, 0, 0))
	_barrier(car, "Collision", Vector3.ZERO, Vector3(1.9, 1.7, 4.1))
	for index: int in 4:
		var x: float = -0.95 if index % 2 == 0 else 0.95
		var z: float = -1.3 if index < 2 else 1.3
		_cyl(car, "Wheel%d" % index, Vector3(x, 0.0, z), 0.35, 0.25, "tyre", false, 12, Vector3(0, 0, 90))


# --- Characters and props ----------------------------------------------------
# Model forward is local +Z. Origin is on the floor.



func _build_bolt() -> Node3D:
	var root := Node3D.new()
	root.name = "RustedBolt"
	_cyl(root, "Shaft", Vector3(0, 0.05, -0.18), 0.045, 0.36, "rust", false, 8, Vector3(90, 0, 0))
	_cyl(root, "Head", Vector3(0, 0.05, 0.12), 0.11, 0.07, "rust_light", false, 6, Vector3(90, 0, 0))
	return root


func _build_can() -> Node3D:
	var root := Node3D.new()
	root.name = "EmptyCan"
	_cyl(root, "Body", Vector3(-0.14, 0.11, 0), 0.11, 0.28, "steel", false, 12, Vector3(0, 0, 90))
	_cyl(root, "Label", Vector3(-0.08, 0.11, 0), 0.113, 0.16, "red", false, 12, Vector3(0, 0, 90))
	return root


func _build_wire_coil() -> Node3D:
	var root := Node3D.new()
	root.name = "WireCoil"
	for index: int in 3:
		var torus := TorusMesh.new()
		torus.inner_radius = 0.13 + index * 0.012
		torus.outer_radius = 0.2 + index * 0.012
		torus.rings = 16
		torus.ring_segments = 8
		_place(root, "Loop%d" % index, Vector3(0.02 * index, 0.04 + index * 0.035, 0), torus, null, "copper", 0.0,
			Vector3(4 * index, 0, -6 * index))
	return root




func _build_radio() -> Node3D:
	var root := Node3D.new()
	root.name = "BrokenRadio"
	_box(root, "Case", Vector3.ZERO, Vector3(0.55, 0.34, 0.26), "wood_light", false, 0.0, Vector3(0, 0, 4))
	_cyl(root, "Speaker", Vector3(-0.1, 0.17, 0.13), 0.1, 0.02, "dark", false, 14, Vector3(90, 0, 0))
	_box(root, "Dial", Vector3(0.15, 0.12, 0.135), Vector3(0.16, 0.1, 0.02), "cream")
	_cyl(root, "Antenna", Vector3(0.2, 0.34, -0.05), 0.012, 0.45, "steel", false, 6, Vector3(0, 0, -30))
	return root


func _build_copper_spool() -> Node3D:
	var root := Node3D.new()
	root.name = "CopperSpool"
	_cyl(root, "Core", Vector3(0, 0.03, 0), 0.13, 0.2, "copper", false, 14)
	_cyl(root, "FlangeBottom", Vector3(0, 0, 0), 0.18, 0.03, "wood_dark", false, 14)
	_cyl(root, "FlangeTop", Vector3(0, 0.23, 0), 0.18, 0.03, "wood_dark", false, 14)
	return root


func _build_electronic_parts() -> Node3D:
	var root := Node3D.new()
	root.name = "ElectronicParts"
	_box(root, "Board", Vector3.ZERO, Vector3(0.36, 0.03, 0.26), "plant", false, 12.0)
	_box(root, "Chip1", Vector3(-0.06, 0.03, 0.02), Vector3(0.1, 0.03, 0.07), "dark", false, 12.0)
	_box(root, "Chip2", Vector3(0.09, 0.03, -0.04), Vector3(0.07, 0.04, 0.07), "dark", false, 12.0)
	_cyl(root, "Capacitor", Vector3(0.1, 0.03, 0.07), 0.025, 0.08, "teal", false, 8)
	_box(root, "Tube", Vector3(-0.12, 0.0, -0.12), Vector3(0.12, 0.08, 0.1), "glass", false, 30.0)
	return root






func _build_dismantle_table() -> Node3D:
	var root := Node3D.new()
	root.name = "DismantleTable"
	_box(root, "Top", Vector3(0, 0.8, 0), Vector3(1.8, 0.1, 1.0), "steel")
	for index: int in 4:
		var x: float = -0.8 if index % 2 == 0 else 0.8
		var z: float = -0.4 if index < 2 else 0.4
		_box(root, "Leg%d" % index, Vector3(x, 0, z), Vector3(0.08, 0.8, 0.08), "steel_dark")
	_box(root, "Mat", Vector3(-0.2, 0.9, 0.05), Vector3(0.9, 0.02, 0.6), "teal")
	_box(root, "Screwdriver", Vector3(0.55, 0.9, 0.1), Vector3(0.35, 0.04, 0.04), "red", false, 30.0)
	_box(root, "BinCopper", Vector3(1.25, 0, 0.0), Vector3(0.5, 0.45, 0.5), "copper")
	_box(root, "BinParts", Vector3(-1.25, 0, 0.0), Vector3(0.5, 0.45, 0.5), "teal")
	_cyl(root, "Lamp", Vector3(-0.7, 0.9, -0.35), 0.03, 0.6, "steel_dark", false, 6)
	_box(root, "LampHead", Vector3(-0.55, 1.45, -0.3), Vector3(0.25, 0.1, 0.15), "mustard")
	return root




func _build_floodlight() -> Node3D:
	var root := Node3D.new()
	root.name = "Floodlight"
	_box(root, "Foot", Vector3.ZERO, Vector3(0.6, 0.2, 0.6), "concrete")
	_cyl(root, "Pole", Vector3(0, 0.2, 0), 0.07, 3.4, "steel_dark", false, 8)
	_box(root, "SwitchBox", Vector3(0, 1.0, 0.1), Vector3(0.22, 0.3, 0.12), "mustard")
	var head := _group(root, "Head", Vector3(0, 3.55, 0.2))
	head.rotation.x = deg_to_rad(35)
	_box(head, "Housing", Vector3.ZERO, Vector3(0.6, 0.35, 0.3), "steel_dark")
	_box(head, "Lens", Vector3(0, 0.05, 0.16), Vector3(0.5, 0.25, 0.02), "lens")
	return root


# --- P1 deepening: finds, sources, office, equipment ------------------------

func _build_wood_offcut() -> Node3D:
	var root := Node3D.new()
	root.name = "WoodOffcut"
	_box(root, "Plank", Vector3.ZERO, Vector3(0.55, 0.07, 0.16), "wood_light", false, 15.0)
	_box(root, "Chunk", Vector3(0.05, 0.07, 0.08), Vector3(0.25, 0.08, 0.12), "wood", false, -30.0)
	return root


func _build_copper_pipe() -> Node3D:
	var root := Node3D.new()
	root.name = "CopperPipe"
	_cyl(root, "Pipe", Vector3(0, 0.05, -0.05), 0.045, 0.6, "copper", false, 10, Vector3(0, 20, 90))
	_cyl(root, "Elbow", Vector3(0.28, 0.05, 0.05), 0.055, 0.12, "copper", false, 10, Vector3(90, 0, 0))
	return root


func _build_brass_figurine() -> Node3D:
	var root := Node3D.new()
	root.name = "BrassFigurine"
	_cyl(root, "Base", Vector3.ZERO, 0.1, 0.04, "brass", false, 12)
	var body := CapsuleMesh.new()
	body.radius = 0.05
	body.height = 0.2
	_place(root, "Body", Vector3(0, 0.14, 0), body, null, "brass", 0.0, Vector3.ZERO)
	var head := SphereMesh.new()
	head.radius = 0.045
	head.height = 0.09
	_place(root, "Head", Vector3(0, 0.28, 0), head, null, "brass", 0.0, Vector3.ZERO)
	# It holds a tiny figurine of itself.
	_cyl(root, "TinyFigure", Vector3(0.07, 0.16, 0.03), 0.015, 0.06, "brass", false, 6)
	return root










func _build_equipment_crowbar() -> Node3D:
	var root := Node3D.new()
	root.name = "CrowbarRack"
	_box(root, "Post", Vector3.ZERO, Vector3(0.1, 1.3, 0.1), "wood_dark")
	_box(root, "Hook", Vector3(0, 1.15, 0.08), Vector3(0.05, 0.05, 0.12), "steel_dark")
	_box(root, "Bar", Vector3(0, 0.35, 0.14), Vector3(0.05, 0.85, 0.05), "red", false, 0.0, Vector3(0, 0, 6))
	_box(root, "Claw", Vector3(0.04, 0.32, 0.14), Vector3(0.14, 0.05, 0.05), "red", false, 0.0, Vector3(0, 0, -25))
	return root


func _build_equipment_hoist() -> Node3D:
	var root := Node3D.new()
	root.name = "Hoist"
	for index: int in 3:
		var angle: float = index * 120.0
		var foot := Vector3(sin(deg_to_rad(angle)) * 0.55, 0, cos(deg_to_rad(angle)) * 0.55)
		_box(root, "Leg%d" % index, foot, Vector3(0.07, 1.9, 0.07), "steel_dark", false, angle,
			Vector3(-17, 0, 0))
	_box(root, "Block", Vector3(0, 1.5, 0), Vector3(0.22, 0.25, 0.14), "mustard")
	_box(root, "Chain", Vector3(0, 0.75, 0), Vector3(0.03, 0.75, 0.03), "steel")
	_box(root, "Hook", Vector3(0, 0.65, 0), Vector3(0.12, 0.1, 0.04), "steel_dark")
	return root


func _build_equipment_handcart() -> Node3D:
	var root := Node3D.new()
	root.name = "Handcart"
	_box(root, "Bed", Vector3(0, 0.38, 0), Vector3(0.8, 0.08, 1.2), "teal")
	_box(root, "SideL", Vector3(-0.4, 0.42, 0), Vector3(0.04, 0.25, 1.2), "teal")
	_box(root, "SideR", Vector3(0.4, 0.42, 0), Vector3(0.04, 0.25, 1.2), "teal")
	_box(root, "Handle", Vector3(0, 0.5, -0.85), Vector3(0.6, 0.05, 0.05), "wood_dark")
	_box(root, "ArmL", Vector3(-0.3, 0.45, -0.7), Vector3(0.04, 0.04, 0.35), "wood_dark")
	_box(root, "ArmR", Vector3(0.3, 0.45, -0.7), Vector3(0.04, 0.04, 0.35), "wood_dark")
	_cyl(root, "WheelL", Vector3(-0.47, 0.0, 0.15), 0.25, 0.08, "tyre", false, 14, Vector3(0, 0, 90))
	_cyl(root, "WheelR", Vector3(0.47, 0.0, 0.15), 0.25, 0.08, "tyre", false, 14, Vector3(0, 0, 90))
	_box(root, "Stand", Vector3(0, 0, 0.5), Vector3(0.06, 0.38, 0.06), "steel_dark")
	return root
