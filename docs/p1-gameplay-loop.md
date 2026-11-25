# Scrapstead — P1: Erste Gameplay-Schleife (Umsetzung)

**Version:** 0.2  
**Status:** Implementiert und automatisiert getestet. Spielgefühl von der Projektleitung als gut bewertet; P1 wird vertieft und ist noch nicht spielerisch freigegeben  
**Engine:** Godot 4.7.2 Stable / GDScript  
**Grundlage:** `mvp-prototype-plan.md` (Abschnitt 4), `starting-yard-item-catalog.md`, `core-gameplay-matrix.md`, P0-Spezifikationen

---

## 1. Ziel

P1 macht aus dem technischen P0-Fundament eine kleine, wiederholbare Spielschleife:

**Erkunden → Sammeln → Bergen → Verkaufen → Credits → Upgrade → effizienter sammeln → erneut verkaufen.**

Die Schleife funktioniert ohne Scrappy, Mitarbeiter, Maschinen, Story oder Debug-Funktionen.

## 2. Spielbereich

Der P1-Ausschnitt liegt im bestehenden Old-Yard-Blockout. Alle Positionen sind Layoutkoordinaten (X Ost, Z Nord); in Godot gilt `Welt-Z = −Layout-Z` (siehe Decision Log).

| Element | Layoutposition | Zone | Zweck |
|---|---|---|---|
| Spielerstart | 8 / 4,6, Blick Nord | E | Einstieg an der Einfahrt (seit Art-Pass 26.11.2026; vorher 8 / 3) |
| Annahmetresen (`station_sell_counter`) | 11,6 / 6, Kundenseite West | E | Verkauf |
| Büro: Bestellkatalog (`station_order_desk`) | 5,4 / 14,2, Front Süd | C | Kauf von Werkzeug und Transportmitteln (0.2) |
| Werkbank (`station_workbench`) | 10,5 / 14,2, Front Süd | C | Nur untersuchbar, Crafting folgt (0.2) |
| Hinweisbrett (`p0_inspect_board_01`) | 4,6 / 3,2 | E | Untersuchen (aus P0) |
| Hofstrahler (`p0_use_floodlight_01`) | 17,5 / 9 | E/D | Benutzen (aus P0) |
| 6 lose Kleinteile | E, D, Weg nach A/B | E, D | Sammeln |
| Metallträger (`bulk_metal_beam_01`) | 31,5 / 25,2 vor dem großen Haufen | B | Bergen |

Es gibt bewusst keine Regeneration der Fundstücke (MVP-Plan, P1-Vereinfachungen).

## 3. Gegenstände (datengetrieben)

Definitionen liegen als Godot-Resources in `data/items/` (`ItemDefinition`), gesammelt im `ItemCatalog` (`data/items/item_catalog.tres`). Werte sind **P1-Prototypwerte** zur Validierung der Schleife, keine finalen Wirtschaftswerte.

| ID | Kategorie | Handhabung | Wert | Plätze | Instanzen |
|---|---|---|---:|---:|---:|
| `scrap_rusted_bolt` | loose_scrap | Hand | 3 Cr | 1 | 2 |
| `scrap_empty_can` | loose_scrap | Hand | 2 Cr | 1 | 2 |
| `scrap_wire_coil` | loose_scrap | Hand | 7 Cr | 1 | 2 |
| `bulk_metal_beam` | bulk_scrap | Carry, Bergung | 20 Cr | 3 | 1 |

Die Wertverhältnisse folgen den relativen Stufen des Katalogs (Very Low < Low < Medium). Jede platzierte Instanz besitzt eine eigene stabile Objekt-ID (`scrap_rusted_bolt_01`, …).

**Weltzustand je Objekt:** `in_world` (ggf. mit abgelegter Position), `carried`, `sold`. Die Bergung wird zusätzlich als `salvaged` geführt.

## 4. Tragen (Tragekorb)

- `CarryInventory` hält aufgenommene Objekt-IDs in Aufnahmereihenfolge.
- Kapazität in **Plätzen**: Grundwert 4 (`data/prototype/p1_balance.tres`), Kleinteile belegen 1, der Träger 3 Plätze.
- Ist kein Platz frei, wird die Aufnahme abgelehnt; der Prompt zeigt „Korb voll“, der Gegenstand bleibt liegen.
- **Ablegen:** Taste Q legt das zuletzt aufgenommene Teil vor dem Spieler ab (nicht in Wände; Fallback: Spielerposition). Die abgelegte Position wird gespeichert. Das deckt „Gegenstände verwalten“ ohne großes Inventarsystem ab.
- HUD oben rechts: „Tragekorb x / y“, Platzanzeige und kompakte Liste (Name × Anzahl · Wert).

## 5. Bergung

