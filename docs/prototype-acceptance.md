# Scrapstead — Prototyp-Abnahme, Testprotokoll und bekannte Einschränkungen

**Version:** 0.1  
**Datum:** 25.11.2026  
**Umfang:** P0 (Technisches Fundament), P1 (Erste Gameplay-Schleife), P1b (Optionale Verarbeitung)  
**Engine:** Godot 4.7.2 Stable (`4.7.2.stable.official.ed1daf0bf`), GDScript, Forward+, Jolt Physics  
**Testumgebung:** Windows 11, NVIDIA GeForce RTX 3060 Laptop GPU, Vulkan 1.4

---

## 1. Statusbegriffe

| Status | Bedeutung |
|---|---|
| **Implementiert** | Im Repository umgesetzt |
| **Automatisiert getestet** | Durch einen ausgeführten Test im Headless-Testrunner geprüft |
| **Im laufenden Spiel getestet** | Im echten Spielfenster (Vulkan, Forward+) per Skript ausgeführt und per Screenshot kontrolliert, oder über echte Prozessneustarts geprüft |
| **Nicht getestet** | Nicht durch einen Test belegt, insbesondere subjektives Spielgefühl |
| **Fehlgeschlagen** | Test ausgeführt und nicht bestanden |

Alle unten als bestanden markierten Tests wurden tatsächlich ausgeführt. Es gibt zum Abnahmezeitpunkt keine fehlgeschlagenen Tests.

## 2. Testwerkzeuge

| Werkzeug | Aufruf | Zweck |
|---|---|---|
| Headless-Testrunner | `godot --headless --path . -s res://tests/run_tests.gd` | 38 Unit- und Integrationstests; Skriptfehler zählen als Fehlschlag |
| Neustarttest | `tests/e2e_restart.gd -- --phase=play`, danach `--phase=continue` | Finale Abnahme über zwei getrennte Godot-Prozesse |
| Screenshot-Lauf | `godot --path . -s res://tools/capture_screens.gd` | Echter Fensterlauf mit 15 Screenshots für die Sichtprüfung |
| Startprüfung | `godot --path . --quit-after 600` | Normaler Start über `Main.tscn` im Fenster, Prüfung der Ausgabe |

Alle Tests verwenden isolierte Speicherverzeichnisse (`user://test_run`, `user://e2e_run`, `user://capture_run`) und berühren den Spielstand der Spielerin bzw. des Spielers nicht.

## 3. Ergebnisse der automatisierten Tests

Letzter Lauf: **45 Tests, 45 bestanden, 0 fehlgeschlagen** (Stand P1-Vertiefung 0.2). Die Tabellen unten nennen die Tests bis Stand 0.1; die Ergänzungen stehen in Abschnitt 3.4.

### 3.1 Unit-Tests

| Test | Prüft | Ergebnis |
|---|---|---|
| `test_save_service::test_missing_save_is_not_valid` | Fehlender Spielstand ist ungültig | bestanden |
| `test_save_service::test_round_trip` | Speichern/Laden, Versionsnummer, keine Temp-Datei | bestanden |
| `test_save_service::test_corrupt_json_is_rejected` | Beschädigtes JSON | bestanden |
| `test_save_service::test_unsupported_version_is_rejected_and_not_overwritten` | Fremde Version wird nicht geladen und nicht überschrieben | bestanden |
| `test_save_service::test_invalid_structure_is_rejected` | Pflichtfelder und Typen | bestanden |
| `test_save_service::test_save_rejects_invalid_data` | Ungültige Daten werden nicht geschrieben | bestanden |
| `test_save_service::test_write_failure_is_reported` | Schreibfehler wird gemeldet | bestanden |
| `test_economy::test_catalog_data_is_valid` | Gegenstandsdaten, Lokalisierung der Namen | bestanden |
| `test_economy::test_wallet_credit_debit_and_validation` | Einnahmen, Ausgaben, doppelte IDs, kein negativer Kontostand | bestanden |
| `test_economy::test_wallet_round_trip` | Kontostand, Protokoll und Sequenz nach Laden | bestanden |
| `test_economy::test_inventory_capacity_rules` | Kapazität, Größen, Duplikate, Revision | bestanden |
| `test_economy::test_upgrade_purchase_rules` | Kaufbedingungen, einmalige Zahlung, Wiederherstellung | bestanden |
| `test_economy::test_localization_parity` | Jeder Schlüssel in en und de, keine Duplikate | bestanden |

### 3.2 P0-Integrationstests (INT-01 bis INT-12 und Bedienungstests)

