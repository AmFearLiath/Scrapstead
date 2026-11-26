"""P3b machine models: the small magnetic collector and its output crate
(docs/first-machine.md, progression-business-growth.md section 5).

The collector is built from pivoted groups for MagnetAnimator: Turret (yaw on
the column), Boom (fixed to the turret) with Cable (scaled to lower the
magnet; origin at the boom tip, 1 m long downwards) and Magnet (moved down
with the cable). Front -Y in Blender is +Z in Godot: the boom points there.
"""
import math

import kit
from kit import box, cylinder, group, patch, rivet, sphere, tape, torus, wonk

BOOM_LENGTH = 2.1
COLUMN_TOP = 1.15


def build_magnet_collector():
    """A squat second-hand machine on skids: mustard chassis with a teal
    engine box, a hand-painted warning stripe, a slewing column, a girder
    boom and a fat magnet disc on a cable. Footprint about 1.7 x 1.3 m."""
    kit.seed(901)
    root = kit.root("MagnetCollector")
    for side, x in (("L", -0.62), ("R", 0.62)):
        box(f"Skid{side}", (x, 0, 0.06), (0.14, 1.5, 0.12), "ink", parent=root, bevel=0.03)
    chassis = box("Chassis", (0, 0, 0.36), (1.5, 1.15, 0.5), "mustard", parent=root, bevel=0.06, jitter=0.01)
    wonk(chassis, 1.2)
    for index in range(5):
        box(f"Stripe{index}", (-0.6 + index * 0.3, -0.585, 0.2), (0.14, 0.01, 0.12), "ink", parent=root,
            rotation=(0, 35, 0), bevel=0.0)
    patch("ChassisPatch", (0.45, -0.585, 0.45), (0.22, 0.16), "rust_light", parent=root, rotation=(90, 0, 0),
          rivets=4)
    engine = box("EngineBox", (-0.38, 0.28, 0.78), (0.6, 0.5, 0.36), "teal", parent=root, bevel=0.05)
    wonk(engine, 1.5)
    for index in range(4):
        box(f"Vent{index}", (-0.38, 0.03, 0.7 + index * 0.06), (0.4, 0.01, 0.025), "ink", parent=root, bevel=0.0)
    cylinder("Exhaust", (-0.6, 0.45, 1.05), 0.045, 0.5, "steel", vertices=10, parent=root)
    cylinder("ExhaustCap", (-0.6, 0.45, 1.32), 0.06, 0.04, "rust", vertices=10, parent=root,
             rotation=(18, 0, 0))
    # Control box at the front right (the Godot interactable sits here).
    box("ControlBox", (0.5, -0.45, 0.82), (0.34, 0.2, 0.42), "steel_light", parent=root, bevel=0.03)
    box("ControlFace", (0.5, -0.555, 0.85), (0.26, 0.01, 0.3), "cream", parent=root, bevel=0.0)
    cylinder("BigButton", (0.44, -0.57, 0.92), 0.05, 0.03, "red", vertices=12, rotation=(90, 0, 0), parent=root)
    cylinder("Dial", (0.56, -0.57, 0.78), 0.035, 0.02, "ink", vertices=10, rotation=(90, 0, 0), parent=root)
    tape("ControlTape", (0.5, -0.565, 1.0), 0.24, parent=root, width=0.05)
    # Column and turret.
    cylinder("Column", (0.1, 0.05, 0.85), 0.16, 0.6, "steel", vertices=12, parent=root)
    turret = group("Turret", location=(0.1, 0.05, COLUMN_TOP), parent=root)
    cylinder("Ring", (0, 0, 0.0), 0.24, 0.1, "rust_light", vertices=14, parent=turret)
    box("Cab", (0, 0.12, 0.17), (0.34, 0.34, 0.26), "mustard", parent=turret, bevel=0.04)
    sphere("Lamp", (0.0, 0.12, 0.34), 0.06, "mustard", parent=turret)
    boom = group("Boom", location=(0, 0, 0.18), parent=turret)
    for side, x in (("L", -0.07), ("R", 0.07)):
        box(f"Rail{side}", (x, -BOOM_LENGTH * 0.5, 0.06), (0.04, BOOM_LENGTH, 0.06), "rust", parent=boom,
            bevel=0.01, rotation=(-4, 0, 0))
    for index in range(7):
        y = -0.2 - index * 0.28
        box(f"Brace{index}", (0, y, 0.06 + index * 0.02), (0.16, 0.03, 0.03), "rust_light", parent=boom,
            rotation=(0, 0, 25 if index % 2 else -25), bevel=0.005)
    cylinder("Pulley", (0, -BOOM_LENGTH, 0.12), 0.07, 0.06, "steel_light", vertices=12, rotation=(0, 90, 0),
             parent=boom)
    cable = group("Cable", location=(0, -BOOM_LENGTH, 0.1), parent=boom)
    cylinder("CableLine", (0, 0, -0.5), 0.012, 1.0, "ink", vertices=6, parent=cable)
    magnet = group("Magnet", location=(0, -BOOM_LENGTH, 0.1 - 1.0), parent=boom)
    torus("Hook", (0, 0, 0.02), 0.05, 0.012, "steel", parent=magnet, rotation=(90, 0, 0))
    cylinder("MagnetDisc", (0, 0, -0.1), 0.3, 0.14, "red", vertices=16, parent=magnet, bevel=0.03)
    cylinder("MagnetFace", (0, 0, -0.18), 0.27, 0.03, "steel", vertices=16, parent=magnet)
    for index in range(4):
        angle = math.radians(index * 90 + 45)
        rivet(f"MagnetRivet{index}", (math.cos(angle) * 0.2, math.sin(angle) * 0.2, -0.03), parent=magnet) \
            if "parent" in rivet.__code__.co_varnames else None
    box("Warn", (0, -0.31, -0.1), (0.14, 0.01, 0.07), "mustard", parent=magnet, bevel=0.0)
    return root


