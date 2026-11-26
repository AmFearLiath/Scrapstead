"""Second machine: the scrap press, its output tray and the steel bale
(docs/scrap-press.md). Front -Y in Blender is +Z in Godot: the output tray
sits in front, the hopper at the back (where a conveyor arrives).

The press is built from groups for ScrapPressAnimator: Ram (moved down along
the press axis; origin at the ram's top), Lever (rotated about X).
"""
import kit
from kit import box, cylinder, group, patch, rivet, sphere, tape, wonk

RAM_TOP = 1.55


def _r(a, b):
    return kit._rng.uniform(a, b)


def build_scrap_press():
    """A squat hydraulic baling press on skids: rust-red chamber, two steel
    columns with a crossbeam, a fat ram, a funnel hopper at the back, a
    control box with a big lever on the right. Footprint about 1.6 x 1.6 m."""
    kit.seed(1401)
    root = kit.root("ScrapPress")
    for side, x in (("L", -0.66), ("R", 0.66)):
        box(f"Skid{side}", (x, 0, 0.06), (0.14, 1.55, 0.12), "ink", parent=root, bevel=0.03)
    base = box("Base", (0, 0, 0.26), (1.45, 1.3, 0.3), "steel", parent=root, bevel=0.05, jitter=0.01)
    wonk(base, 0.8)
    # Pressing chamber, open at the top and the front (the bale leaves there).
    for side, x in (("L", -0.42), ("R", 0.42)):
        box(f"ChamberWall{side}", (x, 0.0, 0.72), (0.08, 0.8, 0.62), "red", parent=root, bevel=0.03)
    box("ChamberBack", (0, 0.38, 0.72), (0.92, 0.08, 0.62), "red", parent=root, bevel=0.03)
    box("ChamberFloor", (0, 0.0, 0.43), (0.8, 0.8, 0.04), "steel_light", parent=root, bevel=0.01)
    patch("ChamberPatch", (-0.465, -0.1, 0.78), (0.24, 0.2), "rust_light", parent=root, rotation=(90, 0, 90),
          rivets=4)
    for index in range(5):
        box(f"Stripe{index}", (-0.36 + index * 0.18, -0.42, 0.47), (0.08, 0.01, 0.07), "ink", parent=root,
            rotation=(0, 35, 0), bevel=0.0)
    for index in range(5):
        box(f"StripeY{index}", (-0.36 + index * 0.18, -0.415, 0.47), (0.08, 0.008, 0.07), "mustard", parent=root,
            rotation=(0, -35, 0), bevel=0.0)
    # Frame: two columns and a crossbeam carrying the hydraulic cylinder.
    for side, x in (("L", -0.55), ("R", 0.55)):
        box(f"Column{side}", (x, 0.05, 1.15), (0.12, 0.16, 1.5), "steel", parent=root, bevel=0.02)
        for index in range(3):
            rivet(f"ColumnRivet{side}{index}", (x, -0.035, 0.7 + index * 0.4), parent=root)
    box("Crossbeam", (0, 0.05, 1.95), (1.3, 0.22, 0.2), "rust", parent=root, bevel=0.03)
    cylinder("Cylinder", (0, 0.05, 1.75), 0.14, 0.45, "mustard", vertices=14, parent=root, bevel=0.03)
    cylinder("CylinderCap", (0, 0.05, 2.07), 0.1, 0.06, "steel_light", vertices=12, parent=root)
    cylinder("Hose", (0.2, 0.2, 1.6), 0.025, 0.9, "ink", vertices=8, parent=root, rotation=(0, 25, 0))
    ram = group("Ram", location=(0, 0.0, RAM_TOP), parent=root)
    cylinder("RamRod", (0, 0.05, -0.2), 0.06, 0.4, "steel_light", vertices=12, parent=ram)
    box("RamPlate", (0, 0.0, -0.45), (0.76, 0.72, 0.1), "steel", parent=ram, bevel=0.02)
    box("RamWarn", (0, -0.365, -0.45), (0.5, 0.01, 0.05), "mustard", parent=ram, bevel=0.0)
    # Hopper funnel at the back, fed by hand or by a conveyor.
    box("HopperFloor", (0, 0.62, 1.05), (0.7, 0.42, 0.04), "steel_light", parent=root, rotation=(-28, 0, 0),
        bevel=0.01)
    for side, x in (("L", -0.36), ("R", 0.36)):
        box(f"HopperSide{side}", (x, 0.66, 1.18), (0.04, 0.46, 0.3), "teal", parent=root, rotation=(-28, 0, 0),
            bevel=0.01)
    box("HopperBack", (0, 0.86, 1.26), (0.76, 0.04, 0.3), "teal", parent=root, bevel=0.01)
    for index in range(3):
        box(f"HopperLeg{index}", (-0.3 + index * 0.3, 0.84, 0.65), (0.05, 0.05, 0.8), "steel", parent=root,
            bevel=0.01)
    tape("HopperTape", (0, 0.885, 1.32), 0.6, parent=root, width=0.05)
    # Control box with a big lever on the right.
    box("ControlBox", (0.68, -0.4, 0.72), (0.22, 0.3, 0.5), "steel_light", parent=root, bevel=0.03)
    box("ControlFace", (0.795, -0.4, 0.76), (0.01, 0.22, 0.32), "cream", parent=root, bevel=0.0)
    sphere("Lamp", (0.68, -0.4, 1.0), 0.05, "mustard", parent=root)
    lever = group("Lever", location=(0.82, -0.4, 0.66), parent=root)
    cylinder("LeverRod", (0, 0, 0.18), 0.02, 0.36, "ink", vertices=8, parent=lever)
    sphere("LeverKnob", (0, 0, 0.37), 0.05, "red", parent=lever)
    # Walt's sign: a hand-painted warning that warns about the wrong thing.
    box("Sign", (-0.68, -0.3, 1.25), (0.02, 0.42, 0.26), "wood_light", parent=root, rotation=(0, 0, 4),
        bevel=0.01)
    box("SignInk", (-0.692, -0.3, 1.27), (0.005, 0.32, 0.04), "ink", parent=root, rotation=(0, 0, 4), bevel=0.0)
    box("SignInk2", (-0.692, -0.3, 1.2), (0.005, 0.22, 0.03), "red", parent=root, rotation=(0, 0, 4), bevel=0.0)
    return root


