extends SceneTree
## Development tool: generates the Old Yard scene (ground, paths, collision and
## the placement of the Blender models from tools/blender/build_props.py), so
## the layout stays reproducible and reviewable.
##
## Run from the project root:
##   godot --headless --path . -s res://tools/build_blockout.gd
##
## Generated file (do not edit by hand, change this script instead):
##   scenes/world/YardBlockout.tscn
##
## Coordinates in this script follow docs/p0-gameplay-blockout.md (layout
## coordinates): origin at the south-west corner, +X = east, +Z = north,
## 1 unit = 1 m, plot 48 x 36 m. Godot is right-handed with -Z as "forward",
## so the yard is written with world Z = -layout Z (north = -Z). Without this
## mapping the yard would be mirrored. See docs/decision-log.md.

const PLOT_W: float = 48.0
const PLOT_D: float = 36.0
const LAYER_WORLD: int = 1

var _materials: Dictionary = {}
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
	# Art style 2 (docs/art-style-2.md): the ground uses the desert sand shader.
	_materials["ground"] = load("res://assets/materials/ground_sand.tres")
	_materials["ground_outside"] = load("res://assets/materials/ground_outer.tres")
	_materials["gravel"] = load("res://assets/materials/ground_path.tres")
	_materials["concrete"] = load("res://assets/materials/ground_concrete.tres")


func _mat(key: String, color: Color, roughness: float = 0.9, metallic: float = 0.0) -> void:
	# Plain lit material in art style 2 (docs/art-style-2.md); models carry
	# their own baked textures, blockout geometry is only posts and helpers.
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
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
	# Concrete apron in front of the sales counter.
	_box(markings, "SalesApron", Vector3(11.5, 0, 5.5), Vector3(6, 0.025, 5), "concrete")


func _build_boundaries(boundaries: Node3D) -> void:
	# North and east fences are tall (behind the play area from the camera);
	# south and west fences are low so they do not hide the yard.
	_fence_run(boundaries, "FenceNorth", Vector3(0, 0, PLOT_D), Vector3(PLOT_W, 0, PLOT_D), true)
	_fence_run(boundaries, "FenceEast", Vector3(PLOT_W, 0, 0), Vector3(PLOT_W, 0, PLOT_D), true)
	_fence_run(boundaries, "FenceWest", Vector3(0, 0, 0), Vector3(0, 0, PLOT_D), false)
	_fence_run(boundaries, "FenceSouthWest", Vector3(0, 0, 0), Vector3(5.5, 0, 0), false)
	_fence_run(boundaries, "FenceSouthEast", Vector3(10.5, 0, 0), Vector3(PLOT_W, 0, 0), false)
	# Gate with the gear sign; the opening itself is blocked invisibly because
	# leaving the plot is not part of the prototype.
	var gate := _group(boundaries, "Gate", Vector3(8, 0, 0))
	_model(gate, "Model", "res://assets/models/gate.glb")
	_barrier(gate, "PostWest", Vector3(-2.5, 0, 0), Vector3(0.35, 2.3, 0.35))
	_barrier(gate, "PostEast", Vector3(2.5, 0, 0), Vector3(0.35, 2.3, 0.35))
	_barrier(boundaries, "BarrierSouth", Vector3(PLOT_W * 0.5, 0, -0.35), Vector3(PLOT_W + 2, 3, 0.5))
	_barrier(boundaries, "BarrierNorth", Vector3(PLOT_W * 0.5, 0, PLOT_D + 0.35), Vector3(PLOT_W + 2, 3, 0.5))
	_barrier(boundaries, "BarrierWest", Vector3(-0.35, 0, PLOT_D * 0.5), Vector3(0.5, 3, PLOT_D + 2))
	_barrier(boundaries, "BarrierEast", Vector3(PLOT_W + 0.35, 0, PLOT_D * 0.5), Vector3(0.5, 3, PLOT_D + 2))


## Fence panels (4 m models) scaled to fit the run exactly, variants mixed.
func _fence_run(parent: Node3D, node_name: String, from: Vector3, to: Vector3, tall: bool) -> void:
	var run := _group(parent, node_name)
	var length: float = from.distance_to(to)
	var direction: Vector3 = (to - from).normalized()
	var yaw: float = rad_to_deg(atan2(direction.x, direction.z)) + 90.0
	var panel_count: int = maxi(1, int(round(length / 4.0)))
	var panel_length: float = length / panel_count
	var variants: PackedStringArray = ["a", "a", "b", "c"] if tall else ["a", "b", "a", "c"]
	for index: int in panel_count:
		var center: Vector3 = from + direction * (panel_length * (index + 0.5))
		var panel := _group(run, "Panel%d" % index, center, yaw)
		var variant: String = variants[(index * 5 + int(from.x + from.z)) % variants.size()]
		var model: Node3D = _model(panel, "Model", "res://assets/models/fence_%s_%s.glb" % [
			"tall" if tall else "low", variant])
		model.scale = Vector3(panel_length / 4.0, 1.0, 1.0)
	_box(run, "EndPost", to, Vector3(0.14, 2.1 if tall else 1.0, 0.14), "wood_dark")


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
	_prop(walls, "WallSegment", "brick_wall", Vector3(6, 0, 24), 0.0, Vector3(4, 1.9, 0.4))
	# Posts / girders forming a 1.5 m pinch point along the storage side path.
	for index: int in 4:
		_prop(walls, "Girder%d" % index, "girder", Vector3(21.0, 0, 14.5 + index * 1.75), 0.0,
			Vector3(0.3, 2.4, 0.3))


