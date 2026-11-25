"""Scrapstead modelling kit for Blender 4.2 (docs/world-art-assets.md).

Small helpers to build stylised props from code: chunky bevelled primitives,
palette colours written as vertex colours, Walt's repair patches, tape and
oversized rivets, slight wonkiness, named state groups, glTF export and a
preview render that mimics the game camera.

Conventions: 1 unit = 1 m, origin at the floor centre, the front faces -Y
(becomes +Z, the model forward, in Godot).
"""
import math
import random

import bpy
import bmesh
from mathutils import Euler, Matrix, Vector

PALETTE = {
    "rust": "9a4a22", "rust_light": "c8642d", "mustard": "e0a93b", "cream": "f2e6cf",
    "moss": "6f8a4a", "teal": "3e8a86", "steel": "5e7c8c", "steel_light": "8fa3ab",
    "wood": "8a6440", "wood_light": "b08658", "wood_dark": "4e3a28", "sand": "b39a72",
    "soil": "8c7a5b", "ink": "2b211b", "plum": "5b4560", "red": "b8402f", "tyre": "2e2b29",
    "brass": "c9a248", "paper": "efe2c4", "glass": "a9cfd2", "green": "5c8a4e", "skin": "e3a77e",
}

_rng = random.Random(1974)


def seed(value: int) -> None:
    """Makes wonkiness and colour variation reproducible per asset."""
    _rng.seed(value)


def _linear(hex_value: str) -> tuple:
    srgb = [int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb)


def color(name: str, variation: float = 0.04) -> tuple:
    """Palette colour (linear) with a small random brightness variation."""
    base = _linear(PALETTE[name])
    factor = 1.0 + _rng.uniform(-variation, variation)
    return tuple(min(1.0, c * factor) for c in base) + (1.0,)


def reset_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.unit_settings.scale_length = 1.0


def _material() -> bpy.types.Material:
    """Single shared material; Godot replaces it with the toon material."""
    material = bpy.data.materials.get("Scrap")
    if material is not None:
        return material
    material = bpy.data.materials.new("Scrap")
    material.use_nodes = True
    nodes = material.node_tree.nodes
    bsdf = nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.9
    attribute = nodes.new("ShaderNodeVertexColor")
    attribute.layer_name = "Col"
    material.node_tree.links.new(attribute.outputs["Color"], bsdf.inputs["Base Color"])
    return material


def _finish(obj, colour_name, bevel, segments, jitter, variation=0.04):
    mesh = obj.data
    if jitter > 0.0:
        for vertex in mesh.vertices:
            vertex.co += Vector((_rng.uniform(-jitter, jitter) for _ in range(3)))
    if bevel > 0.0:
        bm = bmesh.new()
        bm.from_mesh(mesh)
        bmesh.ops.bevel(bm, geom=list(bm.edges), offset=bevel, segments=segments, profile=0.6,
                        affect="EDGES", clamp_overlap=True)
        bm.to_mesh(mesh)
        bm.free()
    attribute = mesh.color_attributes.new("Col", "FLOAT_COLOR", "CORNER")
    rgba = color(colour_name, variation)
    for data in attribute.data:
        data.color = rgba
    mesh.materials.append(_material())
    for polygon in mesh.polygons:
        polygon.use_smooth = False
    return obj


def _place(obj, name, location, rotation, parent):
    obj.name = name
    obj.location = location
    obj.rotation_euler = Euler([math.radians(a) for a in rotation])
    if parent is not None:
        obj.parent = parent
    return obj


def box(name, location, size, colour, rotation=(0, 0, 0), bevel=0.03, segments=2, jitter=0.0,
        parent=None, variation=0.04):
    """Bevelled box; `location` is the centre of the box."""
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector(size), verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    bevel = min(bevel, min(size) * 0.45)
    _finish(obj, colour, bevel, segments, jitter, variation)
    return _place(obj, name, location, rotation, parent)


