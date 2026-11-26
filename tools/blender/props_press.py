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


def build_bale_steel():
    """A pressed bale of cans and bolts, strapped with two steel bands."""
    kit.seed(1421)
    root = kit.root("BaleSteel")
    colours = ["steel", "steel_light", "rust", "rust_light", "red", "teal", "mustard", "steel"]
    box("Core", (0, 0, 0.17), (0.42, 0.32, 0.32), "steel", parent=root, bevel=0.02)
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
        box(f"Strap{side}", (x, 0, 0.17), (0.025, 0.34, 0.345), "steel_light", parent=root, bevel=0.003)
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


ASSETS = {
    "scrap_press": (build_scrap_press, {"focus": (0, 0, 1.0), "ortho_scale": 3.2}),
    "press_tray": (build_press_tray, {"focus": (0, 0, 0.1), "ortho_scale": 1.6}),
    "bale_steel": (build_bale_steel, {"focus": (0, 0, 0.17), "ortho_scale": 0.8}),
    "conveyor_straight": (build_conveyor_straight, {"focus": (0, 0, 0.2), "ortho_scale": 1.0}),
    "conveyor_corner": (build_conveyor_corner, {"focus": (0, 0, 0.2), "ortho_scale": 1.0}),
}
