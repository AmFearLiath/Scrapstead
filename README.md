# Scrapstead

**Every Scrap Has a Story.**

Scrapstead ist ein gemütliches, humorvolles isometrisches Cozy Automation Tycoon-Spiel mit Sandbox-Charakter. Der Spieler übernimmt einen heruntergekommenen Schrottplatz und entwickelt ihn zu einem regionalen Recycling-Netzwerk mit Mitarbeitern, Maschinen, Fahrzeugen und eigenen Produktionsabläufen.

## Projektstatus

**Spielbarer Gameplay-Prototyp (P0 + P1 + P1b + P2).** Godot 4.7.2 Stable, GDScript, Forward+, Windows und Linux.

Der Prototyp enthält Hauptmenü mit Kamerafahrt durch den Old Yard, isometrische Steuerung, Sammeln, Bergen, Verkaufen, Credits, ein Tragekorb-Upgrade, eine optionale Zerlegung und Speichern/Fortsetzen. Seit P2: Walts Brief, ein Notizzettel mit Vorschlägen und Scrappy – sein Kopf steckt irgendwo im Schrott, sein Kernteil hat Walt gut verwahrt. Repariert folgt er dir, kommentiert und erinnert sich an Walt. Stand, Testprotokoll und bekannte Einschränkungen: [Prototyp-Abnahme](docs/prototype-acceptance.md).

## Prototyp starten

1. Godot **4.7.2 Stable** (Standard-Build, ohne .NET) installieren bzw. lokal unter `_engine/` ablegen (wird nicht versioniert).
2. Projekt im Godot-Editor öffnen (`project.godot`) und mit **F5** starten – oder per Kommandozeile:

```bash
godot --path .
```

### Steuerung

| Aktion | Taste |
|---|---|
| Bewegen | WASD / Pfeiltasten |
| Interagieren, Bergen/Durchsuchen/Zerlegen (halten) | E |
| Fundstück oder Einrichtung ansehen | R |
| Mit Scrappy reden (Mitkommen / Hier warten) | E, wenn du ihn ansiehst |
| Zuletzt aufgenommenes Teil ablegen | Q |
| Pausemenü (Speichern) / Panel schließen | Esc |
| Zoom | Mausrad |
| Debug-Overlay / Entwickler-Speichern (nur Debug-Build) | F3 / F5 |

### Ziel der Prototyp-Schleife

Schrott im Hof aufsammeln und am Annahmetresen verkaufen → im Büro aus dem **Bestellkatalog** Werkzeug bestellen (Brechstange, Flaschenzug) → vernagelte Kisten und versiegelte Fässer öffnen, Schrotthaufen durchsuchen, den festsitzenden Metallträger anheben → **Großer Tragekorb** und **Handkarren** für mehr Kapazität. Optional: das defekte Radio direkt verkaufen oder am Zerlegetisch in wertvollere Teile zerlegen.

### Tests und Werkzeuge

```bash
# Unit- und Integrationstests (headless; laufen auch in GitHub Actions, siehe .github/workflows/tests.yml)
godot --headless --path . --import
godot --headless --path . -s res://tests/run_tests.gd

# Abnahme über einen echten Neustart (zwei Prozesse)
godot --headless --path . -s res://tests/e2e_restart.gd -- --phase=play
godot --headless --path . -s res://tests/e2e_restart.gd -- --phase=continue

# Modelle in Blender erzeugen (Stil: docs/world-art-assets.md) und importieren
blender -b -P tools/blender/build_props.py -- --out assets/models --preview tests/_output/blender
godot --headless --path . --import
godot --headless --path . -s res://tools/configure_model_imports.gd
godot --headless --path . --import

# Geräusche und Musik synthetisieren (Python mit numpy und scipy)
python tools/audio/synth_audio.py

# Old-Yard-Blockout und Platzhaltermodelle neu erzeugen
godot --headless --path . -s res://tools/build_blockout.gd

# Screenshots des laufenden Spiels nach tests/_output/screens
godot --path . -s res://tools/capture_screens.gd
```

### Projektstruktur

