"""Renders catalog thumbnails for every placeable (assets/ui/thumbs/<id>.png).

Uses the Blender preview renderer of tools/blender/build_props.py (game camera
angle) into a scratch folder - the models in assets/models stay untouched -
then crops and scales the result. Objects without a Blender model (the gravel
tile) are drawn directly. Run from the project root:
    python tools/make_thumbnails.py [placeable_id ...]
"""
import os
import random
import subprocess
import sys

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLENDER = os.environ.get("BLENDER", "F:/_blender/blender.exe")
SCRATCH = os.path.join(ROOT, "tests", "_output", "thumbs_work")
OUT = os.path.join(ROOT, "assets", "ui", "thumbs")
SIZE = (192, 160)

MODELS = {
    "magnet_collector": "magnet_collector",
    "scrap_press": "scrap_press",
    "sorter": "sorter",
    "storage_pallets": "pallet_stack",
    "storage_crates": "crate_stack",
    "storage_barrels": "barrel_group",
    "paths_fence_low": "fence_low_a",
    "decor_planter": "bathtub_planter",
    "decor_floodlight": "floodlight",
    "decor_tyres": "tyre_stack",
    "decor_wheelbarrow": "deco_wheelbarrow",
    "decor_gnome": "decor_scrap_gnome",
    "decor_bench": "decor_tyre_bench",
    "decor_flamingo": "decor_pipe_flamingo",
}


def render(model):
    os.makedirs(SCRATCH, exist_ok=True)
    subprocess.run([BLENDER, "-b", "-P", os.path.join(ROOT, "tools", "blender", "build_props.py"), "--",
                    "--out", os.path.join(SCRATCH, "glb"), "--preview", SCRATCH, "--only", model],
                   cwd=ROOT, check=True, capture_output=True)
    return os.path.join(SCRATCH, model + ".png")


def crop_to_content(image):
    """Crops to the object (pixels that differ from the sand floor) with a margin."""
    rgb = image.convert("RGB")
    background = rgb.getpixel((4, 4))
    mask = Image.new("L", rgb.size, 0)
    pixels = rgb.load()
    mask_pixels = mask.load()
    for y in range(0, rgb.size[1], 2):
        for x in range(0, rgb.size[0], 2):
            r, g, b = pixels[x, y]
            if abs(r - background[0]) + abs(g - background[1]) + abs(b - background[2]) > 40:
                mask_pixels[x, y] = 255
    box = mask.getbbox() or (0, 0, rgb.size[0], rgb.size[1])
    margin = 24
    box = (max(box[0] - margin, 0), max(box[1] - margin, 0), min(box[2] + margin, rgb.size[0]),
           min(box[3] + margin, rgb.size[1]))
    cropped = rgb.crop(box)
    # Fit into the thumbnail aspect ratio on the floor colour.
    target_ratio = SIZE[0] / SIZE[1]
    width, height = cropped.size
    if width / height < target_ratio:
        new = Image.new("RGB", (int(height * target_ratio), height), background)
        new.paste(cropped, ((new.size[0] - width) // 2, 0))
    else:
        new = Image.new("RGB", (width, int(width / target_ratio)), background)
        new.paste(cropped, (0, (new.size[1] - height) // 2))
    return new.resize(SIZE, Image.LANCZOS)


def gravel():
    random.seed(4)
    image = Image.new("RGB", SIZE, (179, 154, 114))
    draw = ImageDraw.Draw(image)
    draw.polygon([(96, 34), (170, 80), (96, 126), (22, 80)], fill=(184, 168, 140))
    for _ in range(90):
        x, y = random.randint(40, 152), random.randint(48, 112)
        if abs(x - 96) / 74 + abs(y - 80) / 46 <= 1.0:
            r = random.randint(2, 4)
            shade = random.randint(110, 150)
            draw.ellipse((x - r, y - r // 2, x + r, y + r // 2), fill=(shade + 20, shade + 8, shade - 10))
    return image


def main():
    wanted = sys.argv[1:] or list(MODELS) + ["paths_gravel"]
    os.makedirs(OUT, exist_ok=True)
    for placeable in wanted:
        if placeable == "paths_gravel":
            gravel().save(os.path.join(OUT, placeable + ".png"))
        else:
            crop_to_content(Image.open(render(MODELS[placeable]))).save(os.path.join(OUT, placeable + ".png"))
        print("thumb", placeable)


main()
