"""World dressing for the Old Yard: fences, gate, walls, heaps, vehicles,
storage, lights, small finds and plants (docs/world-art-assets.md).

Imported by build_props.py. Same conventions: origin on the floor, front -Y.
"""
import math

import kit
from kit import box, cylinder, group, patch, rivet, sphere, tape, torus, wonk


def _r(a, b):
    return kit._rng.uniform(a, b)


# --- Boundaries -----------------------------------------------------------------

def build_fence_tall(variant):
    """4 m fence panel, 2 m high, centred on X, post at -X. Variant 0: corrugated
    sheet with a patch, 1: planks with one odd board, 2: corrugated, plain."""
    kit.seed(200 + variant)
    root = kit.root("FenceTall")
    box("Post", (-2.0, 0, 1.05), (0.14, 0.14, 2.1), "wood_dark", parent=root, bevel=0.03)
    if variant == 1:
        for index in range(13):
            colour = "teal" if index == 8 else ("wood" if index % 2 else "wood_light")
            height = 1.9 + _r(-0.12, 0.06)
            box(f"Plank{index}", (-1.85 + index * 0.3, 0, height / 2), (0.28, 0.05, height), colour,
                parent=root, bevel=0.015, rotation=(0, _r(-1.5, 1.5), 0))
        for z in (0.45, 1.5):
            box(f"Rail{z}", (0, 0.05, z), (3.9, 0.04, 0.1), "wood_dark", parent=root, bevel=0.01)
    else:
        box("Sheet", (0, 0, 0.98), (3.86, 0.05, 1.86), "steel", parent=root, bevel=0.015,
            rotation=(0, _r(-0.8, 0.8), 0))
        for index in range(16):
            box(f"Rib{index}", (-1.8 + index * 0.24, -0.035, 0.98), (0.06, 0.03, 1.84), "steel_light",
                parent=root, bevel=0.01, variation=0.08)
        box("TopRail", (0, 0, 1.95), (3.95, 0.09, 0.08), "wood_dark", parent=root, bevel=0.02)
        if variant == 0:
            patch("Patch", (0.6, -0.07, 0.8), (0.8, 0.6), "rust_light", parent=root)
            tape("Tape", (-1.1, -0.065, 1.35), 0.6, parent=root, rotation=(0, 30, 0))
    return root


def build_fence_low(variant):
    """4 m low picket fence (0.9 m) for the south/west sides that face the camera."""
    kit.seed(210 + variant)
    root = kit.root("FenceLow")
    box("Post", (-2.0, 0, 0.5), (0.13, 0.13, 1.0), "wood_dark", parent=root, bevel=0.03)
    for z in (0.28, 0.68):
        box(f"Rail{z}", (0, 0.04, z), (3.95, 0.04, 0.09), "wood_dark", parent=root, bevel=0.01)
    for index in range(12):
        height = 0.82 + _r(-0.08, 0.06)
        colour = "mustard" if (variant == 1 and index == 5) else ("wood_light" if index % 2 else "wood")
        if variant == 2 and index == 9:
            continue  # a missing picket
        picket = box(f"Picket{index}", (-1.8 + index * 0.33, 0, height / 2), (0.2, 0.04, height), colour,
                     parent=root, bevel=0.02, rotation=(0, _r(-3, 3), 0))
        box(f"Tip{index}", (0, 0, height / 2), (0.14, 0.04, 0.14), colour, parent=picket, rotation=(0, 45, 0),
            bevel=0.01)
    return root


def build_gate():
    """Entrance: steel posts with caps, arched sign with the Scrapstead gear and
    an open gate leaf. Spans 5 m along X between the posts."""
    kit.seed(220)
    root = kit.root("Gate")
    for side, x in (("W", -2.5), ("E", 2.5)):
        box(f"Post{side}", (x, 0, 1.15), (0.32, 0.32, 2.3), "steel", parent=root, bevel=0.04)
        cylinder(f"Cap{side}", (x, 0, 2.38), 0.22, 0.12, "rust_light", vertices=10, parent=root)
    board = box("SignBoard", (0, 0, 2.55), (5.4, 0.12, 0.62), "rust_light", parent=root, bevel=0.04)
    wonk(board, 1.0)
    box("SignFrame", (0, 0.02, 2.55), (5.6, 0.1, 0.72), "ink", parent=root, bevel=0.03)
    # The gear from the logo.
    cylinder("Gear", (0, -0.09, 2.55), 0.38, 0.06, "mustard", vertices=16, rotation=(90, 0, 0), parent=root)
    for index in range(8):
        angle = index * 45.0
        box(f"Tooth{index}", (math.sin(math.radians(angle)) * 0.4, -0.09, 2.55 + math.cos(math.radians(angle)) * 0.4),
            (0.12, 0.06, 0.14), "mustard", rotation=(0, angle, 0), parent=root, bevel=0.015)
    cylinder("GearHole", (0, -0.12, 2.55), 0.14, 0.04, "ink", vertices=12, rotation=(90, 0, 0), parent=root)
    for side, x in (("L", -1.6), ("R", 1.6)):
        for index in range(3):
            box(f"Stripe{side}{index}", (x + (index - 1) * 0.35, -0.08, 2.55), (0.18, 0.03, 0.5), "cream",
                parent=root, rotation=(0, 35, 0), bevel=0.01)
    tape("SignTape", (2.2, -0.08, 2.75), 0.5, parent=root, rotation=(0, -30, 0))
    # Open gate leaf, swung outwards to the west.
    leaf = group("Leaf", location=(-2.55, -0.2, 0.0), rotation=(0, 0, -70), parent=root)
    for z in (0.2, 1.4):
        box(f"LeafRail{z}", (1.3, 0, z), (2.6, 0.06, 0.08), "steel", parent=leaf, bevel=0.02)
    for index in range(7):
        box(f"LeafBar{index}", (0.1 + index * 0.4, 0, 0.8), (0.05, 0.05, 1.25), "steel", parent=leaf, bevel=0.01)
    box("LeafBrace", (1.3, 0, 0.8), (2.7, 0.05, 0.07), "steel", rotation=(0, -24, 0), parent=leaf, bevel=0.01)
    patch("LeafPatch", (1.9, -0.05, 0.75), (0.5, 0.4), "teal", parent=leaf)
    return root


