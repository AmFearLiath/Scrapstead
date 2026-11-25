# Gameplay & Economy Specification

**Version:** 0.1  
**Status:** Initial system specification

## 1. Core decisions

- Collection uses a hybrid approach: directly pick up small loose objects; larger or embedded objects require tools or equipment.
- Scrap can be sold directly. Sorting and processing are optional value paths, not mandatory steps for every object.
- Progression starts with the player doing the work. Helpers and machines are purchased gradually as the business becomes affordable.
- Keep controls and rules simple; create depth through choices and combinations.

## 2. Collection interactions

### 2.1 Small objects
A short interaction picks up a loose object and adds it to the carried inventory or nearby collection container, according to the eventual inventory design.

### 2.2 Large objects
Large objects use contextual actions such as pry, cut, dismantle, or lift. The game should clearly indicate the required tool or equipment.

### 2.3 Collection feedback
Provide:
- Clear highlight on selectable objects.
- Short pickup or tool animation.
- Small sound and visual feedback.
- Obvious feedback when capacity is reached or a tool is missing.

## 3. Sell or process

Every object should communicate a simple choice where applicable:

- **Sell now:** quick, predictable income.
- **Process:** invest effort or machine capacity for a potentially better return.
- **Keep:** retain a collectible, quest item, robot component, or useful resource.

The value path must not be universally superior after accounting for its time, investment, and opportunity cost. Direct sale remains useful throughout the game.

## 4. Resource and item data

A scrap item should be data-defined. Initial conceptual fields:

- Stable ID.
- Display name and description.
- Category and material.
- Size / handling class.
- Base direct-sale value.
- Possible processing outputs.
- Tool or station requirements, if any.
- Rarity / discovery tags.
- Visual asset reference.
- Collectible or quest flags.

Exact resource categories, weights, values, and recipes are not finalized yet. Avoid creating dozens of resource types before the first prototype proves the loop.

## 5. Economy

Credits are the primary currency.

### 5.1 Revenue sources
- Direct sale of mixed scrap or individual objects.
- Sale of sorted materials.
- Sale of processed outputs.
- Special orders.
- Rare finds and collectibles, where appropriate.

### 5.2 Expenditure
- Tools and tool upgrades.
- Inventory or transport improvements.
- Employee hiring.
- Machines and machine upgrades.
- Storage and work-area improvements.
- Plot expansion.

### 5.3 Balance principles
- Purchases should be attainable through understandable play sessions.
- Each purchase must solve a visible problem or unlock a meaningful option.
- Avoid exponential prices that force monotonous grinding.
- Do not make processing compulsory.
- Communicate estimated output and value before confirming a processing choice.
- Test the economy with actual play sessions; do not treat placeholder figures as final balance.

## 6. Progression ladder

1. Manual collection and direct sale.
2. Basic tool upgrade.
3. Better carrying / transport capacity.
4. First helper, assigned to one simple task.
5. First affordable machine.
6. Basic processing or sorting station.
7. Additional helper or machine specialization.
8. Expanded work area and new object types.
9. More advanced automation and optional optimization.

The order can be tuned during prototyping, but the feeling of earning each step is mandatory.

## 7. Employees

Employees should have simple, legible roles. Initial candidate roles:
- Collector: gathers designated nearby small scrap.
- Carrier: moves collected items to a defined drop-off point.
- Station helper: operates one compatible station.

For the first prototype, implement only one employee role. The player should assign the role in one or two interactions. Avoid complex schedules and needs.

## 8. Early prototype acceptance tests

- A small object can be collected manually.
- A large object visibly requires an appropriate tool.
- The player can sell an item directly.
- A selected item can be processed for a different, understandable outcome.
- Sale and processing update credits / resources correctly.
- The player can buy a basic upgrade.
- A later progression goal clearly communicates the first helper or machine purchase.
- The player is never blocked from earning money due to a mandatory processing chain.