| Test | Spezifikation | Ergebnis |
|---|---|---|
| `test_int01_menu_without_save_disables_continue` | INT-01, Menükamera aktiv | bestanden |
| `test_int02_new_game_starts_clean` | INT-02 | bestanden |
| `test_int05_camera_starts_on_player_without_jump` | INT-05, orthografisch, kein Startsprung | bestanden |
| `test_movement_is_camera_relative_and_stops` | INT-05, Test B: kamerabezogen, 4,5 m/s, Bremsweg < 0,7 m, Ausrichtung bleibt | bestanden |
| `test_diagonal_is_not_faster` | Test B: Diagonale ≤ Maximalgeschwindigkeit | bestanden |
| `test_collision_blocks_walls` | Test B: Werkstattblock blockiert | bestanden |
| `test_camera_zoom_is_bounded` | Test C: Zoomgrenzen 9 / 19 | bestanden |
| `test_int06_int08_pickup_inspect_use` | INT-06, INT-08, Test D | bestanden |
| `test_selection_prefers_near_then_facing_and_is_stable` | Nähe vor Blickrichtung, kein Flackern | bestanden |
| `test_int07_target_invalidated_before_key_press` | INT-07 (unverfügbar und freigegeben) | bestanden |
| `test_int09_save_restart_continue_restores_state` | INT-09, Test F | bestanden |
| `test_int04_corrupt_save_keeps_menu` | INT-04 | bestanden |
| `test_int10_unknown_object_id_is_ignored` | INT-10 | bestanden |
| `test_invalid_saved_position_falls_back_to_spawn` | Sichere Startposition | bestanden |
| `test_int11_save_write_failure_keeps_session` | INT-11 | bestanden |
| `test_int12_repeated_scene_changes_leave_no_leftovers` | INT-12 | bestanden |

INT-03 (Fortsetzen mit gültigem Spielstand) ist in INT-09 und im Neustarttest enthalten.

### 3.3 P1- und P1b-Tests

| Test | Prüft | Ergebnis |
|---|---|---|
| `test_full_p1_loop_with_save_and_continue` | Komplette P1-Abnahmesequenz 1–12 inkl. Korb voll, verweigerter Bergung, abgebrochener Bergung, Verkauf, Doppelbuchungsschutz, Upgrade, Ablegen, Pausemenü-Speichern, Fortsetzen | bestanden |
| `test_stale_quote_is_rejected` | Veraltetes Angebot wird abgelehnt | bestanden |
| `test_sell_with_empty_basket_is_refused` | Kein Verkauf ohne Ladung | bestanden |
| `test_upgrade_unaffordable_is_refused` | Kein Kauf ohne Credits, kein negativer Kontostand | bestanden |
| `test_inconsistent_save_is_repaired` | Unbekannte/inkonsistente IDs werden kontrolliert repariert | bestanden |
| `test_negative_credit_save_is_rejected` | Spielstand mit negativem Kontostand ist ungültig | bestanden |
| `test_dismantle_needs_the_input` | Zerlegen nur mit Radio | bestanden |
| `test_dismantle_yields_more_than_direct_sale` | Mehrwert, max. zwei Ausgaben, Abbruch, keine Duplikation, Persistenz | bestanden |
| `test_direct_sale_of_radio_remains_possible` | Direktverkauf bleibt Alternative | bestanden |

### 3.4 Ergänzungen P1-Vertiefung (0.2)

| Test | Prüft | Ergebnis |
|---|---|---|
| `test_p1_gameplay_loop::test_full_p1_loop_with_save_and_continue` | Neue Sequenz: Verkauf → Brechstange → Kiste → Quellen → Flaschenzug → Träger → Tragekorb → 6 Teile in einem Gang → Speichern/Fortsetzen | bestanden |
| `test_p1_gameplay_loop::test_unaffordable_ware_is_refused` | Katalog ohne Credits, gesperrter Handkarren | bestanden |
| `test_p1_deepening::test_contents_stay_hidden_until_searched` | Inhalte verborgen bis zur Suche | bestanden |
| `test_p1_deepening::test_crate_needs_crowbar_heap_does_not` | Werkzeugpflicht, Erklärung, einmalige Suche | bestanden |
| `test_p1_deepening::test_beam_needs_hoist` | Träger nur mit Flaschenzug, Brechstange reicht nicht | bestanden |
| `test_p1_deepening::test_handcart_requires_basket_and_stacks` | Voraussetzung, Kapazität 12, Preise aus Daten | bestanden |
| `test_p1_deepening::test_searched_sources_and_revealed_items_persist` | Persistenz von Quellen und Funden | bestanden |
| `test_p1_deepening::test_inspection_shows_info_without_changing_state` | Inspektion mit R, Wert und Beschreibung, kein Zustandswechsel | bestanden |
| `test_p1_deepening::test_workbench_is_inspect_only` | Werkbank täuscht kein Crafting vor | bestanden |