def build_press_tray():
    """Output tray in front of the press: a low steel tray on a pallet."""
    kit.seed(1411)
    root = kit.root("PressTray")
    for index in range(3):
        box(f"PalletBoard{index}", (0, -0.3 + index * 0.3, 0.05), (1.2, 0.22, 0.04), "wood", parent=root, bevel=0.01)
    for side, x in (("L", -0.5), ("C", 0.0), ("R", 0.5)):
        box(f"PalletBlock{side}", (x, 0, 0.02), (0.12, 0.8, 0.05), "wood_dark", parent=root, bevel=0.01)
    box("TrayFloor", (0, 0, 0.1), (1.15, 0.78, 0.03), "steel", parent=root, bevel=0.01)
    for side, (x, y, w, d) in {"N": (0, 0.38, 1.15, 0.03), "W": (-0.57, 0, 0.03, 0.78),
                               "E": (0.57, 0, 0.03, 0.78)}.items():
        box(f"TrayWall{side}", (x, y, 0.16), (w, d, 0.12), "steel_light", parent=root, bevel=0.01)
    return root


def _bale(name, seed, core, colours, strap):
    """A pressed, strapped bale with crushed pieces sticking out on every side."""
    kit.seed(seed)
    root = kit.root(name)
    box("Core", (0, 0, 0.17), (0.42, 0.32, 0.32), core, parent=root, bevel=0.02)
    faces = [((0, -1), 0.165), ((0, 1), 0.165), ((1, 0), 0.215), ((-1, 0), 0.215), ((0, 0), 0.335)]
    for index in range(44):
        (fx, fy), depth = faces[index % len(faces)]
        if fx == 0 and fy == 0:
            location = (_r(-0.2, 0.2), _r(-0.15, 0.15), depth)
            size = (_r(0.06, 0.14), _r(0.05, 0.12), 0.02)
        elif fx == 0:
            location = (_r(-0.2, 0.2), fy * depth, _r(0.04, 0.3))
            size = (_r(0.06, 0.14), 0.02, _r(0.04, 0.1))
        else:
            location = (fx * depth, _r(-0.15, 0.15), _r(0.04, 0.3))
            size = (0.02, _r(0.06, 0.12), _r(0.04, 0.1))
        box(f"Crush{index}", location, size, colours[index % len(colours)], parent=root,
            rotation=(_r(-12, 12), _r(-12, 12), _r(-20, 20)), bevel=0.005)
    for side, x in (("L", -0.11), ("R", 0.11)):
        box(f"Strap{side}", (x, 0, 0.17), (0.025, 0.34, 0.345), strap, parent=root, bevel=0.003)
    return root


def build_bale_steel():
    """A pressed bale of cans and bolts, strapped with two steel bands."""
    return _bale("BaleSteel", 1421, "steel",
                 ["steel", "steel_light", "rust", "rust_light", "red", "teal", "mustard", "steel"], "steel_light")


