"""Builds Scrapstead's hero props in Blender and exports them as glTF.

    blender -b -P tools/blender/build_props.py -- --out assets/models [--preview DIR] [--only NAME]

Every asset follows docs/world-art-assets.md: chunky bevelled shapes, palette
vertex colours, Walt's repairs on old things, clean shapes on new things.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kit  # noqa: E402
from kit import box, cylinder, group, patch, rivet, sphere, tape, torus, wonk  # noqa: E402


# --- Sales counter -----------------------------------------------------------

def build_sell_counter():
    """Annahmetresen: patched counter, platform scale, taped service bell,
    a receipt spike that has seen too many sales, and a coin sign."""
    kit.seed(11)
    root = kit.root("SellCounter")
    body = box("Counter", (0, 0, 0.47), (2.2, 0.9, 0.94), "wood", parent=root, bevel=0.04, jitter=0.008)
    wonk(body, 1.0)
    for index in range(6):
        x = -0.92 + index * 0.368
        shade = "wood_light" if index % 2 else "wood"
        box(f"Plank{index}", (x, -0.465, 0.47), (0.33, 0.04, 0.88), shade, parent=root, bevel=0.012,
            rotation=(0, kit._rng.uniform(-1.5, 1.5), 0))
    patch("FrontPatch", (0.55, -0.5, 0.36), (0.5, 0.42), "teal", parent=root)
    tape("FrontTape", (-0.62, -0.495, 0.62), 0.62, parent=root, rotation=(0, 24, 0))
    box("Skirt", (0, 0, 0.04), (2.26, 0.96, 0.08), "wood_dark", parent=root, bevel=0.02)
    top = box("Top", (0, -0.04, 0.985), (2.42, 1.12, 0.08), "wood_light", parent=root, bevel=0.025)
    wonk(top, 0.8)
    # Platform scale with a big round dial.
    box("ScalePlate", (-0.58, -0.08, 1.06), (0.72, 0.6, 0.06), "steel", parent=root, bevel=0.02)
    box("ScaleStand", (-0.58, 0.24, 1.25), (0.08, 0.06, 0.34), "steel", parent=root, bevel=0.015)
    cylinder("DialRim", (-0.58, 0.22, 1.5), 0.2, 0.07, "teal", rotation=(90, 0, 0), vertices=20, parent=root)
    cylinder("DialFace", (-0.58, 0.18, 1.5), 0.165, 0.02, "cream", rotation=(90, 0, 0), vertices=20,
             parent=root, bevel=0.004)
    box("DialNeedle", (-0.55, 0.165, 1.53), (0.02, 0.01, 0.15), "red", rotation=(0, -35, 0), parent=root,
        bevel=0.003)
    cylinder("DialHub", (-0.58, 0.16, 1.5), 0.025, 0.02, "ink", rotation=(90, 0, 0), vertices=8, parent=root)
    # Service bell, repaired with tape.
    cylinder("BellBase", (0.32, -0.33, 1.045), 0.11, 0.04, "wood_dark", vertices=14, parent=root)
    sphere("BellDome", (0.32, -0.33, 1.07), 0.09, "brass", scale=(1, 1, 0.7), parent=root)
    cylinder("BellButton", (0.32, -0.33, 1.14), 0.018, 0.04, "brass", vertices=8, parent=root)
    tape("BellTape", (0.32, -0.33, 1.105), 0.2, rotation=(90, 0, 30), parent=root, width=0.035)
    # Cash box and a small stack of coins.
    box("CashBox", (0.82, 0.0, 1.1), (0.36, 0.28, 0.17), "red", parent=root, bevel=0.025)
    box("CashSlot", (0.82, 0.0, 1.185), (0.16, 0.03, 0.01), "ink", parent=root, bevel=0.0)
    for index in range(4):
        cylinder(f"Coin{index}", (0.48 + kit._rng.uniform(-0.01, 0.01), 0.12, 1.035 + index * 0.022),
                 0.055, 0.02, "mustard", vertices=12, parent=root, bevel=0.005)
    # Receipt spike, overflowing.
    cylinder("SpikeBase", (0.06, 0.18, 1.04), 0.06, 0.03, "steel", vertices=10, parent=root)
    cylinder("Spike", (0.06, 0.18, 1.16), 0.008, 0.22, "steel_light", vertices=6, parent=root, bevel=0.0)
    for index in range(5):
        box(f"Receipt{index}", (0.06, 0.18, 1.07 + index * 0.035), (0.14, 0.2, 0.006), "paper",
            rotation=(kit._rng.uniform(-8, 8), kit._rng.uniform(-8, 8), kit._rng.uniform(0, 180)),
            parent=root, bevel=0.0)
    # Sign on two posts behind the counter: a coin, of course.
    for side, x in (("L", -1.0), ("R", 1.0)):
        box(f"SignPost{side}", (x, 0.46, 1.3), (0.09, 0.09, 1.6), "wood_dark", parent=root, bevel=0.02,
            rotation=(0, kit._rng.uniform(-2, 2), 0))
    board = box("SignBoard", (0, 0.44, 2.05), (2.3, 0.07, 0.52), "mustard", parent=root, bevel=0.02)
    wonk(board, 2.0)
    cylinder("SignCoin", (0, 0.4, 2.06), 0.19, 0.05, "rust_light", rotation=(90, 0, 0), vertices=20,
             parent=root)
    cylinder("SignCoinInner", (0, 0.37, 2.06), 0.12, 0.03, "mustard", rotation=(90, 0, 0), vertices=20,
             parent=root)
    for side, x, sign in (("L", -0.55, 1), ("R", 0.55, -1)):
        box(f"Chevron{side}A", (x, 0.4, 2.1), (0.2, 0.03, 0.06), "ink", parent=root, bevel=0.012,
            rotation=(0, sign * 35, 0))
        box(f"Chevron{side}B", (x, 0.4, 2.02), (0.2, 0.03, 0.06), "ink", parent=root, bevel=0.012,
            rotation=(0, -sign * 35, 0))
    for index, (x, z) in enumerate(((-1.05, 2.25), (1.05, 2.25), (-1.05, 1.86), (1.05, 1.86))):
        rivet(f"SignNail{index}", (x, 0.4, z), (90, 0, 0), parent=root, size=0.025)
    tape("SignTape", (0.92, 0.395, 2.2), 0.3, parent=root, rotation=(0, -40, 0))
    return root


# --- Office desk with the mail-order catalog -------------------------------

def build_order_desk():
    """Walt's desk: one leg replaced by a stack of old catalogs, a rotary phone,
    a catalog bristling with bookmarks, an overflowing in-tray."""
    kit.seed(21)
    root = kit.root("OrderDesk")
    top = box("Top", (0, 0, 0.79), (1.6, 0.82, 0.07), "wood", parent=root, bevel=0.025)
    wonk(top, 1.2)
    box("Drawers", (0.5, 0, 0.4), (0.52, 0.76, 0.76), "wood_dark", parent=root, bevel=0.03)
    for index in range(3):
        box(f"Drawer{index}", (0.5, -0.385, 0.62 - index * 0.22), (0.44, 0.02, 0.18), "wood", parent=root,
            bevel=0.01)
        box(f"Knob{index}", (0.5, -0.405, 0.62 - index * 0.22), (0.08, 0.03, 0.035), "brass", parent=root,
            bevel=0.008)
    box("LegBack", (-0.72, 0.32, 0.38), (0.08, 0.08, 0.76), "wood_dark", parent=root, bevel=0.015)
    # The front leg is missing: a stack of old catalogs holds the desk up.
    for index, colour in enumerate(["teal", "mustard", "rust_light", "cream", "teal", "red"]):
        box(f"LegBook{index}", (-0.68, -0.3, 0.06 + index * 0.125), (0.3, 0.24, 0.11), colour, parent=root,
            bevel=0.012, rotation=(0, 0, kit._rng.uniform(-14, 14)))
    # The catalog: fat, with bookmarks.
    book = box("Catalog", (-0.22, -0.06, 0.875), (0.46, 0.34, 0.1), "mustard", parent=root, bevel=0.02,
               rotation=(0, 0, -8))
    box("CatalogPages", (-0.22, -0.06, 0.875), (0.43, 0.31, 0.085), "paper", parent=root, bevel=0.01,
        rotation=(0, 0, -8))
    for index, colour in enumerate(["red", "teal", "rust_light", "moss"]):
        box(f"Bookmark{index}", (-0.36 + index * 0.08, 0.13, 0.95), (0.035, 0.012, 0.12), colour,
            parent=root, bevel=0.0, rotation=(kit._rng.uniform(-12, 12), 0, -8))
    # Rotary phone.
    box("PhoneBody", (0.42, 0.05, 0.88), (0.3, 0.24, 0.12), "ink", parent=root, bevel=0.04)
    cylinder("PhoneDial", (0.42, -0.02, 0.95), 0.075, 0.02, "cream", vertices=14, parent=root,
             rotation=(-25, 0, 0))
    cylinder("PhoneDialHub", (0.42, -0.02, 0.965), 0.025, 0.02, "ink", vertices=8, parent=root,
             rotation=(-25, 0, 0))
    box("Receiver", (0.42, 0.14, 0.99), (0.36, 0.08, 0.06), "ink", parent=root, bevel=0.025)
    torus("PhoneCord", (0.62, 0.12, 0.84), 0.06, 0.012, "ink", rotation=(90, 0, 70), parent=root)
    # In-tray, overflowing.
    box("Tray", (0.06, 0.24, 0.85), (0.34, 0.26, 0.05), "steel", parent=root, bevel=0.01)
    for index in range(5):
        box(f"Paper{index}", (0.06 + kit._rng.uniform(-0.03, 0.03), 0.24, 0.88 + index * 0.012),
            (0.28, 0.22, 0.006), "paper", parent=root, bevel=0.0,
            rotation=(0, 0, kit._rng.uniform(-18, 18)))
    cylinder("Mug", (-0.58, 0.22, 0.88), 0.055, 0.12, "teal", vertices=12, parent=root)
    torus("MugHandle", (-0.52, 0.22, 0.88), 0.035, 0.01, "teal", rotation=(90, 0, 0), parent=root)
    # Sign with a telephone receiver symbol.
    box("SignPost", (-0.92, 0.3, 0.85), (0.07, 0.07, 1.7), "wood_dark", parent=root, bevel=0.015)
    board = box("SignBoard", (-0.92, 0.27, 1.5), (0.56, 0.06, 0.42), "teal", parent=root, bevel=0.02)
    wonk(board, 4.0)
    box("SignIcon", (-0.92, 0.235, 1.52), (0.3, 0.02, 0.08), "cream", parent=root, bevel=0.02)
    box("SignIconL", (-1.04, 0.235, 1.47), (0.07, 0.02, 0.1), "cream", parent=root, bevel=0.02)
    box("SignIconR", (-0.8, 0.235, 1.47), (0.07, 0.02, 0.1), "cream", parent=root, bevel=0.02)
    return root


# --- Search sources -----------------------------------------------------------

def build_rusted_drum():
    """Sealed rusty drum: dented, two rings, red seal and a warning plate."""
    kit.seed(31)
    root = kit.root("RustedDrum")
    body = cylinder("Body", (0, 0, 0.48), 0.38, 0.92, "rust", vertices=14, parent=root, jitter=0.012)
    wonk(body, 2.5)
    for index, z in enumerate((0.22, 0.72)):
        cylinder(f"Ring{index}", (0, 0, z), 0.4, 0.06, "rust_light", vertices=14, parent=root)
    patch("Patch", (0.12, -0.385, 0.48), (0.24, 0.2), "teal", parent=root, rotation=(0, 0, 12), rivets=2)
    box("Warning", (-0.18, -0.36, 0.5), (0.18, 0.02, 0.16), "mustard", parent=root, rotation=(0, 0, -28),
        bevel=0.01)
    box("WarningMark", (-0.18, -0.372, 0.52), (0.03, 0.015, 0.08), "ink", parent=root, rotation=(0, 0, -28),
        bevel=0.0)
    closed = group("Closed", parent=root)
    cylinder("Lid", (0, 0, 0.955), 0.39, 0.04, "steel", vertices=14, parent=closed)
    box("Seal", (0, 0, 0.985), (0.13, 0.46, 0.025), "red", parent=closed, bevel=0.008)
    cylinder("SealWax", (0, -0.12, 0.995), 0.05, 0.025, "red", vertices=10, parent=closed)
    opened = group("Open", parent=root)
    cylinder("LidOff", (0.55, -0.25, 0.03), 0.39, 0.04, "steel", vertices=14, parent=opened,
             rotation=(8, -4, 0))
    cylinder("Dark", (0, 0, 0.93), 0.35, 0.02, "ink", vertices=14, parent=opened, bevel=0.0)
    return root


def build_storage_crate():
    """Crate "Important spare parts": more nails than wood."""
    kit.seed(41)
    root = kit.root("StorageCrate")
    body = box("Body", (0, 0, 0.38), (1.0, 0.8, 0.74), "wood", parent=root, bevel=0.03, jitter=0.006)
    wonk(body, 1.5)
    for index in range(3):
        box(f"Slat{index}", (0, -0.41, 0.15 + index * 0.24), (1.02, 0.03, 0.18),
            "wood_light" if index % 2 else "wood", parent=root, bevel=0.01)
    box("Label", (0.2, -0.43, 0.4), (0.42, 0.012, 0.2), "paper", parent=root, rotation=(0, 4, 0), bevel=0.005)
    box("LabelMark", (0.2, -0.44, 0.4), (0.3, 0.008, 0.035), "red", parent=root, rotation=(0, 4, 0), bevel=0.0)
    tape("LabelTape", (0.2, -0.442, 0.5), 0.46, parent=root, width=0.045)
    closed = group("Closed", parent=root)
    box("Lid", (0, 0, 0.77), (1.02, 0.82, 0.05), "wood_light", parent=closed, bevel=0.015)
    for index, angle in enumerate((14, -9, 3)):
        plank = box(f"Plank{index}", (0, -0.25 + index * 0.25, 0.81), (1.12, 0.12, 0.04), "wood_dark",
                    parent=closed, bevel=0.01, rotation=(0, 0, angle))
        for nail in range(4):
            cylinder(f"Nail{index}_{nail}", (-0.48 + nail * 0.32, 0, 0.025), 0.018, 0.015, "steel_light",
                     vertices=6, parent=plank, bevel=0.004)
    opened = group("Open", parent=root)
    lid = box("LidOff", (-0.92, 0.1, 0.06), (0.82, 1.02, 0.05), "wood_light", parent=opened,
              rotation=(0, 6, 20), bevel=0.015)
    for nail in range(5):
        cylinder(f"BentNail{nail}", (-0.3 + nail * 0.15, -0.3 + nail * 0.12, 0.06), 0.01, 0.09, "steel_light",
                 vertices=6, parent=lid, rotation=(kit._rng.uniform(-30, 30), 20, 0), bevel=0.0)
    box("Dark", (0, 0, 0.73), (0.9, 0.7, 0.02), "ink", parent=opened, bevel=0.0)
    return root


def build_old_toolbox():
    """'Tools' box that never contained tools: dented green steel, taped handle."""
    kit.seed(51)
    root = kit.root("OldToolbox")
    body = box("Body", (0, 0, 0.15), (0.68, 0.34, 0.28), "moss", parent=root, bevel=0.03, jitter=0.004)
    wonk(body, 2.0)
    box("Latch", (0, -0.175, 0.22), (0.1, 0.03, 0.08), "steel_light", parent=root, bevel=0.01)
    box("Label", (-0.18, -0.175, 0.13), (0.2, 0.012, 0.1), "paper", parent=root, bevel=0.005)
    closed = group("Closed", parent=root)
    box("Lid", (0, 0, 0.32), (0.7, 0.36, 0.07), "moss", parent=closed, bevel=0.025)
    box("Handle", (0, 0, 0.4), (0.32, 0.05, 0.05), "ink", parent=closed, bevel=0.015)
    tape("HandleTape", (0.0, 0, 0.42), 0.12, parent=closed, rotation=(90, 0, 0), width=0.06)
    opened = group("Open", parent=root)
    box("LidLeft", (-0.27, 0, 0.36), (0.36, 0.36, 0.04), "moss", parent=opened, rotation=(0, -55, 0),
        bevel=0.015)
    box("LidRight", (0.27, 0, 0.36), (0.36, 0.36, 0.04), "moss", parent=opened, rotation=(0, 55, 0),
        bevel=0.015)
    box("Dark", (0, 0, 0.29), (0.6, 0.28, 0.02), "ink", parent=opened, bevel=0.0)
    return root


def build_metal_beam():
    """Steel I-beam stuck under junk. Groups Beam (shaken) and Debris (removed)."""
    kit.seed(61)
    root = kit.root("MetalBeam")
    beam = group("Beam", location=(0, 0, 0.13), rotation=(0, -8, 15), parent=root)
    box("Web", (0, 0, 0.0), (2.6, 0.07, 0.26), "rust", parent=beam, bevel=0.012)
    box("FlangeTop", (0, 0, 0.14), (2.6, 0.26, 0.05), "rust_light", parent=beam, bevel=0.015)
    box("FlangeBottom", (0, 0, -0.14), (2.6, 0.26, 0.05), "rust_light", parent=beam, bevel=0.015)
    for index in range(4):
        rivet(f"BoltL{index}", (-1.2 + index * 0.8, 0, 0.17), (0, 0, 0), parent=beam, size=0.03)
    debris = group("Debris", parent=root)
    box("Sheet", (0.55, 0.05, 0.42), (1.1, 0.9, 0.05), "steel", parent=debris, rotation=(6, -10, 30),
        bevel=0.012, jitter=0.01)
    for index in range(5):
        box(f"Rib{index}", (0.55 + (index - 2) * 0.2, 0.05, 0.45), (0.05, 0.85, 0.03), "steel_light",
            parent=debris, rotation=(6, -10, 30), bevel=0.008)
    box("Chunk", (1.0, -0.25, 0.48), (0.46, 0.4, 0.34), "steel", parent=debris, rotation=(0, 14, 10),
        bevel=0.04)
    cylinder("Pipe", (0.1, 0.35, 0.45), 0.07, 1.1, "teal", rotation=(80, 0, 40), parent=debris)
    cylinder("Tyre", (-0.6, 0.3, 0.3), 0.3, 0.16, "tyre", vertices=16, rotation=(70, 0, 20), parent=debris)
    cylinder("TyreHub", (-0.6, 0.3, 0.3), 0.12, 0.18, "steel_light", vertices=10, rotation=(70, 0, 20),
             parent=debris)
    return root


# --- Workbench ------------------------------------------------------------------

def build_workbench():
    """Workbench waiting for crafting: pegboard with tool outlines, a vice, and
    the famous red button whose purpose nobody remembers."""
    kit.seed(71)
    root = kit.root("Workbench")
    top = box("Top", (0, 0, 0.87), (2.5, 1.0, 0.1), "wood_light", parent=root, bevel=0.03)
    wonk(top, 0.8)
    for side, x in (("L", -1.12), ("R", 1.12)):
        for depth, y in (("F", -0.4), ("B", 0.4)):
            box(f"Leg{side}{depth}", (x, y, 0.41), (0.1, 0.1, 0.82), "wood_dark", parent=root, bevel=0.02)
    box("Shelf", (0, 0, 0.25), (2.3, 0.85, 0.06), "wood", parent=root, bevel=0.015)
    box("Board", (0, 0.47, 1.55), (2.5, 0.06, 1.25), "cream", parent=root, bevel=0.02)
    for index in range(8):
        for row in range(4):
            cylinder(f"Hole{index}_{row}", (-1.05 + index * 0.3, 0.435, 1.15 + row * 0.27), 0.015, 0.01,
                     "sand", rotation=(90, 0, 0), vertices=6, parent=root, bevel=0.0)
    # Tool outlines painted on the board; one tool is missing (of course).
    for index, (x, w, h) in enumerate(((-0.8, 0.08, 0.5), (-0.45, 0.24, 0.08), (0.45, 0.06, 0.45))):
        box(f"Outline{index}", (x, 0.43, 1.6), (w + 0.04, 0.005, h + 0.04), "ink", parent=root, bevel=0.0)
        if index != 1:
            box(f"Tool{index}", (x, 0.41, 1.6), (w, 0.03, h), "steel" if index else "wood_dark",
                parent=root, bevel=0.01)
    box("HammerHead", (-0.8, 0.4, 1.86), (0.24, 0.06, 0.09), "steel", parent=root, bevel=0.02)
    box("Vice", (0.9, -0.25, 0.98), (0.3, 0.26, 0.16), "teal", parent=root, bevel=0.03)
    box("ViceJaw", (0.9, -0.42, 1.0), (0.28, 0.06, 0.12), "steel", parent=root, bevel=0.015)
    cylinder("ViceScrew", (0.9, -0.52, 0.98), 0.02, 0.2, "steel_light", rotation=(90, 0, 0), parent=root)
    # The red button with a note.
    box("ButtonBox", (-0.15, -0.3, 0.97), (0.18, 0.16, 0.1), "mustard", parent=root, bevel=0.02)
    cylinder("RedButton", (-0.15, -0.3, 1.04), 0.05, 0.05, "red", vertices=12, parent=root)
    box("Note", (-0.15, -0.39, 0.93), (0.16, 0.01, 0.1), "paper", parent=root, rotation=(15, 0, 8), bevel=0.0)
    cylinder("Mug", (0.35, 0.2, 0.98), 0.055, 0.12, "red", vertices=12, parent=root)
    box("Crate", (-0.8, 0.0, 0.38), (0.5, 0.4, 0.2), "wood", parent=root, bevel=0.02)
    return root


# --- Walt's self-driving wheelbarrow (decoration) ------------------------------

def build_wheelbarrow():
    """Parked in a corner. A sign asks not to disturb: it is thinking."""
    kit.seed(81)
    root = kit.root("Wheelbarrow")
    tub = box("Tub", (0.15, 0, 0.62), (1.2, 0.78, 0.42), "teal", parent=root, rotation=(0, 6, 0),
              bevel=0.06, jitter=0.012)
    patch("TubPatch", (0.2, -0.4, 0.6), (0.34, 0.24), "rust_light", parent=root, rivets=4)
    box("Rim", (0.15, 0, 0.85), (1.28, 0.86, 0.05), "teal", parent=root, rotation=(0, 6, 0), bevel=0.02)
    cylinder("Wheel", (0.92, 0, 0.28), 0.28, 0.13, "tyre", vertices=16, rotation=(90, 0, 0), parent=root)
    cylinder("Hub", (0.92, 0, 0.28), 0.1, 0.17, "mustard", vertices=10, rotation=(90, 0, 0), parent=root)
    for side, y in (("L", -0.3), ("R", 0.3)):
        box(f"Handle{side}", (-0.72, y, 0.55), (1.15, 0.07, 0.07), "wood", parent=root, rotation=(0, -12, 0))
        box(f"Leg{side}", (-0.38, y, 0.22), (0.07, 0.07, 0.44), "wood_dark", parent=root)
    # The motor: a coffee tin with a warning lamp nobody understands.
    cylinder("Motor", (-0.15, 0, 0.98), 0.17, 0.3, "steel", vertices=12, parent=root)
    box("MotorLabel", (-0.15, -0.165, 0.98), (0.2, 0.02, 0.12), "red", parent=root, bevel=0.005)
    cylinder("Lamp", (-0.15, 0, 1.18), 0.06, 0.09, "mustard", vertices=10, parent=root)
    cylinder("Antenna", (-0.05, 0.08, 1.35), 0.01, 0.4, "steel_light", vertices=6, rotation=(10, 15, 0),
             parent=root, bevel=0.0)
    sphere("AntennaTip", (0.0, 0.11, 1.55), 0.035, "red", parent=root)
    # "Please do not disturb. It is thinking." (as a pictogram: a thought bubble).
    box("SignPost", (-1.0, 0.55, 0.6), (0.06, 0.06, 1.2), "wood_dark", parent=root)
    board = box("SignBoard", (-1.0, 0.52, 1.15), (0.6, 0.05, 0.42), "cream", parent=root, bevel=0.02)
    wonk(board, 5.0)
    cylinder("Bubble", (-0.98, 0.49, 1.17), 0.12, 0.02, "ink", rotation=(90, 0, 0), vertices=14, parent=root)
    cylinder("BubbleInner", (-0.98, 0.475, 1.17), 0.09, 0.02, "cream", rotation=(90, 0, 0), vertices=14,
             parent=root)
    cylinder("BubbleDot1", (-1.12, 0.48, 1.04), 0.03, 0.02, "ink", rotation=(90, 0, 0), vertices=8, parent=root)
    cylinder("BubbleDot2", (-1.18, 0.48, 0.98), 0.018, 0.02, "ink", rotation=(90, 0, 0), vertices=8, parent=root)
    return root


# --- Buildings -------------------------------------------------------------------

def _corrugated_wall(name, centre, width, height, colour, axis, parent, ribs_every=0.22):
    """Wall panel with vertical ribs. axis 'x': wall runs along X, faces -Y/+Y."""
    if axis == "x":
        box(name, centre, (width, 0.08, height), colour, parent=parent, bevel=0.02)
        count = int(width / ribs_every)
        for index in range(count):
            x = centre[0] - width / 2 + (index + 0.5) * width / count
            box(f"{name}Rib{index}", (x, centre[1] - 0.05, centre[2]), (0.05, 0.03, height - 0.04), colour,
                parent=parent, bevel=0.01, variation=0.06)
    else:
        box(name, centre, (0.08, width, height), colour, parent=parent, bevel=0.02)
        count = int(width / ribs_every)
        for index in range(count):
            y = centre[1] - width / 2 + (index + 0.5) * width / count
            box(f"{name}Rib{index}", (centre[0] - 0.05, y, centre[2]), (0.03, 0.05, height - 0.04), colour,
                parent=parent, bevel=0.01, variation=0.06)


def build_workshop_shed():
    """Office and workshop: corrugated walls, patched roof, crooked stovepipe,
    a window repaired with an X of tape."""
    kit.seed(91)
    root = kit.root("WorkshopShed")
    w, d, h = 9.0, 6.0, 3.1
    box("Core", (0, 0, h / 2), (w - 0.1, d - 0.1, h), "teal", parent=root, bevel=0.03)
    _corrugated_wall("WallFront", (0, -d / 2, h / 2), w, h, "teal", "x", root)
    _corrugated_wall("WallWest", (-w / 2, 0, h / 2), d, h, "steel", "y", root)
    patch("WallPatch", (2.9, -d / 2 - 0.08, 0.7), (0.9, 0.7), "rust_light", parent=root)
    patch("WallPatch2", (-w / 2 - 0.08, 1.2, 1.9), (0.8, 0.6), "mustard", parent=root, rotation=(0, 0, 90))
    for x in (-w / 2, w / 2):
        for y in (-d / 2, d / 2):
            box(f"Post{x}{y}", (x, y, h / 2), (0.22, 0.22, h + 0.05), "wood_dark", parent=root, bevel=0.03)
    box("Plinth", (0, 0, 0.1), (w + 0.1, d + 0.1, 0.2), "soil", parent=root, bevel=0.04)
    # Door with a horseshoe that is upside down ("so the luck falls on whoever opens it").
    box("Door", (-1.5, -d / 2 - 0.08, 1.12), (1.3, 0.1, 2.2), "wood", parent=root, bevel=0.03)
    for index in range(3):
        box(f"DoorPlank{index}", (-1.5, -d / 2 - 0.14, 0.45 + index * 0.65), (1.2, 0.04, 0.12),
            "wood_dark", parent=root, rotation=(0, 0 if index != 1 else 25, 0), bevel=0.01)
    torus("Horseshoe", (-1.5, -d / 2 - 0.15, 2.0), 0.1, 0.022, "steel_light", rotation=(90, 0, 0),
          parent=root)
    box("DoorKnob", (-1.0, -d / 2 - 0.16, 1.1), (0.08, 0.06, 0.08), "brass", parent=root, bevel=0.02)
    # Office window (above the order desk) with a taped crack and a flower box.
    wx = -3.2
    box("WindowFrame", (wx, -d / 2 - 0.09, 1.65), (1.5, 0.1, 1.05), "cream", parent=root, bevel=0.03)
    box("WindowGlass", (wx, -d / 2 - 0.12, 1.65), (1.28, 0.05, 0.84), "glass", parent=root, bevel=0.01)
    box("WindowBar", (wx, -d / 2 - 0.15, 1.65), (0.06, 0.04, 0.84), "cream", parent=root, bevel=0.01)
    tape("WindowTapeA", (wx + 0.35, -d / 2 - 0.16, 1.7), 0.5, parent=root, rotation=(0, 35, 0), width=0.05)
    tape("WindowTapeB", (wx + 0.35, -d / 2 - 0.16, 1.7), 0.5, parent=root, rotation=(0, -35, 0), width=0.05)
    box("FlowerBox", (wx, -d / 2 - 0.22, 1.08), (1.3, 0.22, 0.16), "rust_light", parent=root, bevel=0.03)
    for index in range(4):
        sphere(f"Plant{index}", (wx - 0.45 + index * 0.3, -d / 2 - 0.22, 1.22), 0.11, "moss", parent=root,
               scale=(1, 1, 0.8))
    # Roof: two pitches of corrugated panels, one replaced by a teal panel.
    pitch = 16.0
    for side, sign in (("S", -1), ("N", 1)):
        for index in range(5):
            colour = "rust_light" if not (side == "S" and index == 3) else "teal"
            x = -w / 2 - 0.25 + (index + 0.5) * (w + 0.5) / 5
            panel = box(f"Roof{side}{index}", (x, sign * d / 4, h + 0.42), ((w + 0.5) / 5 + 0.04, d / 2 + 0.45,
                        0.1), colour, parent=root, rotation=(-sign * pitch, kit._rng.uniform(-1, 1), 0),
                        bevel=0.02, variation=0.07)
    tape("RoofTape", (-1.0, -0.8, h + 0.62), 1.4, parent=root, rotation=(-74, 0, 10), width=0.12)
    box("Ridge", (0, 0, h + 0.82), (w + 0.6, 0.3, 0.12), "rust", parent=root, bevel=0.03)
    # Crooked stovepipe with a hat.
    cylinder("Pipe", (2.8, 1.2, h + 1.2), 0.16, 1.6, "steel", vertices=10, parent=root, rotation=(0, 6, 0))
    cylinder("PipeHat", (2.9, 1.2, h + 2.05), 0.3, 0.06, "steel_light", vertices=10, parent=root,
             radius_top=0.05)
    return root


def build_sales_kiosk():
    """Small wooden kiosk behind the counter, striped awning over the hatch (-X)."""
    kit.seed(101)
    root = kit.root("SalesKiosk")
    w, d, h = 3.0, 4.0, 2.55
    box("Body", (0, 0, h / 2), (w, d, h), "wood_light", parent=root, bevel=0.04)
    for index in range(9):
        box(f"Board{index}", (-w / 2 - 0.02, -d / 2 + 0.22 + index * 0.45, h / 2), (0.04, 0.42, h - 0.1),
            "wood_light" if index % 2 else "wood", parent=root, bevel=0.01, variation=0.06)
    box("Hatch", (-w / 2 - 0.05, 0, 1.35), (0.06, 2.2, 0.9), "ink", parent=root, bevel=0.01)
    box("HatchSill", (-w / 2 - 0.15, 0, 0.88), (0.3, 2.4, 0.08), "wood_dark", parent=root, bevel=0.02)
    for index in range(6):
        box(f"Awning{index}", (-w / 2 - 0.3, -1.25 + index * 0.5, 2.42), (0.65, 0.5, 0.05),
            "rust_light" if index % 2 == 0 else "cream", parent=root, rotation=(0, 18, 0), bevel=0.01)
    box("Roof", (0, 0, h + 0.1), (w + 0.4, d + 0.4, 0.2), "teal", parent=root, rotation=(0, -5, 0), bevel=0.04)
    patch("RoofPatch", (0.6, -1.0, h + 0.22), (0.7, 0.6), "mustard", parent=root, rotation=(90, 0, 0))
    box("Lamp", (-w / 2 - 0.2, 1.6, 2.4), (0.15, 0.15, 0.2), "mustard", parent=root, bevel=0.04)
    return root

# --- Player character (static placeholder in final style) ---------------------

def build_player():
    """Chunky yard worker: big head, cap with visor, overalls with a knee patch,
    oversized gloves and boots, the wicker carry basket on the back.
    Faces -Y (Godot +Z). Height about 1.7 m."""
    kit.seed(111)
    root = kit.root("PlayerModel")
    for side, x in (("L", -0.13), ("R", 0.13)):
        box(f"Boot{side}", (x, -0.04, 0.07), (0.17, 0.27, 0.14), "ink", parent=root, bevel=0.05)
        box(f"Leg{side}", (x, 0.0, 0.33), (0.16, 0.17, 0.4), "rust_light", parent=root, bevel=0.05)
    patch("KneePatch", (-0.13, -0.09, 0.33), (0.12, 0.12), "teal", parent=root, rivets=0)
    body = box("Body", (0, 0, 0.78), (0.46, 0.33, 0.56), "rust_light", parent=root, bevel=0.12)
    box("Bib", (0, -0.17, 0.82), (0.26, 0.02, 0.22), "rust", parent=root, bevel=0.02)
    box("Pocket", (0.0, -0.185, 0.8), (0.12, 0.01, 0.08), "rust_light", parent=root, bevel=0.01)
    cylinder("PencilA", (0.04, -0.18, 0.87), 0.01, 0.1, "mustard", vertices=6, parent=root, rotation=(0, 10, 0))
    box("Belt", (0, 0, 0.55), (0.48, 0.35, 0.06), "wood_dark", parent=root, bevel=0.02)
    box("Buckle", (0, -0.18, 0.55), (0.07, 0.02, 0.05), "brass", parent=root, bevel=0.01)
    for side, x, angle in (("L", -0.3, 12), ("R", 0.3, -12)):
        box(f"Arm{side}", (x, 0.0, 0.83), (0.13, 0.14, 0.42), "rust_light", parent=root, bevel=0.05,
            rotation=(0, angle, 0))
        sphere(f"Glove{side}", (x * 1.1, -0.02, 0.6), 0.095, "mustard", parent=root, scale=(1, 1, 1.1))
    # Head: large and friendly.
    sphere("Head", (0, -0.01, 1.32), 0.24, "skin", segments=14, rings=8, parent=root, scale=(1, 0.95, 1.0))
    sphere("Nose", (0, -0.235, 1.29), 0.06, "rust_light", parent=root)
    for side, x in (("L", -0.085), ("R", 0.085)):
        sphere(f"Eye{side}", (x, -0.215, 1.37), 0.028, "ink", parent=root)
    box("Mustache", (0, -0.225, 1.235), (0.17, 0.04, 0.035), "wood_dark", parent=root, bevel=0.015)
    sphere("EarL", (-0.235, 0, 1.31), 0.055, "skin", parent=root)
    sphere("EarR", (0.235, 0, 1.31), 0.055, "skin", parent=root)
    # Cap with visor, a little patch and a pencil behind the ear.
    sphere("Cap", (0, 0.0, 1.43), 0.245, "teal", segments=14, rings=8, parent=root, scale=(1.02, 1.02, 0.62))
    box("Visor", (0, -0.25, 1.45), (0.3, 0.2, 0.035), "teal", parent=root, bevel=0.015, rotation=(-8, 0, 0))
    box("CapPatch", (0.1, -0.12, 1.55), (0.08, 0.06, 0.02), "mustard", parent=root, rotation=(-35, 0, 20),
        bevel=0.005)
    cylinder("EarPencil", (0.24, -0.06, 1.38), 0.012, 0.18, "mustard", vertices=6, parent=root,
             rotation=(0, 70, 20))
    # Wicker carry basket on the back with straps.
    basket = box("Basket", (0, 0.27, 0.9), (0.42, 0.24, 0.5), "wood_light", parent=root, bevel=0.05,
                 jitter=0.008)
    for index in range(4):
        box(f"Weave{index}", (0, 0.39, 0.72 + index * 0.12), (0.44, 0.02, 0.04), "wood", parent=root,
            bevel=0.01)
    box("BasketRim", (0, 0.27, 1.16), (0.46, 0.28, 0.05), "wood_dark", parent=root, bevel=0.02)
    for side, x in (("L", -0.13), ("R", 0.13)):
        box(f"Strap{side}", (x, -0.15, 0.92), (0.05, 0.02, 0.44), "wood_dark", parent=root, bevel=0.01)
    return root


# --- Notice board at the entrance --------------------------------------------------

def build_notice_board():
    """Wren's notice board: a little roof, notes, one pinned upside down."""
    kit.seed(121)
    root = kit.root("NoticeBoard")
    for side, x in (("L", -0.68), ("R", 0.68)):
        box(f"Post{side}", (x, 0, 0.95), (0.1, 0.1, 1.9), "wood_dark", parent=root, bevel=0.02,
            rotation=(0, kit._rng.uniform(-2, 2), 0))
    board = box("Board", (0, 0, 1.28), (1.5, 0.08, 0.95), "wood", parent=root, bevel=0.03)
    wonk(board, 1.5)
    box("Frame", (0, 0.01, 1.28), (1.58, 0.06, 1.03), "wood_dark", parent=root, bevel=0.02)
    roof = box("Roof", (0, 0.05, 1.92), (1.8, 0.45, 0.07), "rust_light", parent=root, bevel=0.02,
               rotation=(-12, 0, 0))
    patch("RoofPatch", (0.5, -0.1, 1.95), (0.3, 0.2), "teal", parent=root, rotation=(78, 0, 0), rivets=2)
    notes = ((-0.38, 1.42, 0.42, 0.5, "paper", 4), (0.3, 1.45, 0.48, 0.36, "cream", -6),
             (0.35, 1.0, 0.32, 0.3, "mustard", 9), (-0.32, 0.98, 0.36, 0.28, "paper", 180 + 7))
    for index, (x, z, w, h, colour, angle) in enumerate(notes):
        box(f"Note{index}", (x, -0.05, z), (w, 0.01, h), colour, parent=root, rotation=(0, angle, 0), bevel=0.0)
        for line in range(3):
            box(f"Note{index}Line{line}", (x, -0.056, z + h * 0.25 - line * h * 0.22), (w * 0.7, 0.004, 0.025),
                "ink", parent=root, rotation=(0, angle, 0), bevel=0.0)
        sphere(f"Pin{index}", (x, -0.07, z + h * 0.42), 0.025, "red", parent=root)
    return root


