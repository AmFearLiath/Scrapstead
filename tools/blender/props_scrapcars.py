"""Scrap cars made from CC0 car models (Quaternius, tools/blender/sources/
quaternius/LICENSE.md): the clean city cars get weathered paint, dented
bodywork, missing wheels with the car sagging onto that corner, Walt's riveted
patches and the odd tyre lying next to it. Art style 2 only (baked textures).
"""
import math
import os

import bmesh
import bpy
from mathutils import Matrix, Vector, noise

import kit
from kit import box, cylinder, patch, torus

SOURCES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sources", "quaternius")
BODY_MATERIALS = ("Blue", "LightBlue", "White")
MATERIAL_MAP = {"Windows": "window", "Black": "tyre", "Grey": "steel", "Headlights": "cream", "TailLights": "red",
                "Material.007": "steel_light"}


def _r(a, b):
    return kit._rng.uniform(a, b)


def _import(file_name):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(SOURCES, file_name))
    new = [o for o in bpy.data.objects if o not in before]
    bpy.context.view_layer.update()
    meshes = [o for o in new if o.type == "MESH"]
    worlds = {o.name: o.matrix_world.copy() for o in meshes}
    for obj in meshes:
        obj.parent = None
        obj.matrix_world = worlds[obj.name]
    for obj in new:
        if obj.type != "MESH":
            bpy.data.objects.remove(obj, do_unlink=True)
    return meshes


def _restyle(obj, body_colour):
    import style2
    for index, material in enumerate(obj.data.materials):
        name = material.name.split(".")[0] if material else ""
        if material and material.name in MATERIAL_MAP:
            colour = MATERIAL_MAP[material.name]
        elif name in BODY_MATERIALS:
            colour = body_colour
        else:
            colour = MATERIAL_MAP.get(name, "steel")
        obj.data.materials[index] = style2.material_for(colour)


def _dent(obj, strength, seed):
    """Pushes the bodywork in here and there (low-frequency noise)."""
    mesh = obj.data
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.normal_update()
    offset = Vector((seed * 3.1, seed * 1.7, seed * 0.9))
    for vertex in bm.verts:
        if vertex.co.z < 0.25:
            continue
        amount = noise.noise(vertex.co * 2.2 + offset)
        if amount > 0.05:
            vertex.co -= vertex.normal * (amount - 0.05) * strength
    bm.to_mesh(mesh)
    bm.free()


def _wheels(meshes):
    found = {}
    for obj in meshes:
        for key in ("FrontLeftWheel", "FrontRightWheel", "BackWheels"):
            if key in obj.name:
                found[key] = obj
    return found


def build_scrap_car(source, variant, body_colour, missing, sag, seed):
    """`missing`: wheel keys to remove; `sag`: (roll, pitch, drop) the body
    takes when it sits on the bare corner."""
    kit.seed(seed)
    root = kit.root("ScrapCar")
    meshes = _import(source)
    body = next(o for o in meshes if "Wheel" not in o.name)
    wheels = _wheels(meshes)
    for key in missing:
        if key in wheels:
            bpy.data.objects.remove(wheels.pop(key), do_unlink=True)
    for obj in [body] + list(wheels.values()):
        _restyle(obj, body_colour)
    _dent(body, 0.2, seed)
    # Flat tyres on what is left.
    for obj in wheels.values():
        obj.scale.z *= 0.88
    # The car sags onto the bare corner.
    roll, pitch, drop = sag
    tilt = Matrix.Translation((0, 0, -drop)) @ Matrix.Rotation(math.radians(pitch), 4, "X") \
        @ Matrix.Rotation(math.radians(roll), 4, "Y")
    for obj in [body] + list(wheels.values()):
        obj.matrix_world = tilt @ obj.matrix_world
        obj.parent = root
        obj.matrix_parent_inverse = root.matrix_world.inverted()
    length = body.dimensions.y
    width = body.dimensions.x
    # Walt was here: riveted patches on the flanks, a crate under a bare axle.
    patch("PatchL", (-width * 0.5 - 0.01, _r(-0.6, 0.4), 0.55), (0.42, 0.3), "rust_light", parent=root,
          rotation=(90, 0, 90), rivets=4)
    if variant != 1:
        patch("PatchR", (width * 0.5 + 0.01, _r(-0.2, 0.8), 0.5), (0.34, 0.26), "steel_light", parent=root,
              rotation=(90, 0, -90), rivets=4)
    if "FrontLeftWheel" in missing or "BackWheels" in missing:
        y = length * (0.32 if "FrontLeftWheel" in missing else -0.32)
        box("Block", (-width * 0.32, y, 0.1), (0.4, 0.3, 0.2), "wood_dark", parent=root,
            rotation=(0, 0, _r(-10, 10)), bevel=0.02)
        torus("LooseTyre", (-width * 0.5 - 0.55, y + _r(-0.4, 0.4), 0.1), 0.24, 0.09, "tyre", parent=root,
              rotation=(0, 0, 0))
    if variant == 2:
        # Something grows out of the bonnet. It has been there for a while.
        for index in range(7):
            angle = math.radians(index * 51)
            cylinder(f"Grass{index}", (math.cos(angle) * 0.08, length * 0.33 + math.sin(angle) * 0.06, 1.0),
                     0.012, 0.4, "moss", vertices=4, rotation=(math.cos(angle) * 20, math.sin(angle) * 20, 0),
                     parent=root, radius_top=0.002, bevel=0.0)
    return root


ASSETS = {
    "scrap_car_a": (lambda: build_scrap_car("car_sedan.glb", 0, "wreck_teal", ("FrontLeftWheel",), (-6.0, 4.0, 0.12), 1501),
                    {"focus": (0, 0, 0.5), "ortho_scale": 5.0}),
    "scrap_car_b": (lambda: build_scrap_car("car_hatch.glb", 1, "wreck_orange", ("FrontLeftWheel", "FrontRightWheel"),
                                            (0.0, 7.0, 0.2), 1511), {"focus": (0, 0, 0.5), "ortho_scale": 4.5}),
    "scrap_car_c": (lambda: build_scrap_car("car_suv.glb", 2, "wreck_mustard", ("BackWheels",), (1.5, -7.0, 0.24), 1521),
                    {"focus": (0, 0, 0.6), "ortho_scale": 5.0}),
    "scrap_car_d": (lambda: build_scrap_car("car_sports.glb", 3, "wreck_red", ("FrontLeftWheel", "FrontRightWheel",
                                                                          "BackWheels"), (2.0, 0.0, 0.22), 1531),
                    {"focus": (0, 0, 0.4), "ortho_scale": 5.0}),
}
