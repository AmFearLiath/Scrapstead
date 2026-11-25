# Scrapstead

**Every Scrap Has a Story.**

Scrapstead is a cozy, humorous isometric automation tycoon about turning a forgotten scrapyard into a thriving recycling business.

## Project status

Pre-production / Game Design.

The repository is currently used to collect the game's design documentation, decisions, specifications, and development planning. No engine implementation is assumed yet.

## Design pillars

1. **Easy to learn, fun to explore.** Simple interactions; depth through combinations.
2. **Visible progression.** The yard visibly transforms as the business grows.
3. **Hybrid gameplay.** The player begins with manual work and gradually delegates tasks to employees and machines.
4. **Meaningful automation.** Machines have clear, understandable jobs.
5. **Cozy personality.** Warm diorama visuals, humor, charming machines, and Scrappy.
6. **Player freedom.** Multiple ways to collect, process, sell, build, and customize.
7. **Fully multilingual from day one.** All player-facing content is localization-key driven and designed for internationalization from the beginning.

## Canonical decisions

- Perspective: isometric 3D.
- Atmosphere: cozy, funny, whimsical.
- Art direction: stylized low-poly / miniature diorama.
- Gameplay: hybrid manual + automation.
- Collection: direct pickup for small objects; tools or equipment for larger objects.
- Scrap economy: basic scrap can be sold directly; sorting and processing are optional ways to achieve better returns.
- Progression: player performs the work first, then hires help, buys initial machines, and gradually builds an automated operation.
- Companion: Scrappy, a modular robot whose head is found under a scrap pile and restored using a special component from the red toolbox.
- Scrappy customization: player builds him from salvaged parts; combinations can be useful, absurd, or purely cosmetic.
- Localization: fully multilingual development from the first production asset; no hard-coded player-facing strings; stable IDs and localization keys.
- Initial reference locales: English and German; further locales must be addable without gameplay-code changes.
- Core design rule: **Simple Core, Endless Possibilities.**

## Documentation map

- [Game Design Document](docs/gdd.md)
- [Gameplay & Economy Specification](docs/gameplay-economy.md)
- [Progression & Business Growth](docs/progression-business-growth.md)
- [Starting Yard Item Catalog](docs/starting-yard-item-catalog.md)
- [Localization & Internationalization Standard](docs/localization.md)
- [Scrappy Companion Specification](docs/scrappy-companion.md)
- [Machines & Automation Specification](docs/machines-automation.md)
- [World & Asset Design](docs/world-art-assets.md)
- [UI & UX Specification](docs/ui-ux.md)
- [Technical Architecture](docs/technical-architecture.md)
- [Decision Log](docs/decision-log.md)

## Guiding rule

Scrapstead should offer many possibilities without making the player manage unnecessary complexity. Complexity should emerge from simple systems working together—not from complicated controls, excessive menus, or mandatory micromanagement.
