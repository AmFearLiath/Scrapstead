"""Generates the placeable data (data/placeables/*.tres) and their simple
scenes (scenes/placeables/*.tscn) for the build menu (docs/building-system.md).

Each entry: id, category, price, size in 0.5 m cells, height, model, model
offset (to centre the model on its footprint), solid. Run from the project root:
    python tools/make_placeables.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PROPS = [
    # id, category, price, size, height, model, offset (x, z), solid
    ("storage_pallets", "storage", 6, (3, 2), 0.6, "pallet_stack", (0.0, 0.0), True),
    ("storage_crates", "storage", 8, (5, 3), 1.9, "crate_stack", (-0.57, 0.0), True),
    ("storage_barrels", "storage", 8, (4, 4), 1.2, "barrel_group", (-0.45, 0.45), True),
    ("paths_fence_low", "paths", 6, (8, 1), 1.0, "fence_low_a", (0.0, 0.0), True),
    ("decor_planter", "decor", 15, (3, 2), 0.8, "bathtub_planter", (0.0, 0.0), True),
    ("decor_floodlight", "decor", 20, (2, 2), 3.5, "floodlight", (0.0, 0.0), True),
    ("decor_tyres", "decor", 5, (2, 2), 0.7, "tyre_stack", (0.0, 0.0), True),
    ("decor_wheelbarrow", "decor", 12, (4, 2), 1.0, "deco_wheelbarrow", (-0.1, 0.0), True),
    ("decor_gnome", "decor", 9, (1, 1), 0.7, "decor_scrap_gnome", (0.0, 0.0), True),
    ("decor_bench", "decor", 14, (4, 2), 0.9, "decor_tyre_bench", (0.0, 0.0), True),
    ("decor_flamingo", "decor", 7, (1, 1), 1.0, "decor_pipe_flamingo", (0.0, 0.0), True),
]


def write(path, text):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def prop_scene(model, offset):
    return f'''[gd_scene format=3]

[ext_resource type="PackedScene" path="res://assets/models/{model}.glb" id="1_model"]

[node name="Placeable" type="Node3D"]

[node name="Model" parent="." instance=ExtResource("1_model")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {offset[0]}, 0, {offset[1]})
'''


GRAVEL_SCENE = '''[gd_scene format=3]

[sub_resource type="StandardMaterial3D" id="gravel"]
albedo_color = Color(0.72, 0.66, 0.55, 1)
roughness = 1.0

[sub_resource type="BoxMesh" id="tile"]
material = SubResource("gravel")
size = Vector3(0.98, 0.03, 0.98)

[sub_resource type="StandardMaterial3D" id="pebble"]
albedo_color = Color(0.55, 0.5, 0.42, 1)
roughness = 1.0

[sub_resource type="SphereMesh" id="pebble_mesh"]
material = SubResource("pebble")
radius = 0.05
height = 0.06
radial_segments = 6
rings = 3

[node name="Placeable" type="Node3D"]

[node name="Tile" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.016, 0)
mesh = SubResource("tile")

[node name="PebbleA" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.22, 0.035, 0.18)
mesh = SubResource("pebble_mesh")

[node name="PebbleB" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.27, 0.035, -0.12)
mesh = SubResource("pebble_mesh")

[node name="PebbleC" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.05, 0.035, 0.31)
mesh = SubResource("pebble_mesh")
'''


def definition(pid, category, price, size, height, scene, solid, extra=""):
    return f'''[gd_resource type="Resource" script_class="PlaceableDefinition" load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/build/PlaceableDefinition.gd" id="1_def"]
[ext_resource type="PackedScene" path="res://{scene}" id="2_scene"]

[resource]
script = ExtResource("1_def")
id = "{pid}"
name_key = "placeable.{pid}.name"
description_key = "placeable.{pid}.description"
category = "{category}"
price = {price}
scene = ExtResource("2_scene")
size = Vector2i({size[0]}, {size[1]})
solid = {"true" if solid else "false"}
height = {height}
{extra}'''


def main():
    ids = []
    for pid, category, price, size, height, model, offset, solid in PROPS:
        write(f"scenes/placeables/{pid}.tscn", prop_scene(model, offset))
        write(f"data/placeables/{pid}.tres", definition(pid, category, price, size, height,
                                                       f"scenes/placeables/{pid}.tscn", solid))
        ids.append(pid)
    write("scenes/placeables/paths_gravel.tscn", GRAVEL_SCENE)
    write("data/placeables/paths_gravel.tres", definition("paths_gravel", "paths", 2, (2, 2), 0.05,
                                                          "scenes/placeables/paths_gravel.tscn", False))
    ids.insert(4, "paths_gravel")
    # The magnetic collector: bought as catalog ware, footprint covers machine and crate.
    write("data/placeables/magnet_collector.tres", '''[gd_resource type="Resource" script_class="PlaceableDefinition" load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/build/PlaceableDefinition.gd" id="1_def"]
[ext_resource type="PackedScene" path="res://scenes/machines/MagnetCollector.tscn" id="2_scene"]

[resource]
script = ExtResource("1_def")
id = "magnet_collector"
name_key = "machine.magnet_collector.name"
description_key = "placeable.magnet_collector.description"
category = "machines"
price = 60
unlock_ware = "machine_magnet_collector"
max_count = 1
scene = ExtResource("2_scene")
size = Vector2i(4, 7)
clearance = Array[Rect2i]([Rect2i(0, 7, 4, 1)])
work_radius = 2.8
solid = true
height = 1.4
ports = Array[Dictionary]([{"cell": Vector2i(1, 6), "kind": "out"}])
''')
    ids.insert(0, "magnet_collector")
    entries = ", ".join(f'ExtResource("{i + 2}")' for i in range(len(ids)))
    ext = "\n".join(f'[ext_resource type="Resource" path="res://data/placeables/{pid}.tres" id="{i + 2}"]'
                    for i, pid in enumerate(ids))
    write("data/placeables/placeable_catalog.tres", f'''[gd_resource type="Resource" script_class="PlaceableCatalog" format=3]

[ext_resource type="Script" path="res://scripts/build/PlaceableCatalog.gd" id="1_catalog"]
[ext_resource type="Script" path="res://scripts/build/PlaceableDefinition.gd" id="1_def"]
{ext}

[resource]
script = ExtResource("1_catalog")
placeables = Array[ExtResource("1_def")]([{entries}])
''')
    print("placeables:", len(ids))


main()