ASSETS = {
    "sell_counter": (build_sell_counter, {"focus": (0, 0, 0.9), "ortho_scale": 3.8}),
    "order_desk": (build_order_desk, {"focus": (0, 0, 0.8), "ortho_scale": 2.8}),
    "source_rusted_drum": (build_rusted_drum, {"focus": (0, 0, 0.5), "ortho_scale": 2.2}),
    "source_storage_crate": (build_storage_crate, {"focus": (0, 0, 0.4), "ortho_scale": 2.4}),
    "source_old_toolbox": (build_old_toolbox, {"focus": (0, 0, 0.2), "ortho_scale": 1.3}),
    "bulk_metal_beam": (build_metal_beam, {"focus": (0, 0, 0.3), "ortho_scale": 3.4}),
    "workbench": (build_workbench, {"focus": (0, 0, 1.0), "ortho_scale": 3.6}),
    "deco_wheelbarrow": (build_wheelbarrow, {"focus": (0, 0, 0.7), "ortho_scale": 3.4}),
    "workshop_shed": (build_workshop_shed, {"focus": (0, 0, 1.8), "ortho_scale": 12.0}),
    "sales_kiosk": (build_sales_kiosk, {"focus": (0, 0, 1.3), "ortho_scale": 6.0}),
    "player_model": (build_player, {"focus": (0, 0, 0.85), "ortho_scale": 2.2}),
    "notice_board": (build_notice_board, {"focus": (0, 0, 1.1), "ortho_scale": 2.8}),
}


import props_world  # noqa: E402

ASSETS.update(props_world.ASSETS)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    out_dir = argv[argv.index("--out") + 1] if "--out" in argv else "assets/models"
    preview_dir = argv[argv.index("--preview") + 1] if "--preview" in argv else ""
    only = argv[argv.index("--only") + 1] if "--only" in argv else ""
    os.makedirs(out_dir, exist_ok=True)
    for name, (builder, preview) in ASSETS.items():
        if only and name != only:
            continue
        kit.reset_scene()
        root = builder()
        kit.merge_parts(root)
        if preview_dir:
            os.makedirs(preview_dir, exist_ok=True)
            kit.render_preview(os.path.abspath(os.path.join(preview_dir, name + ".png")), **preview)
        kit.export_glb(root, os.path.abspath(os.path.join(out_dir, name + ".glb")))
        print("built", name)
    print("BUILD_PROPS_DONE")


main()
