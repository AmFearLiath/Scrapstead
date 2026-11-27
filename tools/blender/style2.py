"""Scrapstead art style 2 (docs/art-style-2.md): weathered, warm, high quality.

Instead of flat vertex colours with a toon shader, every part gets a
procedural material chosen by its palette colour name - painted sheet metal,
raw steel, rust, wood, rubber, glass, concrete, fabric - with rust patches,
rain streaks, dirt near the ground and sand dust on upward faces. After the
parts are merged, Cycles bakes that surface and its ambient occlusion into one
texture per mesh; the glTF then carries a plain textured material.

The builders stay unchanged: kit.py switches to this module when the
environment variable SCRAP_STYLE is "2".
"""
import math

import bpy

# colour name -> (kind, base colour hex). Warm, slightly desaturated; a few
# accents stay strong (Scrappy's teal, signal yellow, warning red).
PALETTE = {
    "rust": ("rust", "7e3a1e"), "rust_light": ("paint", "c8602c"), "mustard": ("paint", "f0b52e"),
    "cream": ("paint", "efe3c8"), "moss": ("plant", "a08f4f"), "teal": ("paint", "2f9d96"),
    "steel": ("metal", "6d7a82"), "steel_light": ("metal", "b5bcbe"), "wood": ("wood", "9a6a40"),
    "wood_light": ("wood", "c79560"), "wood_dark": ("wood", "5e4029"), "sand": ("concrete", "d6aa7c"),
    "soil": ("concrete", "93704f"), "ink": ("paint", "2a2624"), "plum": ("fabric", "6b4a6b"),
    "red": ("paint", "c63f2a"), "tyre": ("rubber", "262422"), "brass": ("metal", "c9a24a"), "copper": ("metal", "b8693a"),
    "paper": ("paper", "f3e9d2"), "glass": ("glass", "5f8f9c"), "green": ("paint", "5c9a4a"),
    "skin": ("skin", "e8a47c"),
    "wreck_teal": ("wreck", "2f9d96"), "wreck_orange": ("wreck", "c8602c"), "wreck_mustard": ("wreck", "f0b52e"),
    "wreck_red": ("wreck", "c63f2a"), "window": ("fabric", "34434a"),
}

RUST = (0.29, 0.13, 0.06, 1.0)
DIRT = (0.42, 0.33, 0.24, 1.0)
DUST = (0.86, 0.62, 0.45, 1.0)
TEXELS_PER_METRE = 160
_materials = {}
# Set while a character (player, Juri) is built: clothes become fabric, skin
# stays clean, metal parts keep their colour but do not rust.
CHARACTER = False
CHARACTER_TEXELS_PER_METRE = 320


def _linear(hex_value):
    srgb = [int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb) + (1.0,)


def _srgb_to_linear(rgba):
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgba[:3]) + (1.0,)


# --- Node helpers ----------------------------------------------------------------

