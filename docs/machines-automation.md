# Machines & Automation Specification

**Version:** 0.1  
**Status:** Initial concept

## 1. Design goal

Machines make work easier and visibly transform the yard. Every machine should have one clear primary purpose, simple inputs / outputs, and understandable upgrade options.

Automation should be gradual and affordable only after the player has earned it.

## 2. Machine families

- Collection: magnet crane, scrap collector, collection robot.
- Sorting: magnetic separator, basic material sorter.
- Processing: dismantling station, shredder, metal press.
- Transport: handcart, conveyor, small transport vehicle.
- Sales / logistics: drop-off point, loading station.

Only a small subset belongs in the first prototype.

## 3. Machine definition

Conceptual data fields:
- Stable ID and display name.
- Machine category.
- Purchase cost.
- Footprint and placement requirements.
- Primary function.
- Input and output types.
- Processing duration / throughput.
- Capacity.
- Upgrade options.
- Operating state.
- Visual asset and animation references.

## 4. Operating states

- Idle.
- Working.
- Waiting for input.
- Output full.
- Blocked.
- Needs player attention.

States must be clearly visible and explained with concise UI feedback.

## 5. Automation principles

- Do not require complex conveyor routing in the first prototype.
- Machines can initially work within a simple defined area or use direct input / output slots.
- Simulation should be tick-based or event-based, not dependent on every physical object being simulated.
- Visual animations should represent the simulation rather than drive its economic logic.
- Keep machine setup to a small number of clear interactions.

## 6. Progression

A machine should be purchased only after the player has had enough time to understand and perform the task manually. The first helper and first machine should feel like meaningful business milestones.

## 7. Prototype target

Implement one simple machine that takes a clear input and produces a clear output, with visible operation and a measurable benefit over manual work.
