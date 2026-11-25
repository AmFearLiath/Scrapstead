# Scrapstead — Progression & Business Growth Specification

**Version:** 0.1  
**Status:** Initial design specification

## 1. Purpose

This document defines how the player grows from a one-person scrapyard into a small, increasingly automated business.

The central fantasy is not simply buying increasingly expensive upgrades. It is **earning the right to stop doing one exhausting task personally, then choosing what to do with the time that creates**.

Every new employee or machine should:
- Take over a task the player already understands.
- Create a visible change in the yard.
- Have a clear cost and benefit.
- Open a new choice rather than add mandatory micromanagement.
- Leave the player with enjoyable things to do.

## 2. Progression principles

### 2.1 Earned delegation
The player starts by doing nearly everything. Help is purchased only after the player has earned enough money and demonstrated the relevant task through play.

### 2.2 One new concept at a time
Do not introduce hiring, machine placement, processing recipes, storage rules, and multiple material types all at once. Each system should arrive with a short, contextual explanation.

### 2.3 Automation removes repetition, not agency
Automation should remove repetitive chores while leaving exploration, decisions, upgrades, discoveries, layout choices, and Scrappy customization meaningful.

### 2.4 The player remains useful
Manual work must remain viable and sometimes advantageous. Employees and machines improve throughput or convenience; they should not make the player feel redundant.

### 2.5 No idle-wall progression
The player should not be forced to wait for long periods just to afford the next milestone. Active play, discoveries, optional processing, and orders should provide ways to make progress.

## 3. Business stages

### Stage 0 — The inherited yard

**Player role:** Owner, collector, sorter, loader, and salesperson.

Available:
- A small starting plot.
- A basic hand tool.
- A small carrying capacity.
- A simple place to sell mixed scrap.
- A few visible scrap piles and loose objects.
- The red toolbox and Scrappy's buried head as early discoveries.

The player learns movement, interaction, collection, and direct sale. Do not introduce employees or machinery before the basic loop is understood.

**Goal:** Earn enough to make the first practical improvement.

### Stage 1 — Working smarter

**Player role:** Hands-on owner with better tools.

Unlocks may include:
- Better gloves or a basic collection tool.
- A handcart or improved carrying capacity.
- A simple inspection tool.
- Access to one optional dismantling interaction.

This stage teaches the distinction between selling something immediately and spending extra effort to obtain better value.

**Goal:** Improve the daily work routine and build a financial buffer.

### Stage 2 — First helper

**Player role:** Owner who can delegate one simple task.

The player hires the first employee. Recommended first role: **yard hand / carrier**.

The yard hand:
- Collects or carries a limited class of small scrap.
- Works within a clearly marked or easily understood area.
- Moves items to one designated drop-off point.
- Does not make complex economic decisions.
- Has a visible, friendly presence in the yard.

For the first prototype, implement only one task. Preferred candidate: carrying items to a drop-off point, because the player has already experienced repeated trips.

The employee has a clear hiring cost and a modest, understandable wage or operating cost. The player should be able to sustain the role through normal play, without a hidden financial trap.

**Goal:** Decide which task is worth delegating and use the time saved for higher-value activities.

### Stage 3 — First machine

**Player role:** Owner who combines personal work with a small amount of mechanical assistance.

Recommended first machine: **small magnetic collector**.

It:
- Collects loose metal objects in a defined area.
- Has a visible magnet arm or magnetic head.
- Deposits collected items at one nearby drop-off point.
- Has one obvious upgrade, such as collection speed or radius.

The player still collects non-metal objects and investigates interesting finds.

A basic sorting station is the next machine milestone, not part of the first machine's feature set.

**Goal:** Combine manual collection, one helper, and one machine without complex production-line management.

### Stage 4 — A small working yard

New options:
- A second helper or a specialized task.
- A sorting station.
- A larger storage or drop-off area.
- More object types.
- A simple order or delivery request.
- Additional Scrappy modules.

The player chooses whether to invest in more people, more machinery, better tools, or optional processing. There must not be one mandatory upgrade path.

### Stage 5 — A growing recycling business

New options:
- Specialized machines.
- Additional work areas.
- More employee task types.
- Better transport.
- Higher-value materials and objects.
- More complex, but still optional, processing choices.
- Further land expansion.

### Stage 6 — Established operation

