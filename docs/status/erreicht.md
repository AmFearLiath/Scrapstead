# Was bisher erreicht ist

**Stand:** 27.11.2026 · Godot 4.7.2 (GDScript, Forward+) · Branch `main`
**Prüfung:** 151 automatische Tests und die Neustart-Abnahme (zwei Prozesse:
spielen, beenden, fortsetzen) laufen grün, ebenso die CI auf GitHub
(`.github/workflows/tests.yml`). Spielstand-Version 7.

Scrapstead ist ein spielbarer Vertical Slice des **Old Yard**: Der Spieler erbt
Walts Schrottplatz, sammelt, verkauft, weckt Scrappy, stellt Juri ein, baut den
Hof frei um und betreibt eine kleine automatische Verarbeitungskette.

---

## 1. Meilensteine nach Prototypplan

| Phase | Inhalt | Status | Doku |
|---|---|---|---|
| P0 | Projektbasis, Hauptmenü mit Kamerafahrt, Spieler, Kamera, Interaktion, Speichern | fertig | [p0-implementation-readiness](../p0-implementation-readiness.md) |
| P1 | Sammeln, Bergen, Verkaufen, Credits, Upgrades, Speichern im Spiel | fertig | [p1-gameplay-loop](../p1-gameplay-loop.md) |
| P1b | Optionale Zerlegung (Zerlegetisch) als Alternative zum Direktverkauf | fertig | [p1-gameplay-loop](../p1-gameplay-loop.md) |
| P1-Vertiefung | Bestellkatalog, Werkzeuge (Brechstange, Flaschenzug), Suchquellen, Inspektion | fertig | [starting-yard-item-catalog](../starting-yard-item-catalog.md) |
| P2 | Walts Brief, Notizzettel, Scrappys Fund und Wiederherstellung, Begleiter | fertig | [p2-arrival-and-scrappy](../p2-arrival-and-scrappy.md) |
| P3a | Erster Mitarbeiter Juri (anstellen, pausieren, entlassen, Lohn pro Stück) | fertig | [first-employee](../first-employee.md) |
| P3b | Erste Maschine: Magnetsammler am Nagelhaufen | fertig | [first-machine](../first-machine.md) |
| P4 | Vertical Slice: Walts Liste, Einstellungen im Spiel, Klang, Leistungsmessung | fertig | [p4-vertical-slice](../p4-vertical-slice.md) |
| Phase 4 (Produktion) | Bausystem, Fundstellen, Presse, Förderbänder, Sortiermaschine, Verarbeitungskette | in Arbeit | siehe unten |

## 2. Spielsysteme im Detail

### Kernschleife und Wirtschaft
- Gegenstände mit Kategorie, Wert, Tragegröße und Handhabung
  (`data/items/`, 15 Definitionen inkl. drei Ballenarten).
- Tragekorb mit Kapazität, Upgrades (größerer Korb, Handkarren).
- Verkaufstresen mit Angebot und eindeutigen Buchungen (`Wallet`).
- Bestellkatalog im Büro: Werkzeuge, Upgrades, Herrichten des Eingangs.
- Zerlegetisch: Radio und Toaster werden zu Kupferkabel und Elektronikteilen.

### Geschichte und Führung
- Walts Brief zum Start, Notizzettel mit dem jeweils nächsten Schritt.
- Scrappy: im Schrott gefunden, Kopf und Kern suchen, an der Werkbank
  reparieren; folgt dem Spieler, kommentiert Funde, Bauten, Maschinen und die
  Verarbeitungskette (77 Sprüche, DE/EN).
- Walts Liste: sieben Hauptaufgaben, im Pausenmenü abrufbar.

### Nachschub
- Nachbarn liefern Schrott an die Palette am Tor, sobald der Eingang
  hergerichtet ist (13 Lieferungen mit Absender und Notiz, nur Spielzeit).
- Durchsuchbare Hof-Requisiten: zwölf Fundstellen (Reifen, Autowrack, Regal,
  Kisten, Fässer, Container, Paletten, Motorblock, Schrotthaufen) mit Ladungen,
  die sich langsam wieder auffüllen; manche brauchen Brechstange oder
  Flaschenzug. [yard-stashes](../yard-stashes.md)

