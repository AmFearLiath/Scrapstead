# World & Asset Design

**Version:** 0.1  
**Status:** Initial art direction

## 1. Art direction

Cozy, funny, stylized low-poly 3D presented as an isometric miniature diorama.

Visual keywords:
- Warm.
- Whimsical.
- Recycled.
- Handmade.
- Slightly wonky.
- Inviting.
- Readable.

## 2. Palette

Initial palette direction:
- Rust orange.
- Warm amber.
- Cream.
- Moss green.
- Vintage teal.
- Steel blue.

Treat these as visual direction, not immutable technical color values.

## 3. Environment

The first plot should include:
- Entrance gate.
- Small office / shed.
- Workbench.
- Red toolbox.
- A few distinct scrap piles.
- Simple drop-off / sale area.
- Space for the first machine.
- Scrappy's discovery location.

The starting area should feel messy but inviting, not grim or hazardous.

## 4. Modular assets

Build reusable asset families:
- Ground tiles: grass, compacted dirt, asphalt, concrete.
- Scrap: metal sheets, pipes, tires, barrels, appliances, electronics, vehicle parts.
- Buildings: office, shed, workshop, storage.
- Machinery: conveyor segments, crane pieces, sorting station, press.
- Props: pallets, fences, signs, lamps, containers.
- Character parts: robot heads, bodies, wheels, tracks, arms, tools, antennas, accessories.

## 5. Modeling guidelines

- Consistent scale and pivot conventions.
- Clear silhouettes at gameplay camera distance.
- Reusable materials.
- Simple collision geometry.
- Modular attachment points for machines and Scrappy.
- Avoid tiny details that cannot be seen in the isometric view.

## 6. Visual progression

The yard should visibly become cleaner, more organized, more active, and more colorful as the business grows. New assets should communicate progression at a glance.

## 7. Performance

Favor instancing for repeated props, low-cost materials, simplified collisions, and restrained animation counts. The world should look busy without requiring a physics simulation for every scrap object.
