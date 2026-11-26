"""Scenery for art style 2 (docs/art-style-2.md): denser yard dressing in the
spirit of a sun-baked junkyard - stacked car wrecks, tyre towers, dry grass
and a proper scrap mountain. Built like every other prop (kit primitives), so
both art styles can render them.
"""
import math

import kit
from kit import box, cylinder, group, patch, sphere, torus, wonk


def _r(a, b):
    return kit._rng.uniform(a, b)


def _car(name, location, yaw, colour, parent, squashed=0.0):
    """A small, boxy car wreck (about 1.7 x 3.8 m) as its own group."""
    car = group(name, location=location, rotation=(0, 0, yaw), parent=parent)
    roof_drop = 0.25 * squashed
    body = box(f"{name}Body", (0, 0, 0.55), (1.7, 3.8, 0.58), colour, parent=car, bevel=0.13, jitter=0.02)
    wonk(body, 2.0)
    box(f"{name}Cabin", (0, 0.2, 1.08 - roof_drop / 2), (1.5, 1.85, 0.55 - roof_drop), colour, parent=car, bevel=0.15)
    box(f"{name}Screen", (0, -0.62, 1.08 - roof_drop / 2), (1.3, 0.07, 0.45 - roof_drop), "glass", parent=car,
        rotation=(-28, 0, 0), bevel=0.02)
    box(f"{name}Side", (0.76, 0.2, 1.1 - roof_drop / 2), (0.05, 1.45, 0.34 - roof_drop * 0.8), "ink", parent=car,
        bevel=0.02)
    box(f"{name}SideL", (-0.76, 0.2, 1.1 - roof_drop / 2), (0.05, 1.45, 0.34 - roof_drop * 0.8), "ink", parent=car,
        bevel=0.02)
    box(f"{name}Bumper", (0, -1.92, 0.38), (1.65, 0.12, 0.13), "steel_light", parent=car, bevel=0.04)
    for side, x in (("L", -0.55), ("R", 0.55)):
        cylinder(f"{name}Light{side}", (x, -1.91, 0.6), 0.11, 0.05, "cream", rotation=(90, 0, 0), parent=car)
    for index, (x, y) in enumerate(((-0.82, -1.2), (0.82, -1.2), (-0.82, 1.25), (0.82, 1.25))):
        if kit._rng.random() < 0.8:
            cylinder(f"{name}Wheel{index}", (x, y, 0.28), 0.3, 0.2, "tyre", vertices=14, rotation=(0, 90, 0),
                     parent=car, bevel=0.05)
    patch(f"{name}Patch", (_r(-0.4, 0.4), _r(-1.4, 1.2), 0.85), (0.5, 0.4), "rust_light", parent=car,
          rotation=(90, 0, 0), rivets=2)
    return car


def build_car_stack(variant):
    """Two or three wrecks stacked like the yard ran out of space in 1987."""
    kit.seed(1200 + variant)
    root = kit.root("CarStack")
    colours = [["teal", "rust_light", "steel"], ["red", "steel_light", "teal"], ["mustard", "rust", "cream"]][variant % 3]
    _car("CarA", (0, 0, 0), _r(-3, 3), colours[0], root)
    _car("CarB", (_r(-0.15, 0.15), _r(-0.3, 0.3), 1.12), _r(-9, 9), colours[1], root, squashed=0.6)
    if variant != 1:
        _car("CarC", (_r(-0.1, 0.1), _r(-0.2, 0.2), 2.16), _r(-12, 12), colours[2], root, squashed=1.0)
    # A tyre and a door that slid off.
    torus("LooseTyre", (1.25, -1.6, 0.12), 0.3, 0.1, "tyre", parent=root, rotation=(0, 0, 0))
    box("LooseDoor", (-1.2, 0.8, 0.45), (0.06, 1.0, 0.82), colours[1], parent=root, rotation=(0, -14, 10),
        bevel=0.04)
    return root


def build_tyre_tower():
    """Three wobbly towers of tyres, one of them leaning on the others."""
    kit.seed(1250)
    root = kit.root("TyreTower")
    for tower, (x, y, count) in enumerate(((0.0, 0.0, 7), (0.66, 0.15, 5), (0.25, 0.68, 4))):
        for level in range(count):
            torus(f"Tyre{tower}_{level}", (x + _r(-0.05, 0.05), y + _r(-0.05, 0.05), 0.11 + level * 0.21), 0.27,
                  0.105, "tyre", parent=root, rotation=(_r(-4, 4), _r(-4, 4), 0))
    torus("Leaning", (-0.55, 0.3, 0.35), 0.27, 0.105, "tyre", parent=root, rotation=(75, 0, 30))
    return root