def cylinder(name, location, radius, depth, colour, vertices=12, rotation=(0, 0, 0), bevel=0.02,
             segments=2, jitter=0.0, parent=None, radius_top=None, variation=0.04):
    """Bevelled cylinder (or cone when radius_top differs) centred at `location`."""
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=vertices, radius1=radius,
                          radius2=radius if radius_top is None else radius_top, depth=depth)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    bevel = min(bevel, depth * 0.4, radius * 0.4)
    _finish(obj, colour, bevel, segments, jitter, variation)
    return _place(obj, name, location, rotation, parent)


def sphere(name, location, radius, colour, segments=10, rings=6, scale=(1, 1, 1), parent=None):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segments, v_segments=rings, radius=radius)
    bmesh.ops.scale(bm, vec=Vector(scale), verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    _finish(obj, colour, 0.0, 1, 0.0)
    return _place(obj, name, location, (0, 0, 0), parent)


def torus(name, location, major, minor, colour, rotation=(0, 0, 0), parent=None, segments=16):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=segments,
                                     minor_segments=6)
    obj = bpy.context.object
    obj.data.name = name
    _finish(obj, colour, 0.0, 1, 0.0)
    return _place(obj, name, location, rotation, parent)


def group(name, location=(0, 0, 0), rotation=(0, 0, 0), parent=None):
    """Empty used as named node (state groups such as Closed / Open)."""
    empty = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(empty)
    empty.empty_display_size = 0.2
    return _place(empty, name, location, rotation, parent)


def rivet(name, location, normal_rotation=(0, 0, 0), colour="steel_light", parent=None, size=0.035):
    """Oversized dome rivet (2.2: details 1.5x real size)."""
    return cylinder(name, location, size, size * 0.6, colour, vertices=8, rotation=normal_rotation,
                    bevel=size * 0.25, parent=parent)


def patch(name, location, size, colour, rotation=(0, 0, 0), parent=None, rivets=4):
    """Walt's riveted repair plate (2.1). `size` = (width, height); thickness 1.5 cm.

    The plate lies in the local XZ plane facing -Y, so rotate it to the surface.
    """
    tilt = _rng.uniform(-7, 7)
    plate = box(name, location, (size[0], 0.015, size[1]), colour,
                rotation=(rotation[0], rotation[1] + tilt, rotation[2]), bevel=0.006, parent=parent)
    inset_x, inset_z = size[0] * 0.5 - 0.035, size[1] * 0.5 - 0.035
    corners = [(-inset_x, inset_z), (inset_x, inset_z), (-inset_x, -inset_z), (inset_x, -inset_z)]
    for index, (x, z) in enumerate(corners[:rivets]):
        rivet(f"{name}_Rivet{index}", (x, -0.012, z), (90, 0, 0), parent=plate, size=0.022)
    return plate


def tape(name, location, length, colour="mustard", rotation=(0, 0, 0), parent=None, width=0.07):
    """A strip of tape: thin, slightly wonky."""
    return box(name, location, (length, 0.008, width), colour,
               rotation=(rotation[0], rotation[1] + _rng.uniform(-10, 10), rotation[2]), bevel=0.003,
               parent=parent)


def wonk(obj, degrees=2.5):
    """Tilts an object slightly (2.2: old things are never quite straight)."""
    obj.rotation_euler.x += math.radians(_rng.uniform(-degrees, degrees))
    obj.rotation_euler.y += math.radians(_rng.uniform(-degrees, degrees))
    return obj


def root(name):
    """Top level empty; every part of the asset is parented below it."""
    return group(name)


def export_glb(root_obj, path):
    """Exports all descendants of the root as binary glTF with vertex colours.

    The root empty itself is removed first so that the glTF top-level nodes
    (e.g. Closed, Open, Debris) become direct children of the imported scene.
    """
    bpy.context.view_layer.update()
    children = list(root_obj.children)
    for child in children:
        world = child.matrix_world.copy()
        child.parent = None
        child.matrix_world = world
    bpy.data.objects.remove(root_obj, do_unlink=True)
    bpy.ops.object.select_all(action="DESELECT")
    stack = list(children)
    while stack:
        current = stack.pop()
        current.select_set(True)
        stack.extend(current.children)
    bpy.context.view_layer.objects.active = children[0]
    kwargs = dict(filepath=path, export_format="GLB", use_selection=True, export_apply=True,
                  export_yup=True, export_materials="EXPORT", export_cameras=False, export_lights=False)
    try:
        bpy.ops.export_scene.gltf(export_vertex_color="ACTIVE", **kwargs)
    except TypeError:
        bpy.ops.export_scene.gltf(export_colors=True, **kwargs)