def build_brick_wall():
    """4 m free-standing brick wall with a faded poster and a mended crack."""
    kit.seed(230)
    root = kit.root("BrickWall")
    for row in range(9):
        offset = 0.0 if row % 2 == 0 else 0.2
        for index in range(11):
            x = -2.0 + offset + index * 0.4
            if x > 1.85 or x < -2.05:
                continue
            width = 0.38 if -1.85 < x < 1.85 else 0.18
            box(f"Brick{row}_{index}", (x + (0.1 if width < 0.3 and x < 0 else 0), 0, 0.1 + row * 0.2),
                (width, 0.36, 0.18), "rust" if (row + index) % 4 else "rust_light", parent=root, bevel=0.025,
                variation=0.1)
    box("Coping", (0, 0, 1.86), (4.1, 0.44, 0.1), "sand", parent=root, bevel=0.03)
    poster = box("Poster", (-0.8, -0.2, 1.05), (0.7, 0.01, 0.95), "cream", parent=root, rotation=(0, 3, 0),
                 bevel=0.0)
    box("PosterImage", (0, -0.006, 0.1), (0.5, 0.005, 0.45), "teal", parent=poster, bevel=0.0)
    cylinder("PosterCoin", (0, -0.012, 0.1), 0.13, 0.005, "mustard", rotation=(90, 0, 0), parent=poster,
             vertices=14, bevel=0.0)
    box("PosterCorner", (0.3, -0.008, 0.44), (0.18, 0.006, 0.12), "paper", parent=poster, rotation=(0, -40, 0),
        bevel=0.0)
    box("Crack", (1.1, -0.19, 0.9), (0.06, 0.01, 0.8), "sand", parent=root, rotation=(0, 18, 0), bevel=0.0)
    tape("CrackTape", (1.1, -0.2, 0.95), 0.4, parent=root, rotation=(0, 75, 0))
    return root


def build_girder():
    """Steel post with hazard stripes (the 1.5 m pinch point)."""
    kit.seed(240)
    root = kit.root("Girder")
    box("Web", (0, 0, 1.2), (0.08, 0.22, 2.4), "steel", parent=root, bevel=0.015)
    for side, x in (("A", -0.1), ("B", 0.1)):
        box(f"Flange{side}", (x, 0, 1.2), (0.04, 0.26, 2.4), "steel", parent=root, bevel=0.01)
    for index in range(4):
        box(f"Stripe{index}", (0, 0, 0.18 + index * 0.16), (0.27, 0.28, 0.08),
            "mustard" if index % 2 == 0 else "ink", parent=root, bevel=0.01)
    box("Foot", (0, 0, 0.04), (0.42, 0.42, 0.08), "steel_light", parent=root, bevel=0.02)
    for index, (x, y) in enumerate(((-0.15, -0.15), (0.15, -0.15), (-0.15, 0.15), (0.15, 0.15))):
        rivet(f"Bolt{index}", (x, y, 0.09), parent=root, size=0.03)
    return root


# --- Scrap heaps and vehicles --------------------------------------------------------

def _fridge(name, location, rotation, parent):
    fridge = group(name, location=location, rotation=rotation, parent=parent)
    box(f"{name}Body", (0, 0, 0.6), (0.6, 0.6, 1.2), "cream", parent=fridge, bevel=0.07)
    box(f"{name}Handle", (0.22, -0.31, 0.8), (0.04, 0.04, 0.35), "steel", parent=fridge, bevel=0.01)
    box(f"{name}Line", (0, -0.305, 0.85), (0.56, 0.01, 0.02), "steel", parent=fridge, bevel=0.0)
    return fridge


def _washer(name, location, rotation, parent):
    washer = group(name, location=location, rotation=rotation, parent=parent)
    box(f"{name}Body", (0, 0, 0.42), (0.6, 0.6, 0.84), "steel_light", parent=washer, bevel=0.06)
    torus(f"{name}Door", (0, -0.31, 0.42), 0.18, 0.04, "steel", rotation=(90, 0, 0), parent=washer)
    cylinder(f"{name}Glass", (0, -0.3, 0.42), 0.16, 0.02, "glass", rotation=(90, 0, 0), parent=washer,
             vertices=14)
    return washer


def _tyre(name, location, rotation, parent, radius=0.32):
    cylinder(name, location, radius, 0.2, "tyre", vertices=16, rotation=rotation, parent=parent, bevel=0.06)
    cylinder(f"{name}Rim", location, radius * 0.45, 0.22, "steel_light", vertices=10, rotation=rotation,
             parent=parent)


def _bike_wheel(name, location, rotation, parent):
    wheel = group(name, location=location, rotation=rotation, parent=parent)
    torus(f"{name}Tyre", (0, 0, 0), 0.34, 0.025, "ink", parent=wheel, segments=20)
    for index in range(6):
        box(f"{name}Spoke{index}", (0, 0, 0), (0.66, 0.01, 0.01), "steel_light", rotation=(0, 0, index * 30),
            parent=wheel, bevel=0.0)
    return wheel