Der Metallträger steckt unter Gerümpel (sichtbare Trümmer auf dem Modell).

- **Erkennbare Voraussetzung:** Der Prompt zeigt „Bergen (halten)“ und „braucht 3 freie Plätze · 20 Cr“.
- **Aktion:** Taste E **halten** (2,5 s). Fortschrittsbalken im Prompt, der Träger rüttelt währenddessen.
- **Abbruch:** Loslassen, Weglaufen oder Zielwechsel bricht ohne Zustandsänderung ab.
- **Abschluss:** Trümmer verschwinden, der Träger liegt im Tragekorb (3 Plätze), Rückmeldung „Geborgen: Metallträger (20 Cr)“.
- Ohne genügend Platz wird die Bergung mit verständlicher Meldung abgelehnt.
- Ein bereits geborgener, wieder abgelegter Träger wird normal aufgehoben (keine zweite Bergung).

Ein Werkzeug wird nicht eingeführt; die Spezifikation erlaubt „passende Interaktion oder ein einfaches Werkzeug“.

## 6. Verkauf

- Der Annahmetresen zeigt im Prompt die Anzahl und den möglichen Erlös.
- E öffnet das Verkaufsfenster: Zeilen je Gegenstandsart (Anzahl × Stückpreis = Summe), Gesamtsumme, Schaltfläche „Für X Cr verkaufen“ und „Abbrechen“.
- Es wird immer die gesamte Ladung verkauft (einfachster verständlicher Ablauf).
- **Doppelte Transaktionen werden verhindert durch:**
  1. eine eindeutige Transaktions-ID pro Angebot (vom Wallet reserviert),
  2. Ablehnung bereits gebuchter IDs im Wallet,
  3. eine Inventar-Revision im Angebot – ändert sich die Ladung, wird das Angebot als veraltet abgelehnt,
  4. Deaktivieren der Bestätigung vor der Buchung (Doppelklick).
- Erst nach erfolgreicher Gutschrift werden Gegenstände entfernt und als `sold` markiert.
- Ohne Ladung lehnt der Tresen mit Hinweis ab.

## 7. Credits

`Wallet` ist die zentrale Credit-Verwaltung der Sitzung:

- `credit()` / `debit()` mit Validierung (nur positive Beträge, keine doppelte Transaktions-ID, kein negativer Kontostand).
- Laufende Transaktionsnummer und ein Buchungsprotokoll der letzten 20 Buchungen (nachvollziehbar, gespeichert).
- Signal `balance_changed` aktualisiert das HUD (Zähler-Animation und +/−-Anzeige).
- Nur eine Währung (Credits).

## 8. Upgrade

Definition: `data/upgrades/upgrade_carry_basket.tres` (`UpgradeDefinition`), gelistet in `upgrade_catalog.tres`.

| ID | Preis | Wirkung |
|---|---:|---|
| `upgrade_carry_basket` (Großer Tragekorb) | 30 Cr | Tragekapazität +4 (4 → 8) |

- Die Werkbank zeigt Name, Beschreibung, Wirkung („Tragekapazität: 4 → 8 Plätze“), Preis und Status (Kaufen / Zu wenig Credits / Gekauft).
- Kauf nur bei ausreichenden Credits; Zahlung über das Wallet (Transaktions-ID je Upgrade), erst danach wird das Upgrade gewährt.
- Die Kapazität ändert sich sofort; das HUD zeigt die neuen Plätze.
- Weitere Upgrades werden als zusätzliche Resources angelegt. Unterstützt wird derzeit der Wert `carry_capacity`; ein neuer Wert erfordert eine bewusste Erweiterung.

**Warum diese Werte:** Alle losen Teile zusammen bringen 24 Cr. Das Upgrade (30 Cr) ist also nur mit der Bergung des Trägers (20 Cr) erreichbar – die Schleife verlangt Sammeln **und** Bergen. Nach zwei Verkaufsgängen ist das Upgrade immer bezahlbar; die restlichen Teile passen danach in einen statt zwei Gänge. Die Werte sind im Playtest zu prüfen.

## 9. Speichern und Fortsetzen

- Spielerseitig: **Esc → Pausemenü** mit „Weiterspielen“, „Speichern“, „Speichern & Hauptmenü“, „Hauptmenü ohne Speichern“. F5 bleibt eine reine Entwickleraktion.
- Spielstandschema **Version 2** (Version 1 = P0 wird abgelehnt, nicht migriert):

```json
{
  "save_version": 2,
  "scene_id": "old_yard_test",
  "player": {"position": [x, y, z], "facing": 0.0},
  "world_objects": {"<id>": {"state": "carried|sold|in_world", "position": [x, y, z], "yaw": 0.0, "salvaged": true}},
  "wallet": {"balance": 0, "sequence": 0, "ledger": [{"id": "sale-1", "amount": 15, "reason": "ui.ledger.sale"}]},
  "inventory": ["<object_id>", "..."],
  "upgrades": ["upgrade_carry_basket"]
}
```

