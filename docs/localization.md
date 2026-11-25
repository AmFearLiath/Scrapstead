# Scrapstead — Localization & Internationalization Standard

**Version:** 0.1  
**Status:** Foundational production rule  
**Initial reference locales:** English (en), German (de)

## 1. Non-negotiable principle

Scrapstead is developed as a fully multilingual game from the first production asset onward. Localization is not a late-stage translation pass.

Every player-facing string must be externalized and addressable through a stable localization key. No gameplay system, UI component, item definition, dialogue, tutorial, notification, achievement, settings screen, or error message may depend on a hard-coded display string.

## 2. Separation of concerns

Keep these concerns separate:

- **Gameplay identity:** Stable IDs such as `scrap_rusted_bolt`.
- **Localization identity:** Keys such as `item.scrap_rusted_bolt.name`.
- **Localized content:** The translated value for each locale.
- **Gameplay data:** Values, tags, recipes, requirements, and behavior.
- **Presentation:** Fonts, layout, line wrapping, formatting, and audio/subtitle presentation.

Never use a translated name as a save-game identifier, database key, asset filename, code enum, or network identifier.

## 3. What must be localized

At minimum:
- UI labels, buttons, menus, settings, tooltips, and HUD text.
- Item, material, tool, machine, upgrade, employee, and Scrappy names.
- Descriptions, inspection text, contextual interaction prompts, and flavor text.
- Tutorials, onboarding, objectives, orders, notifications, and achievements.
- Dialogue, barks, subtitles, and accessibility text.
- Error, warning, confirmation, and save/load messages.
- Credits, legal notices, store-facing descriptions, and player-facing documentation shipped with the game.

Player-authored content and platform-provided names may follow separate rules, but must not break layout or encoding.

## 4. Locale files and key conventions

Use domain-oriented namespaces and stable semantic keys.

Examples:
- `ui.inventory.title`
- `ui.action.pick_up`
- `item.scrap_rusted_bolt.name`
- `item.scrap_rusted_bolt.description`
- `material.mat_copper_wire.name`
- `machine.magnet_collector.description`
- `dialogue.scrappy.first_repair.line_01`
- `tutorial.collection.pickup_hint`

Recommended locale structure:

```text
localization/
  en/
    ui.json
    items.json
    materials.json
    machines.json
    dialogue.json
    tutorials.json
  de/
    ui.json
    items.json
    materials.json
    machines.json
    dialogue.json
    tutorials.json
```

This is a logical structure, not a final engine-specific implementation decision. The chosen engine and localization tooling may dictate the physical file format.

## 5. Translation quality

- English and German are maintained as complete first-class locales.
- Translation must preserve meaning, tone, humor, and gameplay clarity rather than follow word-for-word literalism.
- Scrappy's personality must remain recognizable in every language while allowing culturally natural phrasing.
- Context notes should be available to translators for ambiguous strings.
- Avoid concatenating fragments to form sentences. Use complete translatable sentences and named placeholders.
- Gender, grammatical case, pluralization, and word order must be handled by localization-aware message formatting.
- Do not assume English word order or sentence structure in code.

## 6. Formatting and regional conventions

Use locale-aware formatting for:
- Numbers and decimal separators.
- Currency and price display.
- Dates and times.
- Measurement units where relevant.
- Percentages and signed values.
- Plural forms and count-sensitive messages.

Credits are the in-game currency, but their numeric presentation still uses locale-aware number formatting. Do not embed currency formatting into gameplay values.

## 7. UI and font readiness

Design all UI for text expansion and language-specific typography:
- Allow labels and descriptions to wrap or grow vertically.
- Avoid fixed-width controls that only fit English.
- Test long German compounds and longer translated phrases.
- Support accented characters and the required Unicode range for every supported language.
- Verify fallback fonts for missing glyphs.
- Avoid baking text into textures or images unless the asset is generated per locale.
- Keep text separate from icons wherever possible.
- Test subtitles, dialogue boxes, item cards, and narrow HUD elements at all supported resolutions.

## 8. Audio, subtitles, and accessibility

- Dialogue data must have stable line IDs independent of audio filenames.
- Subtitle text must be localized even when voice-over is not available in a locale.
- The architecture must allow per-language voice availability and fallback behavior.
- Accessibility labels and screen-reader-facing text are also localization content.
- Never make essential gameplay information available only through spoken dialogue or visual color.

## 9. Fallback and missing-key behavior

- Define one explicit fallback locale (initially English).
- Missing keys must be reported during development and automated validation.
- A missing translation must never silently display a raw localization key in a release build.
- Development builds should visibly flag missing keys.
- Locale changes must refresh relevant UI content without corrupting gameplay state or save data.

## 10. Validation and release gates

A locale is not considered complete merely because a translation file exists.

Required checks:
- Key parity between all shipped locales.
- No duplicate keys.
- No unused or unresolved keys without an explicit allowlist.
- Placeholder parity and valid formatting syntax.
- Font glyph coverage.
- UI overflow and clipping checks.
- Subtitle timing and line-break review.
- Manual linguistic review for high-visibility content.
- Save/load and locale-switch tests.

Localization checks should run automatically in the content validation pipeline.

## 11. Content authoring workflow

1. A designer creates a stable content ID and localization keys.
2. The source-language text is authored with context and character limits where relevant.
3. The same content record is completed for every active reference locale.
4. Validation checks key parity, placeholders, and formatting.
5. UI and in-game review checks text fit and meaning.
6. New content cannot be marked production-ready while required locale entries are missing.

English and German are the initial reference locales. The system must support adding further locales without changing gameplay code or content IDs.

## 12. Definition of done

A player-facing feature is localization-ready only when:
- It contains no hard-coded player-facing strings.
- All displayed text is referenced by stable localization keys.
- Every active reference locale has complete entries.
- Placeholders and plural rules are valid.
- Layout has been tested for text expansion and glyph coverage.
- Missing-key validation passes.

## 13. Engine implementation remains open

The localization principles in this document are binding. The specific runtime implementation, file format, import pipeline, translation management platform, and voice-over strategy remain technical decisions to be made after the engine/toolchain is selected.
