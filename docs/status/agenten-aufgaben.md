# Aufgaben für weitere Agenten

**Stand:** 27.11.2026 · Vorher lesen: [erreicht.md](erreicht.md)

Diese Aufgaben erweitern Spielfunktionen und Inhalte **nach dem bestehenden
Plan**. Sie sind so geschnitten, dass mehrere Agenten parallel arbeiten können,
ohne die Hauptentwicklung zu übernehmen und **ohne Grafiken zu erstellen**.

---

## Teil A — Verbindliche Regeln

### A1. Rollen
- Die **Hauptentwicklerrolle** bleibt beim Hauptentwickler (Claude in der
  Hauptsitzung). Er entscheidet über Architektur, Grafikstil, Spielgefühl,
  Balancing-Freigaben und führt in `main` zusammen.
- Agenten arbeiten **je Aufgabe auf einem eigenen Branch**
  (`agent/<aufgaben-id>-<kurzname>`, z. B. `agent/F1-auftraege-daten`) und
  öffnen einen Pull Request. **Nie direkt nach `main` pushen, nie mergen.**
- Eine Aufgabe pro Branch. Wer eine Aufgabe beginnt, trägt sich unten in der
  Spalte „Bearbeitung“ ein (im eigenen PR).

### A2. Keine Grafikarbeit
- Keine neuen oder geänderten Modelle, Texturen, Shader, Materialien,
  Umgebungen, Thumbnails, UI-Bilder, Icons.
- Tabu sind: `tools/blender/`, `assets/models/`, `assets/shaders/`,
  `assets/materials/`, `assets/environment/`, `assets/ui/`, `scenes/world/OutsideScenery.tscn`,
  `tools/make_scenery.py`, `tools/make_thumbnails.py`.
- Erlaubt ist, **vorhandene** Modelle und Szenen wiederzuverwenden. Braucht
  eine Funktion ein neues Modell, kommt sie mit einem vorhandenen Platzhalter
  und einem Vermerk im PR („Modell nötig: …“); das Modell baut der Hauptentwickler.
- UI nur mit den vorhandenen Bausteinen und dem vorhandenen Theme (Panels wie
  `TaskListPanel`, `SettingsPanel`, `StaffPanel` als Vorbild).

### A3. Architektur (siehe [p0-system-integration](../p0-system-integration.md))
- Nur die Autoloads `GameSession` und `SaveService`. Keine neuen Autoloads,
  kein globaler Event-Bus, kein Service-Locator.
- Neue Inhalte als Ressourcen in `data/` (eigene `Resource`-Klasse in
  `scripts/data/`), nicht als Konstanten im Code.
- Laufzeitlogik als szenenlokale Knoten nach dem Muster von
  `ScrapDeliveries`, `YardStashes`, `ScrapPress`: eigene Signale, eigener
  Speicherblock, Registrierung über den Szenen-Controller.
- Spielstand: Neue Daten als **optionaler** Schlüssel, ältere Spielstände
  müssen ohne ihn laden (Beispiel: `stashes`, `placed.links`). **Keine
  Erhöhung von `SAVE_VERSION`** ohne Freigabe des Hauptentwicklers. Neue
  Schlüssel in `SaveService` validieren.
- Gameplay-Zeit zählt nur, solange gespielt wird (kein Offline-Fortschritt).

### A4. Gemeinsame Dateien mit Konfliktgefahr
Änderungen hier **klein halten** und im PR einzeln begründen:
`scripts/world/OldYardTestController.gd`, `scripts/world/YardWorker.gd`,
`scripts/build/MachineLinks.gd`, `scripts/build/PlacedObjects.gd`,
`scripts/build/BuildMode.gd`, `scripts/core/SaveService.gd`,
`scenes/world/OldYardTest.tscn`, `localization/scrapstead.csv` (nur Zeilen
**anhängen**, keine bestehenden Zeilen umsortieren).

### A5. Texte und Ton
- Jeder sichtbare Text als Schlüssel in `localization/scrapstead.csv`, immer
  **Englisch und Deutsch**. Spalten: `keys,en,de`. Mit dem `csv`-Modul schreiben
  (Kommas in Texten werden gequotet).
