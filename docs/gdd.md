# Scrapstead — Game Design Document

**Version:** 1.3  
**Status:** Pre-production  
**Genre:** Cozy Automation Tycoon / Incremental Simulation  
**Platform target:** PC first  
**Perspective:** Isometric 3D  
**Visual style:** Stylized low-poly / cozy diorama  
**Tagline:** Every Scrap Has a Story.

## 1. High concept

The player inherits a neglected scrapyard and rebuilds it into a thriving recycling business. The journey begins with manual work and small sales, then grows through affordable tools, the first employee, the first machines, and eventually increasingly autonomous operations.

The scrapyard is a place of discovery. Ordinary junk can be sold immediately, while sorting, dismantling, and processing selected objects can produce better returns or reveal valuable components and collectibles.

A small, eccentric robot named Scrappy becomes the player's loyal companion. The player initially finds only his head beneath a heap of scrap and restores him with a special component from the red toolbox. From then on, Scrappy can be rebuilt piece by piece from salvaged parts.

## 2. Design pillars

1. **Easy to learn, fun to explore.** Every action should be immediately understandable.
2. **Visible progression.** The yard, machinery, workers, and Scrappy visibly evolve.
3. **Hybrid gameplay.** Manual play remains useful while delegation and automation gradually reduce repetitive work.
4. **Meaningful choices without mandatory complexity.** Players can sell directly or invest effort for better returns.
5. **Cozy personality.** Humor, small discoveries, warm visuals, and expressive machinery.
6. **Player freedom.** Players choose their preferred balance of collecting, processing, building, and optimization.
7. **Fully multilingual from day one.** All player-facing content is localization-key driven, and all systems, data, UI, and content pipelines are designed for additional languages from the start.

## 3. Core loop

Explore → Collect → Sell or Process → Earn → Invest → Delegate → Automate → Expand.

### 3.1 Collection

- Small loose objects can be picked up directly.
- Larger, awkward, or embedded objects require a suitable tool or machine.
- Tools improve access, speed, reach, or capacity.
- Scrappy can eventually assist with specific collection tasks.
- The player should always be able to make progress manually.

### 3.2 Scrap handling

There are two valid paths:

**Fast path:** Sell ordinary objects or mixed scrap directly for a lower, predictable return.

**Value path:** Inspect, sort, dismantle, or process selected objects for a potentially higher return, useful materials, components, or collectibles.

Processing is an opportunity, not a mandatory chore for every item.

### 3.3 Business growth

The player's growth should feel earned and gradual. The intended early sequence is manual work, practical tool improvements, a first helper, then a first machine. This is a pacing direction to validate in the prototype:

1. The player performs nearly all work personally.
2. The player improves basic tools and transport capacity.
3. The player can afford a first helper.
4. The helper takes over a clearly defined, simple task.
5. The player saves for the first affordable machine.
6. The business gains throughput and frees player time.
7. New employees, machines, and work areas are unlocked progressively.
8. The player eventually supervises a mostly automated yard.

Hiring and machines are meaningful investments. They should not be granted automatically or arrive so early that manual play becomes irrelevant.

## 4. Early, mid, and late game

The first employee and first machine are separate milestones. The employee demonstrates delegation; the first machine demonstrates mechanical automation. The player should experience both transitions and understand the benefit of each.

### Early game — One-person yard

- Manual collection and delivery.
- Small, clear sales.
- Basic tools and a simple handcart.
- Scrappy is discovered and restored.
- The first meaningful purchase is an attainable goal.
- The player learns the direct-sale and value-path options.

### Mid game — A growing business

- First employee or helper.
- First stationary machine.
- Basic sorting and dismantling.
- A small storage area.
- Scrappy gains useful modules.
- The player chooses which tasks to delegate first.

### Late game — A thriving operation

- Multiple workers and specialized machines.
- Several work areas.
- Expanded collection and processing capabilities.
- Optional production optimization.
- More plots and special discoveries.
- Scrappy has a highly personalized build and advanced assistance.

## 5. Economy principles