The player oversees multiple simple systems and a mostly automated yard. This stage is beyond the first prototype and should be designed only after earlier stages are fun.

## 4. Employee design

Employees are helpful characters, not a management spreadsheet.

Each employee should have:
- A name and recognizable appearance.
- One assigned job.
- A simple work area or target.
- A readable speed / efficiency value.
- A clearly displayed cost.
- A small set of contextual reactions.

Do not implement hunger, fatigue, complex schedules, morale meters, skill trees, or staff hierarchies in the initial game.

### First employee flow

1. Meet or unlock the candidate.
2. Review their task and cost.
3. Hire.
4. Select the one supported task.
5. See them begin working in the yard.

The employee should not generate money from nothing. They move or collect actual available objects, and their contribution is visible.

Use a transparent, modest operating cost. Avoid negative cash spirals. If the player cannot cover costs, use a forgiving behavior such as pausing the employee's work or allowing clear dismissal. Never silently drain the player into an unrecoverable state.

## 5. Machine progression

### First machine: Small magnetic collector

- Collects loose metal objects in a defined area.
- Has a visible magnet mechanism.
- Deposits objects at one nearby drop-off point.
- Has one obvious upgrade: speed or radius.
- Does not require conveyor routing in the first implementation.

### Second machine: Basic sorting station

- Accepts a small set of mixed scrap.
- Separates one or two material categories.
- Produces clearly labeled outputs.
- Improves the return compared with selling the same mixed batch.

Keep the first recipe and output set deliberately small.

Before purchase, show what a machine does, what it handles, where it can be placed, what it costs, and what it improves.

## 6. Economy and affordability

Exact prices, wages, sale values, and production rates are **not finalized**. They must be tuned through a playable prototype.

### 6.1 Purchase hierarchy

Intended order of magnitude:
1. Basic tool improvement — inexpensive and quickly attainable.
2. Carrying / transport improvement — affordable after a little more play.
3. First employee — a meaningful investment, but not an intimidating grind.
4. First machine — a larger milestone requiring saving and deliberate choice.
5. Second production capability — a substantial next goal.

The first employee should generally arrive before the first machine. This is the intended pacing, subject to playtest validation.

### 6.2 Value comparison

Direct sale remains a viable baseline. Optional processing is compared using direct sale value, processed output value, time or machine capacity consumed, operating cost, and opportunity cost.

Processing should be attractive in selected situations, not universally mandatory.

### 6.3 Playtest telemetry

Record:
- Time to first sale.
- Time to first tool upgrade.
- Time to first carrying upgrade.
- Time to first employee.
- Time to first machine.
- Player cash balance over time.
- Share of objects sold directly versus processed.
- Time spent walking / carrying versus collecting / discovering.
- Whether the player understands why the next purchase is useful.

Use this data to tune pacing. Do not lock exact minute targets before the prototype exists.

## 7. First-hour experience

This is an intended sequence of discoveries, not a strict timer:

1. The player arrives and learns to pick up a small object.
2. The player sells the first load and receives a clear reward.
3. The player discovers that a larger object needs a tool.
4. The player finds the red toolbox and eventually Scrappy's head.
5. The player restores Scrappy with the special component.
6. Scrappy gives a helpful hint or points out an interesting object.
7. The player purchases a basic tool or carrying improvement.
8. The player encounters the first optional dismantling / better-value opportunity.
9. The player meets or unlocks the first employee candidate.
10. The player saves for and hires the first helper.
11. The player sees the helper take over a task they previously performed.
12. The first machine becomes the next clear business goal.

Avoid introducing every system in one tutorial sequence. Let the player use each new system before another is presented.

## 8. First playable progression slice

The first vertical slice should include:
- One small yard.
- A few loose scrap objects.
- One large object requiring a tool.
- Direct sale.
- One optional dismantling or processing interaction.
- One basic tool upgrade.
- One carrying upgrade.
- Scrappy's discovery and restoration.
- One employee with one simple task.
- One machine with one clear function.

This validates the defining progression fantasy: **the player starts by doing the work, earns help, and gradually builds a business.**

## 9. Open questions for later validation

- Should the first employee carry objects or collect them?
- Should employee upkeep be a per-day, per-shift, or simple periodic cost?
- Should the first machine require a worker, or operate independently?
- How large should the initial plot and work radius be?
- How much of the player's income should come from direct sales versus optional processing?

Resolve these through prototype playtests, not speculative complexity.