- Ton: warm, trocken-humorvoll, nie zynisch; Walt, Scrappy und Juri haben ihre
  eigene Stimme (siehe [lore-walt-wren](../lore-walt-wren.md),
  [scrappy-companion](../scrappy-companion.md)). Spielerhinweise sind kurz und
  erklären in einem Satz, was zu tun ist.

### A6. Tests und Abnahme
- Jede Aufgabe bringt Tests mit (`tests/unit/` oder `tests/integration/`,
  Muster: `test_yard_stashes.gd`, `test_processing_chain.gd`).
- Vor dem PR: komplette Testsuite **und** Neustart-Abnahme grün
  (Befehle in [erreicht.md](erreicht.md), Abschnitt 4). Die Testsuite dauert rund 10 Minuten.
- Ergebnisse ehrlich angeben; nichts als „getestet“ melden, was nicht lief.
- Doku: Fachdokument in `docs/` anlegen oder ergänzen, Beschluss als Vorschlag
  im PR formulieren (der Hauptentwickler trägt ihn ins Entscheidungslog ein).

### A7. Sonstiges
- `docs/Game-Design-Document.md` niemals committen (lokale Datei des Nutzers).
- Keine Zugangsdaten, keine kostenpflichtigen Dienste, keine ungetesteten
  Abhängigkeiten. Fremde Assets nur nach Lizenzprüfung (betrifft hier nur Daten).
- Unklare Designfragen nicht selbst entscheiden: im PR als Frage stellen.

---

## Teil B — Aufgaben

Legende Größe: S (bis ½ Tag), M (1 Tag), L (mehrere Tage).
„Hängt ab von“ bedeutet: erst beginnen, wenn die genannte Aufgabe gemergt ist.

| ID | Aufgabe | Größe | Hängt ab von | Bearbeitung |
|---|---|---|---|---|
| F1 | Auftragssystem: Daten und Logik | L | – | frei |
| F2 | Auftragstafel: Bedienung und Panel | M | F1 | frei |
| F3 | Erste Auftragsinhalte (Nachbarn) | M | F1 | frei |
| F4 | Juri nutzt den Flaschenzug | M | – | frei |
| F5 | Juri durchsucht Fundstellen | M | – | frei |
| F6 | Verkaufspalette für Ballen | M | – | frei |
| F7 | Walts zweite Liste: die Verarbeitungskette | S | – | frei |
| F8 | Notizzettel-Hinweise für Maschinen und Bänder | S | – | frei |
| F9 | Mehr Lieferungen und Fundinhalte | S | – | frei |
| F10 | Wirtschaftsbericht (Balance-Werkzeug) | M | – | frei |
| F11 | Einnahmen-Übersicht im Pausenmenü | M | – | frei |
| Q1 | Lokalisierungs-Prüfung als Test | S | – | frei |
| Q2 | Abnahmetest: komplette Verarbeitungskette | M | – | frei |
| Q3 | Spielstand-Robustheit für neue Blöcke | S | – | frei |

### F1 — Auftragssystem: Daten und Logik
**Ziel:** Wiederkehrende Aufträge von Nachbarn nach
[quest-mission-event-system](../quest-mission-event-system.md) Abschnitt 3.3, 6, 7 und 8:
„Liefere 3 Kupferballen bis Tag X“, „Bring 5 Holzreste“.
**Umfang:**
- `scripts/data/OrderDefinition.gd` (ID, Auftraggeber-Schlüssel, Ziel als Liste
  `{item, count}`, Belohnung in Credits, Frist in Spielminuten oder ohne Frist,
  Wiederholbarkeit, Freischaltbedingung über Story-Flags oder Besitz) und
  `OrderTable.gd`, Daten in `data/orders/`.
- `scripts/world/YardOrders.gd` (szenenlokal): angebotene, angenommene,
  erfüllte und verfallene Aufträge, Annahme, Teilfortschritt, Abgabe,
  Spielzeit-Fristen, optionaler Speicherblock `orders`.
- Abgabe zunächst am **Verkaufstresen** (`SellStation`): Erfüllt der Korb einen
  angenommenen Auftrag, wird er dort mit Vorrang verrechnet (Umfang klein halten,
  Änderung im PR begründen).
- Kein Strafsystem; verfallene Aufträge verschwinden mit einem freundlichen Hinweis.
**Abnahme:** Tests für Annahme, Teilfortschritt, Abgabe, Frist, Wiederholung,
Speichern/Laden, alter Spielstand ohne `orders`.