def build_scrap_heap(size):
    """Junk heap. size 'large' ~5x4x2.4 m, 'small' ~3x3x1.4 m, 'pile' ~3x3x1.2 m."""
    kit.seed({"large": 300, "small": 310, "pile": 320}[size])
    root = kit.root("ScrapHeap")
    w, d, h = {"large": (4.6, 3.6, 1.5), "small": (2.7, 2.7, 0.9), "pile": (2.6, 2.6, 0.75)}[size]
    mound = cylinder("Mound", (0, 0, h / 2), w / 2, h, "rust", vertices=7, radius_top=w * 0.14, parent=root,
                     jitter=0.12, bevel=0.1, rotation=(0, 0, 10))
    mound.scale = (1.0, d / w, 1.0)
    pieces = group("Pieces", parent=root)
    count = {"large": 34, "small": 18, "pile": 15}[size]
    top_radius, base_radius = w * 0.14, w / 2

    def surface(rx, ry):
        # Height of the mound at a horizontal point (cone, elliptic footprint).
        r = math.hypot(rx, ry * w / d)
        return max(0.0, h * (base_radius - r) / (base_radius - top_radius)) if r > top_radius else h

    for index in range(count):
        angle = _r(0, math.tau)
        radius = (_r(0.0, 1.0) ** 0.7) * base_radius * 0.85
        x, y = math.cos(angle) * radius, math.sin(angle) * radius * d / w
        z = surface(x, y) + 0.05
        kind = index % 8
        rotation = (_r(-40, 40), _r(-40, 40), _r(0, 180))
        if kind == 0:
            box(f"Sheet{index}", (x, y, z), (_r(0.6, 1.2), _r(0.5, 0.9), 0.04),
                ["steel", "teal", "steel_light"][index % 3], rotation=rotation, parent=pieces, bevel=0.01,
                jitter=0.02)
        elif kind == 1:
            _tyre(f"Tyre{index}", (x, y, z + 0.1), (rotation[0] + 60, rotation[1], rotation[2]), pieces)
        elif kind == 2:
            cylinder(f"Pipe{index}", (x, y, z + 0.2), _r(0.05, 0.09), _r(0.9, 1.7),
                     "rust_light" if index % 2 else "teal", rotation=(_r(45, 75), 0, rotation[2]), parent=pieces,
                     vertices=8)
        elif kind == 3 and size == "large" and index < 16:
            _fridge(f"Fridge{index}", (x, y, z - 0.35), (_r(-25, 25), _r(50, 80), rotation[2]), pieces)
        elif kind == 4 and size != "pile":
            _washer(f"Washer{index}", (x, y, z - 0.15), (rotation[0] * 0.4, rotation[1] * 0.4, rotation[2]), pieces)
        elif kind == 5:
            _bike_wheel(f"Bike{index}", (x, y, z + 0.2), (_r(50, 80), rotation[1], rotation[2]), pieces)
        elif kind == 6:
            box(f"Plank{index}", (x, y, z), (_r(0.8, 1.4), 0.16, 0.05), "wood", rotation=rotation, parent=pieces,
                bevel=0.01, jitter=0.01)
        else:
            box(f"Chunk{index}", (x, y, z), (_r(0.3, 0.6), _r(0.3, 0.5), _r(0.2, 0.45)),
                ["steel", "rust_light", "wood", "red", "steel_light"][index % 5], rotation=rotation,
                parent=pieces, bevel=0.04, jitter=0.02)
    for index in range(10 if size == "large" else 6):
        angle = _r(0, math.tau)
        radius = base_radius * _r(0.9, 1.12)
        box(f"Rubble{index}", (math.cos(angle) * radius, math.sin(angle) * radius * d / w, 0.06),
            (_r(0.15, 0.35), _r(0.15, 0.3), _r(0.08, 0.16)), ["rust", "steel", "rust_light"][index % 3],
            rotation=(0, 0, _r(0, 180)), parent=pieces, bevel=0.03, jitter=0.01)
    if size == "large":
        # A tiny flag on top: somebody once claimed this summit.
        cylinder("FlagPole", (0.1, 0.0, h + 0.75), 0.02, 1.2, "wood_dark", vertices=6, parent=pieces)
        box("Flag", (0.32, 0.0, h + 1.2), (0.4, 0.02, 0.26), "mustard", parent=pieces, rotation=(0, -6, 0),
            bevel=0.01)
    return root


def build_car_wreck():
    """Old teal car: one flat tyre, a door leaning against it, a plant growing
    out of the window. Long axis along Y, front at -Y."""
    kit.seed(330)
    root = kit.root("CarWreck")
    body = box("Body", (0, 0, 0.6), (1.75, 3.9, 0.62), "teal", parent=root, bevel=0.14, jitter=0.015)
    wonk(body, 1.5)
    box("Cabin", (0, 0.25, 1.15), (1.55, 1.9, 0.6), "teal", parent=root, bevel=0.16)
    box("Windscreen", (0, -0.62, 1.15), (1.35, 0.08, 0.5), "glass", parent=root, rotation=(-28, 0, 0), bevel=0.02)
    box("RearWindow", (0, 1.15, 1.15), (1.3, 0.08, 0.45), "glass", parent=root, rotation=(22, 0, 0), bevel=0.02)
    box("SideWindow", (0.78, 0.25, 1.18), (0.06, 1.5, 0.38), "ink", parent=root, bevel=0.02)
    box("Bumper", (0, -1.97, 0.42), (1.7, 0.12, 0.14), "steel_light", parent=root, bevel=0.04)
    for side, x in (("L", -0.55), ("R", 0.55)):
        cylinder(f"Light{side}", (x, -1.96, 0.65), 0.12, 0.06, "cream", rotation=(90, 0, 0), parent=root)
    for index, (x, y, flat) in enumerate(((-0.85, -1.25, False), (0.85, -1.25, True), (-0.85, 1.3, False),
                                          (0.85, 1.3, False))):
        cylinder(f"Wheel{index}", (x, y, 0.3 if not flat else 0.22), 0.32, 0.22, "tyre", vertices=16,
                 rotation=(0, 90, 0), parent=root, bevel=0.06)
        cylinder(f"Hub{index}", (x * 1.07, y, 0.3 if not flat else 0.22), 0.13, 0.1, "steel_light", vertices=10,
                 rotation=(0, 90, 0), parent=root)
    patch("HoodPatch", (0.2, -1.4, 0.92), (0.6, 0.5), "rust_light", parent=root, rotation=(90, 0, 0))
    patch("SidePatch", (-0.88, 0.9, 0.62), (0.45, 0.3), "mustard", parent=root, rotation=(0, 0, 90))
    door = box("Door", (-1.25, -0.2, 0.55), (0.06, 1.0, 0.85), "teal", parent=root, rotation=(0, -18, 8), bevel=0.05)
    box("DoorWindow", (-0.04, 0.0, 0.2), (0.02, 0.8, 0.3), "ink", parent=door, bevel=0.0)
    # Plant growing through the cabin.
    for index in range(5):
        sphere(f"Leaf{index}", (0.25 + _r(-0.2, 0.2), 0.3 + _r(-0.3, 0.3), 1.55 + _r(0, 0.35)), _r(0.14, 0.22),
               "moss", parent=root, scale=(1, 1, 0.8))
    return root