- SaveService validiert Typen, negative Kontostände und String-Listen.
- Beim Laden repariert OldYardTest Inkonsistenzen kontrolliert und protokolliert sie (unbekannte IDs, getragene Objekte ohne Inventareintrag, unbekannte Upgrades).

## 10. Systeme und Verantwortlichkeiten

| Baustein | Datei | Verantwortung |
|---|---|---|
| `ItemDefinition`, `ItemCatalog` | `scripts/data/` | Gegenstandsdaten |
| `UpgradeDefinition`, `UpgradeCatalog` | `scripts/data/` | Upgradedaten |
| `PrototypeBalance` | `scripts/data/` | Grundkapazität, Startcredits, Protokollgröße |
| `Wallet` | `scripts/economy/` | Credits, Transaktionen |
| `CarryInventory` | `scripts/inventory/` | Getragene Objekte, Kapazität |
| `UpgradeProgress` | `scripts/progression/` | Gekaufte Upgrades, Boni |
| `ScrapItem` | `scripts/world/` | Weltzustand eines Fundstücks, Aufnahme, Ablegen |
| `SalvageableScrap` | `scripts/world/` | Bergung (Halten, Voraussetzung, Trümmer) |
| `SellStation` | `scripts/world/` | Angebot, Verkaufsbuchung |
| `UpgradeStation` | `scripts/world/` | Angebote, Kauf |
| `EconomyHud`, `SellPanel`, `UpgradePanel`, `PauseMenu` | `scripts/ui/` | Darstellung, keine Regeln |
| `OldYardTestController` | `scripts/world/` | Aufbau, Wiederherstellung, Snapshot, UI-Routing |

Die P1-Laufzeitsysteme sind kleine `RefCounted`-Objekte der Gameplay-Szene. Es gibt weiterhin nur die Autoloads GameSession und SaveService. Interaktionsziele erhalten ihre Abhängigkeiten über `InteractionContext`.

## 11. Steuerung

| Aktion | Taste |
|---|---|
| Bewegen | WASD / Pfeiltasten |
| Interagieren / Bergen (halten) | E |
| Letztes Teil ablegen | Q |
| Pausemenü / Panel schließen | Esc |
| Zoom | Mausrad |
| Debug-Overlay (nur Debug-Build) | F3 |
| Entwickler-Speichern (nur Debug-Build) | F5 |

## 12. Bewusst nicht umgesetzt

Dynamische Preise, Lager, Regeneration, Werkzeuge, Qualitätsstufen, Scrappy, Story, Mitarbeiter, Maschinen, Baumodus.

## 13. P1b: Optionale Verarbeitung

| Element | Umsetzung |
|---|---|
| Eingabe | `device_broken_radio_01` (Defektes Radio, 12 Cr, 2 Plätze), Lagerzone A (Layout 12 / 30) |
| Station | Zerlegetisch `station_dismantle_table`, Zone D (Layout 31 / 7) |
| Aufwand | E 3,5 s halten, Radio muss getragen werden |
| Ausgaben | Kupferdraht (8 Cr) + Elektronikteile (8 Cr), je 1 Platz |
| Anzeige | Prompt zeigt Direktwert, Dauer, Ausgaben und Ergebniswert |
| Daten | `ProcessingProfile` in `data/processing/dismantle_broken_radio.tres` |

Direktverkauf des Radios bleibt möglich. Bewertung in der [Prototyp-Abnahme](prototype-acceptance.md), Abschnitt 8.

## 14. P1-Vertiefung (Version 0.2)

**Status:** Beschlossen am 25.11.2026 nach dem ersten Anspielen; umgesetzt und automatisiert getestet. Die Abschnitte 2–8 beschreiben den Stand 0.1; wo 0.2 abweicht, gilt dieser Abschnitt.

### 14.1 Entscheidungen der Projektverantwortlichen

- Die Schleife wird vor P2 vertieft: Suchquellen, erstes Werkzeug, zweites Transport-Upgrade, Objekt-Inspektion.
- Werkzeuge, Ausrüstung und Transportmittel werden **gekauft**, und zwar im **Büro über Walts alten Bestellkatalog** – nicht an der Werkbank.
- Die **Werkbank ist für das Herstellen (Crafting)** vorgesehen. Crafting folgt später; bis dahin ist die Werkbank nur untersuchbar und täuscht keine Funktion vor.
- Der Metallträger erfordert ein **Hebemittel (Flaschenzug)**. Der **Handkarren** ist das separate zweite Transport-Upgrade.
- Alle Texte folgen der Humoridentität (lore-walt-wren.md, Abschnitte 7–8): trockener Ton, Komik über Objekte, Beschriftungen und den Katalog, sparsam dosiert, de/en gleichwertig. Scrappy tritt in P1 nicht auf.