```text
assets/        Blender-Modelle (models/), Audio (audio/), Shader, Materialien, Theme, Icons
data/          Gegenstände, Upgrades, Verarbeitung, Balancing, Klangbibliothek (Godot-Resources)
localization/  scrapstead.csv (en/de)
scenes/        Main, Menü, Old Yard, Spieler, Kamera, Interaktionsobjekte
scripts/       core (Autoloads), player, camera, interaction, world, economy,
               inventory, progression, data, ui, menu, debug
ui/            HUD, Panels, Hauptmenü
tests/         Headless-Testrunner, Unit-, Integrations- und Neustarttests
tools/         Blender-Modellskripte (blender/), Blockout-Generator, Import- und Screenshot-Werkzeuge
docs/          Konzept, Spezifikationen, Decision Log, Abnahme
```

## Design-Leitlinien

1. **Einfacher Einstieg, langfristige Tiefe.** Verständliche Einzelaktionen, Tiefe durch Kombinationen.
2. **Sichtbarer Fortschritt.** Grundstücke, Gebäude, Maschinen, Mitarbeiter und Scrappy entwickeln sich erkennbar.
3. **Cozy, Tycoon und Sandbox.** Atmosphäre, Unternehmensentwicklung und kreative Freiheit bleiben gleichwertig.
4. **Manuell beginnen, sinnvoll delegieren.** Der Spieler übernimmt zunächst die Arbeit selbst und gibt Wiederholungen später an Mitarbeiter und Maschinen ab.
5. **Bedeutsame Automatisierung.** Systeme haben klare Aufgaben und lassen unterschiedliche Lösungen zu.
6. **Lebendige Figuren.** Mitarbeiter und Scrappy besitzen Persönlichkeit, ohne eine komplexe Lebenssimulation zu erzwingen.
7. **Freiheit ohne Pflicht-Mikromanagement.** Der Spieler steuert Bereiche und Prioritäten, nicht jeden einzelnen Arbeitsschritt.
8. **Von Anfang an mehrsprachig.** Alle spielerseitigen Inhalte werden über Lokalisierungsschlüssel eingebunden.
9. **Komplexität im richtigen Moment.** Neue Systeme werden schrittweise eingeführt.
10. **Humor mit Charakter.** Trockener Witz, erfinderischer Unsinn und liebenswerte Absurdität mit gutem Timing.

## Aktuelle Grundsatzentscheidungen

- Perspektive: Isometrisches 3D.
- Grafikstil: Stylized Low-Poly / Cozy Miniatur-Diorama.
- Spielidentität: Kombination aus Cozy, Tycoon und Sandbox.
- Welt: Zusammenhängende Hauptregion plus separate Spezialstandorte (Hybrid).
- Weltaktivitäten: Erkundung, Fundorte, Bewohner, regionale Aufträge, Ereignisse und sichtbare Gemeinschaftsprojekte.
- Fortbewegung: Zu Fuß und mit Fahrzeugen.
- Bauen: Hybrid aus Raster/definierten Bauflächen und freierer Platzierung.
- Wirtschaft: Stabile Grundpreise mit dynamischer Nachfrage und Sonderaufträgen.
- Beschaffung: Eigener Schrottplatz, Anlieferungen, aktive Erkundung und Einkaufs-/Liefernetzwerke.
- Scrappy: Eigenständiger Begleiter, der abhängig von Modulen und Erfahrung auch Beschaffung und Logistik unterstützen kann.
- Mitarbeiter: Individuelle Persönlichkeiten und Fähigkeiten, einfache Arbeitsbereiche und autonome Aufgabenverteilung.
- Schichtsystem: Optionaler Zwei- bzw. perspektivisch Dreischichtbetrieb bei ausreichendem Personal.
- Zeit: Kontinuierliche Simulation mit Tag-Nacht-Rhythmus und täglichen Wirtschaftsereignissen.
- Offline-Fortschritt: Bevorzugt begrenzt, maximal 24 Stunden.
- Ressourcen: Vier Ebenen aus Gegenständen, Rohmaterialien, Komponenten und Erzeugnissen.
- Gameplay: Ausgewogene Aktivitäten, hybride Zerlegung, begrenztes modulares Crafting und automatisierte Logistik.
- Fahrzeuge: Keine direkte Steuerung; Transport über Aufträge, Routen und intelligente Disposition.
- Lager und Produktion: Standortgebundene Bestände, hybride Lagerverwaltung, physische und logische Produktionsverbindungen.
- Energie: Externer Netzbezug plus optionale Eigenproduktion; vollständige Autonomie ist kein Pflichtziel.
- Zerlegung: Hybrid – einfache Zerlegung für gewöhnliche Gegenstände, detaillierte Komponenten für besondere Objekte.
- Spielabschluss: Echtes Hauptende, optionaler Meisterabschluss und freies Weiterspielen danach.
- Statistik: Erfassung relevanter Ereignisse ab Spielbeginn.
- Begleiter: Scrappy, gebaut von Walt Wren; sein Kopf wird unter Schrott gefunden und mit einer besonderen Komponente aus dem roten Werkzeugkasten wiederhergestellt.
- Mehrsprachigkeit: Deutsch und Englisch als erste Referenzsprachen, weitere Sprachen ohne Änderungen an der Spiellogik.
- Zentrale Designregel: **Simple Core, Endless Possibilities.**