Der Neustarttest (Abschnitt 4) wurde auf den neuen Ablauf umgestellt und erneut bestanden (Endstand nach Fortsetzen: 34 Cr).

## 4. Finale Abnahme über echten Neustart

| Schritt | Durchführung | Ergebnis |
|---|---|---|
| Spiel starten | Phase `play`: Hauptmenü, „Fortsetzen“ deaktiviert | bestanden |
| Neues Spiel | Klick auf „Neues Spiel“ | bestanden |
| Old Yard betreten, Gegenstände sammeln | 4 Kleinteile über die echte Eingabe (E) | bestanden |
| Größeres Objekt bergen | E 3 s halten am Metallträger | bestanden |
| Verkaufen, Credits verdienen | Zwei Verkäufe, 35 Cr | bestanden |
| Upgrade kaufen | Großer Tragekorb, 5 Cr Rest | bestanden |
| Upgrade nutzen | 3 weitere Teile, 4 von 8 Plätzen belegt | bestanden |
| Speichern, Spiel beenden | Pausemenü → „Speichern & Hauptmenü“, Prozess beendet | bestanden |
| Spiel erneut starten, Fortsetzen | Phase `continue` (neuer Prozess): „Fortsetzen“ aktiv, Klick | bestanden |
| Zustand kontrollieren | 5 Cr, Kapazität 8, Ladung 4 Plätze, Träger verkauft, Schraube weg | bestanden |
| Funktionen nach Fortsetzen | Zerlegen und Verkaufen, Endstand 30 Cr | bestanden |

Zusätzlich startet das Spiel über `Main.tscn` im Fenster ohne Fehlerausgabe.

## 5. Sichtprüfung im laufenden Spiel

Der Screenshot-Lauf (`tools/capture_screens.gd`, Ausgabe nach `tests/_output/screens`, nicht versioniert) wurde im echten Fenster ausgeführt und manuell gesichtet:

- Hauptmenü: Schriftzug, Tagline und Menü bleiben über der Kamerafahrt lesbar; „Fortsetzen“ ist ohne Spielstand deaktiviert.
- Startansicht: Spieler, Einfahrt, Kiosk, Hinweisbrett und erstes Fundstück sind sichtbar; die Grundstücksausrichtung entspricht dem Lageplan.
- Prompt mit Taste, Aktion und Name; Hervorhebungsring am Ziel.
- Fernzoom: Werkstatt, Pfosten-Engstelle, Schrotthaufen, Auto und Maschinenfläche bleiben unterscheidbar.
- HUD: Credits, Tragekorb mit Platzanzeige und Liste; Bergungs-Prompt mit Voraussetzung und Fortschrittsbalken.
- Verkaufsfenster, Werkbank (vor/nach Kauf), Pausemenü, Zerlegetisch-Prompt in Deutsch und Englisch.

Bei der Sichtprüfung gefundene und behobene Fehler: gespiegelte Grundstücksachse, sichtbarer Prompt unter offenen Panels, Anzeige „8 → 8“ bei gekauftem Upgrade, nicht aktualisierte Texte nach Sprachwechsel.

## 6. Nicht getestet

- **Subjektives Spielgefühl** (Beschleunigung, Bremsen, Drehgeschwindigkeit, Kamera-Glättung, Zoomgefühl, Lesbarkeit für neue Spieler). Die Werte entsprechen den Startwerten der Spezifikationen und sind technisch geprüft, aber nicht von Menschen beurteilt.
- **Bedienung mit echter Maus und Tastatur durch einen Menschen**; Eingaben wurden über Godots Eingabe-Pipeline (`InputEventAction`) simuliert, Menüklicks über Button-Signale.
- **Linux**-Lauf (nur Windows geprüft).
- **Performance** auf schwächerer Hardware und Bildraten-Unabhängigkeit bei sehr niedrigen Bildraten (die Logik ist zeitbasiert; nicht gemessen).
- **Vollbildmodus** (Einstellung wird gesetzt und gespeichert; nicht visuell geprüft).
- Verhalten bei **Fokusverlust** des Fensters.

## 7. Abnahmestatus

| Stufe | Technisch | Spielerische Freigabe |
|---|---|---|
| P0 | Alle Kriterien automatisiert bzw. im Fensterlauf geprüft | Offen: Bedienungstest durch Menschen |
| P1 | Abnahmesequenz 1–12 vollständig und wiederholbar geprüft | Erstes Anspielen durch die Projektleitung: Spielgefühl gut. Noch nicht freigegeben – Schleife wird vertieft (0.2) |
| P1b | Umgesetzt und geprüft (siehe 8) | Offen: Bewertung im Playtest |

