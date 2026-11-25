# Scrapstead — Starting Yard Item Catalog

**Version:** 0.1  
**Status:** Initial design baseline  
**Scope:** First playable property / starting scrapyard  
**Localization:** Every player-facing string uses a stable localization key. English and German are the initial reference locales.

## 1. Purpose

This catalog defines the initial set of collectible objects, scrap sources, valuable finds, and processing outputs for the first property. It is a gameplay catalog, not an exhaustive world item list.

The goal is to create variety from a compact set of objects. Each object should support at least one clear interaction: pick up, move, inspect, sell, sort, dismantle, process, or discover.

The first property should teach the complete basic loop without requiring a large item taxonomy:
- Find and collect.
- Decide whether to sell directly or investigate further.
- Use tools for bulky or embedded objects.
- Discover that selected objects contain useful materials or components.
- Find the special component needed to restore Scrappy.

## 2. Catalog rules

1. **Stable IDs:** IDs are language-independent and never derived from displayed names.
2. **Localized presentation:** Display names, descriptions, interaction labels, inspection text, and flavor text are localization keys.
3. **Direct sale remains valid:** Every sellable object has a direct-sale path, even if processing is available.
4. **Processing is selective:** Only designated objects have dismantling or processing recipes.
5. **Handling is readable:** The player can tell whether an object is hand-pickable, carryable, tool-required, or machine-handled.
6. **Discoveries are deliberate:** Rare finds should have authored placement or controlled spawn rules, not arbitrary luck alone.
7. **No premature economy lock-in:** Values are relative tiers for now. No final credits, wages, yields, or timings are set here.
8. **Prototype scope stays small:** Some objects can share visual families and interaction logic.

## 3. Data model

Every catalog entry should eventually support the following fields:

| Field | Purpose |
|---|---|
| `id` | Stable unique identifier |
| `name_key` | Localization key for display name |
| `description_key` | Localization key for description |
| `category` | Gameplay grouping |
| `material_tags` | Material classification, e.g. metal, wood, plastic |
| `handling_class` | Hand, carry, tool, station, or machine |
| `direct_value_tier` | Relative direct-sale value |
| `processing_recipe_ids` | Optional recipe references |
| `outputs` | Materials or components produced by processing |
| `required_tool_or_station` | Optional requirement |
| `source_tags` | Spawn or discovery source |
| `rarity` | Common, uncommon, rare, unique |
| `special_flags` | Scrappy, collectible, order, tutorial, etc. |
| `asset_id` | Visual asset reference, independent of localized text |

Suggested value tiers: **Very Low, Low, Medium, High, Exceptional**. These are balancing labels, not final prices.

Suggested handling classes:
- **Hand:** Small object, picked up directly.
- **Carry:** Larger object, manually carried or moved with a carrying upgrade.
- **Tool:** Requires a suitable tool to extract, cut, pry, or dismantle.
- **Station:** Must be processed at a dedicated station.
- **Machine:** Collected or handled by a machine once that machine is unlocked.

## 4. First-property catalog

### 4.1 Loose scrap — direct pickup

These are the everyday objects that make the yard feel alive. They provide quick, satisfying collection and reliable starter income.

| ID | English name | German name | Material | Handling | Direct value | Optional path / role |
|---|---|---|---|---|---|---|
| `scrap_rusted_bolt` | Rusty Bolt | Verrostete Schraube | Metal | Hand | Very Low | Bulk metal after sorting |
| `scrap_metal_nut` | Metal Nut | Metallmutter | Metal | Hand | Very Low | Bulk metal after sorting |
| `scrap_wire_coil` | Wire Coil | Kabelknäuel | Copper / mixed metal | Hand | Low | Copper wire after sorting |
| `scrap_copper_pipe` | Copper Pipe | Kupferrohr | Copper | Hand | Low | Copper material |
| `scrap_bent_sheet` | Bent Sheet Metal | Verbogenes Blech | Metal | Hand | Low | Sheet metal |
| `scrap_empty_can` | Empty Can | Leere Dose | Aluminum | Hand | Very Low | Aluminum scrap |
| `scrap_broken_spring` | Broken Spring | Defekte Feder | Steel | Hand | Low | Spring component chance |
| `scrap_plastic_crate_piece` | Cracked Plastic Piece | Kunststoffbruchstück | Plastic | Hand | Very Low | Plastic material |
| `scrap_wood_offcut` | Wood Offcut | Holzabschnitt | Wood | Hand | Very Low | Reusable wood |
| `scrap_rubber_piece` | Rubber Offcut | Gummirest | Rubber | Hand | Very Low | Rubber material |