def build_magnet_bin():
    """Output crate: a dented wire-mesh crate with a cardboard sign."""
    kit.seed(911)
    root = kit.root("MagnetBin")
    box("BinFloor", (0, 0, 0.04), (1.3, 0.9, 0.06), "steel", parent=root, bevel=0.02)
    for side, (x, y, w, d) in {"N": (0, 0.44, 1.3, 0.04), "S": (0, -0.44, 1.3, 0.04),
                               "W": (-0.64, 0, 0.04, 0.9), "E": (0.64, 0, 0.04, 0.9)}.items():
        box(f"Wall{side}", (x, y, 0.2), (w, d, 0.32), "steel_light", parent=root, bevel=0.01)
        bars = 6 if w > d else 4
        for index in range(bars):
            offset = -0.5 + (index + 0.5) / bars
            location = (offset * w, y, 0.2) if w > d else (x, offset * d, 0.2)
            box(f"Bar{side}{index}", location, (0.02, 0.05, 0.32) if w > d else (0.05, 0.02, 0.32), "steel",
                parent=root, bevel=0.0)
    box("Sign", (0.3, -0.47, 0.42), (0.36, 0.02, 0.2), "wood_light", parent=root, rotation=(0, 4, 0), bevel=0.01)
    box("SignInk", (0.3, -0.485, 0.42), (0.26, 0.005, 0.04), "ink", parent=root, rotation=(0, 4, 0), bevel=0.0)
    return root