### F2 — Auftragstafel: Bedienung und Panel
**Ziel:** Die vorhandene Notiztafel am Eingang (`TestObjects/InspectTestObject`,
Objekt-ID `p0_inspect_board_01`, Skript `InspectTestObject.gd`) wird zur
Auftragstafel; ihre bisherige Ansehen-Funktion bleibt als Zweitaktion erhalten.
**Umfang:** Interaktion „Aufträge ansehen“, Panel nach Vorbild
`TaskListPanel` (Liste, Annehmen, Status, Restzeit), HUD-Meldungen bei neuen,
erfüllten und verfallenden Aufträgen. Nur vorhandenes Theme, keine Bilder.
**Abnahme:** Integrationstest öffnet das Panel, nimmt an, erfüllt; Text DE/EN.

### F3 — Erste Auftragsinhalte
**Ziel:** 8–12 Aufträge der bekannten Nachbarn (Frau Pohl, Krull, Lotte,
Anonym; siehe `data/deliveries/neighbor_deliveries.tres`) mit Humor.
Mischung aus einfachen (lose Teile) und Ketten-Aufträgen (Ballen).
**Abnahme:** Datenvalidierungstest, alle Texte übersetzt, Belohnungen als
Vorschlag mit Begründung (Aufpreis gegenüber Direktverkauf maßvoll, 10–40 %).

### F4 — Juri nutzt den Flaschenzug
**Ziel:** Bergungsobjekte, die den Flaschenzug brauchen (`SalvageableScrap` mit
`required_tool = "hoist"`, z. B. der Träger `bulk_metal_beam_01` im Hof), kann
bisher nur der Spieler freilegen. Juri soll das übernehmen können: Flaschenzug
holen, freilegen, das freigelegte Teil per Handkarren zur Kette oder zum
Verkauf bringen, Flaschenzug zurückbringen. Ohne Flaschenzug meldet er, dass er
ihn braucht (wie bei der Brechstange).
**Umfang:** Werkzeuglogik in `YardWorker.gd` nach dem Muster `TOOL_CART` und
`TOOL_CROWBAR` (ein Werkzeug gleichzeitig), Arbeitsbereich um
Bergungsobjekte erweitern, Sprüche, Anzeige im Personalfenster. Das
Flaschenzug-Modell existiert (`equipment_hoist`). Muster: `test_staff_crowbar.gd`.
**Abnahme:** Tests mit und ohne Flaschenzug, Speichern während er ihn trägt.

### F5 — Juri durchsucht Fundstellen
**Ziel:** Hat Juri nichts zu tun, durchsucht er Fundstellen
([yard-stashes](../yard-stashes.md)) mit Ladung in der Nähe seines Bereichs und
bringt die Funde in die Kette oder zum Verkauf. Werkzeugpflicht gilt auch für ihn.
**Umfang:** neue Aufgabe im Arbeitsablauf, Einstellungsschalter im
Personalfenster („Fundstellen durchsuchen“), längere Suchzeit als der Spieler
(`tool_time_factor`).
**Abnahme:** Test: leerer Hof → Juri sucht → Funde landen in Presse oder Verkauf;
Schalter aus → er sucht nicht.

### F6 — Verkaufspalette für Ballen
**Ziel:** Platzierbares Objekt mit Eingang (Förderband-Ziel), auf dem Ballen
abgelegt werden; Juri holt sie von dort zum Verkauf
([processing-chain](../processing-chain.md), Abschnitt „Offen“).
**Umfang:** Platzierbar mit **vorhandenem** Modell (`pallet_stack`), Logik nach
dem Muster der Sortierkisten (Teil wird angenommen und dort neu erzeugt),
Ports im `PlaceableDefinition`, Speichern. Thumbnail: vorhandenes Bild von
`storage_pallets` wiederverwenden oder im PR als „Bild nötig“ vermerken.
**Abnahme:** Test Presse → Band → Palette → Juri verkauft.