### 4.2 Bulk scrap — tools and carrying

These objects teach the player that not everything can be picked up immediately. They also make tool and transport upgrades tangible.

| ID | English name | German name | Material | Handling | Direct value | Optional path / role |
|---|---|---|---|---|---|---|
| `bulk_metal_beam` | Metal Beam | Metallträger | Steel | Carry | Medium | Cut into metal stock with a cutting tool |
| `bulk_scrap_panel` | Scrap Panel | Schrottplatte | Mixed metal | Carry | Low | Sort into metal grades |
| `bulk_rusted_barrel` | Rusty Barrel | Verrostetes Fass | Steel | Carry / Tool | Medium | Inspect first; may contain residue or useful contents |
| `bulk_broken_fence` | Broken Fence Section | Kaputtes Zaunsegment | Wood / metal | Tool | Low | Recover wood and metal |
| `bulk_engine_block` | Old Engine Block | Alter Motorblock | Metal | Tool | High | Dismantle into metal and mechanical parts |
| `bulk_scrap_wheelbarrow` | Broken Wheelbarrow | Defekte Schubkarre | Metal / rubber / wood | Carry | Medium | Recover wheel, metal, and wood |
| `bulk_metal_cabinet` | Metal Cabinet | Metallschrank | Metal | Tool | Medium | Search contents; dismantle shell |
| `bulk_car_door` | Car Door | Autotür | Metal / plastic | Carry | Medium | Dismantle into sheet metal and fittings |

### 4.3 Dismantling candidates — objects with a story

These objects create the optional value path. The player can sell them intact or invest time and access to recover useful materials.

| ID | English name | German name | Material | Handling | Direct value | Optional path / role |
|---|---|---|---|---|---|---|
| `device_broken_radio` | Broken Radio | Defektes Radio | Metal / plastic / electronics | Carry | Medium | Recover wire and electronic parts |
| `device_old_fan` | Old Fan | Alter Ventilator | Metal / plastic / electronics | Carry | Medium | Recover motor, wire, and casing |
| `device_microwave` | Broken Microwave | Defekte Mikrowelle | Metal / electronics | Carry | High | Dismantle for metal and electronic parts; special handling required |
| `device_table_lamp` | Bent Table Lamp | Verbogene Tischlampe | Metal / glass / wire | Carry | Low | Recover wire and metal |
| `device_broken_vacuum` | Broken Vacuum Cleaner | Defekter Staubsauger | Plastic / metal / motor | Carry | Medium | Recover motor and plastic |
| `device_old_typewriter` | Old Typewriter | Alte Schreibmaschine | Metal / mechanical parts | Carry | High | Dismantle for precision parts or sell as a collectible |
| `device_broken_toy_robot` | Broken Toy Robot | Defekter Spielzeugroboter | Plastic / wire / electronics | Hand / Carry | Medium | Small chance of a quirky component; visual foreshadowing for Scrappy |

### 4.4 Scrap piles and containers — discovery sources

These are not ordinary inventory items. They are world objects that create collection moments and can contain several catalog items.

| ID | English name | German name | Interaction | Contents / purpose |
|---|---|---|---|---|
| `source_small_scrap_pile` | Small Scrap Pile | Kleiner Schrotthaufen | Search / clear | A few common loose scrap objects |
| `source_mixed_scrap_heap` | Mixed Scrap Heap | Gemischter Schrotthaufen | Tool-assisted clearing | Bulk scrap plus a chance of uncommon finds |
| `source_old_toolbox` | Old Toolbox | Alter Werkzeugkasten | Open / inspect | Common tools, small parts, or a useful early upgrade component |
| `source_red_toolbox` | Red Toolbox | Roter Werkzeugkasten | Open / inspect; authored discovery | Contains the unique component required to restore Scrappy's head |
| `source_storage_crate` | Storage Crate | Lagerkiste | Open / inspect | Mixed materials or a small stash |
| `source_rusted_drum` | Sealed Rusty Drum | Versiegeltes Rostfass | Tool interaction | Uncertain contents; teaches inspection before processing |

### 4.5 Valuable finds and collectibles

These objects create memorable discoveries and reinforce the idea that every scrap has a story. They should not become a mandatory farming loop.

