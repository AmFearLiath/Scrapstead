# Scrapstead

**Every Scrap Has a Story.**

Scrapstead ist ein gemütliches, humorvolles isometrisches Automatisierungs-Tycoon-Spiel über den Aufbau eines florierenden Recyclingbetriebs aus einem heruntergekommenen Schrottplatz.

## Projektstatus

Vorproduktion / Spieldesign.

Dieses Repository sammelt die Designdokumentation, Entscheidungen, Spezifikationen und Entwicklungsplanung. Eine konkrete Engine-Implementierung ist noch nicht vorausgesetzt.

## Design-Leitlinien

1. **Leicht zu lernen, spannend zu entdecken.** Einfache Interaktionen, Tiefe durch Kombinationen.
2. **Sichtbarer Fortschritt.** Der Schrottplatz verändert sich mit dem Wachstum des Betriebs.
3. **Hybrides Gameplay.** Der Spieler beginnt mit manueller Arbeit und delegiert Aufgaben nach und nach an Mitarbeiter und Maschinen.
4. **Sinnvolle Automatisierung.** Maschinen haben klare, verständliche Aufgaben.
5. **Gemütlicher Charakter.** Warme Diorama-Optik, Humor, charmante Maschinen und Scrappy.
6. **Freiheit für den Spieler.** Verschiedene Wege zum Sammeln, Verarbeiten, Verkaufen, Bauen und Anpassen.
7. **Von Anfang an vollständig mehrsprachig.** Alle spielerseitigen Inhalte sind über Lokalisierungsschlüssel eingebunden und von Beginn an internationalisierbar.

## Grundsatzentscheidungen

- Perspektive: Isometrisches 3D.
- Atmosphäre: Gemütlich, humorvoll, skurril.
- Grafikstil: Stylized Low-Poly / Miniatur-Diorama.
- Gameplay: Kombination aus manueller Arbeit und Automatisierung.
- Sammeln: Kleine Gegenstände direkt aufheben; größere Objekte benötigen Werkzeuge oder Ausrüstung.
- Schrottwirtschaft: Gewöhnlicher Schrott kann direkt verkauft werden; Sortierung und Verarbeitung sind optionale Wege zu besseren Erträgen.
- Fortschritt: Der Spieler erledigt die Arbeit zunächst selbst, stellt später Mitarbeiter ein, kauft Maschinen und baut schrittweise einen automatisierten Betrieb auf.
- Begleiter: Scrappy, ein modularer Roboter. Sein Kopf wird unter einem Schrotthaufen gefunden und mit einer besonderen Komponente aus dem roten Werkzeugkasten wiederhergestellt.
- Scrappy-Anpassung: Der Spieler baut ihn aus gefundenen Teilen zusammen. Kombinationen können nützlich, absurd oder rein kosmetisch sein.
- Mehrsprachigkeit: Vollständig mehrsprachige Entwicklung ab dem ersten Produktionsinhalt. Keine fest codierten Anzeigetexte; stabile IDs und Lokalisierungsschlüssel.
- Erste Referenzsprachen: Deutsch und Englisch. Weitere Sprachen müssen ohne Änderungen an der Spiellogik ergänzt werden können.
- Zentrale Designregel: **Simple Core, Endless Possibilities.**

## Dokumentationsübersicht

- [Spieldesign-Dokument](docs/gdd.md)
- [Gameplay- und Wirtschaftsspezifikation](docs/gameplay-economy.md)
- [Spielfortschritt und Unternehmensentwicklung](docs/progression-business-growth.md)
- [Gegenstandskatalog des Startgrundstücks](docs/starting-yard-item-catalog.md)
- [Lage- und Entdeckungsplan des Startgrundstücks](docs/starting-yard-layout-discovery.md)
- [Grundstücksgeometrie und Blockout-Spezifikation](docs/starting-yard-blockout.md)
- [Bauen, Platzierung und Maschinenverbindungen](docs/building-and-logistics.md)
- [Baumodus und Bauinteraktionen](docs/build-mode-and-interactions.md)
- [Standard für Lokalisierung und Internationalisierung](docs/localization.md)
- [Spezifikation des Begleiters Scrappy](docs/scrappy-companion.md)
- [Maschinen und Automatisierung](docs/machines-automation.md)
- [Welt- und Assetgestaltung](docs/world-art-assets.md)
- [UI- und UX-Spezifikation](docs/ui-ux.md)
- [Technische Architektur](docs/technical-architecture.md)
- [Entscheidungsprotokoll](docs/decision-log.md)

## Leitgedanke

Scrapstead soll viele Möglichkeiten bieten, ohne den Spieler mit unnötiger Komplexität zu belasten. Tiefe entsteht durch das Zusammenspiel einfacher Systeme – nicht durch komplizierte Steuerung, überladene Menüs oder verpflichtendes Mikromanagement.