class _Tree:
    def __init__(self, material):
        self.nodes = material.node_tree.nodes
        self.links = material.node_tree.links
        self.coord = self.nodes.new("ShaderNodeTexCoord")
        self.geometry = self.nodes.new("ShaderNodeNewGeometry")

    def link(self, output, target):
        self.links.new(output, target)

    def noise(self, scale, detail=4.0, roughness=0.55, stretch=(1.0, 1.0, 1.0), offset=0.0):
        mapping = self.nodes.new("ShaderNodeMapping")
        mapping.inputs["Scale"].default_value = stretch
        mapping.inputs["Location"].default_value = (offset, offset * 1.7, offset * 0.6)
        self.link(self.coord.outputs["Object"], mapping.inputs["Vector"])
        node = self.nodes.new("ShaderNodeTexNoise")
        node.inputs["Scale"].default_value = scale
        node.inputs["Detail"].default_value = detail
        node.inputs["Roughness"].default_value = roughness
        self.link(mapping.outputs["Vector"], node.inputs["Vector"])
        return node.outputs["Fac"]

    def ramp(self, value, low, high, low_colour=(0, 0, 0, 1), high_colour=(1, 1, 1, 1)):
        node = self.nodes.new("ShaderNodeValToRGB")
        node.color_ramp.elements[0].position = low
        node.color_ramp.elements[0].color = low_colour
        node.color_ramp.elements[1].position = high
        node.color_ramp.elements[1].color = high_colour
        self.link(value, node.inputs["Fac"])
        return node.outputs["Color"]

    def mix(self, factor, a, b, blend="MIX"):
        node = self.nodes.new("ShaderNodeMix")
        node.data_type = "RGBA"
        node.blend_type = blend
        self._feed(node.inputs[0], factor)
        self._feed(node.inputs[6], a)
        self._feed(node.inputs[7], b)
        return node.outputs[2]

    def math(self, operation, a, b):
        node = self.nodes.new("ShaderNodeMath")
        node.operation = operation
        self._feed(node.inputs[0], a)
        self._feed(node.inputs[1], b)
        return node.outputs[0]

    def _feed(self, socket, value):
        if isinstance(value, (int, float)):
            socket.default_value = value
        elif isinstance(value, tuple):
            socket.default_value = value
        else:
            self.link(value, socket)

    def height(self):
        separate = self.nodes.new("ShaderNodeSeparateXYZ")
        self.link(self.coord.outputs["Object"], separate.inputs["Vector"])
        return separate.outputs["Z"]

    def up(self):
        separate = self.nodes.new("ShaderNodeSeparateXYZ")
        self.link(self.geometry.outputs["Normal"], separate.inputs["Vector"])
        return separate.outputs["Z"]


def _weather(tree, colour, rust=0.35, streaks=0.3, dirt=0.5, dust=0.35, variation=0.12, seed=0.0, chips=0.0,
             chip_colour=(0.42, 0.44, 0.45, 1.0)):
    """Weathering on top of a base colour: sun bleaching, chipped edges, rust
    spots near edges and the ground, rust streaks running down, dirt at the
    bottom and sand dust on upward faces."""
    bleach = tree.ramp(tree.noise(0.35, 2.0, 0.45, offset=seed), 0.25, 0.75,
                       (1 - variation, 1 - variation, 1 - variation * 0.8, 1),
                       (1 + variation * 0.5, 1 + variation * 0.45, 1 + variation * 0.35, 1))
    result = tree.mix(1.0, colour, bleach, "MULTIPLY")
    edges = tree.ramp(tree.geometry.outputs["Pointiness"], 0.52, 0.62)
    if chips > 0.0:
        chip_noise = tree.ramp(tree.noise(6.0, 2.0, 0.5, offset=seed + 4.4), 0.5, 0.56)
        chip_mask = tree.math("MULTIPLY", tree.math("MULTIPLY", edges, chip_noise), chips)
        result = tree.mix(chip_mask, result, chip_colour)
    if rust > 0.0:
        low = tree.ramp(tree.height(), 0.0, 0.8, (1, 1, 1, 1), (0, 0, 0, 1))
        spots = tree.ramp(tree.noise(2.6, 3.0, 0.55, offset=seed + 3.1), 0.56, 0.64)
        near = tree.math("MAXIMUM", edges, low)
        spot_mask = tree.math("MULTIPLY", tree.math("MULTIPLY", spots, near), min(1.0, rust * 2.2))
        rust_tone = tree.mix(tree.noise(6.0, 2.0, 0.5, offset=seed + 1.3), RUST, (0.5, 0.24, 0.09, 1.0))
        result = tree.mix(spot_mask, result, rust_tone)
        runs = tree.ramp(tree.noise(7.0, 4.0, 0.55, stretch=(9.0, 9.0, 0.25), offset=seed + 6.2), 0.58, 0.72)
        run_mask = tree.math("MULTIPLY", runs, rust * 0.55)
        result = tree.mix(run_mask, result, (0.36, 0.17, 0.07, 1.0))
    if streaks > 0.0:
        streak = tree.ramp(tree.noise(5.0, 3.0, 0.5, stretch=(7.0, 7.0, 0.3), offset=seed + 5.5), 0.45, 0.78,
                           (1, 1, 1, 1), (1 - streaks * 0.35, 1 - streaks * 0.38, 1 - streaks * 0.42, 1))
        result = tree.mix(1.0, result, streak, "MULTIPLY")
    if dirt > 0.0:
        ground = tree.ramp(tree.height(), 0.0, 0.6, (dirt, dirt, dirt, 1), (0, 0, 0, 1))
        grime = tree.ramp(tree.noise(2.5, 3.0, 0.5, offset=seed + 9.9), 0.3, 0.7)
        result = tree.mix(tree.math("MULTIPLY", ground, grime), result, DIRT)
    if dust > 0.0:
        upward = tree.ramp(tree.up(), 0.6, 0.95)
        blotch = tree.ramp(tree.noise(2.0, 3.0, 0.5, offset=seed + 2.2), 0.25, 0.85)
        result = tree.mix(tree.math("MULTIPLY", tree.math("MULTIPLY", upward, blotch), dust), result, DUST)
    return result