### 14.2 Bestellkatalog (Büro, Zone C)

| ID | Ware | Preis | Wirkung | Voraussetzung |
|---|---|---:|---|---|
| `tool_crowbar` | Brechstange | 12 Cr | Werkzeug `crowbar`: öffnet vernagelte bzw. versiegelte Suchquellen | – |
| `upgrade_carry_basket` | Großer Tragekorb | 30 Cr | Tragekapazität +4 (4 → 8) | – |
| `tool_hoist` | Flaschenzug | 25 Cr | Werkzeug `hoist`: hebt feststeckende schwere Objekte frei | – |
| `upgrade_handcart` | Handkarren | 40 Cr | Tragekapazität +4 (8 → 12) | Großer Tragekorb |

- Bestellt wird am Schreibtisch neben der Bürotür (`station_order_desk`). Gekaufte Ware erscheint sichtbar an der Lieferstelle vor dem Büro.
- Das HUD zeigt besessene Ausrüstung unter dem Tragekorb.
- Datenmodell: `UpgradeDefinition` erhält `grants_tool`; Werkzeugbesitz fragt `UpgradeProgress.has_tool()` ab.

### 14.3 Suchquellen

Durchsuchen ist eine kurze Halte-Aktion (1,5 s). Die Funde sind festgelegt (kein Zufall) und fallen sichtbar vor die Quelle; aufgehoben werden sie wie jedes Fundstück. Jede Quelle ist einmalig.

| ID | Quelle | Zone | Werkzeug | Inhalt |
|---|---|---|---|---|
| `source_small_scrap_pile_01` | Kleiner Schrotthaufen | A | – | Schraube, Dose, Holzabschnitt |
| `source_old_toolbox_01` | Alter Werkzeugkasten | C | – | Messingfigur, Kabelknäuel |
| `source_storage_crate_01` | Lagerkiste „Wichtige Ersatzteile“ | A | Brechstange | 3 Schrauben, Kabelknäuel |
| `source_rusted_drum_01` | Versiegeltes Rostfass | B | Brechstange | 2 Dosen, Kupferrohr |

Neue Gegenstände (Startkatalog): `scrap_wood_offcut` (2 Cr), `scrap_copper_pipe` (6 Cr), `find_brass_figurine` (15 Cr, Sammlerstück).

### 14.4 Wirtschaftliche Prüfung

Gesamterlös aller Funde: lose Teile 24, Suchquellen ohne Werkzeug 29, mit Brechstange 26, Träger 20, Radio 12 (zerlegt 16) → **111–115 Cr**. Gesamtkosten des Katalogs: **107 Cr**. Wer alles kauft, hat am Ende kaum Reserve; die Reihenfolge der Käufe ist eine echte Entscheidung (früh Kapazität oder früh Zugang). Werte bleiben Playtest-Startwerte in `data/`.

### 14.5 Objekt-Inspektion

- Neue Eingabe `inspect_target` (Taste R). Der Prompt zeigt sie zusätzlich, wenn das Ziel Informationen bietet.
- Fundstücke zeigen Name, Kategorie, Wert, Plätze und eine kurze Beschreibung; Quellen und Einrichtungen eine Beschreibung.
- Inspektion verändert keinen Zustand (Matrix 4.1, Objektinspektion).

### 14.6 Umsetzung

| Baustein | Datei |
|---|---|
| Bestellkatalog | `scripts/world/OrderDesk.gd`, `scenes/interaction/OrderDesk.tscn`, `scripts/ui/CatalogPanel.gd` |
| Lieferstelle | `DeliveryArea` in `OldYardTest.tscn`; Kindknoten heißen wie die Waren-IDs |
| Suchquellen | `scripts/world/SearchSource.gd`, `scenes/interaction/Source*.tscn`; Inhalte sind `ScrapItem` mit `starts_pending` |
| Werkzeugpflicht | `SearchSource.required_tool`, `SalvageableScrap.required_tool`, `UpgradeProgress.has_tool()` |
| Inspektion | `Interactable.get_inspection()`, Eingabe `inspect_target` (R), `InspectPanel` |
| Werkbank | `scenes/interaction/Workbench.tscn` (Inspect-Objekt) |
| Daten | `data/upgrades/*.tres`, neue `data/items/*.tres` |

Der Spielstand bleibt Version 2: Werkzeuge stehen in `upgrades`, durchsuchte Quellen als `{"searched": true}` in `world_objects`.