### Mitarbeiter Juri
- Erscheint nach den ersten Lieferungen, wird angestellt, arbeitet die Palette ab.
- Holt Handkarren und Brechstange selbst, zerlegt Geräte (abschaltbar).
- Läuft per A* auf dem Bauraster, umgeht alles, was gebaut wurde.
- Verarbeitungskette: bringt Ladung zur Sortiermaschine (wenn verbunden), sonst
  zur Presse, holt fertige Ballen ab und verkauft sie.

### Bausystem
- 0,5-m-Raster, Drehen, Platzieren, Verschieben, Entfernen ins Lager,
  Rückgängig/Wiederholen (50 Schritte), Vorschau mit Begründung in einem Satz.
- Der ganze Hof ist umbaubar (auch Schuppen, Kiosk, Stationen); Laufwege und
  Erreichbarkeit werden geprüft, Juris Wege neu berechnet.
- Werkzeugleiste, Baukatalog-Fenster mit Vorschaubildern, Infoleiste.
- Platzierbare Objekte mit Funktion: Lager, Strahler (schaltbar), Bank für
  Juris Pausen, Kieswege (schneller laufen), Deko. [building-system](../building-system.md)

### Maschinen und Automatisierung
- **Magnetsammler:** hebt Eisen aus Walts Nagelhaufen in seine Kiste; der
  Haufen wird nachgefüllt.
- **Schrottpresse** (bis zu 3): presst Stahl, Kupfer & Elektronik und Holz
  sortenrein zu Ballen mit Aufpreis. [scrap-press](../scrap-press.md)
- **Sortiermaschine:** ein Trichter, drei Kisten als drei Ausgänge.
  [processing-chain](../processing-chain.md)
- **Förderbänder:** Verbinden-Werkzeug (Taste L), Route automatisch, begehbar,
  folgen verschobenen Maschinen, blockieren keine Anschlüsse, Teile kommen
  sichtbar an. [machine-links](../machine-links.md)

### Präsentation
- Grafikstil 2 (dauerhaft): verwitterte, gebackene Blender-Modelle,
  Wüstensand-Shader, warmes Licht, dichte Kulisse vor dem Zaun, Schrottautos
  aus CC0-Modellen. [art-style-2](../art-style-2.md), [asset-credits](../asset-credits.md)
- Prozedurale Figurenanimation, Staub-, Funken- und Münzeffekte.
- Synthetisierte Geräusche, zwei Musikstücke, Atmosphäre.
- Grafikqualität (Niedrig/Mittel/Hoch), Sprache DE/EN, Fenster, Lautstärken.

### Technik
- Nur zwei Autoloads (`GameSession`, `SaveService`); Szenen-Controller statt
  globaler Manager. [p0-system-integration](../p0-system-integration.md)
- Inhalte als Ressourcen in `data/`, Texte in `localization/scrapstead.csv`
  (DE/EN, rund 690 Schlüssel).
- Spielstand v7 mit Migration älterer Versionen und Prüfung beim Laden.
- Werkzeuge: Blender-Modellbau (`tools/blender/`), Screenshot-Rundgang
  (`tools/capture_screens.gd`), Leistungsmessung, Szenen-Generatoren.

## 3. Bewusst noch offen

| Thema | Wo geplant |
|---|---|
| Aufträge (wiederkehrend, mit Fristen) und Wirtschaftsbalance über die ganze Kette | Phase 4, [quest-mission-event-system](../quest-mission-event-system.md) |
| Grundstückserweiterung | Phase 4, [production-scope-and-roadmap](../production-scope-and-roadmap.md) |
| Weitere Mitarbeiterrollen | Phase 4, [progression-business-growth](../progression-business-growth.md) |
| Region, Figuren, Betriebe, Geschichten | Phase 5, [regional-businesses-and-services](../regional-businesses-and-services.md) |
| Verkaufspalette für Ballen (Juri holt sie derzeit an den Pressen ab) | [processing-chain](../processing-chain.md) |
| Juri nutzt den Flaschenzug und durchsucht Fundstellen | [first-employee](../first-employee.md), [yard-stashes](../yard-stashes.md) |
| Natur-Assets (CC0) für die Umgebung | [asset-credits](../asset-credits.md) |

## 4. So prüft man den Stand

```powershell
_engine\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tests/run_tests.gd
```

```powershell
_engine\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tests/e2e_restart.gd -- --phase=play
```

```powershell
_engine\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tests/e2e_restart.gd -- --phase=continue
```

Spielanleitung zum Ausprobieren: [playtest-guide](../playtest-guide.md).
