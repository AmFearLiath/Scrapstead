# Scrapstead — Decision Log

This file records decisions considered canonical for the current design. New decisions should be appended with date, context, decision, and consequences.

## 2026-11-25 — Project identity and core design

- Name: Scrapstead.
- Tagline: Every Scrap Has a Story.
- Genre: Cozy Automation Tycoon.
- Camera: Isometric 3D.
- Gameplay: Hybrid manual work and automation.
- Atmosphere: Cozy, funny, whimsical.
- Art direction: Stylized low-poly / miniature diorama.
- Core principle: Simple Core, Endless Possibilities.
- Scrappy is the companion and mascot.

## 2026-11-25 — Collection model

**Decision:** Hybrid collection.

- Small loose objects are picked up directly.
- Larger or embedded objects require tools or equipment.
- Rationale: direct interaction keeps the game fast, while tools create progression and variety.

## 2026-11-25 — Scrap economy

**Decision:** Direct sale plus optional value path.

- Ordinary scrap may be sold directly for a lower predictable return.
- Selected items can be sorted, dismantled, or processed for potentially better returns, components, or discoveries.
- Processing is optional, not mandatory.
- Rationale: the game stays approachable while still offering meaningful choices.

## 2026-11-25 — Business progression

**Decision:** Gradual earned delegation.

- The player begins doing almost everything personally.
- Better tools and carrying capacity come first.
- The player can then afford a first employee.
- The player later saves for the first machine.
- Employees and machines gradually take over clear tasks.
- Automation grows over time; it does not arrive immediately.
- Rationale: each investment should feel earned and visibly meaningful.

## 2026-11-25 — Scrappy's origin and customization

**Decision:** The player initially finds only Scrappy's head beneath scrap.

- A special component from the red toolbox restores the head.
- The player builds Scrappy from salvaged body, locomotion, arm, sensor, and cosmetic parts.
- Builds can be practical, silly, or cosmetic.
- Scrappy remains loyal, witty, and a little talkative.
- His personality must not depend on the chosen parts.

## 2026-11-25 — Simplicity

**Decision:** Keep the game simple while offering many possibilities.

- Complexity comes from combinations of understandable systems.
- Avoid mandatory micromanagement, complex logistics programming, excessive menus, and unnecessarily large resource taxonomies.
- Introduce systems gradually.

## 2026-11-25 — First progression sequence

**Decision:** The player's business grows through earned, gradual delegation.

- The player begins by doing nearly all work personally.
- Basic tool and carrying improvements come first.
- The first employee is intended to arrive before the first machine, subject to playtest validation.
- The employee takes over one clear task the player already understands.
- The first machine then automates a similarly clear task.
- Exact prices, wages, and timing are deliberately not fixed before the economy prototype.
- Rationale: each investment should feel like a meaningful step toward a larger business, not an instant jump to automation.

## 2026-11-25 — Hybrid collection and optional processing

- Small loose objects can be picked up directly.
- Larger or embedded objects require suitable tools or equipment.
- Ordinary scrap can be sold directly.
- Selected items can be sorted, dismantled, or processed for better potential value.
- Processing is optional and must not become a mandatory chore.

## 2026-11-25 — Fully multilingual development

**Decision:** Scrapstead is multilingual by design from the first production asset.

- Every player-facing string must use a localization key; hard-coded display strings are not permitted.
- Stable gameplay IDs, save data, asset identifiers, and logic are independent of language.
- English and German are the initial reference locales.
- Additional languages must be addable without changing gameplay code or content IDs.
- UI, fonts, formatting, subtitles, accessibility text, and content validation must support localization from the beginning.
- Missing translations and key mismatches must be detectable through automated checks.
- Rationale: retrofitting localization later would create avoidable architectural, content, and UI rework.

## 2026-11-25 — First property item catalog

**Decision:** Build the first property's object catalog as a compact gameplay system rather than an unstructured list.

- Catalog entries use stable language-independent IDs and localized name/description keys.
- The initial catalog includes loose scrap, bulk scrap, dismantling candidates, discovery sources, valuable finds, and standardized processing outputs.
- Direct sale remains available for sellable objects.
- Processing is optional and selective.
- Economy values remain relative tiers until prototype balancing.
- The red toolbox's Scrappy Core Component is an authored, guaranteed progression discovery rather than a random blocker.
- Rationale: a focused catalog should teach the core loop and create meaningful variety without overwhelming the first property.
