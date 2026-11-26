"""P2 story models: Scrappy, his buried head, the red toolbox, the entrance
improvement (docs/p2-arrival-and-scrappy.md, scrappy-companion.md section 25).

Scrappy is built from pivoted groups for ScrappyAnimator: Chassis (wheels),
Body, Head (neck pivot) with EyeL/EyeR (each with a Lid), Antenna, ArmL, ArmR.
"""
import math

import kit
from kit import box, cylinder, group, patch, rivet, sphere, tape, torus, wonk


def _head(parent, dormant=False):
    """Scrappy's head: dented teal box, two big asymmetric eyes with lids,
    speaker grille, bent antenna with a red tip, a rust patch."""
    head_box = box("HeadShell", (0, 0, 0.15), (0.38, 0.3, 0.28), "teal", parent=parent, bevel=0.06, jitter=0.006)
    patch("HeadPatch", (0.13, -0.155, 0.24), (0.1, 0.08), "rust_light", parent=parent, rivets=2)
    box("Brow", (0, -0.15, 0.27), (0.3, 0.03, 0.03), "steel", parent=parent, bevel=0.01)
    for side, x, radius in (("L", -0.085, 0.078), ("R", 0.09, 0.062)):
        eye = group(f"Eye{side}", location=(x, -0.155, 0.16), parent=parent)
        cylinder(f"EyeRim{side}", (0, 0, 0), radius + 0.016, 0.04, "steel_light", vertices=16, rotation=(90, 0, 0),
                 parent=eye, bevel=0.008)
        cylinder(f"EyeWhite{side}", (0, -0.012, 0), radius, 0.03, "ink" if dormant else "cream", vertices=16,
                 rotation=(90, 0, 0), parent=eye, bevel=0.004)
        if not dormant:
            cylinder(f"Pupil{side}", (0.0, -0.03, -0.005), radius * 0.45, 0.02, "ink", vertices=12,
                     rotation=(90, 0, 0), parent=eye, bevel=0.003)
            sphere(f"Shine{side}", (radius * 0.25, -0.04, radius * 0.25), radius * 0.15, "cream", parent=eye)
        lid = group(f"Lid{side}", location=(0, -0.03, radius * (1.05 if not dormant else 0.5)), parent=eye)
        box(f"LidPlate{side}", (0, 0, 0), (radius * 2.3, 0.02, radius * 0.5 if not dormant else radius * 2.1),
            "steel", parent=lid, bevel=0.006)
    for index in range(3):
        box(f"Grille{index}", (0, -0.152, 0.055 - index * 0.025), (0.12, 0.012, 0.01), "ink", parent=parent,
            bevel=0.002)
    antenna = group("Antenna", location=(0.12, 0.02, 0.29), parent=parent)
    cylinder("AntennaBase", (0, 0, 0.02), 0.025, 0.04, "steel", vertices=8, parent=antenna)
    cylinder("AntennaRod1", (0, 0, 0.11), 0.008, 0.16, "steel_light", vertices=6, parent=antenna, bevel=0.0)
    cylinder("AntennaRod2", (0.03, 0, 0.22), 0.008, 0.1, "steel_light", vertices=6, rotation=(0, 35, 0),
             parent=antenna, bevel=0.0)
    sphere("AntennaTip", (0.06, 0, 0.27), 0.028, "red", parent=antenna)
    for side, x in (("L", -0.2), ("R", 0.2)):
        cylinder(f"EarBolt{side}", (x, 0, 0.15), 0.04, 0.04, "steel", vertices=8, rotation=(0, 90, 0), parent=parent)
    return head_box