def build_item_toaster():
    """Broken toaster: chrome-ish box, two slots, a slice of toast stuck
    in one of them for decades, lever and a frayed cord."""
    kit.seed(921)
    root = kit.root("BrokenToaster")
    body = box("Body", (0, 0, 0.16), (0.42, 0.26, 0.3), "steel_light", parent=root, bevel=0.07, rotation=(0, 3, 0))
    wonk(body, 2.0)
    for index, x in enumerate((-0.09, 0.09)):
        box(f"Slot{index}", (x, 0, 0.315), (0.06, 0.2, 0.02), "ink", parent=root, bevel=0.0)
    box("Toast", (0.09, 0.0, 0.35), (0.05, 0.16, 0.1), "wood_light", parent=root, rotation=(0, 6, 0), bevel=0.02)
    box("ToastCrust", (0.09, 0.0, 0.405), (0.055, 0.165, 0.02), "wood_dark", parent=root, rotation=(0, 6, 0),
        bevel=0.008)
    box("Lever", (0.23, 0.0, 0.2), (0.05, 0.07, 0.04), "ink", parent=root, bevel=0.01)
    box("Dial", (0.0, -0.135, 0.1), (0.07, 0.01, 0.07), "red", parent=root, bevel=0.005)
    patch("Scorch", (-0.08, -0.133, 0.22), (0.12, 0.08), "wood_dark", parent=root, rotation=(90, 0, 0), rivets=0)
    cylinder("Cord", (-0.28, 0.05, 0.03), 0.012, 0.22, "ink", vertices=6, rotation=(0, 80, 25), parent=root)
    box("Plug", (-0.4, 0.1, 0.03), (0.05, 0.04, 0.04), "cream", parent=root, bevel=0.01)
    return root


def build_item_sealed_crate():
    """A crate nailed shut with far too many nails and a stencilled warning
    nobody can read any more."""
    kit.seed(931)
    root = kit.root("SealedCrate")
    crate = box("Crate", (0, 0, 0.21), (0.62, 0.46, 0.42), "wood", parent=root, bevel=0.03, jitter=0.01)
    wonk(crate, 1.5)
    for index in range(3):
        box(f"Slat{index}", (0, -0.235, 0.08 + index * 0.13), (0.64, 0.02, 0.07), "wood_light", parent=root,
            bevel=0.01, rotation=(0, kit._rng.uniform(-3, 3), 0))
    for index in range(4):
        box(f"Lid{index}", (-0.23 + index * 0.155, 0, 0.43), (0.13, 0.48, 0.03), "wood_light", parent=root,
            bevel=0.01, rotation=(0, 0, kit._rng.uniform(-4, 4)))
    for index in range(10):
        sphere(f"Nail{index}", (kit._rng.uniform(-0.28, 0.28), kit._rng.uniform(-0.2, 0.2), 0.45), 0.018,
               "steel_light", parent=root)
    box("Stencil", (0.05, -0.248, 0.22), (0.3, 0.005, 0.08), "ink", parent=root, bevel=0.0)
    tape("Tape", (-0.2, -0.24, 0.33), 0.18, colour="red", parent=root, rotation=(0, -25, 0), width=0.04)
    return root


# --- Build-mode decorations (docs/building-system.md) --------------------------

def build_scrap_gnome():
    """Garden gnome welded from scrap: can body, bolt nose, a funnel for a hat
    and a wrench he holds like a fishing rod."""
    kit.seed(941)
    root = kit.root("ScrapGnome")
    box("Base", (0, 0, 0.03), (0.3, 0.3, 0.06), "steel", parent=root, bevel=0.02)
    cylinder("Body", (0, 0, 0.2), 0.11, 0.28, "red", vertices=12, parent=root, bevel=0.02)
    cylinder("Belt", (0, 0, 0.17), 0.115, 0.04, "ink", vertices=12, parent=root)
    sphere("Head", (0, 0, 0.4), 0.09, "skin", parent=root)
    sphere("Beard", (0, -0.06, 0.35), 0.08, "cream", parent=root, scale=(1.0, 0.7, 1.1))
    cylinder("Nose", (0, -0.085, 0.41), 0.022, 0.04, "rust_light", vertices=6, rotation=(90, 0, 0), parent=root)
    cylinder("Hat", (0, 0, 0.56), 0.1, 0.22, "teal", vertices=10, radius_top=0.01, parent=root,
             rotation=(8, 0, 0))
    cylinder("Rod", (0.12, -0.05, 0.38), 0.012, 0.45, "steel_light", vertices=6, parent=root, rotation=(0, -30, 0))
    box("Wrench", (0.24, -0.06, 0.58), (0.06, 0.02, 0.05), "steel_light", parent=root, bevel=0.005)
    return root