| ID | English name | German name | Handling | Value / role | Notes |
|---|---|---|---|---|---|
| `find_vintage_pocket_watch` | Vintage Pocket Watch | Antike Taschenuhr | Hand | High | Can be sold or kept as a collectible |
| `find_old_camera` | Old Camera | Alte Kamera | Carry | High | Valuable intact; dismantling is an alternative, not automatically superior |
| `find_brass_figurine` | Brass Figurine | Messingfigur | Hand | Medium | Small collectible with flavor text |
| `find_mystery_key` | Unusual Key | Ungewöhnlicher Schlüssel | Hand | Exceptional / special | A discovery hook; purpose may be revealed later |
| `find_handwritten_note` | Handwritten Note | Handschriftliche Notiz | Hand | No direct sale or Very Low | Narrative collectible; localized readable text |
| `find_scrappy_core_component` | Scrappy Core Component | Scrappy-Kernkomponente | Hand | Unique / progression | Unique component from the red toolbox; restores Scrappy's head |

### 4.6 Processing outputs and reusable materials

Outputs are not separate world discoveries by default. They are standardized material types produced by sorting or dismantling and later consumed by upgrades, crafting, orders, or machine construction.

| ID | English name | German name | Produced from | Initial uses |
|---|---|---|---|---|
| `mat_ferrous_metal` | Ferrous Metal | Eisenmetall | Bolts, beams, panels, engine block | Basic upgrades and machine frames |
| `mat_nonferrous_metal` | Non-Ferrous Metal | Nichteisenmetall | Copper pipe, wire, selected devices | Wiring and higher-value parts |
| `mat_copper_wire` | Copper Wire | Kupferdraht | Wire coil, radios, lamps | Electrical components |
| `mat_plastic` | Plastic | Kunststoff | Crates, device casings, toys | Casings and utility parts |
| `mat_wood` | Reclaimed Wood | Wiederverwertetes Holz | Offcuts, fence, wheelbarrow | Storage and basic construction |
| `mat_rubber` | Rubber | Gummi | Rubber pieces, wheels, appliances | Wheels and flexible parts |
| `mat_mechanical_parts` | Mechanical Parts | Mechanische Bauteile | Springs, engines, typewriter | Tool and machine upgrades |
| `mat_electronic_parts` | Electronic Parts | Elektronische Bauteile | Radios, fans, microwave, vacuum | Sensors and Scrappy modules |
| `mat_glass` | Reclaimed Glass | Altglas | Lamps and selected devices | Later crafting / orders |

## 5. First-yard teaching sequence

The first property should introduce object families in a controlled order:

1. **Loose scrap:** Pick up bolts, cans, wire, and wood directly. Learn collection and direct sale.
2. **Bulk object:** Encounter a metal beam or broken wheelbarrow. Learn carrying and the value of transport capacity.
3. **Tool-required object:** Find an embedded or dismantle-ready object. Learn that tools unlock new interactions.
4. **Optional value path:** Find a radio or fan. Compare selling intact with dismantling.
5. **Discovery source:** Search a toolbox or crate. Learn that the yard contains more than loose scrap.
6. **Scrappy discovery:** Find the red toolbox and its unique core component. Restore Scrappy as a memorable early milestone.
7. **First material outputs:** Introduce a small number of sorted materials and show why they matter for upgrades.

The order is a teaching recommendation, not a rigid quest script. The player should retain freedom to explore the property.

## 6. Prototype priority

### Must be playable
- Rusty Bolt
- Wire Coil
- Empty Can
- Wood Offcut
- Metal Beam
- Rusty Barrel
- Broken Radio
- Old Fan
- Small Scrap Pile
- Old Toolbox
- Red Toolbox
- Scrappy Core Component
- Ferrous Metal
- Copper Wire
- Mechanical Parts
- Electronic Parts

### Can be represented by shared placeholder families initially
- Remaining loose scrap variants
- Remaining bulk scrap variants
- Additional appliances
- Valuable finds and collectibles
- Additional containers and scrap heaps

## 7. Balance and content safeguards

- Do not make dismantling the best choice for every object.
- Some intact collectibles should be worth more intact than their recovered materials.
- Direct sale should remain useful throughout the game.
- Avoid too many material types in the first hour.
- Do not introduce rare components as random blockers for core progression.
- The Scrappy Core Component is guaranteed through the authored red toolbox discovery.
- Microwave dismantling and any hazardous residue interaction must be handled as a stylized, safe game mechanic; do not teach real-world disassembly procedures.
- Use shared object families and material tags to keep content production manageable.

## 8. Open questions for playtesting

- How many loose objects should be visible in the first camera view?
- How many objects should fit in the starting carry capacity?
- Should the player be able to carry a bulky object before buying a handcart, but more slowly?
- Which first appliance gives the clearest dismantling lesson?
- How quickly should the player encounter the red toolbox and restore Scrappy?
- Which material outputs are actually needed before the first employee and first machine?

These questions should be answered through a playable first-hour prototype, not by assigning arbitrary economy numbers now.