def material_for(colour_name):
    """Procedural material for a palette colour name (shared per name)."""
    key = ("char:" if CHARACTER else "") + colour_name
    if key in _materials:
        try:
            _materials[key].name  # noqa: B018 - removed by a scene reset?
            return _materials[key]
        except ReferenceError:
            _materials.clear()
    kind, hex_value = PALETTE.get(colour_name, ("paint", "999999"))
    if CHARACTER:
        kind = {"skin": "skin", "glass": "glass", "rubber": "rubber", "metal": "clean_metal"}.get(kind, "fabric")
    base = _linear(hex_value)
    material = bpy.data.materials.new(f"S2_{key}")
    material.use_nodes = True
    bsdf = material.node_tree.nodes["Principled BSDF"]
    tree = _Tree(material)
    seed = (sum(ord(c) for c in colour_name) % 97) * 0.37
    if kind == "paint":
        colour = _weather(tree, base, rust=0.28, streaks=0.3, dirt=0.5, dust=0.18, seed=seed, chips=0.0,
                          variation=0.08)
        roughness = 0.75
    elif kind == "wreck":
        # Car wrecks: sun-bleached paint, big rust blooms, heavy streaks and dust.
        faded = tree.mix(0.16, base, (0.78, 0.72, 0.62, 1.0))
        bloom = tree.ramp(tree.noise(1.8, 3.0, 0.55, offset=seed + 7.7), 0.52, 0.6)
        rusty = tree.mix(bloom, faded, tree.mix(tree.noise(5.0, 2.0, 0.5, offset=seed), RUST, (0.5, 0.24, 0.09, 1.0)))
        colour = _weather(tree, rusty, rust=0.6, streaks=0.6, dirt=0.7, dust=0.4, seed=seed, chips=0.0,
                          variation=0.12)
        roughness = 0.85
    elif kind == "metal":
        darker = tuple(c * 0.72 for c in base[:3]) + (1.0,)
        blotch = tree.mix(tree.ramp(tree.noise(2.0, 6.0, 0.55, offset=seed), 0.3, 0.75), darker, base)
        colour = _weather(tree, blotch, rust=0.4, streaks=0.4, dirt=0.5, dust=0.25, seed=seed, chips=0.0,
                          chip_colour=tuple(min(1.0, c * 1.25) for c in base[:3]) + (1.0,))
        roughness = 0.6
    elif kind == "rust":
        tone = tree.mix(tree.noise(6.0, 8.0, 0.65, offset=seed), base, (0.52, 0.27, 0.12, 1.0))
        flake = tree.ramp(tree.noise(18.0, 2.0, 0.5, offset=seed + 4), 0.6, 0.66, (1, 1, 1, 1), (0.65, 0.55, 0.5, 1))
        colour = _weather(tree, tree.mix(1.0, tone, flake, "MULTIPLY"), rust=0.0, streaks=0.3, dirt=0.4, dust=0.3, seed=seed)
        roughness = 0.9
    elif kind == "wood":
        wave = tree.nodes.new("ShaderNodeTexWave")
        wave.inputs["Scale"].default_value = 3.5
        wave.inputs["Distortion"].default_value = 7.0
        wave.inputs["Detail"].default_value = 3.0
        tree.link(tree.coord.outputs["Object"], wave.inputs["Vector"])
        grain = tree.mix(tree.ramp(wave.outputs["Fac"], 0.2, 0.85), tuple(c * 0.68 for c in base[:3]) + (1.0,), base)
        colour = _weather(tree, grain, rust=0.0, streaks=0.25, dirt=0.6, dust=0.35, variation=0.18, seed=seed)
        roughness = 0.88
    elif kind == "rubber":
        colour = _weather(tree, base, rust=0.0, streaks=0.0, dirt=0.25, dust=0.55, variation=0.08, seed=seed)
        roughness = 0.95
    elif kind == "glass":
        sheen = tree.ramp(tree.height(), 0.5, 2.5, base, (0.75, 0.86, 0.88, 1.0))
        colour = _weather(tree, sheen, rust=0.0, streaks=0.2, dirt=0.0, dust=0.15, seed=seed)
        roughness = 0.2
    elif kind == "concrete":
        speckle = tree.mix(tree.ramp(tree.noise(25.0, 2.0, 0.5, offset=seed), 0.45, 0.6),
                           tuple(c * 0.85 for c in base[:3]) + (1.0,), base)
        colour = _weather(tree, speckle, rust=0.0, streaks=0.3, dirt=0.4, dust=0.3, seed=seed)
        roughness = 0.95
    elif kind == "plant":
        colour = _weather(tree, base, rust=0.0, streaks=0.0, dirt=0.2, dust=0.25, variation=0.25, seed=seed)
        roughness = 0.9
    elif kind == "clean_metal":
        colour = _weather(tree, base, rust=0.0, streaks=0.0, dirt=0.0, dust=0.1, variation=0.06, seed=seed)
        roughness = 0.45
    elif kind == "skin":
        # Soft, clean skin with a faint warm blush variation.
        blush = tree.ramp(tree.noise(3.0, 2.0, 0.4, offset=seed), 0.35, 0.75,
                          (1.0, 0.97, 0.95, 1.0), (1.04, 0.95, 0.92, 1.0))
        colour = tree.mix(1.0, base, blush, "MULTIPLY")
        roughness = 0.6
    elif kind == "fabric" and CHARACTER:
        # Work clothes: fine weave, softly darker folds, a little dust at the boots.
        weave = tree.ramp(tree.noise(60.0, 2.0, 0.5, stretch=(1.0, 1.0, 3.0), offset=seed), 0.3, 0.7,
                          (0.93, 0.93, 0.93, 1.0), (1.03, 1.03, 1.03, 1.0))
        folds = tree.ramp(tree.noise(4.0, 2.0, 0.5, stretch=(1.0, 1.0, 0.4), offset=seed + 1.0), 0.3, 0.7,
                          (0.9, 0.9, 0.9, 1.0), (1.02, 1.02, 1.02, 1.0))
        cloth = tree.mix(1.0, tree.mix(1.0, base, weave, "MULTIPLY"), folds, "MULTIPLY")
        colour = _weather(tree, cloth, rust=0.0, streaks=0.0, dirt=0.3, dust=0.12, variation=0.05, seed=seed)
        roughness = 0.9
    else:  # fabric, paper
        colour = _weather(tree, base, rust=0.0, streaks=0.15, dirt=0.25, dust=0.15, variation=0.08, seed=seed)
        roughness = 0.85
    tree.link(colour, bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = roughness
    material["s2_roughness"] = roughness
    _materials[key] = material
    return material


# --- Baking ----------------------------------------------------------------------

def _setup_cycles():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    preferences = bpy.context.preferences.addons["cycles"].preferences
    try:
        preferences.compute_device_type = "OPTIX"
        preferences.get_devices()
        for device in preferences.devices:
            device.use = True
        scene.cycles.device = "GPU"
    except Exception:  # noqa: BLE001 - no GPU: CPU works, only slower
        scene.cycles.device = "CPU"
    scene.cycles.samples = 16
    scene.render.bake.margin = 6


def _surface_area(obj):
    scale = obj.matrix_world.to_scale()
    factor = abs(scale.x * scale.y * scale.z) ** (2.0 / 3.0)
    return sum(polygon.area for polygon in obj.data.polygons) * factor


def _resolution(area):
    size = math.sqrt(max(area, 0.01)) * (CHARACTER_TEXELS_PER_METRE if CHARACTER else TEXELS_PER_METRE)
    for candidate in (256, 512, 1024, 2048):
        if size <= candidate:
            return candidate
    return 2048


def _bake_object(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.004, area_weight=0.0)
    bpy.ops.object.mode_set(mode="OBJECT")
    size = _resolution(_surface_area(obj))
    albedo = bpy.data.images.new(f"{obj.name}_albedo", size, size)
    occlusion = bpy.data.images.new(f"{obj.name}_ao", size, size)
    image_nodes = []
    for slot in obj.material_slots:
        if slot.material is None:
            continue
        slot.material = slot.material.copy()
        node = slot.material.node_tree.nodes.new("ShaderNodeTexImage")
        slot.material.node_tree.nodes.active = node
        image_nodes.append(node)
    for node in image_nodes:
        node.image = albedo
    bpy.context.scene.cycles.samples = 4
    bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, use_clear=True, margin=6)
    for node in image_nodes:
        node.image = occlusion
    bpy.context.scene.cycles.samples = 48
    bpy.context.scene.world.light_settings.distance = 0.8 if bpy.context.scene.world else 0.8
    bpy.ops.object.bake(type="AO", use_clear=True, margin=6)
    # Albedo times softened occlusion: crevices darken, flat faces stay clean.
    colour_pixels = list(albedo.pixels)
    ao_pixels = list(occlusion.pixels)
    for index in range(0, len(colour_pixels), 4):
        shade = 0.42 + 0.58 * ao_pixels[index]
        colour_pixels[index] *= shade
        colour_pixels[index + 1] *= shade
        colour_pixels[index + 2] *= shade
    albedo.pixels = colour_pixels
    albedo.pack()
    roughness = 0.8
    if obj.material_slots and obj.material_slots[0].material is not None:
        roughness = float(obj.material_slots[0].material.get("s2_roughness", 0.8))
    baked = bpy.data.materials.new(f"Baked_{obj.name}")
    baked.use_nodes = True
    bsdf = baked.node_tree.nodes["Principled BSDF"]
    texture = baked.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = albedo
    baked.node_tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = roughness
    obj.data.materials.clear()
    obj.data.materials.append(baked)
    bpy.data.images.remove(occlusion)


def bake_root(root_obj):
    """Bakes every merged mesh below the root into its own texture."""
    _setup_cycles()
    if bpy.context.scene.world is None:
        bpy.context.scene.world = bpy.data.worlds.new("BakeWorld")
    stack = list(root_obj.children)
    meshes = []
    while stack:
        current = stack.pop()
        stack.extend(current.children)
        if current.type == "MESH" and len(current.data.polygons) > 0:
            meshes.append(current)
    for mesh in meshes:
        _bake_object(mesh)
