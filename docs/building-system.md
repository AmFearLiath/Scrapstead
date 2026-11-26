# Scrapstead — Bausystem (Phase 4, Block B)

**Status:** Platzieren, Verschieben, Drehen, Entfernen, Lager, Rückgängig/Wiederholen umgesetzt (26.11.2026); Verbinden folgt mit der zweiten Maschine
**Bezug:** [Bauen und Maschinenverbindungen](building-and-logistics.md), [Baumodus und Bauinteraktionen](build-mode-and-interactions.md), [Kernmatrix 4.6](core-gameplay-matrix.md), [Entscheidungslog 25.11.2026](decision-log.md), [Produktionsfahrplan Phase 4](production-scope-and-roadmap.md)

## 1. Ziel

Der Spieler gestaltet seinen Hof selbst: Er stellt Maschinen, Ablagen und Dekoration auf, verschiebt, dreht und entfernt sie wieder. Das Spiel prüft jede Position vorher und erklärt in Spielersprache, was nicht passt. Das Bausystem ist das Fundament für weitere Maschinen, Maschinenverbindungen, Lager und den Grundstücksausbau. Es wird deshalb vollständig und belastbar gebaut, nicht als Provisorium (Kernmatrix 7: keine provisorische Grundlage für hauptrelevante Funktionen).

## 2. Entscheidungen für die im Konzept offenen Punkte

| Offener Punkt (Konzept) | Entscheidung | Begründung |
|---|---|---|
| Rastergröße | **0,5-m-Raster** für Position und Grundfläche; Objekte belegen ganze Zellen | Fein genug für Deko und Zäune, grob genug für saubere Ausrichtung und einfache Prüfung |
| Freie oder rastergebundene Platzierung | Immer am Raster; kein freier Modus im ersten Schritt | „Vorschau und Ergebnis stimmen überein“ ist damit garantiert |
| Drehschritte | 90°, `R` dreht im Uhrzeigersinn, `Shift+R` dagegen | Konzeptvorschlag; feinere Drehung später nur für Deko |
| Eingabe | Maus zielt, Linksklick bestätigt, Rechtsklick/Esc bricht ab, `B` öffnet und schließt den Baumodus, WASD verschiebt die Kamera, Mausrad zoomt, `Entf`/`X` entfernt, `Strg+Z`/`Strg+Y` | Konzepttabelle; das Mausrad bleibt beim Zoomen, weil es im ganzen Spiel zoomt |
| Kaufort | **Platzierbare Objekte werden im Baumenü gekauft**, Werkzeuge und Upgrades weiterhin im Katalog | Konzept: Das Baumenü zeigt Preis, Platzbedarf, Funktion und Freischaltung |
| Entfernen | Entfernte Objekte gehen ins **Lager** (eigene, noch nicht aufgestellte Objekte) und lassen sich ohne neue Kosten wieder aufstellen; kein Geldverlust | Fehlertolerant; man soll gefahrlos ausprobieren können |
| Erreichbarkeit | Geprüft über **freizuhaltende Flächen**: Bedienflächen jedes Objekts, Interaktionspunkte aller vorhandenen Stationen, Tor und Laufwege der Mitarbeiter | Erklärbar („Juri läuft hier entlang“); kein Navigationsnetz nötig |
| Rückgängig/Wiederholen | Platzieren, Verschieben, Drehen, Entfernen; Verlauf gilt für die laufende Sitzung (nicht gespeichert), höchstens 50 Schritte | Konzept 8 |
| Mehrfach platzieren | Nach dem Platzieren bleibt das Objekt ausgewählt, solange Geld oder Lagerbestand reichen | Konzept 8 |
| Maschinenverbindungen | Datenmodell (Anschlusspunkte) wird jetzt angelegt; das **Verbinden-Werkzeug** folgt mit der zweiten Maschine (Sortierstation) | Eine Verbindung braucht zwei Maschinen; nichts Halbfertiges ausliefern |

## 3. Bausteine