- Credits are the primary currency.
- Direct sale provides reliable, lower-value income.
- Processing may yield higher value but requires time, capacity, or investment.
- Employees and machines have purchase costs and understandable ongoing costs where appropriate.
- Every investment should communicate its expected benefit clearly.
- Avoid punitive upkeep, forced waiting, or economic soft-locks.
- Prices, costs, output, and progression pacing must be tuned through playtesting rather than assumed prematurely.

## 6. Employees

Employees are simple helpers, not a complex workforce-management simulation.

Each employee should have:
- A clear assigned task.
- A simple efficiency or speed value.
- A visible workplace behavior.
- A readable cost and benefit.

Initial tasks may include collecting nearby small scrap, moving items to a drop-off point, or assisting at a basic station. Avoid shift scheduling, complex needs, morale spreadsheets, and deep HR systems in the initial design.

## 7. Machines and automation

Machines should have one clear primary job, such as collecting, sorting, dismantling, compacting, or transporting. Their operation should be visible, but economic simulation should remain lightweight.

Automation should be unlocked gradually and should complement, not immediately invalidate, manual play.

## 8. Scrappy

Scrappy's head is found under a scrap pile. A special component from the red toolbox restores his core systems. The player then builds a body and upgrades him using parts found around the yard.

Scrappy is:
- A companion and guide.
- A source of dry humor and commentary.
- A helper with gradually unlocked functions.
- A modular customization project.
- A recognizable character and mascot.

The player can make practical, ridiculous, mismatched, or purely cosmetic builds. Scrappy's personality must remain consistent regardless of build efficiency.

## 9. World and presentation

- Isometric 3D camera.
- Cozy stylized low-poly / miniature diorama art.
- Warm, readable colors and soft lighting.
- Modular environment and machine assets.
- Clear silhouettes and readable interaction feedback.
- The yard visibly becomes cleaner, busier, and more organized as the player progresses.

## 10. User experience

- Context-sensitive interactions.
- Compact HUD.
- Short, optional explanations.
- New systems introduced one at a time.
- No mandatory complex production graphs.
- No excessive nested menus.
- Clear costs, yields, and upgrade effects.

## 11. Multilingual development

Scrapstead is developed as a fully multilingual game from the beginning. Localization is a foundational production and architecture requirement, not a post-production translation task.

- Every player-facing string must be stored in localization resources and referenced through a stable key.
- No UI, item, machine, dialogue, tutorial, notification, objective, accessibility label, or error message may rely on hard-coded display text.
- Gameplay IDs, save data, asset identifiers, and logic must never depend on translated names.
- English and German are the initial reference locales.
- The localization architecture must allow additional languages without changes to gameplay code or content IDs.
- Layouts must support text expansion, language-specific typography, Unicode glyph coverage, and locale-aware number/date/currency formatting.
- Plural forms, grammatical variation, and placeholders must use localization-aware formatting rather than string concatenation.
- Missing translations and key mismatches must be detected by automated validation.
- Scrappy's humor, tone, and personality must be adapted naturally in every language, not translated mechanically.
- Subtitles and accessibility text are localization content even when voice-over is unavailable in a language.

The detailed production rules, key conventions, validation gates, and content workflow are defined in [Localization & Internationalization Standard](localization.md).

## 12. MVP direction

The first prototype should validate one small plot and the complete progression loop:
- Collect small scrap manually.
- Use a tool for at least one larger object.
- Sell directly.
- Process a selected object for better value.
- Purchase a meaningful upgrade.
- Restore Scrappy.
- Demonstrate the first helper or first machine as the next progression milestone.

The MVP should prove that the game remains enjoyable before and after the first automation purchase.

## 13. Non-goals for the first version

- Multiplayer.
- Complex logistics programming.
- Mandatory processing of all items.
- Deep employee simulation.
- Complex power-grid management.
- Large procedural worlds.
- Large narrative campaign.
- Mandatory machine maintenance micromanagement.

## 14. Success criteria

The core experience succeeds when a new player can understand the first actions without a manual, feels a meaningful reward from the first sale, sees a clear reason to save for the next investment, and enjoys the gradual transition from doing the work to building a business.

The production pipeline succeeds when new content can be authored once with stable IDs and validated localized text, without introducing hard-coded language dependencies.