def build_tyre_bench():
    """Bench: two stacks of tyres, a weathered plank, a cushion that has seen
    things."""
    kit.seed(951)
    root = kit.root("TyreBench")
    for side, x in (("L", -0.7), ("R", 0.7)):
        for level in range(2):
            torus(f"Tyre{side}{level}", (x, 0, 0.1 + level * 0.19), 0.24, 0.09, "tyre", parent=root)
    plank = box("Plank", (0, 0, 0.46), (1.85, 0.42, 0.07), "wood_light", parent=root, bevel=0.02)
    wonk(plank, 1.0)
    box("Back", (0, 0.2, 0.75), (1.8, 0.06, 0.32), "wood", parent=root, bevel=0.02, rotation=(-8, 0, 0))
    for side, x in (("L", -0.75), ("R", 0.75)):
        box(f"Post{side}", (x, 0.2, 0.62), (0.07, 0.07, 0.4), "wood_dark", parent=root, bevel=0.01)
    box("Cushion", (0.35, -0.02, 0.52), (0.45, 0.35, 0.06), "plum", parent=root, bevel=0.03, rotation=(0, 0, 4))
    patch("CushionPatch", (0.42, -0.02, 0.555), (0.12, 0.1), "mustard", parent=root, rivets=0)
    return root


def build_pipe_flamingo():
    """Flamingo bent from copper pipe, painted pink by someone with ambition."""
    kit.seed(961)
    root = kit.root("PipeFlamingo")
    cylinder("Leg", (0, 0, 0.28), 0.015, 0.56, "steel_light", vertices=6, parent=root)
    cylinder("LegBent", (0.05, 0, 0.33), 0.013, 0.22, "steel_light", vertices=6, parent=root, rotation=(0, 60, 0))
    sphere("Body", (0, 0, 0.62), 0.12, "red", parent=root, scale=(1.4, 0.8, 0.85))
    cylinder("Neck", (-0.13, 0, 0.8), 0.022, 0.32, "red", vertices=8, parent=root, rotation=(0, -25, 0))
    sphere("Head", (-0.2, 0, 0.96), 0.05, "red", parent=root)
    cylinder("Beak", (-0.25, 0, 0.94), 0.015, 0.08, "ink", vertices=6, parent=root, rotation=(0, -70, 0))
    sphere("Eye", (-0.21, -0.04, 0.98), 0.012, "ink", parent=root)
    box("Foot", (0, 0, 0.02), (0.12, 0.08, 0.03), "steel", parent=root, bevel=0.01)
    return root


ASSETS = {
    "magnet_collector": (build_magnet_collector, {"focus": (0, -0.6, 0.9), "ortho_scale": 4.2}),
    "magnet_bin": (build_magnet_bin, {"focus": (0, 0, 0.2), "ortho_scale": 1.8}),
    "device_broken_toaster": (build_item_toaster, {"focus": (0, 0, 0.2), "ortho_scale": 0.9}),
    "sealed_crate": (build_item_sealed_crate, {"focus": (0, 0, 0.25), "ortho_scale": 1.1}),
    "decor_scrap_gnome": (build_scrap_gnome, {"focus": (0, 0, 0.35), "ortho_scale": 0.9}),
    "decor_tyre_bench": (build_tyre_bench, {"focus": (0, 0, 0.45), "ortho_scale": 2.2}),
    "decor_pipe_flamingo": (build_pipe_flamingo, {"focus": (0, 0, 0.5), "ortho_scale": 1.2}),
}