def render_preview(path, focus=(0, 0, 0.5), ortho_scale=4.0, resolution=(900, 760)):
    """Preview render with the game camera angles (pitch -35, 45 degree diagonal)."""
    scene = bpy.context.scene
    camera_data = bpy.data.cameras.new("PreviewCam")
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = ortho_scale
    camera = bpy.data.objects.new("PreviewCam", camera_data)
    scene.collection.objects.link(camera)
    distance = 30.0
    horizontal = distance * math.cos(math.radians(35))
    camera.location = (focus[0] - horizontal * math.sin(math.radians(45)),
                       focus[1] - horizontal * math.cos(math.radians(45)),
                       focus[2] + distance * math.sin(math.radians(35)))
    target = bpy.data.objects.new("PreviewTarget", None)
    scene.collection.objects.link(target)
    target.location = focus
    constraint = camera.constraints.new("TRACK_TO")
    constraint.target = target
    constraint.track_axis = "TRACK_NEGATIVE_Z"
    constraint.up_axis = "UP_Y"
    scene.camera = camera
    sun_data = bpy.data.lights.new("PreviewSun", "SUN")
    sun_data.energy = 3.6
    sun_data.color = (1.0, 0.9, 0.78)
    sun_data.angle = math.radians(6)
    sun = bpy.data.objects.new("PreviewSun", sun_data)
    scene.collection.objects.link(sun)
    sun.rotation_euler = Euler((math.radians(52), 0, math.radians(-30)))
    floor = box("PreviewFloor", (focus[0], focus[1], -0.05), (12, 12, 0.1), "sand", bevel=0.0)
    world = bpy.data.worlds.new("PreviewWorld")
    scene.world = world
    world.use_nodes = True
    background = world.node_tree.nodes["Background"]
    background.inputs[0].default_value = (0.42, 0.35, 0.45, 1.0)
    background.inputs[1].default_value = 1.0
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x, scene.render.resolution_y = resolution
    scene.view_settings.view_transform = "AgX"
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    for obj in (camera, target, sun, floor):
        bpy.data.objects.remove(obj, do_unlink=True)


def _descendants(obj):
    result = []
    stack = list(obj.children)
    while stack:
        current = stack.pop()
        result.append(current)
        stack.extend(current.children)
    return result


def _owning_group(obj, root_obj):
    current = obj.parent
    while current is not None and current is not root_obj and current.type != "EMPTY":
        current = current.parent
    return current if current is not None else root_obj


def merge_parts(root_obj):
    """Joins all meshes below each named group into one mesh per group.

    Keeps the node hierarchy needed by gameplay (state groups) while reducing
    draw calls: one mesh per group instead of one per bolt.
    """
    groups = [root_obj] + [o for o in _descendants(root_obj) if o.type == "EMPTY"]
    for group_obj in groups:
        # matrix_world is only valid after a depsgraph update.
        bpy.context.view_layer.update()
        meshes = [o for o in _descendants(root_obj)
                  if o.type == "MESH" and _owning_group(o, root_obj) is group_obj]
        if not meshes:
            continue
        worlds = {mesh.name: mesh.matrix_world.copy() for mesh in meshes}
        for mesh in meshes:
            mesh.parent = None
        for mesh in meshes:
            mesh.matrix_world = worlds[mesh.name]
        bpy.ops.object.select_all(action="DESELECT")
        for mesh in meshes:
            mesh.select_set(True)
        bpy.context.view_layer.objects.active = meshes[0]
        if len(meshes) > 1:
            bpy.ops.object.join()
        merged = bpy.context.view_layer.objects.active
        merged.name = f"{group_obj.name}_Mesh"
        merged.data.name = merged.name
        world = merged.matrix_world.copy()
        merged.parent = group_obj
        merged.matrix_world = world