### 3.1 Objektprofil (`PlaceableDefinition`)
Jedes platzierbare Objekt hat ein Datenprofil:
- ID, Name, Beschreibung, Kategorie (Maschinen, Lager und Ablagen, Wege und Zäune, Dekoration), Preis, Freischaltung (z. B. Story-Flag), Höchstzahl.
- **Grundfläche** in Zellen (Breite × Tiefe bei Drehung 0), Szene, Vorschaumodell.
- **Bedienflächen**: Zellen relativ zum Objekt, die frei und betretbar bleiben müssen (z. B. vor dem Schaltkasten).
- **Arbeitsbereich**: Radius, der in der Vorschau angezeigt wird (z. B. Magnetsammler).
- **Anschlusspunkte** (Eingang/Ausgang) für spätere Verbindungen.
- Ob es den Weg versperrt (Kollision) oder begehbar ist (Wegplatten, flache Deko).

### 3.2 Platzierungsprüfung (`PlacementValidator`)
Reine Logik, ohne Szene testbar. Sie prüft der Reihe nach und liefert alle gefundenen Gründe mit den betroffenen Zellen:
1. **Grundstück:** Alle Zellen liegen innerhalb der Grundstücksgrenze (mit Rand am Zaun).
2. **Feste Hindernisse:** Keine Überschneidung mit Gebäuden, Haufen, Containern und anderen festen Teilen des Hofs (Physikabfrage auf Weltebene 1).
3. **Andere Objekte:** Keine Überschneidung mit Grundfläche oder Bedienfläche bereits platzierter Objekte.
4. **Freizuhaltende Flächen:** Tor, Laufwege von Mitarbeitern, Interaktionspunkte von Stationen.
5. **Eigene Bedienfläche:** Die Bedienfläche des Objekts selbst ist frei (nicht im Hindernis, nicht außerhalb).
6. **Funktionale Hinweise** (blockieren nicht): z. B. „Kein Nagelhaufen in Reichweite – der Magnet nimmt nur lose Teile.“

### 3.3 Baumodus (`BuildMode`)
- Kamera löst sich vom Spieler und folgt einem Baucursor (WASD); der Spieler bleibt stehen.
- Werkzeugleiste unten: **Bauen**, **Verschieben**, **Entfernen**, **Ansehen**, dazu Rückgängig/Wiederholen. Daneben das Baumenü mit Kategorien und Objektkarten.
- **Vorschau:** halbtransparentes Modell, Rasterzellen der Grundfläche (grün gültig / rot ungültig), Bedienfläche (blau), Arbeitsradius (Ring) und eine Textzeile mit dem Grund. Rot allein reicht nicht; jeder Fehler hat einen Satz.
- Platzieren, Verschieben und Entfernen haben Geräusch, Staub und eine kleine Absetzanimation.

### 3.4 Objekte auf dem Hof (`PlacedObjects`)
- Verwaltet platzierte Objekte (eindeutige ID, Profil, Zelle, Drehung) und das Lager.
- Setzt Kollision, meldet die Objekte dem Szenen-Controller und speichert alles im Spielstand (**Version 7**).

## 4. Erste Objekte

| Kategorie | Objekte |
|---|---|
| Maschinen | Magnetsammler (bisher fest auf dem Stellplatz) |
| Lager und Ablagen | Palettenstapel, Kistenstapel, Fässer |
| Wege und Zäune | Kiesplatte (begehbar), Zaun niedrig (3 Varianten) |
| Dekoration | Badewannenbeet, Hofstrahler, Reifenstapel, Schubkarre, neue Stücke im Hofstil |

**Magnetsammler:** Er ist bewegbar. Sein Ausgabekorb gehört zur Maschine und wandert mit; Teile in der Kiste ziehen mit um. Walts Nagelhaufen bleibt, wo er ist, denn er gehört zum Hof. Steht der Sammler mit dem Haufen in Reichweite, holt er wie bisher daraus; sonst sammelt er nur lose Eisenteile in seinem Arbeitsradius. Die Vorschau zeigt das.

## 5. Spielstand und Übergang

- Version 7: Block `placed` mit Objekten (`uid`, `def`, `cell`, `rot`) und Lager (`stored`).
- Migration aus Version 6: Ein gekaufter Magnetsammler wird an seinem bisherigen Stellplatz als platziertes Objekt übernommen.
- Walts Liste: „Eine Maschine aufstellen“ zählt erst, wenn eine Maschine wirklich steht.