def build_bale_copper():
    """Copper pipes, wire and circuit boards pressed into a shiny brown bale."""
    return _bale("BaleCopper", 1451, "copper", ["copper", "copper", "brass", "green", "copper", "ink", "rust_light"],
                 "steel_light")


def build_bale_wood():
    """A bundle of offcuts and broken boards, tied with two ropes."""
    kit.seed(1461)
    root = kit.root("BaleWood")
    for row in range(3):
        for column in range(4):
            colour = ["wood", "wood_light", "wood_dark"][(row + column) % 3]
            length = _r(0.44, 0.56)
            box(f"Plank{row}{column}", (_r(-0.03, 0.03), -0.12 + column * 0.08, 0.06 + row * 0.1),
                (length, 0.075, 0.09), colour, parent=root, rotation=(0, _r(-3, 3), _r(-4, 4)), bevel=0.01)
    for side, x in (("L", -0.13), ("R", 0.13)):
        box(f"Rope{side}", (x, 0.0, 0.16), (0.03, 0.36, 0.33), "sand", parent=root, bevel=0.01)
    return root


def build_conveyor_straight():
    """One 0.5 m belt section: steel side rails, a rubber belt over rollers,
    two legs. Travel along Blender -Y (Godot +Z)."""
    kit.seed(1431)
    root = kit.root("ConveyorStraight")
    for side, x in (("L", -0.2), ("R", 0.2)):
        box(f"Rail{side}", (x, 0, 0.3), (0.04, 0.5, 0.08), "mustard", parent=root, bevel=0.01)
        box(f"Leg{side}", (x, 0, 0.14), (0.04, 0.04, 0.26), "steel", parent=root, bevel=0.005)
    box("Belt", (0, 0, 0.31), (0.36, 0.5, 0.03), "tyre", parent=root, bevel=0.005)
    for index in range(3):
        box(f"Cleat{index}", (0, -0.17 + index * 0.17, 0.33), (0.34, 0.025, 0.012), "ink", parent=root, bevel=0.0)
    box("Foot", (0, 0, 0.015), (0.48, 0.08, 0.03), "steel", parent=root, bevel=0.005)
    return root


def build_conveyor_corner():
    """Corner section: a round roller table where the belt turns."""
    kit.seed(1441)
    root = kit.root("ConveyorCorner")
    box("Frame", (0, 0, 0.27), (0.46, 0.46, 0.06), "mustard", parent=root, bevel=0.015)
    cylinder("Table", (0, 0, 0.31), 0.2, 0.03, "steel_light", vertices=16, parent=root)
    for index in range(4):
        box(f"Roller{index}", (0, -0.12 + index * 0.08, 0.33), (0.3, 0.03, 0.02), "steel", parent=root, bevel=0.005,
            rotation=(0, 0, 45))
    for x in (-0.19, 0.19):
        for y in (-0.19, 0.19):
            box(f"Leg{x}{y}", (x, y, 0.13), (0.04, 0.04, 0.26), "steel", parent=root, bevel=0.005)
    return root


