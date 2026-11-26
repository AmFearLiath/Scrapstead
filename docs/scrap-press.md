# Schrottpresse (zweite Maschine)

**Status:** umgesetzt (26.11.2026), Phase 4 „vollständiger eigener Betrieb“.
**Bezug:** [Maschinenverbindungen](machine-links.md), [Erste Maschine](first-machine.md),
[Bausystem](building-system.md), [Maschinen-Konzept](machines-automation.md).

## Zweck

Der Magnetsammler liefert viele kleine, billige Stahlteile (Schrauben 3 Cr,
Dosen 2 Cr). Die Presse macht daraus Stahlballen: 6 Teile werden ein Ballen
für 22 Cr, der im Korb nur 2 Plätze braucht statt 6. Mit einem Förderband vom
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

`data/machines/scrap_press.tres` (`PressProfile`): angenommene Teile
(Schraube, Dose), 6 Teile pro Ballen, 8 s pro Ballen, Trichter 12, Ablage 3.
Ballen: `data/items/bale_steel.tres` (22 Cr, Größe 2, Kategorie
`bulk_scrap`, Juri darf ihn tragen und verkaufen). Kauf im Baumenü über die
versteckte Katalogware `machine_scrap_press` (140 Cr), Platzierbar
`scrap_press` (4 × 6 Felder, Eingang hinten, Ausgang vorne, Bedienplatz vorne
und rechts).

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
