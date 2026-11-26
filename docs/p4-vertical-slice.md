# Scrapstead — P4: Vertical Slice Old Yard

**Status:** P4.1–P4.4 umgesetzt (26.11.2026, autonome Entwicklungsphase); menschlicher Playtest offen
**Bezug:** [MVP-Plan, Abschnitt 8](mvp-prototype-plan.md), [First-Hour-Experience](first-hour-experience.md), [Prototyp-Abnahme](prototype-acceptance.md)

## 1. Ziel

Laut MVP-Plan soll der Vertical Slice die validierten Teile (P0–P3) zu einem zusammenhängenden Ausschnitt verbinden und die Produktionsqualität festlegen. Dabei soll er die erste Stunde nicht künstlich aufblasen. Es kommen deshalb kaum neue Systeme hinzu. P4 schließt Lücken im Zusammenhang, in der Bedienbarkeit und in der Präsentation.

## 2. Abgleich mit dem Inhaltsumfang

| Anforderung (MVP-Plan 8) | Stand nach P3 | Lücke |
|---|---|---|
| Zusammenhängender Ausschnitt des Old Yard | Hof mit allen Zonen, Werkstatt, Verkauf, Arbeitsfläche | – |
| Bewegung, Kamera, Interaktion | P0, getestet | – |
| Sammeln, Bergen, Transport, Direktverkauf | P1 | – |
| Credits, erste Upgrades | Katalog mit 9 Waren | – |
| Optionale Verwertung | Zerlegetisch (Radio, Toaster), vernagelte Kisten | – |
| Erkundungs- und Entdeckungsfolge | Kopf im Haufen, roter Werkzeugkasten, Fundstücke | – |
| Scrappys Wiederherstellung und Begleitverhalten | P2 | – |
| **Kurze Hauptaufgabenfolge** | Nur wechselnde Vorschläge auf dem Notizzettel | **Fehlt:** eine sichtbare, kurze Folge mit Fortschritt, die dauerhaft abrufbar ist |
| Wiederkehrender NPC / Kontaktfigur | Nachbarn über Zettel, Juri als Figur | – |
| Sichtbare Verbesserung des Grundstücks | Eingang, Maschine | – |
| Kontext-HUD, Objektinfos, Aufgabenanzeige, Menüs | vorhanden; Einstellungen nur im Hauptmenü | **Lücke:** Lautstärke, Sprache und Fenster nur im Hauptmenü |
| Speichern/Laden des Slice-Zustands | Version 6, alle Systeme | – |
| Repräsentative Audio-, VFX-, Licht- und Animationsqualität | Synth-Klänge, Musik, Staub, Funken, prozedurale Animation | **Lücke:** Maschine ohne eigenen Klang, Juris Werkzeuge ohne Geräusch |
| Performance auf Zielhardware | nicht gemessen | **Lücke:** keine Messung mit vollem Hof (Juri, Maschine, Lieferungen) |

Qualitätskriterium „Der Spieler versteht die wichtigsten Aktionen ohne externe Erklärung“: Die Steuerungshinweise stehen unten im Bild. Das Ziel der ersten Stunde wird bisher nur in Bruchstücken sichtbar.

## 3. Arbeitspakete

| Paket | Inhalt | Abnahme |
|---|---|---|
| P4.1 Walts Liste | Kurze Hauptaufgabenfolge als Walts handgeschriebene To-do-Liste im Pausenmenü, jede Zeile mit Walt-Kommentar. Erledigte Punkte werden abgehakt und kurz gemeldet. Abgeleitet aus vorhandenen Zuständen, also kein neuer Spielstand. | Liste spiegelt den Spielstand nach Laden korrekt, Meldung genau einmal je Punkt |
| P4.2 Einstellungen im Spiel | Musik, Effekte, Sprache und Fenster im Pausenmenü, dieselben Einstellungen wie im Hauptmenü | Änderungen wirken sofort und bleiben gespeichert |
| P4.3 Klang und Messung | Brummen des Magnetsammlers, Geräusche für Juris Werkzeuge, Bildratenmessung im vollen Hof | Messwerte im Testprotokoll, Klänge eingebunden |
| P4.4 Abnahme | Spielanleitung für den menschlichen Playtest, aktualisierte Prototyp-Abnahme | Dokument vorhanden |