def build_sorter():
    """The sorting machine: a hopper at the back drops scrap into a rattling
    drum; three chutes lead to three bins - steel to the left, copper and
    electronics to the front, wood to the right - each with a painted sign.
    Footprint 2.5 x 2.5 m. Groups for SorterAnimator: Drum (spins about X)."""
    kit.seed(1471)
    root = kit.root("Sorter")
    for side, x in (("L", -0.5), ("R", 0.5)):
        box(f"Skid{side}", (x, 0, 0.06), (0.14, 1.4, 0.12), "ink", parent=root, bevel=0.03)
    base = box("Base", (0, 0, 0.35), (1.2, 1.1, 0.5), "teal", parent=root, bevel=0.05)
    wonk(base, 0.8)
    patch("BasePatch", (0.3, -0.555, 0.4), (0.24, 0.18), "rust_light", parent=root, rotation=(90, 0, 0), rivets=4)
    for side, x in (("L", -0.5), ("R", 0.5)):
        box(f"DrumStand{side}", (x, 0, 0.85), (0.08, 0.3, 0.6), "steel", parent=root, bevel=0.01)
    drum = group("Drum", location=(0, 0, 1.15), parent=root)
    cylinder("DrumShell", (0, 0, 0), 0.32, 0.9, "steel_light", vertices=12, rotation=(0, 90, 0), parent=drum,
             bevel=0.02)
    for index in range(4):
        cylinder(f"DrumRib{index}", (-0.33 + index * 0.22, 0, 0), 0.35, 0.04, "rust", vertices=12,
                 rotation=(0, 90, 0), parent=drum, bevel=0.01)
    for index in range(3):
        box(f"DrumSlat{index}", (0, 0, 0), (0.86, 0.06, 0.05), "rust_light", parent=drum,
            rotation=(index * 60, 0, 0), bevel=0.005)
    # Hopper at the back.
    box("HopperFloor", (0, 0.62, 1.45), (0.7, 0.42, 0.04), "steel_light", parent=root, rotation=(-28, 0, 0),
        bevel=0.01)
    for side, x in (("L", -0.36), ("R", 0.36)):
        box(f"HopperSide{side}", (x, 0.66, 1.58), (0.04, 0.46, 0.3), "mustard", parent=root, rotation=(-28, 0, 0),
            bevel=0.01)
    box("HopperBack", (0, 0.86, 1.66), (0.76, 0.04, 0.3), "mustard", parent=root, bevel=0.01)
    for index in range(2):
        box(f"HopperLeg{index}", (-0.3 + index * 0.6, 0.84, 0.75), (0.05, 0.05, 1.5), "steel", parent=root,
            bevel=0.01)
    # Three chutes and bins.
    chutes = {"Steel": ((-0.62, 0, 0.62), (0, 0, -90), "steel"),
              "Copper": ((0, -0.62, 0.62), (0, 0, 0), "copper"),
              "Wood": ((0.62, 0, 0.62), (0, 0, 90), "mustard")}
    for name, (location, rotation, colour) in chutes.items():
        chute = group(f"Chute{name}", location=location, rotation=rotation, parent=root)
        box(f"ChuteFloor{name}", (0, 0, 0), (0.34, 0.55, 0.03), "steel_light", parent=chute,
            rotation=(38, 0, 0), bevel=0.005)
        for side, x in (("L", -0.17), ("R", 0.17)):
            box(f"ChuteSide{name}{side}", (x, 0, 0.05), (0.03, 0.55, 0.1), colour, parent=chute,
                rotation=(38, 0, 0), bevel=0.005)
    bins = {"Steel": (-1.0, 0.0, "steel"), "Copper": (0.0, -1.0, "copper"), "Wood": (1.0, 0.0, "wood")}
    for name, (x, y, colour) in bins.items():
        horizontal = abs(x) > 0.5
        w, d = (0.5, 0.9) if horizontal else (0.9, 0.5)
        box(f"Bin{name}Floor", (x, y, 0.05), (w, d, 0.06), "steel", parent=root, bevel=0.01)
        for side, (ox, oy, sw, sd) in {"A": (0, d / 2, w, 0.03), "B": (0, -d / 2, w, 0.03),
                                       "C": (w / 2, 0, 0.03, d), "D": (-w / 2, 0, 0.03, d)}.items():
            box(f"Bin{name}Wall{side}", (x + ox, y + oy, 0.17), (sw, sd, 0.24), "steel_light", parent=root,
                bevel=0.005)
        sx, sy = (x * 1.27, y) if horizontal else (x, y * 1.27)
        box(f"Bin{name}Sign", (sx, sy, 0.45), (0.3 if not horizontal else 0.02, 0.02 if not horizontal else 0.3, 0.18),
            colour if colour != "steel" else "steel_light", parent=root, bevel=0.005)
        cylinder(f"Bin{name}Post", (sx, sy, 0.2), 0.02, 0.4, "ink", vertices=6, parent=root)
    # Control box at the front right.
    box("ControlBox", (0.55, -0.62, 0.75), (0.24, 0.16, 0.36), "steel_light", parent=root, bevel=0.02)
    box("ControlFace", (0.55, -0.705, 0.78), (0.18, 0.01, 0.24), "cream", parent=root, bevel=0.0)
    sphere("Lamp", (0.55, -0.62, 0.98), 0.045, "mustard", parent=root)
    tape("SorterTape", (-0.3, -0.56, 0.55), 0.4, parent=root, width=0.05)
    return root


ASSETS = {
    "scrap_press": (build_scrap_press, {"focus": (0, 0, 1.0), "ortho_scale": 3.2}),
    "press_tray": (build_press_tray, {"focus": (0, 0, 0.1), "ortho_scale": 1.6}),
    "bale_steel": (build_bale_steel, {"focus": (0, 0, 0.17), "ortho_scale": 0.8}),
    "bale_copper": (build_bale_copper, {"focus": (0, 0, 0.17), "ortho_scale": 0.8}),
    "bale_wood": (build_bale_wood, {"focus": (0, 0, 0.17), "ortho_scale": 0.8}),
    "sorter": (build_sorter, {"focus": (0, 0, 0.8), "ortho_scale": 3.6}),
    "conveyor_straight": (build_conveyor_straight, {"focus": (0, 0, 0.2), "ortho_scale": 1.0}),
    "conveyor_corner": (build_conveyor_corner, {"focus": (0, 0, 0.2), "ortho_scale": 1.0}),
}