def build_container():
    """Rusty shipping container (2.5 x 6 x 2.6) with a replaced teal panel and a
    sleeping cat on the roof."""
    kit.seed(340)
    root = kit.root("Container")
    box("Body", (0, 0, 1.3), (2.45, 5.95, 2.6), "rust_light", parent=root, bevel=0.05)
    for index in range(20):
        y = -2.8 + index * 0.3
        colour = "teal" if 9 <= index <= 11 else "rust_light"
        box(f"RibL{index}", (-1.25, y, 1.3), (0.05, 0.14, 2.5), colour, parent=root, bevel=0.01, variation=0.08)
        box(f"RibR{index}", (1.25, y, 1.3), (0.05, 0.14, 2.5), "rust_light", parent=root, bevel=0.01, variation=0.08)
    box("Frame", (0, 0, 2.6), (2.55, 6.05, 0.1), "rust", parent=root, bevel=0.03)
    box("Doors", (0, -3.0, 1.3), (2.35, 0.06, 2.45), "rust", parent=root, bevel=0.02)
    for x in (-0.6, 0.6):
        box(f"Bar{x}", (x, -3.06, 1.3), (0.06, 0.06, 2.35), "steel", parent=root, bevel=0.015)
    patch("DoorPatch", (-0.5, -3.08, 0.7), (0.6, 0.5), "mustard", parent=root)
    # The cat.
    cat = group("Cat", location=(0.3, 1.5, 2.66), rotation=(0, 0, 30), parent=root)
    sphere("CatBody", (0, 0, 0.12), 0.22, "ink", parent=cat, scale=(1.3, 0.85, 0.6))
    sphere("CatHead", (0.26, -0.05, 0.17), 0.11, "ink", parent=cat)
    for side, y in (("L", -0.1), ("R", 0.02)):
        cylinder(f"CatEar{side}", (0.29, y, 0.27), 0.04, 0.08, "ink", vertices=4, radius_top=0.0, parent=cat,
                 bevel=0.0)
    cylinder("CatTail", (-0.3, 0.12, 0.06), 0.035, 0.4, "ink", vertices=6, rotation=(90, 0, 60), parent=cat)
    return root


def build_engine_block():
    kit.seed(350)
    root = kit.root("EngineBlock")
    box("Block", (0, 0, 0.42), (1.3, 0.85, 0.7), "steel", parent=root, bevel=0.08, jitter=0.01)
    for index in range(4):
        cylinder(f"Cyl{index}", (-0.45 + index * 0.3, 0, 0.88), 0.11, 0.25, "steel_light", vertices=10, parent=root)
    cylinder("Fan", (0.7, 0, 0.5), 0.3, 0.06, "rust_light", vertices=12, rotation=(0, 90, 0), parent=root)
    box("OilStain", (0.3, -0.45, 0.005), (1.0, 0.6, 0.01), "plum", parent=root, bevel=0.0, rotation=(0, 0, 15))
    return root


# --- Storage zone ---------------------------------------------------------------

def build_crate_stack():
    """Three crates; the top one marked 'this side up' with the arrow pointing down."""
    kit.seed(360)
    root = kit.root("CrateStack")
    for index, (x, y, z, angle) in enumerate(((0, 0, 0.5, 0), (1.15, 0.05, 0.5, 9), (0.55, 0.1, 1.5, 24))):
        crate = box(f"Crate{index}", (x, y, z), (1.05, 1.05, 0.95), "wood" if index != 1 else "wood_light",
                    parent=root, rotation=(0, 0, angle), bevel=0.04, jitter=0.01)
        for slat in range(2):
            box(f"Slat{index}_{slat}", (0, -0.53, -0.25 + slat * 0.5), (1.07, 0.03, 0.12), "wood_dark",
                parent=crate, bevel=0.01)
    arrow = group("Arrow", location=(0.55, -0.45, 1.55), rotation=(0, 180, 24), parent=root)
    box("ArrowShaft", (0, -0.06, 0), (0.06, 0.01, 0.3), "red", parent=arrow, bevel=0.0)
    box("ArrowHeadA", (0.06, -0.06, 0.13), (0.06, 0.01, 0.18), "red", parent=arrow, rotation=(0, 40, 0), bevel=0.0)
    box("ArrowHeadB", (-0.06, -0.06, 0.13), (0.06, 0.01, 0.18), "red", parent=arrow, rotation=(0, -40, 0), bevel=0.0)
    return root


def build_barrel_group():
    """Four barrels; one wears a watering can as a funnel."""
    kit.seed(370)
    root = kit.root("BarrelGroup")
    for index, (x, y) in enumerate(((0, 0), (0.85, 0.05), (0.05, 0.85), (0.9, 0.9))):
        colour = ["rust", "teal", "rust_light", "teal"][index]
        barrel = cylinder(f"Barrel{index}", (x, y, 0.55), 0.4, 1.1, colour, vertices=14, parent=root, jitter=0.01)
        wonk(barrel, 2.0)
        for ring in (0.25, 0.85):
            cylinder(f"Ring{index}_{ring}", (x, y, ring), 0.415, 0.05, "steel", vertices=14, parent=root)
    can = group("WateringCan", location=(0.9, 0.9, 1.15), rotation=(0, 160, 0), parent=root)
    cylinder("CanBody", (0, 0, 0.18), 0.17, 0.28, "moss", vertices=12, parent=can)
    cylinder("CanSpout", (0.25, 0, 0.18), 0.03, 0.35, "moss", vertices=8, rotation=(0, 60, 0), parent=can)
    return root