## 6. Abnahme

Die Prüfkriterien aus beiden Konzeptdokumenten gelten, soweit sie nicht das Verbinden betreffen:
1. Baumodus schnell erreichbar und ohne Erklärung bedienbar.
2. Objekte frei innerhalb der Grenzen platzierbar, drehbar, verschiebbar, entfernbar.
3. Anforderungen vor der Bestätigung sichtbar, ungültige Positionen mit konkretem Grund.
4. Vorschau und Ergebnis stimmen überein.
5. Mehrere gleiche Objekte nacheinander.
6. Rückgängig und Wiederholen ohne inkonsistente Zustände.
7. Bedien- und Laufflächen bleiben nutzbar; Juri kommt weiter überall hin.
8. Alles übersteht Speichern und Laden.

## 7. Umsetzung

### Bedienung im Spiel
- **B** öffnet den Baumodus. Der Spieler bleibt stehen, die Kamera folgt einem Baucursor (WASD, mit Shift schneller), und das Mausrad zoomt.
- Unten erscheint das Baumenü:
  - Oben die Tastenzeile.
  - Darunter die **Infozeile**: Sie sagt immer, was ein Klick tut („Reifenbank: Linksklick kauft für 14 Cr und stellt auf. R dreht.“) oder warum es nicht geht („Hier läuft Juri. Er würde sich nur vorbeiquetschen.“).
  - Darunter ein gelber Hinweis, z. B. zur Reichweite des Nagelhaufens.
  - Dann die Werkzeuge, Rückgängig/Wiederholen und „Fertig (B)“.
  - Ganz unten die Kategorien und die Objektkarten mit Preis oder Lagerbestand und Größe in Metern.
- **Vorschau:**
  - Durchscheinendes Modell.
  - Belegte Zellen grün oder rot (nur die problematischen Zellen sind rot), die freizuhaltende Bedienfläche blau.
  - Ein heller Rasterkreis um die Stelle.
  - Ein Ring für den Arbeitsradius (Magnetsammler).
  - In der Nähe: orange Flächen für Juris Laufwege und das Tor, türkise für den Platz vor Stationen.
- **Werkzeuge:**
  - **Bauen:** Linksklick platziert. Das Objekt bleibt ausgewählt, damit man mehrere hintereinander setzen kann.
  - **Verschieben:** Ein Klick nimmt auf (das Original wird blass), ein zweiter stellt ab, R dreht.
  - **Entfernen:** Das Objekt geht ins Lager, ebenso mit `Entf` oder `X`.
  - **Ansehen:** Name und Beschreibung beim Zeigen.
- Rechtsklick bricht die laufende Aktion ab. Esc bricht ab und verlässt den Baumodus, wenn nichts läuft; das Pausenmenü öffnet sich dabei nicht. `Strg+Z` / `Strg+Y` machen rückgängig und wiederholen.
- Aufstellen staubt und poltert, Entfernen klappert, Fehler machen „nope“.

### Regeln (getestet)
- Rückgängig eines Kaufs bringt das Objekt ins Lager. Geld wird nur einmal bezahlt und geht nie verloren.
- Passt ein Schritt nicht mehr, weil inzwischen etwas im Weg steht, wird er mit Begründung verworfen.
- Der Magnetsammler wird nur noch im Baumenü gekauft (60 Cr, als Katalogware hinterlegt, damit „Stärkerer Magnet“ ihn weiter voraussetzt).
  - Er lässt sich nur mit leerer Kiste entfernen. Dabei behält er seinen Zustand (Haufenbestand, Schalter).
  - Beim Versetzen wandern Teile in der Kiste mit.
- Die Vorschau blockiert nie: Sie hat keine Kollision, verarbeitet nichts und wird nicht gespeichert.