Der Prototyp ist technisch abnahmefähig. Die im MVP-Plan geforderte spielerische Bewertung („befriedigende Schleife“) kann nur durch menschliche Playtests erfolgen.

## 8. P1b-Bewertung

- Eine Station (Zerlegetisch), eine Eingabe (Defektes Radio, direkt 12 Cr), zwei Ausgaben (Kupferdraht 8 Cr, Elektronikteile 8 Cr).
- Aufwand: Weg zum Zerlegetisch und 3,5 s Halten. Ergebnis: 16 Cr statt 12 Cr.
- Der Prompt zeigt vor der Aktion Direktwert, Aufwand, Ausgaben und Ergebniswert.
- Direktverkauf bleibt gleichwertig nutzbar und ist schneller; Verarbeitung ist nie Voraussetzung für das Upgrade.
- Einschätzung: Die Entscheidung ist verständlich und optional. Ob +4 Cr den Umweg rechtfertigen, muss der Playtest zeigen; die Werte liegen in `data/` und sind ohne Codeänderung anpassbar.

## 9. Bekannte Einschränkungen

1. Es gibt **einen Speicherplatz**. „Neues Spiel“ überschreibt den alten Stand erst beim nächsten Speichern.
2. Kein automatisches Speichern (bewusst, siehe Integrationsspezifikation); ungespeicherter Fortschritt geht bei „Hauptmenü ohne Speichern“ verloren.
3. Fundstücke regenerieren nicht. Mit den Suchquellen (0.2) gibt es rund 115 Cr Gesamterlös bei 107 Cr Katalogkosten; danach endet die Schleife inhaltlich (Regeneration laut Matrix erst Phase 4–5).
4. Die Verarbeitung ist an genau eine Radio-Platzierung gebunden (vorbereitete Ausgabeplätze); mehrere Verarbeitungsobjekte erfordern später eine Erzeugung von Ausgaben zur Laufzeit.
5. Ablegen nimmt immer das zuletzt aufgenommene Teil; es gibt keine Auswahl einzelner Teile.
6. Zahlenformatierung ist nicht vollständig gebietsschemaabhängig (z. B. „3.5 s“ statt „3,5 s“ im Deutschen).
7. Sprache lässt sich nur im Hauptmenü umstellen; Tastenbelegung ist nicht änderbar (kein Rebinding in P0/P1).
12. Die Werkbank hat noch keine Funktion (Crafting folgt); sie ist nur untersuchbar.
14. Grafik: Boden und Wege sind bewusst flache Geometrie; die Spielfigur ist prozedural animiert (kein Skelett-Rig, keine Mimik). Es gibt noch kein Audio. Für Modelländerungen wird Blender 4.2 benötigt.
13. Gekaufte Ware wird ohne Lieferzeit sofort an der Lieferstelle angezeigt.
8. Keine Sichtlinienprüfung bei Interaktionen; im Blockout traten keine offensichtlich falschen Interaktionen durch Wände auf.
9. Keine Gebäudetransparenz; hohe Objekte (Werkstatt, Container) können den Spieler teilweise verdecken (laut Kamera-Spezifikation bewusst nicht Teil von P0).
10. Platzhaltermodelle und Standardschrift; kein Audio.
11. Beim Beenden von Godot im Skriptmodus (`-s`, Tests/Werkzeuge) meldet die Engine interne Shutdown-Meldungen („Unreferenced static string“, „RID allocations leaked“). Beim normalen Spielstart treten sie nicht auf; sie stammen nicht aus Projektskripten.

## 10. Empfehlungen für die nächste Phase

1. **Menschlicher Playtest** mit 3–5 Personen nach MVP-Plan 11.3; Bewegung, Kamera und Prompt-Lesbarkeit zuerst.
2. **Balancing** der P1-Werte anhand der Playtests (Kapazität, Preise, Upgrade-Preis, Zerlege-Mehrwert).
3. Entscheidung über **Regeneration oder Nachschub** (z. B. Schrotthaufen als Suchquelle), damit die Schleife länger trägt – als bewusste Designentscheidung vor P2.
4. **Gebietsschemaabhängige Zahlenformatierung** und automatischer Lokalisierungscheck in der Testpipeline erweitern.
5. **CI** für Headless-Tests (Windows und Linux) einrichten.
6. Danach P2-Planung (Einstieg, Scrappy) gemäß MVP-Plan.