def build_dry_grass(variant):
    """Tuft of dry desert grass: thin straw-coloured blades."""
    kit.seed(1300 + variant)
    root = kit.root("DryGrass")
    blades = 22 + variant * 6
    for index in range(blades):
        angle = math.radians(_r(0, 360))
        lean = _r(10, 38)
        height = _r(0.25, 0.6)
        direction = (math.cos(angle), math.sin(angle))
        tilt = math.radians(lean)
        base = (direction[0] * _r(0.0, 0.07), direction[1] * _r(0.0, 0.07))
        # Centre of the blade: half its length out along the leaning axis.
        centre = (base[0] + direction[0] * math.sin(tilt) * height / 2,
                  base[1] + direction[1] * math.sin(tilt) * height / 2, math.cos(tilt) * height / 2)
        cylinder(f"Blade{index}", centre, 0.014, height, "moss" if index % 3 else "sand", vertices=4,
                 rotation=(-lean * direction[1], lean * direction[0], 0), parent=root, radius_top=0.002,
                 bevel=0.0)
    return root


def build_scrap_mountain():
    """A real scrap mountain: sheets, tyres, pipes, a barrel, a car door, a
    bathtub and an old sign, piled on a lumpy core."""
    kit.seed(1350)
    root = kit.root("ScrapMountain")
    def mound(x, y):
        return max(0.0, 1.45 * (1.0 - (x / 2.3) ** 2 - (y / 1.7) ** 2))

    for index in range(6):
        sphere(f"Core{index}", (_r(-1.2, 1.2), _r(-0.8, 0.8), -0.15), _r(0.8, 1.1), "rust", parent=root,
               scale=(1.4, 1.0, 0.75), segments=10, rings=6)
    colours = ["steel", "rust", "rust_light", "teal", "steel_light", "mustard", "red", "cream", "steel", "rust"]
    for index in range(95):
        x, y = _r(-2.2, 2.2), _r(-1.6, 1.6)
        z = mound(x, y) + _r(0.0, 0.15)
        if z <= 0.05:
            z = _r(0.05, 0.2)
        kind = kit._rng.random()
        colour = colours[index % len(colours)]
        rotation = (_r(-45, 45), _r(-45, 45), _r(0, 360))
        if kind < 0.42:
            box(f"Sheet{index}", (x, y, z), (_r(0.4, 1.0), _r(0.3, 0.8), 0.04), colour, parent=root,
                rotation=rotation, bevel=0.01)
        elif kind < 0.56:
            torus(f"Tyre{index}", (x, y, z), 0.26, 0.1, "tyre", parent=root, rotation=rotation)
        elif kind < 0.74:
            cylinder(f"Pipe{index}", (x, y, z), _r(0.04, 0.08), _r(0.6, 1.4), colour if colour != "cream" else "steel",
                     vertices=8, parent=root, rotation=rotation, bevel=0.0)
        elif kind < 0.9:
            box(f"Chunk{index}", (x, y, z), (_r(0.2, 0.5), _r(0.2, 0.5), _r(0.15, 0.4)), colour, parent=root,
                rotation=rotation, bevel=0.03)
        else:
            cylinder(f"Can{index}", (x, y, z), 0.2, 0.5, colour, vertices=10, parent=root, rotation=rotation)
    box("Door", (1.5, -0.8, 0.55), (0.06, 1.0, 0.8), "teal", parent=root, rotation=(35, 10, 30), bevel=0.04)
    box("Sign", (-0.4, 0.3, 1.45), (0.9, 0.05, 0.45), "mustard", parent=root, rotation=(70, 0, 20), bevel=0.02)
    box("Tub", (-1.5, -0.6, 0.5), (1.1, 0.55, 0.4), "cream", parent=root, rotation=(15, -20, 40), bevel=0.15)
    return root


ASSETS = {
    "car_stack_a": (lambda: build_car_stack(0), {"focus": (0, 0, 1.0), "ortho_scale": 5.5}),
    "car_stack_b": (lambda: build_car_stack(1), {"focus": (0, 0, 0.8), "ortho_scale": 5.0}),
    "car_stack_c": (lambda: build_car_stack(2), {"focus": (0, 0, 1.1), "ortho_scale": 5.5}),
    "tyre_tower": (build_tyre_tower, {"focus": (0, 0, 0.6), "ortho_scale": 2.6}),
    "dry_grass_a": (lambda: build_dry_grass(0), {"focus": (0, 0, 0.3), "ortho_scale": 1.2}),
    "dry_grass_b": (lambda: build_dry_grass(1), {"focus": (0, 0, 0.3), "ortho_scale": 1.2}),
    "scrap_mountain": (build_scrap_mountain, {"focus": (0, 0, 0.9), "ortho_scale": 6.5}),
}