## 4. Bewusst nicht in P4

- Platzierungssystem (Maschine versetzen), weitere Maschinen, weitere Mitarbeiter.
- Neue Zonen außerhalb des Old Yard.
- Finale Grafik (die Blender-Platzhalter im Zielstil bleiben).

## 5. Ergebnisse

### P4.1 Walts Liste
- Walts handgeschriebene Liste hing „innen an der Bürotür“. Sie hat sieben Punkte: Brief lesen, erste Ladung verkaufen, etwas bestellen, Scrappy finden und wecken, Eingang herrichten, jemanden finden, der mit anpackt, eine Maschine aufstellen. Jeder Punkt hat einen Walt-Kommentar, z. B. „Fair bezahlen. Handschuhe sind Pflicht.“
- Die Liste ist im Pausenmenü abrufbar. Erledigte Punkte bekommen einen gezeichneten Haken, ihr Text wird blasser. Darunter steht der Fortschritt; ist alles erledigt: „Alles erledigt. Walt wäre stolz. Oder würde nach dem roten Knopf fragen.“
- Wird ein Punkt erledigt, meldet das Spiel einmal „Walts Liste: … abgehakt“ mit Papiergeräusch. Beim letzten Punkt heißt es: „Der Hof gehört jetzt richtig dir.“
- Die Liste leitet sich aus Storyflags und gekauften Waren ab. Sie braucht keinen eigenen Spielstand und meldet nach dem Laden nichts erneut.
- Daten: `data/story/walts_list.tres` (`TaskList`), Auswertung im `StoryDirector`, Anzeige `ui/hud/TaskListPanel.tscn`.

### P4.2 Einstellungen im Spiel
- Das Pausenmenü hat jetzt „Einstellungen“: Sprache, Anzeige, Musik und Geräusche, dieselben wie im Hauptmenü. Änderungen wirken sofort und werden gespeichert. Bei der Geräuschlautstärke klingt ein kurzes Probe-Klicken.
- Papier- und Einstellungsfenster liegen jetzt über den Meldungen.

### P4.3 Klang und Messung
- Der Magnetsammler brummt räumlich (Dieseltuckern, Spulenbrummen, Kettenklirren), blendet beim Arbeiten ein und beim Stillstand aus und klingt mit stärkerem Magnet etwas höher.
- Das Aufhebeln hat ein eigenes Geräusch (knarzendes Holz, quietschender Nagel, Knacken). Während des Haltens läuft das Ratschengeräusch.
- **Leistungsmessung** (`tools/measure_performance.gd`): voller Hof mit Scrappy, Juri bei der Arbeit, Magnetsammler mit stärkerem Magnet und drei Lieferungen. Fenster 1600×900, VSync aus, 15 s nach 4 s Aufwärmen, NVIDIA GeForce RTX 3060 Laptop GPU:

| Wert | Ergebnis |
|---|---|
| Durchschnitt | 2,33 ms (≈ 430 FPS) |
| Median / 95 % / 99 % | 2,23 / 2,91 / 3,42 ms |
| 1 %-Tief | ≈ 281 FPS |
| Längster Frame | 3,86 ms |
| Draw Calls / Objekte | 555 / 993 |
| Videospeicher | ≈ 299 MB |

  Für die Zielhardware gibt es laut MVP-Plan noch keine Budgets. Auf dieser Mittelklasse-GPU bleibt großer Spielraum. Schwächere Hardware ist ungemessen.

### P4.4 Abnahme
- Spielanleitung für den menschlichen Playtest: [Playtest-Leitfaden](playtest-guide.md).
- Tests: `tests/integration/test_walts_list.gd` (5 Tests). Screenshots `47_pause_menu`, `48_walts_list`, `49_settings_in_game`.
