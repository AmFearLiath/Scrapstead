# Technical Architecture

**Version:** 0.1  
**Status:** Proposed architecture; subject to prototype validation

## 1. Engine

Proposed engine: Godot 4.x with 3D rendering and an isometric camera. Confirm exact engine version and rendering choices when the development environment is initialized.

## 2. Architecture principles

- Data-driven definitions for items, machines, upgrades, and Scrappy parts.
- Separate simulation state from visuals.
- Small, testable gameplay systems.
- Prefer composition and reusable components.
- Avoid premature abstraction and overengineering.
- Keep content authoring straightforward.

## 3. Suggested system boundaries

- GameState / SessionManager.
- World and plot management.
- Player controller and interaction.
- Item and inventory.
- Collection and tools.
- Economy and transactions.
- Processing and recipes.
- Employees.
- Machines and automation.
- Scrappy companion and customization.
- Progression and objectives.
- Save / load.
- UI and audio.

## 4. Simulation

Use a central simulation tick or event-driven updates for economic operations. Machine animations should reflect state and progress; they must not be the authoritative source of production results.

Offline progression is not assumed for the first prototype.

## 5. Save data

Persist:
- Player progression and credits.
- Plot unlocks and layout.
- Items and storage.
- Machine instances and states.
- Employees and assignments.
- Scrappy's parts and unlocks.
- Objectives and discoveries.
- Settings.

Use versioned save data and plan migration from the beginning.

## 6. Prototype-first implementation

Do not build all systems at once. First prove the collection → sale / processing → investment loop on one plot. Add employee delegation and the first machine only after the manual loop is enjoyable.

## 7. Open technical decisions

- Exact Godot version.
- Input and movement model.
- Grid size and placement rules.
- Inventory model.
- Simulation tick frequency.
- Offline progression policy.
- Save format and migration strategy.
- Target hardware / performance budget.