def build_scrappy():
    """Scrappy on Walt's emergency chassis: a paint bucket on a skateboard."""
    kit.seed(700)
    root = kit.root("Scrappy")
    chassis = group("Chassis", parent=root)
    box("Board", (0, 0, 0.09), (0.34, 0.56, 0.035), "wood_dark", parent=chassis, bevel=0.015)
    box("BoardStripe", (0, 0, 0.11), (0.08, 0.5, 0.005), "mustard", parent=chassis, bevel=0.0)
    for index, (x, y) in enumerate(((-0.14, -0.2), (0.14, -0.2), (-0.14, 0.2), (0.14, 0.2))):
        wheel = group(f"Wheel{index}", location=(x, y, 0.045), parent=chassis)
        cylinder(f"Tyre{index}", (0, 0, 0), 0.045, 0.035, "red", vertices=12, rotation=(0, 90, 0), parent=wheel)
    body = group("Body", location=(0, 0, 0.11), parent=root)
    cylinder("Bucket", (0, 0, 0.15), 0.16, 0.3, "mustard", vertices=16, radius_top=0.18, parent=body,
             jitter=0.004)
    torus("BucketRim", (0, 0, 0.3), 0.18, 0.015, "steel", parent=body, segments=16)
    for index, (angle, length) in enumerate(((20, 0.1), (75, 0.06), (130, 0.13), (220, 0.08))):
        x = math.sin(math.radians(angle)) * 0.168
        y = -math.cos(math.radians(angle)) * 0.168
        box(f"Drip{index}", (x, y, 0.3 - length / 2), (0.035, 0.01, length), "teal", parent=body,
            rotation=(0, 0, -angle), bevel=0.004)
    torus("Handle", (0, 0.0, 0.33), 0.16, 0.01, "steel_light", rotation=(90, 0, 90), parent=body, segments=16)
    # Bow tie (cosmetic accessory).
    for side, x in (("L", -0.035), ("R", 0.035)):
        box(f"Bow{side}", (x, -0.18, 0.27), (0.06, 0.02, 0.045), "red", parent=body,
            rotation=(0, 25 if side == "L" else -25, 0), bevel=0.008)
    sphere("BowKnot", (0, -0.19, 0.27), 0.017, "red", parent=body)
    # Arms: a flashlight (useful) and a grabber claw (tool module).
    arm_left = group("ArmL", location=(-0.17, 0, 0.24), parent=body)
    cylinder("ArmLRod", (-0.03, 0, -0.07), 0.018, 0.16, "steel", vertices=8, rotation=(0, -20, 0), parent=arm_left)
    cylinder("Flashlight", (-0.06, -0.02, -0.17), 0.035, 0.12, "steel_light", vertices=10, rotation=(70, 0, 0),
             parent=arm_left)
    cylinder("FlashLens", (-0.06, -0.08, -0.19), 0.036, 0.01, "cream", vertices=10, rotation=(70, 0, 0),
             parent=arm_left)
    arm_right = group("ArmR", location=(0.17, 0, 0.24), parent=body)
    cylinder("ArmRRod", (0.03, 0, -0.07), 0.018, 0.16, "steel", vertices=8, rotation=(0, 20, 0), parent=arm_right)
    for side, angle in (("A", 20), ("B", -20)):
        box(f"Claw{side}", (0.06, -0.03, -0.17), (0.015, 0.06, 0.06), "rust_light", parent=arm_right,
            rotation=(angle, 0, 0), bevel=0.005)
    neck = group("Head", location=(0, 0, 0.47), parent=root)
    cylinder("Neck", (0, 0, -0.03), 0.035, 0.08, "steel", vertices=8, parent=neck)
    _head(neck)
    return root


def build_scrappy_head_buried():
    """Scrappy's head, dormant and half-buried in rubble; one eye peeks out."""
    kit.seed(710)
    root = kit.root("ScrappyHeadBuried")
    head = group("Head", location=(0, 0, 0.05), rotation=(18, -12, 25), parent=root)
    _head(head, dormant=True)
    for index in range(9):
        angle = index * 40 + kit._rng.uniform(-10, 10)
        radius = kit._rng.uniform(0.2, 0.42)
        box(f"Rubble{index}", (math.cos(math.radians(angle)) * radius, math.sin(math.radians(angle)) * radius + 0.08,
                               kit._rng.uniform(0.05, 0.22)),
            (kit._rng.uniform(0.15, 0.3), kit._rng.uniform(0.12, 0.25), kit._rng.uniform(0.06, 0.14)),
            ["rust", "steel", "rust_light", "wood"][index % 4], rotation=(kit._rng.uniform(-30, 30),
                                                                         kit._rng.uniform(-30, 30), angle),
            parent=root, bevel=0.02)
    box("Sheet", (0.05, 0.12, 0.3), (0.5, 0.4, 0.03), "steel", parent=root, rotation=(28, -12, 30), bevel=0.01)
    return root


