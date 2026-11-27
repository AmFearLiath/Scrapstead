"""Generates scenes/world/OutsideScenery.tscn: purely decorative dressing
outside the fence (and dry grass along the inside of it), art style 2
(docs/art-style-2.md). No collisions, no gameplay - the yard itself stays
exactly as the build system and navigation know it.

    python tools/make_scenery.py
"""
import math
import random

OUT = "scenes/world/OutsideScenery.tscn"
# The plot spans x 0..48, z -36..0; the gate gap is on the south side.
GATE = (1.5, 15.0)

rng = random.Random(4711)
models = {}
nodes = []


def model(name):
    if name not in models:
        models[name] = f"{len(models) + 1}_{name}"
    return models[name]


def place(name, x, z, yaw=None, scale=1.0):
    model(name)
    yaw = rng.uniform(0, math.tau) if yaw is None else yaw
    c, s = math.cos(yaw) * scale, math.sin(yaw) * scale
    nodes.append((name, f"Transform3D({c:.4f}, 0, {-s:.4f}, 0, {scale:.4f}, 0, {s:.4f}, 0, {c:.4f}, {x:.3f}, 0, {z:.3f})"))


big = []


def outside_ring(count, near, far, kinds, gap=0.0):
    """Scatters `kinds` in a band `near`..`far` metres outside the fence."""
    placed = 0
    while placed < count:
        side = rng.choice(("n", "n", "e", "w", "s"))
        depth = rng.uniform(near, far)
        if side == "n":
            x, z = rng.uniform(-6, 54), -36 - depth
        elif side == "e":
            x, z = 48 + depth, rng.uniform(-40, 4)
        elif side == "w":
            x, z = -depth, rng.uniform(-40, 4)
        else:
            x, z = rng.uniform(-6, 54), depth
            if GATE[0] - 3 < x < GATE[1] + 3:
                continue
        if gap and any((x - bx) ** 2 + (z - bz) ** 2 < gap * gap for bx, bz in big):
            continue
        if gap:
            big.append((x, z))
        place(kinds[placed % len(kinds)], x, z)
        placed += 1


# Big pieces first, a little further out so they frame the yard.
outside_ring(16, 3.0, 9.0, ["car_stack_a", "scrap_car_b", "scrap_mountain", "scrap_car_c", "car_stack_b",
                            "scrap_car_d", "car_stack_c", "scrap_car_a"], gap=6.0)
outside_ring(12, 1.5, 6.0, ["tyre_tower", "car_wreck", "scrap_heap_large", "barrel_group"], gap=3.5)
outside_ring(70, 0.6, 12.0, ["dry_grass_a", "dry_grass_b"])

# Dry grass along the inside of the fence, where nobody ever sweeps.
for _ in range(45):
    side = rng.choice(("n", "e", "w"))
    if side == "n":
        x, z = rng.uniform(1, 47), rng.uniform(-35.75, -35.4)
    elif side == "e":
        x, z = rng.uniform(47.4, 47.75), rng.uniform(-35, -1)
    else:
        x, z = rng.uniform(0.25, 0.6), rng.uniform(-35, -1)
    place(rng.choice(["dry_grass_a", "dry_grass_b"]), x, z, scale=rng.uniform(0.7, 1.1))

lines = [f'[gd_scene load_steps={len(models) + 1} format=3]', ""]
for name, ident in models.items():
    lines.append(f'[ext_resource type="PackedScene" path="res://assets/models/{name}.glb" id="{ident}"]')
lines += ["", '[node name="OutsideScenery" type="Node3D"]', ""]
counts = {}
for name, transform in nodes:
    counts[name] = counts.get(name, 0) + 1
    lines.append(f'[node name="{name}_{counts[name]}" parent="." instance=ExtResource("{models[name]}")]')
    lines.append(f"transform = {transform}")
    lines.append("")
open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
print(f"{OUT}: {len(nodes)} pieces")