## Dokumentationsübersicht

- [Spieldesign-Dokument](docs/gdd.md)
- [Produktionsumfang und Entwicklungsfahrplan](docs/production-scope-and-roadmap.md)
- [Core-Gameplay-Matrix](docs/core-gameplay-matrix.md)
- [MVP- und Prototypenplan](docs/mvp-prototype-plan.md)
- [P1: Erste Gameplay-Schleife (Umsetzung)](docs/p1-gameplay-loop.md)
- [Prototyp-Abnahme, Testprotokoll und bekannte Einschränkungen](docs/prototype-acceptance.md)
- [P0-Implementierungs- und Projektstruktur](docs/p0-implementation-readiness.md)
- [Welt-, Unternehmens- und Simulationskonzept](docs/world-and-company-simulation.md)
- [Gameplay- und Wirtschaftsspezifikation](docs/gameplay-economy.md)
- [Regionale Wirtschaft und begrenzter Simulationsumfang](docs/regional-economy-scope.md)
- [Regionale Betriebe und Dienstleistungen](docs/regional-businesses-and-services.md)
- [Interaktion, Transport, Lager, Produktion und Energie](docs/gameplay-interaction-logistics-production.md)
- [Welt, Erkundung und Aktivitäten](docs/world-exploration-activities.md)
- [Regionalkarte, Gebietsstruktur und Weltfreischaltung](docs/regional-map-and-world-progression.md)
- [Bewohner, Charaktere und Beziehungen](docs/characters-residents-relationships.md)
- [Quest-, Missions- und Ereignissystem](docs/quest-mission-event-system.md)
- [Ergänzungsprotokoll: Welt und Unternehmenssimulation](docs/decision-log-world-and-simulation.md)
- [Spielfortschritt und Unternehmensentwicklung](docs/progression-business-growth.md)
- [First-Hour-Experience – Spielstart und erste Stunde](docs/first-hour-experience.md)
- [Walt Wren und die Geschichte hinter dem Schrottplatz](docs/lore-walt-wren.md)
- [Gegenstandskatalog des Startgrundstücks](docs/starting-yard-item-catalog.md)
- [Lage- und Entdeckungsplan des Startgrundstücks](docs/starting-yard-layout-discovery.md)
- [Grundstücksgeometrie und Blockout-Spezifikation](docs/starting-yard-blockout.md)
- [Bauen, Platzierung und Maschinenverbindungen](docs/building-and-logistics.md)
- [Baumodus und Bauinteraktionen](docs/build-mode-and-interactions.md)
- [Gebäude- und Modulsystem](docs/buildings-and-modular-construction.md)
- [Standard für Lokalisierung und Internationalisierung](docs/localization.md)
- [Spezifikation des Begleiters Scrappy](docs/scrappy-companion.md)
- [Maschinen und Automatisierung](docs/machines-automation.md)
- [Art Direction: Walts Flickwerk-Diorama](docs/world-art-assets.md)
- [UI- und UX-Spezifikation](docs/ui-ux.md)
- [Technische Architektur](docs/technical-architecture.md)
- [Entscheidungsprotokoll (bisherige Entscheidungen)](docs/decision-log.md)

## Leitgedanke

Scrapstead soll viele Möglichkeiten bieten, ohne den Spieler mit unnötiger Komplexität zu belasten. Tiefe entsteht durch das Zusammenspiel einfacher Systeme – nicht durch komplizierte Steuerung, überladene Menüs oder verpflichtendes Mikromanagement.