def build_shelf():
    """Metal shelf with jars, boxes and a rubber duck guarding everything."""
    kit.seed(380)
    root = kit.root("Shelf")
    for x in (-1.45, 1.45):
        for y in (-0.42, 0.42):
            box(f"Upright{x}{y}", (x, y, 1.1), (0.06, 0.06, 2.2), "steel", parent=root, bevel=0.01)
    for index in range(4):
        box(f"Board{index}", (0, 0, 0.2 + index * 0.62), (2.95, 0.9, 0.05), "steel_light", parent=root, bevel=0.01)
    for index in range(10):
        level = index % 3
        x = -1.2 + (index // 3) * 0.75 + _r(-0.1, 0.1)
        if index % 3 == 0:
            cylinder(f"Jar{index}", (x, _r(-0.2, 0.2), 0.36 + level * 0.62), 0.1, 0.26, "glass", vertices=10,
                     parent=root)
        else:
            box(f"Box{index}", (x, _r(-0.2, 0.2), 0.36 + level * 0.62), (_r(0.3, 0.5), 0.4, _r(0.2, 0.35)),
                ["wood", "teal", "cream", "rust_light"][index % 4], parent=root, bevel=0.03,
                rotation=(0, 0, _r(-10, 10)))
    duck = group("Duck", location=(1.1, -0.2, 2.07), rotation=(0, 0, -30), parent=root)
    sphere("DuckBody", (0, 0, 0.08), 0.1, "mustard", parent=duck, scale=(1.3, 1, 0.8))
    sphere("DuckHead", (0.08, 0, 0.18), 0.065, "mustard", parent=duck)
    box("DuckBeak", (0.15, 0, 0.17), (0.06, 0.05, 0.025), "rust_light", parent=duck, bevel=0.01)
    return root


def build_pallet_stack():
    kit.seed(390)
    root = kit.root("PalletStack")
    for level in range(3):
        pallet = group(f"Pallet{level}", location=(_r(-0.05, 0.05), _r(-0.05, 0.05), level * 0.15),
                       rotation=(0, 0, _r(-8, 8)), parent=root)
        for index in range(5):
            box(f"Top{level}_{index}", (-0.48 + index * 0.24, 0, 0.13), (0.18, 1.0, 0.03), "wood_light",
                parent=pallet, bevel=0.008, variation=0.08)
        for index in range(3):
            box(f"Block{level}_{index}", (0, -0.4 + index * 0.4, 0.06), (1.2, 0.12, 0.1), "wood", parent=pallet,
                bevel=0.01)
    return root


def build_tyre_stack():
    """Tyres: a stack of three and one turned into a flower bed."""
    kit.seed(400)
    root = kit.root("TyreStack")
    for index in range(3):
        _tyre(f"Stack{index}", (0, 0, 0.12 + index * 0.21), (0, 0, _r(0, 40)), root, radius=0.45)
    _tyre("Planter", (1.2, -0.7, 0.12), (0, 0, 0), root, radius=0.45)
    cylinder("Soil", (1.2, -0.7, 0.2), 0.3, 0.06, "soil", vertices=12, parent=root)
    for index in range(5):
        sphere(f"Flower{index}", (1.2 + _r(-0.18, 0.18), -0.7 + _r(-0.18, 0.18), 0.32 + _r(0, 0.1)), 0.07,
               ["red", "mustard", "cream"][index % 3], parent=root)
        sphere(f"Leaf{index}", (1.2 + _r(-0.2, 0.2), -0.7 + _r(-0.2, 0.2), 0.26), 0.1, "moss", parent=root,
               scale=(1, 1, 0.6))
    return root


def build_bathtub_planter():
    """Old claw-foot bathtub turned flower bed at the entrance."""
    kit.seed(410)
    root = kit.root("BathtubPlanter")
    box("Tub", (0, 0, 0.42), (1.5, 0.75, 0.5), "cream", parent=root, bevel=0.18)
    box("Soil", (0, 0, 0.66), (1.3, 0.56, 0.06), "soil", parent=root, bevel=0.03)
    for index, (x, y) in enumerate(((-0.6, -0.28), (0.6, -0.28), (-0.6, 0.28), (0.6, 0.28))):
        sphere(f"Foot{index}", (x, y, 0.1), 0.08, "brass", parent=root)
    cylinder("Tap", (-0.72, 0, 0.75), 0.03, 0.18, "steel_light", vertices=8, parent=root)
    for index in range(9):
        x, y = _r(-0.55, 0.55), _r(-0.2, 0.2)
        sphere(f"Leaf{index}", (x, y, 0.78), _r(0.12, 0.18), "moss", parent=root, scale=(1, 1, 0.7))
        if index % 2 == 0:
            sphere(f"Bloom{index}", (x + 0.05, y, 0.92), 0.07, ["red", "mustard", "teal"][index % 3], parent=root)
    return root


# --- Lights, stations, deliveries -------------------------------------------------

def build_floodlight():
    """Yard floodlight. Head/Lens is switched by the UseTestObject script."""
    kit.seed(420)
    root = kit.root("Floodlight")
    box("Foot", (0, 0, 0.12), (0.6, 0.6, 0.24), "sand", parent=root, bevel=0.05)
    cylinder("Pole", (0, 0, 1.9), 0.07, 3.4, "steel", vertices=10, parent=root, rotation=(0, 1.5, 0))
    box("SwitchBox", (0, -0.1, 1.0), (0.24, 0.12, 0.32), "mustard", parent=root, bevel=0.03)
    box("Lever", (0.06, -0.18, 1.04), (0.03, 0.05, 0.14), "red", parent=root, rotation=(0, 20, 0), bevel=0.01)
    cylinder("Cable", (0.05, -0.02, 0.6), 0.015, 0.8, "ink", vertices=6, parent=root)
    tape("PoleTape", (0, -0.075, 1.6), 0.18, parent=root, rotation=(0, 90, 0))
    head = group("Head", location=(0, -0.2, 3.55), rotation=(-35, 0, 0), parent=root)
    box("Housing", (0, 0, 0), (0.62, 0.36, 0.34), "steel", parent=head, bevel=0.06)
    box("Visor", (0, -0.22, 0.17), (0.66, 0.12, 0.03), "steel", parent=head, bevel=0.01)
    lens = group("Lens", location=(0, -0.18, 0), parent=head)
    box("LensGlass", (0, 0, 0), (0.5, 0.03, 0.24), "paper", parent=lens, bevel=0.01)
    return root


def build_dismantle_table():
    """Dismantling table: a half-opened radio, sorting bins, a lamp."""
    kit.seed(430)
    root = kit.root("DismantleTable")
    box("Top", (0, 0, 0.82), (1.8, 1.0, 0.08), "steel_light", parent=root, bevel=0.025)
    for x in (-0.82, 0.82):
        for y in (-0.42, 0.42):
            box(f"Leg{x}{y}", (x, y, 0.4), (0.07, 0.07, 0.8), "steel", parent=root, bevel=0.01)
    box("Mat", (-0.15, 0.0, 0.875), (0.9, 0.6, 0.02), "teal", parent=root, bevel=0.005)
    box("RadioShell", (-0.2, 0.05, 0.96), (0.42, 0.24, 0.16), "wood_light", parent=root, bevel=0.03,
        rotation=(0, 0, 10))
    box("RadioGuts", (0.15, -0.1, 0.9), (0.2, 0.16, 0.06), "green", parent=root, bevel=0.01, rotation=(0, 0, -15))
    box("Screwdriver", (0.55, -0.25, 0.88), (0.3, 0.04, 0.04), "red", parent=root, rotation=(0, 0, 30), bevel=0.01)
    for side, x, colour in (("Copper", 1.25, "rust_light"), ("Parts", -1.25, "green")):
        box(f"Bin{side}", (x, 0, 0.24), (0.5, 0.5, 0.48), colour, parent=root, bevel=0.04)
        box(f"Bin{side}Label", (x, -0.255, 0.3), (0.26, 0.01, 0.12), "cream", parent=root, bevel=0.0)
    cylinder("LampArm", (-0.7, 0.35, 1.15), 0.02, 0.6, "steel", vertices=6, parent=root, rotation=(0, 15, 0))
    cylinder("LampShade", (-0.55, 0.3, 1.45), 0.12, 0.14, "mustard", vertices=10, radius_top=0.05, parent=root,
             rotation=(0, 160, 0))
    return root


def build_equipment_crowbar():
    kit.seed(440)
    root = kit.root("CrowbarRack")
    box("Post", (0, 0, 0.65), (0.1, 0.1, 1.3), "wood_dark", parent=root, bevel=0.02)
    box("Hook", (0, -0.08, 1.15), (0.05, 0.12, 0.05), "steel", parent=root, bevel=0.01)
    bar = box("Bar", (0.02, -0.13, 0.72), (0.06, 0.06, 0.9), "red", parent=root, rotation=(0, 6, 0), bevel=0.02)
    box("Claw", (0.06, 0, -0.42), (0.18, 0.06, 0.06), "red", parent=bar, rotation=(0, -30, 0), bevel=0.02)
    box("Tag", (0.1, -0.17, 0.95), (0.1, 0.01, 0.07), "cream", parent=root, rotation=(0, 15, 0), bevel=0.0)
    return root


def build_equipment_hoist():
    kit.seed(450)
    root = kit.root("Hoist")
    apex_height = 1.9
    for index in range(3):
        angle = math.radians(index * 120.0)
        fx, fy = math.sin(angle) * 0.6, math.cos(angle) * 0.6
        horizontal = math.hypot(fx, fy)
        length = math.hypot(horizontal, apex_height)
        tilt = math.degrees(math.atan2(horizontal, apex_height))
        yaw = math.degrees(math.atan2(-fx / horizontal, fy / horizontal))
        box(f"Leg{index}", (fx / 2, fy / 2, apex_height / 2), (0.07, 0.07, length), "steel", parent=root,
            rotation=(tilt, 0, yaw), bevel=0.015)
    box("Top", (0, 0, 1.9), (0.2, 0.2, 0.1), "steel", parent=root, bevel=0.02)
    box("Block", (0, 0, 1.6), (0.24, 0.16, 0.3), "mustard", parent=root, bevel=0.04)
    for index in range(7):
        torus(f"Chain{index}", (0, 0, 1.38 - index * 0.09), 0.03, 0.008, "steel_light",
              rotation=(90 if index % 2 else 0, 0, 90), parent=root, segments=8)
    box("Hook", (0, 0, 0.7), (0.12, 0.04, 0.14), "red", parent=root, bevel=0.02)
    return root


def build_equipment_handcart():
    kit.seed(460)
    root = kit.root("Handcart")
    box("Bed", (0, 0, 0.42), (0.85, 1.25, 0.08), "teal", parent=root, bevel=0.03)
    for side, x in (("L", -0.42), ("R", 0.42)):
        box(f"Side{side}", (x, 0, 0.56), (0.05, 1.25, 0.25), "teal", parent=root, bevel=0.015)
        cylinder(f"Wheel{side}", (x * 1.18, 0.2, 0.28), 0.28, 0.1, "tyre", vertices=16, rotation=(0, 90, 0),
                 parent=root, bevel=0.03)
        cylinder(f"Hub{side}", (x * 1.22, 0.2, 0.28), 0.1, 0.06, "mustard", vertices=10, rotation=(0, 90, 0),
                 parent=root)
        box(f"Arm{side}", (x * 0.75, -0.85, 0.55), (0.05, 0.5, 0.05), "wood_dark", parent=root, bevel=0.01)
    box("Handle", (0, -1.1, 0.55), (0.65, 0.06, 0.06), "wood_dark", parent=root, bevel=0.02)
    box("Stand", (0, 0.55, 0.2), (0.06, 0.06, 0.4), "steel", parent=root, bevel=0.01)
    box("PriceTag", (0.3, -0.63, 0.65), (0.12, 0.01, 0.08), "cream", parent=root, rotation=(0, 20, 0), bevel=0.0)
    return root


# --- Small finds -----------------------------------------------------------------
# Items are a little oversized so they read at gameplay zoom (2.2).

def build_item_bolt():
    kit.seed(500)
    root = kit.root("RustedBolt")
    cylinder("Shaft", (0, 0.05, 0.06), 0.05, 0.38, "rust", vertices=8, rotation=(90, 0, 0), parent=root)
    for index in range(5):
        torus(f"Thread{index}", (0, 0.13 + index * 0.05, 0.06), 0.05, 0.012, "rust_light", rotation=(90, 0, 0),
              parent=root, segments=8)
    cylinder("Head", (0, -0.16, 0.06), 0.11, 0.07, "rust_light", vertices=6, rotation=(90, 0, 0), parent=root)
    return root


def build_item_can():
    kit.seed(510)
    root = kit.root("EmptyCan")
    cylinder("Body", (0, 0, 0.11), 0.11, 0.3, "steel_light", vertices=12, rotation=(0, 90, 0), parent=root,
             jitter=0.008)
    cylinder("Label", (0.02, 0, 0.11), 0.113, 0.16, "red", vertices=12, rotation=(0, 90, 0), parent=root)
    box("LabelStripe", (0.02, -0.1, 0.17), (0.16, 0.02, 0.03), "cream", parent=root, bevel=0.0)
    return root


def build_item_wire_coil():
    kit.seed(520)
    root = kit.root("WireCoil")
    for index in range(4):
        torus(f"Loop{index}", (0.02 * index, 0, 0.04 + index * 0.03), 0.17 + index * 0.01, 0.025, "rust_light",
              rotation=(_r(-8, 8), _r(-8, 8), 0), parent=root, segments=16)
    cylinder("LooseEnd", (0.22, -0.1, 0.06), 0.015, 0.25, "rust_light", vertices=6, rotation=(80, 0, 40),
             parent=root)
    return root


def build_item_wood_offcut():
    kit.seed(530)
    root = kit.root("WoodOffcut")
    box("Plank", (0, 0, 0.04), (0.6, 0.18, 0.08), "wood_light", parent=root, rotation=(0, 0, 15), bevel=0.015,
        jitter=0.01)
    box("Chunk", (0.05, 0.12, 0.12), (0.28, 0.14, 0.09), "wood", parent=root, rotation=(0, 0, -30), bevel=0.02)
    rivet("Nail", (0.15, 0.02, 0.09), parent=root, size=0.025)
    return root


def build_item_copper_pipe():
    kit.seed(540)
    root = kit.root("CopperPipe")
    cylinder("Pipe", (-0.05, 0, 0.06), 0.05, 0.6, "rust_light", vertices=10, rotation=(0, 90, 20), parent=root)
    cylinder("Elbow", (0.27, 0.07, 0.1), 0.06, 0.16, "rust_light", vertices=10, rotation=(90, 0, 20), parent=root)
    box("Patina", (0.0, -0.05, 0.1), (0.14, 0.02, 0.03), "teal", parent=root, rotation=(0, 0, 20), bevel=0.0)
    return root


def build_item_brass_figurine():
    kit.seed(550)
    root = kit.root("BrassFigurine")
    cylinder("Base", (0, 0, 0.03), 0.11, 0.06, "wood_dark", vertices=12, parent=root)
    box("Body", (0, 0, 0.18), (0.1, 0.08, 0.2), "brass", parent=root, bevel=0.035)
    sphere("Head", (0, 0, 0.33), 0.055, "brass", parent=root)
    cylinder("Hat", (0, 0, 0.39), 0.045, 0.06, "brass", vertices=10, parent=root)
    box("Arm", (0.07, -0.03, 0.22), (0.1, 0.03, 0.03), "brass", parent=root, rotation=(0, 20, 0), bevel=0.01)
    box("TinyBody", (0.13, -0.05, 0.26), (0.03, 0.03, 0.06), "brass", parent=root, bevel=0.01)
    sphere("TinyHead", (0.13, -0.05, 0.31), 0.018, "brass", parent=root)
    return root


def build_item_radio():
    kit.seed(560)
    root = kit.root("BrokenRadio")
    body = box("Case", (0, 0, 0.18), (0.56, 0.26, 0.34), "wood_light", parent=root, bevel=0.05, rotation=(0, 4, 0))
    cylinder("Speaker", (-0.11, -0.135, 0.18), 0.1, 0.02, "ink", vertices=14, rotation=(90, 0, 0), parent=root)
    for index in range(3):
        box(f"Grille{index}", (-0.11, -0.148, 0.12 + index * 0.06), (0.17, 0.01, 0.015), "wood_dark", parent=root,
            bevel=0.0)
    box("Dial", (0.14, -0.135, 0.23), (0.17, 0.02, 0.09), "cream", parent=root, bevel=0.01)
    box("Needle", (0.12, -0.148, 0.23), (0.01, 0.01, 0.08), "red", parent=root, bevel=0.0)
    for index in range(2):
        cylinder(f"Knob{index}", (0.08 + index * 0.12, -0.14, 0.1), 0.03, 0.03, "brass", vertices=8,
                 rotation=(90, 0, 0), parent=root)
    cylinder("Antenna", (0.2, 0.0, 0.55), 0.01, 0.45, "steel_light", vertices=6, rotation=(0, -28, 0),
             parent=root, bevel=0.0)
    tape("Tape", (-0.1, -0.13, 0.3), 0.2, parent=root, rotation=(0, 20, 0), width=0.04)
    return root


def build_item_copper_spool():
    kit.seed(570)
    root = kit.root("CopperSpool")
    cylinder("Core", (0, 0, 0.13), 0.13, 0.2, "rust_light", vertices=14, parent=root)
    for z in (0.02, 0.24):
        cylinder(f"Flange{z}", (0, 0, z), 0.19, 0.03, "wood_dark", vertices=14, parent=root)
    return root


def build_item_electronic_parts():
    kit.seed(580)
    root = kit.root("ElectronicParts")
    box("Board", (0, 0, 0.015), (0.38, 0.28, 0.03), "green", parent=root, rotation=(0, 0, 12), bevel=0.008)
    box("Chip", (-0.06, 0.02, 0.05), (0.11, 0.08, 0.03), "ink", parent=root, rotation=(0, 0, 12), bevel=0.008)
    cylinder("Capacitor", (0.1, 0.07, 0.07), 0.03, 0.09, "teal", vertices=8, parent=root)
    cylinder("Tube", (0.1, -0.08, 0.1), 0.04, 0.14, "glass", vertices=8, parent=root, radius_top=0.035)
    return root


# --- Plants -----------------------------------------------------------------------

def build_weed_tuft(variant):
    """Grass tuft, optionally with a flower. Scattered along fences and corners."""
    kit.seed(600 + variant)
    root = kit.root("WeedTuft")
    for index in range(5 + variant):
        angle = index * (360 / (5 + variant)) + _r(-15, 15)
        cylinder(f"Blade{index}", (math.sin(math.radians(angle)) * 0.05, math.cos(math.radians(angle)) * 0.05, 0.14),
                 0.035, 0.3 + _r(0, 0.12), "moss" if index % 2 else "green", vertices=4, radius_top=0.0,
                 rotation=(_r(10, 25), 0, angle), parent=root, bevel=0.0)
    if variant == 1:
        sphere("Flower", (0.0, 0.03, 0.36), 0.05, "mustard", parent=root)
    if variant == 2:
        sphere("Flower", (0.02, -0.02, 0.4), 0.05, "red", parent=root)
    return root


ASSETS = {
    "fence_tall_a": (lambda: build_fence_tall(0), {"focus": (0, 0, 1.0), "ortho_scale": 5.0}),
    "fence_tall_b": (lambda: build_fence_tall(1), {"focus": (0, 0, 1.0), "ortho_scale": 5.0}),
    "fence_tall_c": (lambda: build_fence_tall(2), {"focus": (0, 0, 1.0), "ortho_scale": 5.0}),
    "fence_low_a": (lambda: build_fence_low(0), {"focus": (0, 0, 0.5), "ortho_scale": 5.0}),
    "fence_low_b": (lambda: build_fence_low(1), {"focus": (0, 0, 0.5), "ortho_scale": 5.0}),
    "fence_low_c": (lambda: build_fence_low(2), {"focus": (0, 0, 0.5), "ortho_scale": 5.0}),
    "gate": (build_gate, {"focus": (0, 0, 1.3), "ortho_scale": 7.0}),
    "brick_wall": (build_brick_wall, {"focus": (0, 0, 0.9), "ortho_scale": 5.0}),
    "girder": (build_girder, {"focus": (0, 0, 1.2), "ortho_scale": 3.0}),
    "scrap_heap_large": (lambda: build_scrap_heap("large"), {"focus": (0, 0, 1.0), "ortho_scale": 7.0}),
    "scrap_heap_small": (lambda: build_scrap_heap("small"), {"focus": (0, 0, 0.7), "ortho_scale": 4.5}),
    "scrap_heap_pile": (lambda: build_scrap_heap("pile"), {"focus": (0, 0, 0.6), "ortho_scale": 4.5}),
    "car_wreck": (build_car_wreck, {"focus": (0, 0, 0.8), "ortho_scale": 5.5}),
    "container": (build_container, {"focus": (0, 0, 1.3), "ortho_scale": 8.0}),
    "engine_block": (build_engine_block, {"focus": (0, 0, 0.5), "ortho_scale": 2.6}),
    "crate_stack": (build_crate_stack, {"focus": (0.5, 0, 0.8), "ortho_scale": 3.8}),
    "barrel_group": (build_barrel_group, {"focus": (0.45, 0.45, 0.7), "ortho_scale": 3.2}),
    "storage_shelf": (build_shelf, {"focus": (0, 0, 1.1), "ortho_scale": 4.2}),
    "pallet_stack": (build_pallet_stack, {"focus": (0, 0, 0.3), "ortho_scale": 2.2}),
    "tyre_stack": (build_tyre_stack, {"focus": (0.6, -0.3, 0.4), "ortho_scale": 3.2}),
    "bathtub_planter": (build_bathtub_planter, {"focus": (0, 0, 0.5), "ortho_scale": 2.6}),
    "floodlight": (build_floodlight, {"focus": (0, 0, 1.8), "ortho_scale": 4.5}),
    "dismantle_table": (build_dismantle_table, {"focus": (0, 0, 0.7), "ortho_scale": 3.6}),
    "equipment_crowbar": (build_equipment_crowbar, {"focus": (0, 0, 0.7), "ortho_scale": 1.8}),
    "equipment_hoist": (build_equipment_hoist, {"focus": (0, 0, 1.0), "ortho_scale": 2.8}),
    "equipment_handcart": (build_equipment_handcart, {"focus": (0, 0, 0.5), "ortho_scale": 2.6}),
    "scrap_rusted_bolt": (build_item_bolt, {"focus": (0, 0, 0.1), "ortho_scale": 0.8}),
    "scrap_empty_can": (build_item_can, {"focus": (0, 0, 0.1), "ortho_scale": 0.8}),
    "scrap_wire_coil": (build_item_wire_coil, {"focus": (0, 0, 0.1), "ortho_scale": 0.9}),
    "scrap_wood_offcut": (build_item_wood_offcut, {"focus": (0, 0, 0.1), "ortho_scale": 0.9}),
    "scrap_copper_pipe": (build_item_copper_pipe, {"focus": (0, 0, 0.1), "ortho_scale": 0.9}),
    "find_brass_figurine": (build_item_brass_figurine, {"focus": (0, 0, 0.2), "ortho_scale": 0.7}),
    "device_broken_radio": (build_item_radio, {"focus": (0, 0, 0.2), "ortho_scale": 1.0}),
    "mat_copper_wire": (build_item_copper_spool, {"focus": (0, 0, 0.1), "ortho_scale": 0.7}),
    "mat_electronic_parts": (build_item_electronic_parts, {"focus": (0, 0, 0.05), "ortho_scale": 0.7}),
    "weed_a": (lambda: build_weed_tuft(0), {"focus": (0, 0, 0.15), "ortho_scale": 0.8}),
    "weed_b": (lambda: build_weed_tuft(1), {"focus": (0, 0, 0.15), "ortho_scale": 0.8}),
    "weed_c": (lambda: build_weed_tuft(2), {"focus": (0, 0, 0.15), "ortho_scale": 0.8}),
}