### Technik
- `scripts/build/`: `BuildGrid`, `PlaceableDefinition`, `PlaceableCatalog`, `PlacementValidator`, `PlacedObjects`, `BuildMode`; `scripts/ui/BuildMenu.gd`.
- Daten: `data/placeables/*.tres` und `scenes/placeables/*.tscn`, erzeugt mit `tools/make_placeables.py`.
- Neue Deko-Modelle (Schrottzwerg, Reifenbank, Rohrflamingo) in `tools/blender/props_machines.py`.
- Walts Nagelhaufen: `scenes/world/NailHeap.tscn`, fest im Hof.
- Spielstand Version 7 (`placed`); Migration aus Version 6.
- Tests:
  - `test_building.gd` (7): Raster, Gründe, Kaufen, Versetzen/Drehen/Lager, Magnet versetzen, Speichern, Walts Liste.
  - `test_build_mode.gd` (4): Ein/Aus, Bauen mit Infozeile, Verschieben/Entfernen/Rückgängig/Wiederholen, Vorschau.
  - Magnet-Tests auf das Bausystem umgestellt, einschließlich v6-Migration.
- Screenshots `50_build_menu` bis `55_build_move_magnet`.

### Offen
- **Verbinden** (Anschlusspunkte sind im Datenmodell angelegt) kommt mit der zweiten Maschine.
- Lager mit Funktion (Teile einlagern), Grundstückserweiterung, Gebäude.
- Menschlicher Test der Bedienung, besonders der Maussteuerung (die Tests zielen über die Programmierschnittstelle).

## 8. Erweiterung nach dem ersten Spielen

### Bau-UI
- Die Werkzeugleiste steht am linken Rand: Katalog C, Verschieben M, Entfernen X, Ansehen V, Rückgängig, Wiederholen, Fertig B.
- Der **Baukatalog** öffnet sich als zentriertes Fenster mit Kategorien, Bildkarten (Vorschaubilder aus Blender, `tools/make_thumbnails.py`) und einem Detailbereich mit Kaufknopf; ein Doppelklick stellt direkt auf.
- Die Infoleiste steht unten. Esc schließt zuerst den Katalog, dann die laufende Aktion, dann den Baumodus.

### Funktionen gebauter Objekte
- **Hofstrahler:** schaltbares Spotlicht.
- **Lager:** Paletten 6, Kistenstapel 10, Fässer 4 Teile. Mit E alles einlagern oder herausnehmen, neuer Gegenstandszustand `stored`.
- **Kieswege:** 25 % schneller für Spieler und Juri.
- **Reifenbank:** Juris Pausenplatz.
- **Scrappy** kommentiert neue Dekorationen.

### Ganzer Hof umbaubar
- Alle festen Hofobjekte werden beim Laden **übernommen** (`PlacedObjects.adopt`). Ihre Grundfläche ergibt sich aus den Kollisionsboxen.
  - Dazu gehören Werkstatt, Kiosk, Mauer, Träger, alle Requisiten, Theke, Bürotisch, Werkbank, Zerlegetisch, Schwarzes Brett, Hofstrahler, Fundorte, Kopf-Haufen, roter Werkzeugkasten, Abladepalette, Nagelhaufen und die Werkzeugplätze.
  - Sie lassen sich versetzen und drehen, aber nicht wegräumen.
  - Gespeichert werden nur versetzte Objekte (`placed.yard`).
- **Wegfindung:** `YardNavigation` rechnet A* auf dem 0,5-m-Raster.
  - Fest blockiert sind nur Dinge, die nicht übernommen sind (Zaun, Tor). Alles andere kommt aus den Grundflächen.
  - Neu berechnet wird nach jeder Bauaktion und beim Schließen des Baumodus.
  - Juri läuft über diese Wege; die festen Routen bleiben nur als Rückfallebene.
- **Erreichbarkeit:** Eine Platzierung, die eine Station, einen Fundort oder die Palette vom Tor aus abschneidet, wird abgelehnt: „Das würde den Weg abschneiden zu: …“.
- **Juris Plätze** (Theke, Zerlegetisch, Pause, Karren, Brechstange) hängen relativ an ihrem Objekt und wandern mit. Vorbereitete Funde von Fundorten wandern ebenfalls mit.
- **Tests:** Navigation, Hofobjekt versetzen und speichern, Juri findet die versetzte Theke.
