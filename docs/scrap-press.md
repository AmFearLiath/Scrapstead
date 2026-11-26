# Schrottpresse (zweite Maschine)

**Status:** umgesetzt (26.11.2026), Phase 4 „vollständiger eigener Betrieb“.
**Bezug:** [Maschinenverbindungen](machine-links.md), [Erste Maschine](first-machine.md),
[Bausystem](building-system.md), [Maschinen-Konzept](machines-automation.md).

## Zweck

Die Presse macht aus losem Schrott sortenreine Ballen: Stahl (6 Teile → 22 Cr),
Kupfer & Elektronik (4 Teile → 40 Cr) und Holz (6 Teile → 17 Cr). Ein Ballen
braucht im Korb nur 2 Plätze. Bis zu drei Pressen, je 140 Cr; siehe
[Verarbeitungskette](processing-chain.md). Mit einem Förderband vom
Magnetsammler läuft die Kette „Magnet → Band → Presse → Ballen“ ohne Zutun;
der Spieler (oder Juri) verkauft nur noch Ballen.

## Bedienung

- **Trichter** (hinten): „Einfüllen (halten)“ nimmt alle passenden Teile aus
  dem Korb. Ohne passende Teile erklärt die Presse, was sie mag.
- **Steuerkasten** (rechts): Ein/Aus, Status (presst / wartet auf Schrott /
  Ablage voll / aus), Trichter- und Ablagestand. Die Statuslampe zeigt den
  Zustand farbig.
- **Ablage** (vorne): bis zu 3 Ballen. Ist sie voll, hält die Presse an.
- Wegräumen geht erst mit leerem Trichter und leerer Ablage.

## Daten

`data/machines/scrap_press.tres` (`PressProfile`): Materialgruppen aus
`data/materials/`, 8 s pro Ballen, Trichter 12, Ablage 3. Ballen:
`bale_steel`, `bale_copper`, `bale_wood` (Größe 2, Kategorie `bulk_scrap`,
Juri darf sie tragen und verkaufen). Kauf im Baumenü als Stückware (140 Cr,
höchstens 3), Platzierbar `scrap_press` (4 × 6 Felder, Eingang hinten,
Ausgang vorne, Bedienplatz vorne und rechts).

## Technik

- `scripts/world/ScrapPress.gd`: Prozesslogik, Speichern (`on`, `timer`,
  `hopper`, `counter`, Ballen), Bau-Hooks, Port-Schnittstelle
  (`accepts_item_type`, `can_accept`, `accept_item`, `get_output_items`,
  `get_output_item_ids`, `get_port_position`).
- `scripts/world/PressControls.gd`: Trichter und Steuerkasten.
- `scripts/world/ScrapPressAnimator.gd`: Stempel, Hebel, Statuslampe.
- Modelle in `tools/blender/props_press.py`: `scrap_press`, `press_tray`,
  `bale_steel`, Förderbandteile.
- Eingefüllte Teile werden sofort verbraucht (Zustand „processed“); der
  Trichter speichert nur ihre Item-IDs.

## Tests

`tests/integration/test_press_links.gd`.