### F7 — Walts zweite Liste: die Verarbeitungskette
**Ziel:** Ist Walts erste Liste erledigt, folgt eine zweite (z. B. „Eine Presse
aufstellen“, „Zwei Maschinen verbinden“, „Den ersten Kupferballen pressen“,
„Die Sortiermaschine in Betrieb nehmen“).
**Umfang:** `TaskList` um eine Folgeliste erweitern (Daten in `data/story/`),
Bedingungen über Flags oder `placed:`, Anzeige im vorhandenen Panel. Neue
Story-Flags dort setzen, wo die Ereignisse schon gemeldet werden
(`StoryDirector.on_linked`, `on_bale_pressed`).
**Abnahme:** Test wie `test_walts_list.gd`.

### F8 — Notizzettel-Hinweise für Maschinen und Bänder
**Ziel:** Der Notizzettel (`StoryDirector.refresh_notes`) gibt passende nächste
Schritte: Presse steht, aber nicht verbunden; Sortiermaschine ohne Band;
Ablage voll; Band blockiert.
**Abnahme:** Test für jeden Hinweis; nie mehr als ein Hinweis gleichzeitig.

### F9 — Mehr Lieferungen und Fundinhalte
**Ziel:** Abwechslung für die Kette: weitere Nachbarlieferungen
(`data/deliveries/neighbor_deliveries.tres`) und überarbeitete Fundtabellen
(`tools/make_stashes.py` → `data/stashes/yard_stashes.tres`), sodass alle drei
Materialgruppen regelmäßig vorkommen. Nur vorhandene Gegenstände.
**Abnahme:** Bestehende Tests grün, neuer Test: über 20 Lieferungen erscheinen
alle drei Materialgruppen.

### F10 — Wirtschaftsbericht (Balance-Werkzeug)
**Ziel:** Ein Kommandozeilen-Werkzeug `tools/balance_report.gd`, das aus den
Daten Erträge pro Spielminute für typische Aufbauten berechnet
(nur Hand, Juri, Magnet, Magnet+Presse, volle Kette) und die
Amortisationszeit jeder Maschine ausgibt.
**Umfang:** Nur lesen und rechnen, **keine Werte ändern**. Ergebnis als
Markdown-Bericht in `docs/balance-report.md` mit Vorschlägen; die Entscheidung
trifft der Hauptentwickler ([gameplay-economy](../gameplay-economy.md) Abschnitt 13).

### F11 — Einnahmen-Übersicht im Pausenmenü
**Ziel:** Ein Panel „Bücher“ zeigt die letzten Buchungen und Summen nach Quelle
(Verkauf, Juri, Aufträge, Ausgaben) aus dem vorhandenen `Wallet`
(`scripts/economy/Wallet.gd`, `get_ledger()` liefert Buchungen mit
`reason`-Schlüssel wie `ui.ledger.staff_sale`).
**Umfang:** Nur Anzeige, Gruppierung über den `reason`-Schlüssel. Vorbild `TaskListPanel`.

### Q1 — Lokalisierungs-Prüfung als Test
Test, der alle `tr()`-Schlüssel in Skripten, Szenen und Daten findet und
prüft, dass jeder in DE und EN existiert und nicht leer ist; plus Liste
unbenutzter Schlüssel als Warnung (nicht als Fehler).

### Q2 — Abnahmetest: komplette Verarbeitungskette
Langer Integrationstest mit Zeitraffer: Eingang herrichten, Juri einstellen,
Magnet, Sortiermaschine, drei Pressen, Bänder; nach N Lieferungen sind alle
drei Ballenarten entstanden und verkauft, nichts ist verloren gegangen
(Anzahl Teile rein = Teile in Ballen + verkaufte Einzelteile + Bestand).

### Q3 — Spielstand-Robustheit für neue Blöcke
Tests für beschädigte oder fehlende Teile der Blöcke `stashes`,
`placed.links`, Maschinenzustände (`hopper`, `items`): Laden darf nie
abstürzen, Fehler werden repariert und als Notiz gemeldet.

---

## Teil C — Nicht für Agenten

Diese Themen bleiben beim Hauptentwickler, weil sie Grafik, Weltgestaltung
oder Grundsatzentscheidungen brauchen: Grundstückserweiterung, neue Maschinen
mit eigenem Modell, Region und Figuren (Phase 5), Grafik- und
Umgebungsarbeiten (Natur-Assets, Kulisse), neue Mitarbeiterrollen,
Spielstand-Versionssprünge, Änderungen am Bausystem-Kern.