def build_red_toolbox():
    """Walt's red toolbox: well kept, a little sticker, Closed/Open states."""
    kit.seed(720)
    root = kit.root("RedToolbox")
    box("Body", (0, 0, 0.15), (0.62, 0.3, 0.28), "red", parent=root, bevel=0.035)
    box("Latch", (0, -0.155, 0.24), (0.1, 0.02, 0.06), "brass", parent=root, bevel=0.008)
    box("Sticker", (-0.18, -0.152, 0.12), (0.14, 0.008, 0.1), "cream", parent=root, rotation=(0, 6, 0), bevel=0.0)
    box("StickerHeart", (-0.18, -0.157, 0.12), (0.04, 0.004, 0.035), "red", parent=root, rotation=(0, 45, 0),
        bevel=0.0)
    closed = group("Closed", parent=root)
    box("Lid", (0, 0, 0.32), (0.64, 0.32, 0.07), "red", parent=closed, bevel=0.03)
    box("Handle", (0, 0, 0.4), (0.3, 0.05, 0.05), "ink", parent=closed, bevel=0.015)
    opened = group("Open", parent=root)
    box("LidOpen", (0, 0.22, 0.42), (0.64, 0.07, 0.3), "red", parent=opened, rotation=(-15, 0, 0), bevel=0.03)
    box("Tray", (0, 0, 0.27), (0.56, 0.24, 0.04), "steel", parent=opened, bevel=0.01)
    box("Velvet", (0, 0, 0.29), (0.3, 0.16, 0.02), "plum", parent=opened, bevel=0.005)
    return root


def build_entrance_improvement():
    """'Eingang herrichten': a freshly painted sign with lanterns, two planters
    and a welcome mat. Origin at the gate centre, front -Y (outside/south)."""
    kit.seed(730)
    root = kit.root("EntranceImprovement")
    board = box("FreshSign", (0, -0.16, 2.55), (5.0, 0.06, 0.58), "mustard", parent=root, bevel=0.03)
    box("FreshFrame", (0, -0.14, 2.55), (5.2, 0.05, 0.7), "teal", parent=root, bevel=0.03)
    cylinder("Gear", (0, -0.2, 2.55), 0.34, 0.05, "rust_light", vertices=16, rotation=(90, 0, 0), parent=root)
    for index in range(8):
        angle = index * 45.0
        box(f"Tooth{index}", (math.sin(math.radians(angle)) * 0.36, -0.2, 2.55 + math.cos(math.radians(angle)) * 0.36),
            (0.1, 0.05, 0.12), "rust_light", rotation=(0, angle, 0), parent=root, bevel=0.015)
    cylinder("GearHole", (0, -0.23, 2.55), 0.12, 0.03, "cream", vertices=12, rotation=(90, 0, 0), parent=root)
    for side, x in (("L", -1.6), ("R", 1.6)):
        for index in range(3):
            sphere(f"Dot{side}{index}", (x + (index - 1) * 0.3, -0.2, 2.55), 0.05, "cream", parent=root)
    for side, x in (("W", -2.3), ("E", 2.3)):
        lantern = group(f"Lantern{side}", location=(x, -0.3, 2.2), parent=root)
        box(f"LanternArm{side}", (0, 0.1, 0.12), (0.04, 0.24, 0.04), "ink", parent=lantern, bevel=0.01)
        box(f"LanternBody{side}", (0, 0, 0), (0.14, 0.14, 0.2), "cream", parent=lantern, bevel=0.03)
        box(f"LanternCap{side}", (0, 0, 0.12), (0.18, 0.18, 0.04), "ink", parent=lantern, bevel=0.01)
        planter = group(f"Planter{side}", location=(x + (0.6 if x < 0 else -0.6), 0.9, 0), parent=root)
        cylinder(f"Pot{side}", (0, 0, 0.22), 0.26, 0.44, "rust_light", vertices=12, radius_top=0.3, parent=planter)
        for leaf in range(5):
            sphere(f"Leaf{side}{leaf}", (kit._rng.uniform(-0.15, 0.15), kit._rng.uniform(-0.15, 0.15),
                                         0.5 + kit._rng.uniform(0, 0.15)), 0.13, "moss", parent=planter,
                   scale=(1, 1, 0.8))
        for bloom in range(3):
            sphere(f"Bloom{side}{bloom}", (kit._rng.uniform(-0.15, 0.15), kit._rng.uniform(-0.15, 0.15), 0.68),
                   0.05, ["red", "mustard", "cream"][bloom], parent=planter)
    box("Mat", (0, 1.4, 0.01), (1.4, 0.8, 0.02), "plum", parent=root, bevel=0.005)
    box("MatStripe", (0, 1.4, 0.022), (1.2, 0.12, 0.005), "mustard", parent=root, bevel=0.0)
    return root


ASSETS = {
    "scrappy": (build_scrappy, {"focus": (0, 0, 0.4), "ortho_scale": 1.3}),
    "scrappy_head_buried": (build_scrappy_head_buried, {"focus": (0, 0, 0.2), "ortho_scale": 1.4}),
    "source_red_toolbox": (build_red_toolbox, {"focus": (0, 0, 0.25), "ortho_scale": 1.1}),
    "entrance_improvement": (build_entrance_improvement, {"focus": (0, 0.5, 1.2), "ortho_scale": 7.0}),
}