func _build_obstacles(obstacles: Node3D) -> void:
	# Zone A - old storage: crates, barrels, a shelf, a small scrap pile.
	var storage := _group(obstacles, "StorageZoneA")
	_prop(storage, "Crates1", "crate_stack", Vector3(4, 0, 30), 0.0, Vector3(2.3, 1.9, 1.2), Vector3(0.57, 0, 0))
	_prop(storage, "Crates2", "crate_stack", Vector3(8.5, 0, 32.5), 180.0, Vector3(2.3, 1.9, 1.2),
		Vector3(0.57, 0, 0))
	_prop(storage, "Shelf", "storage_shelf", Vector3(13.5, 0, 34.2), 0.0, Vector3(3.0, 2.2, 1.0))
	_prop(storage, "Barrels", "barrel_group", Vector3(14.5, 0, 28), 0.0, Vector3(1.8, 1.2, 1.8),
		Vector3(0.45, 0, 0.45))
	_prop(storage, "SmallScrapPile", "scrap_heap_pile", Vector3(9.5, 0, 27.5), 0.0, Vector3(2.55, 1.2, 2.55))
	# Zone B - wild scrap yard: large heap, small heap, a car wreck, engine block.
	var yard := _group(obstacles, "ScrapYardB")
	_prop(yard, "LargeScrapHeap", "scrap_heap_large", Vector3(34, 0, 28.5), 0.0, Vector3(4.25, 2.4, 3.4))
	_prop(yard, "SmallScrapHeap", "scrap_heap_small", Vector3(42, 0, 23.5), 0.0, Vector3(2.55, 1.4, 2.55))
	_prop(yard, "CarWreck", "car_wreck", Vector3(26.5, 0, 31), 12.0, Vector3(1.9, 1.7, 4.1))
	_prop(yard, "EngineBlock", "engine_block", Vector3(40.5, 0, 31.5), 20.0, Vector3(1.4, 0.9, 1.0))
	_prop(yard, "Container", "container", Vector3(44.5, 0, 31), 0.0, Vector3(2.5, 2.6, 6.0))
	# Zone D - open work area: pallets near the reserved machine pad, tyres.
	var work := _group(obstacles, "WorkAreaD")
	_prop(work, "Pallets", "pallet_stack", Vector3(28, 0, 16.5), 8.0, Vector3(1.2, 0.5, 1.0))
	_prop(work, "Tyres", "tyre_stack", Vector3(42.6, 0, 8.6), 0.0, Vector3(1.0, 0.7, 1.0))
	# Walt's self-driving wheelbarrow, parked and "thinking" next to the side path.
	_prop(obstacles, "WaltsWheelbarrow", "deco_wheelbarrow", Vector3(16.2, 0, 22.8), -110.0, Vector3(2.0, 1.0, 0.9),
		Vector3(0.1, 0, 0))
	# Zone E - entrance: Walt's bathtub planter.
	_prop(obstacles, "Planter", "bathtub_planter", Vector3(3, 0, 9), 90.0, Vector3(1.5, 0.75, 0.8))
	_scatter_weeds(obstacles)


## Places a Blender model with a simple box collision (layout coordinates).
func _prop(parent: Node3D, node_name: String, model: String, base: Vector3, yaw: float, collision: Vector3,
		collision_offset: Vector3 = Vector3.ZERO) -> Node3D:
	var group := _group(parent, node_name, base, yaw)
	_model(group, "Model", "res://assets/models/%s.glb" % model)
	_barrier(group, "Collision", collision_offset, collision)
	return group


## Deterministic grass tufts along the fences and in quiet corners; no collision,
## never on paths or the interaction spots near the entrance.
func _scatter_weeds(parent: Node3D) -> void:
	var weeds := _group(parent, "Weeds")
	var spots: Array[Vector3] = []
	for index: int in 24:
		spots.append(Vector3(1.5 + index * 1.9 + _rng.randf_range(-0.5, 0.5), 0, 35.3 - _rng.randf_range(0, 0.4)))
	for index: int in 17:
		spots.append(Vector3(47.3 - _rng.randf_range(0, 0.4), 0, 1.5 + index * 2.0 + _rng.randf_range(-0.5, 0.5)))
		spots.append(Vector3(0.6 + _rng.randf_range(0, 0.4), 0, 1.5 + index * 2.0 + _rng.randf_range(-0.5, 0.5)))
	for index: int in 20:
		var x: float = 12.0 + index * 1.8 + _rng.randf_range(-0.4, 0.4)
		spots.append(Vector3(x, 0, 0.7 + _rng.randf_range(0, 0.3)))
	for center: Vector3 in [Vector3(4.2, 0, 15.2), Vector3(13.2, 0, 20.5), Vector3(16.8, 0, 7.8),
			Vector3(31.5, 0, 26.0), Vector3(37.5, 0, 30.5), Vector3(24.0, 0, 33.5), Vector3(45.0, 0, 27.5)]:
		for index: int in 4:
			spots.append(center + Vector3(_rng.randf_range(-0.9, 0.9), 0, _rng.randf_range(-0.6, 0.6)))
	var variants: PackedStringArray = ["weed_a", "weed_a", "weed_b", "weed_c"]
	for index: int in spots.size():
		var spot: Vector3 = spots[index]
		var tuft := _group(weeds, "Weed%d" % index, spot, _rng.randf_range(0, 360))
		var model: Node3D = _model(tuft, "Model", "res://assets/models/%s.glb" % variants[index % variants.size()])
		model.scale = Vector3.ONE * _rng.randf_range(0.8, 1.4)






