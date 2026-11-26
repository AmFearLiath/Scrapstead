"""Generates data/stashes/yard_stashes.tres (docs/yard-stashes.md).

    python tools/make_stashes.py
"""

OUT = "data/stashes/yard_stashes.tres"
OBST = "LevelGeometry/Obstacles/"

# id, fixture, name, action, tool, seconds, capacity, refill s, min, max, loot {item: weight}, results
STASHES = [
    ("tyres", OBST + "WorkAreaD/Tyres", "yard.tyres", "ui.action.search", "", 1.4, 2, 300, 1, 2,
     {"scrap_wire_coil": 3, "scrap_rusted_bolt": 2, "scrap_empty_can": 2}, 3),
    ("car_wreck", OBST + "ScrapYardB/CarWreck", "yard.car_wreck", "ui.action.pry_open", "crowbar", 2.4, 2, 480, 1, 3,
     {"device_broken_radio": 2, "mat_copper_wire": 3, "scrap_copper_pipe": 2, "scrap_rusted_bolt": 2,
      "find_brass_figurine": 0.3}, 3),
    ("shelf", OBST + "StorageZoneA/Shelf", "yard.shelf", "ui.action.search", "", 1.6, 3, 360, 1, 2,
     {"scrap_rusted_bolt": 3, "scrap_wire_coil": 2, "device_broken_toaster": 1, "mat_electronic_parts": 1}, 3),
    ("crates_open", OBST + "StorageZoneA/Crates1", "yard.crates", "ui.action.search", "", 1.6, 2, 360, 1, 2,
     {"scrap_wood_offcut": 3, "scrap_rusted_bolt": 2, "scrap_empty_can": 2}, 3),
    ("crates_nailed", OBST + "StorageZoneA/Crates2", "yard.crates_nailed", "ui.action.pry_open", "crowbar", 2.2, 2, 420,
     1, 3, {"mat_electronic_parts": 2, "scrap_wire_coil": 2, "scrap_wood_offcut": 2, "device_broken_radio": 1}, 3),
    ("barrels", OBST + "StorageZoneA/Barrels", "yard.barrels", "ui.action.search", "", 1.4, 2, 300, 1, 2,
     {"scrap_empty_can": 3, "scrap_copper_pipe": 2, "scrap_rusted_bolt": 1}, 3),
    ("scrap_pile", OBST + "StorageZoneA/SmallScrapPile", "yard.scrap_pile", "ui.action.search", "", 1.4, 2, 240, 1, 2,
     {"scrap_rusted_bolt": 3, "scrap_empty_can": 2, "scrap_wire_coil": 1}, 3),
    ("scrap_heap_large", OBST + "ScrapYardB/LargeScrapHeap", "yard.scrap_heap_large", "ui.action.dig", "", 2.0, 4, 240,
     2, 3, {"scrap_rusted_bolt": 3, "scrap_empty_can": 2, "scrap_copper_pipe": 2, "scrap_wire_coil": 2,
            "device_broken_toaster": 0.7, "find_brass_figurine": 0.2}, 3),
    ("scrap_heap_small", OBST + "ScrapYardB/SmallScrapHeap", "yard.scrap_heap_small", "ui.action.dig", "", 1.6, 2, 240,
     1, 2, {"scrap_rusted_bolt": 3, "scrap_empty_can": 2, "scrap_wire_coil": 1}, 3),
    ("engine_block", OBST + "ScrapYardB/EngineBlock", "yard.engine_block", "ui.action.lift", "hoist", 2.6, 1, 600, 2, 3,
     {"mat_copper_wire": 3, "scrap_copper_pipe": 2, "scrap_rusted_bolt": 2}, 3),
    ("container", OBST + "ScrapYardB/Container", "yard.container", "ui.action.pry_open", "crowbar", 2.6, 2, 600, 2, 3,
     {"device_broken_toaster": 2, "device_broken_radio": 2, "mat_electronic_parts": 2, "scrap_wire_coil": 1,
      "find_brass_figurine": 0.3}, 3),
    ("pallets", OBST + "WorkAreaD/Pallets", "yard.pallets", "ui.action.search", "", 1.2, 2, 300, 1, 2,
     {"scrap_wood_offcut": 4, "scrap_rusted_bolt": 1}, 3),
]

lines = [f'[gd_resource type="Resource" script_class="StashTable" load_steps={len(STASHES) + 3} format=3]', "",
         '[ext_resource type="Script" path="res://scripts/data/StashTable.gd" id="1_table"]',
         '[ext_resource type="Script" path="res://scripts/data/StashDefinition.gd" id="2_def"]', ""]
for (sid, path, name, action, tool, seconds, capacity, refill, lo, hi, loot, results) in STASHES:
    items = ", ".join(f'"{k}"' for k in loot)
    weights = ", ".join(f"{float(v)}" for v in loot.values())
    keys = ", ".join(f'"ui.stash.result.{sid}.{i}"' for i in range(1, results + 1))
    lines += [f'[sub_resource type="Resource" id="{sid}"]', 'script = ExtResource("2_def")', f'id = "{sid}"',
              f'fixture_path = "{path}"', f'name_key = "{name}"', f'action_key = "{action}"',
              f'required_tool = "{tool}"', f"search_seconds = {seconds}", f"capacity = {capacity}",
              f"refill_seconds = {float(refill)}", f"min_items = {lo}", f"max_items = {hi}",
              f"loot_items = PackedStringArray({items})", f"loot_weights = PackedFloat32Array({weights})",
              f"result_keys = PackedStringArray({keys})", ""]
refs = ", ".join(f'SubResource("{s[0]}")' for s in STASHES)
lines += ["[resource]", 'script = ExtResource("1_table")', f'stashes = Array[ExtResource("2_def")]([{refs}])', ""]
open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
print(OUT, len(STASHES))
