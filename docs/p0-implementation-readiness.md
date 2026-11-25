# Scrapstead — P0-Implementierungs- und Projektstruktur

**Version:** 0.1  
**Status:** Umgesetzt (P0) und durch P1 erweitert; Umsetzungsstand siehe Abschnitt 11  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel

Dieses Dokument überführt die vorhandenen P0-Spezifikationen in eine konkrete, anlegbare Godot-Projektstruktur. Es legt fest:

- Ordner und Dateinamen.
- Szenen- und Node-Hierarchien.
- Script-Zuordnung.
- Autoloads.
- Input-Map-Aktionen.
- Reihenfolge der Implementierung.
- Prüfpunkte vor und nach jedem Arbeitsschritt.

Es enthält bewusst keinen GDScript-Quellcode. Die fachlichen Anforderungen bleiben in den bereits vorhandenen Einzelspezifikationen verbindlich.

## 2. Projektstruktur

Die folgende Struktur ist die verbindliche Zielstruktur für P0. Ordner werden angelegt, sobald die erste darin vorgesehene Datei benötigt wird. Leere Zukunftsordner werden nicht vorsorglich erstellt.

```text
Scrapstead/
├── project.godot
├── _engine/                         # lokale Engine-Bereitstellung, nicht versionieren
├── assets/
│   ├── branding/
│   ├── environment/
│   ├── objects/
│   └── ui/
├── scenes/
│   ├── main/
│   │   └── Main.tscn
│   ├── menu/
│   │   ├── MainMenu.tscn
│   │   └── MenuBackdrop.tscn
│   ├── world/
│   │   └── OldYardTest.tscn
│   ├── player/
│   │   └── Player.tscn
│   ├── camera/
│   │   └── GameplayCamera.tscn
│   └── interaction/
│       ├── PickupTestObject.tscn
│       ├── InspectTestObject.tscn
│       └── UseTestObject.tscn
├── scripts/
│   ├── core/
│   │   ├── GameSession.gd
│   │   └── SaveService.gd
│   ├── main/
│   │   └── MainController.gd
│   ├── menu/
│   │   └── MainMenuController.gd
│   ├── world/
│   │   └── OldYardTestController.gd
│   ├── player/
│   │   ├── PlayerController.gd
│   │   └── PlayerInteractor.gd
│   ├── camera/
│   │   └── GameplayCameraController.gd
│   ├── interaction/
│   │   └── Interactable.gd
│   └── debug/
│       └── DebugOverlay.gd
├── ui/
│   ├── main_menu/
│   │   └── MainMenuUI.tscn
│   ├── interaction/
│   │   └── InteractionPrompt.tscn
│   └── debug/
│       └── DebugOverlay.tscn
├── data/
│   └── prototype/
│       └── p0_defaults.gd
└── docs/
```

### 2.1 Strukturentscheidungen

- `Main.tscn` bleibt ein schlanker Einstiegspunkt. Ein eigenes `MainController.gd` ist nur erforderlich, wenn der Übergang zur Menüszene tatsächlich eine eigene Ablaufsteuerung benötigt. Für den ersten Aufbau darf der Szenenwechsel direkt über die Main-Szene erfolgen; es wird keine leere Controller-Klasse nur der Symmetrie wegen angelegt.
- `MainMenuUI.tscn` wird als eigenständige UI-Szene geführt, damit Menüoberfläche und 3D-Hintergrund getrennt bleiben.
- `InteractionPrompt.tscn` ist ein kleines, wiederverwendbares HUD-Control.
- `Interactable.gd` beschreibt den kleinen gemeinsamen Vertrag der drei Testobjekte. Es ist kein allgemeines Interaktionsframework.
- `p0_defaults.gd` enthält nur dann gemeinsame P0-Startwerte, wenn dieselben Werte tatsächlich an mehreren Stellen benötigt werden. Andernfalls bleiben Werte als exportierte Parameter an ihren jeweiligen Komponenten.
- `_engine/ ` ist lokal und wird nicht versioniert. Godot-Projektdateien dürfen keinen absoluten Engine-Pfad voraussetzen.

## 3. Szenen- und Node-Hierarchien

### 3.1 Main.tscn

**Root:** `Node`

```text
Main (Node)
```

Aufgabe:
- Einstiegsszene des Projekts.
- Übergabe an MainMenu.
- Keine Gameplay- oder Menülogik.

### 3.2 MainMenu.tscn

**Root:** `Node`

```text
MainMenu (Node) [MainMenuController.gd]
├── MenuBackdrop (Instanz: MenuBackdrop.tscn)
└── MenuUI (Instanz: MainMenuUI.tscn)
```

MainMenuController:
- Fragt den Fortsetzen-Status über GameSession ab.
- Verarbeitet Menüaktionen.
- Ruft GameSession für Neues Spiel und Fortsetzen auf.
- Verwaltet nur den lokalen Menüstatus und Fehlermeldungen.

### 3.3 MainMenuUI.tscn

**Root:** `CanvasLayer`

```text
MainMenuUI (CanvasLayer)
└── Root (Control)
    ├── Logo (TextureRect)
    ├── MenuPanel (VBoxContainer)
    │   ├── NewGameButton (Button)
    │   ├── ContinueButton (Button)
    │   ├── SettingsButton (Button)
    │   └── QuitButton (Button)
    ├── SettingsPanel (Control, zunächst verborgen)
    └── StatusMessage (Label)
```

- Die UI sendet Menüaktionen an MainMenuController.
- Die UI prüft weder Spielstände noch Spielfortschritt selbst.
- Continue wird anhand des von MainMenuController gelieferten Status aktiviert/deaktiviert.
- StatusMessage zeigt verständliche Lade- oder Speicherfehler.
- Einstellungen zeigen nur Optionen, die in P0 tatsächlich funktionieren.

### 3.4 MenuBackdrop.tscn

**Root:** `Node3D`

```text
MenuBackdrop (Node3D)
├── WorldEnvironment
├── YardBlockout (Node3D)
├── CameraPath (Path3D)
│   └── CameraPathFollow (PathFollow3D)
│       └── MenuCamera (Camera3D)
└── CameraAnimation (AnimationPlayer)
```

- Die Kamerafahrt ist eine Präsentation des Old Yard und keine aktive Gameplay-Simulation.
- Keine Referenz auf Player oder GameplayCamera.
- Der Hintergrund darf vereinfachte oder eigens arrangierte Geometrie verwenden.

### 3.5 OldYardTest.tscn

**Root:** `Node3D`

```text
OldYardTest (Node3D) [OldYardTestController.gd]
├── WorldEnvironment
├── LevelGeometry (Node3D)
│   ├── Ground
│   ├── Boundaries
│   ├── Walls
│   └── Obstacles
├── TestObjects (Node3D)
│   ├── PickupTestObject (Instanz)
│   ├── InspectTestObject (Instanz)
│   └── UseTestObject (Instanz)
├── Player (Instanz: Player.tscn)
├── GameplayCamera (Instanz: GameplayCamera.tscn)
└── HUD (CanvasLayer)
    ├── InteractionPrompt (Instanz)
    └── DebugOverlay (Instanz)
```

OldYardTestController:
- Liest den aktuellen Zustand aus GameSession.
- Stellt Spieler und Testobjekte wieder her.
- Aktiviert Eingaben erst nach abgeschlossener Initialisierung.
- Erstellt bei Speicheranforderung einen Datensnapshot.
- Führt keine Datei-I/O aus.

### 3.6 Player.tscn

**Root:** `CharacterBody3D`; Script: `PlayerController.gd`

```text
Player (CharacterBody3D) [PlayerController.gd]
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── PlaceholderModel (Node3D / MeshInstance3D)
├── CameraAnchor (Marker3D)
├── InteractionDetector (Area3D)
│   └── CollisionShape3D
└── PlayerInteractor (Node) [PlayerInteractor.gd]
```

- PlayerController sitzt auf dem Root.
- CameraAnchor ist ein Referenzpunkt für GameplayCameraController, nicht selbst ein Controller.
- InteractionDetector erkennt mögliche Interaktionsziele, trifft aber keine Auswahl.
- PlayerInteractor verwaltet Auswahl und Aktion.
- Das Modell wird über VisualRoot gedreht; CharacterBody3D bleibt die physische Referenz.
- Kollisionslayer und -masken werden in P0 ausdrücklich für Spieler, Weltgeometrie und Interaktionsziele festgelegt und dokumentiert.

### 3.7 GameplayCamera.tscn

**Root:** `Node3D`; Script: `GameplayCameraController.gd`

```text
GameplayCamera (Node3D) [GameplayCameraController.gd]
├── CameraTarget (Node3D)
└── Camera3D
```

- GameplayCameraController sitzt auf dem Root.
- CameraTarget ist der interne Fokuspunkt des Kamera-Rigs.
- Die externe Referenz auf Player/CameraAnchor wird bei der Initialisierung explizit übergeben.
- Camera3D verwendet orthografische Projektion, feste Rotation und den definierten Offset.
- Das Rig wird beim ersten Setzen des Ziels direkt positioniert; danach folgt es weich.

### 3.8 Interaktionsobjekte

Jedes Testobjekt ist eine eigene Szene mit einem stabilen Instanz-Identifier und einer gemeinsamen Interaktionsschnittstelle.

Empfohlene gemeinsame Grundstruktur:

```text
[TestObject] (StaticBody3D) [Interaktionsvertrag]
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── PlaceholderModel (MeshInstance3D)
└── InteractionPoint (Marker3D)
```

- Die StaticBody3D-Kollision dient der Erkennung durch den InteractionDetector und der optionalen Weltkollision, soweit benötigt.
- InteractionPoint definiert den Messpunkt für Reichweite und Interaktion.
- PickupTestObject führt Pickup aus und wird danach als nicht verfügbar markiert bzw. aus der Welt entfernt.
- InspectTestObject liefert einen vorbereiteten, lokalisierten Informationstext.
- UseTestObject verändert einen klar sichtbaren Testzustand.
- Der Interaktionsvertrag muss Verfügbarkeit, Aktionsdarstellung, erneute Gültigkeitsprüfung und Aktionsergebnis abdecken.
- Keine zusätzlichen Interaktionsarten und kein allgemeines Kontextmenü.

### 3.9 InteractionPrompt.tscn

**Root:** `Control`

```text
InteractionPrompt (Control)
└── PanelContainer
    └── HBoxContainer
        ├── TargetName (Label)
        ├── ActionLabel (Label)
        └── InputHint (Label)
```

- PlayerInteractor liefert die Anzeigedaten.
- Kein direkter Aufruf von GameSession oder Zielobjekten.
- Bei fehlendem Ziel wird das Control ausgeblendet.

### 3.10 DebugOverlay.tscn

**Root:** `Control`

```text
DebugOverlay (Control) [DebugOverlay.gd]
└── PanelContainer
    └── VBoxContainer
        ├── PlayerPositionLabel
        ├── PlayerVelocityLabel
        ├── InteractionStateLabel
        ├── CameraStateLabel
        └── SessionSaveStateLabel
```

- Rein lesende Diagnose.
- Nur im Entwicklungs-/Debugbetrieb sichtbar.
- Keine Gameplay-Regeln und keine direkten Zustandsänderungen.

## 4. Autoload-Konfiguration

In den Projekteinstellungen werden genau zwei Autoloads registriert:

| Name | Script | Aufgabe |
|---|---|---|
| `GameSession` | `res://scripts/core/GameSession.gd` | Sitzung, P0-Zustand, Start-/Fortsetzen-Ablauf, Speicherkoordination |
| `SaveService` | `res://scripts/core/SaveService.gd` | Datei-I/O, JSON, Save-Version und Validierung |

Beide Dienste dürfen beim Initialisieren keine Szenen-Nodes voraussetzen. GameSession darf SaveService aufrufen; SaveService darf GameSession nicht zurückrufen. Die Reihenfolge der Autoload-Registrierung wird entsprechend festgelegt: SaveService vor GameSession.

Es werden keine weiteren Autoloads für HUD, Debugging, Audio, globale Events oder Szenenverwaltung angelegt.

## 5. Input Map

Die folgenden Aktionen sind für P0 vorgesehen:

| Action | Standardbelegung | Besitzer | Funktion |
|---|---|---|---|
| `move_up` | W / Pfeil hoch | PlayerController | Bewegung nach oben relativ zur Kamera |
| `move_down` | S / Pfeil runter | PlayerController | Bewegung nach unten relativ zur Kamera |
| `move_left` | A / Pfeil links | PlayerController | Bewegung nach links relativ zur Kamera |
| `move_right` | D / Pfeil rechts | PlayerController | Bewegung nach rechts relativ zur Kamera |
| `interact` | E | PlayerInteractor | Hauptaktion des aktiven Interaktionsziels |
| `camera_zoom_in` | Mausrad hoch | GameplayCameraController | Zoom hinein |
| `camera_zoom_out` | Mausrad runter | GameplayCameraController | Zoom heraus |
| `debug_save` | F5 | OldYardTestController | Temporärer P0-Speichertest |

F5 ist eine Entwickleraktion für den P0-Test und keine finale Spielerfunktion. Es wird keine vollständige Rebinding-Oberfläche gebaut.

## 6. Initialisierungsreihenfolge der Gameplay-Szene

1. OldYardTest lädt statische Geometrie und Testobjekte.
2. OldYardTest liest den validierten Zustand aus GameSession.
3. Spielerposition und Ausrichtung werden gesetzt.
4. Gespeicherte Objektzustände werden anhand stabiler IDs angewendet.
5. CameraAnchor wird an GameplayCameraController übergeben.
6. Die Gameplay-Kamera setzt ihre Startposition direkt.
7. PlayerController erhält die aktive Kamera als Bewegungsreferenz.
8. PlayerInteractor erhält InteractionDetector, Interaktionshinweis und Spielerreferenzen.
9. HUD und DebugOverlay verbinden ihre Anzeigequellen.
10. Eingaben und Interaktionen werden freigegeben.

Die Reihenfolge verhindert, dass der Spieler vor dem Wiederherstellen losläuft, der Interactor kurzzeitig ein falsches Ziel auswählt oder die Kamera sichtbar vom Weltursprung zum Spieler springt.

## 7. Implementierungsreihenfolge

### Phase 0 — Projektbasis

- Godot-Projekt anlegen bzw. vorhandenes Projekt prüfen.
- Renderer und Projektversion kontrollieren.
- Ordnerstruktur anlegen.
- Main.tscn als Startszene setzen.
- Input Map konfigurieren.
- Autoloads registrieren, zunächst mit minimaler Initialisierung.
- Projekt startet fehlerfrei in eine leere Main-/Menüszene.

**Abnahme:** Projekt öffnet und startet ohne Parserfehler, fehlende Ressourcen oder Autoload-Fehler.

### Phase 1 — Menü und Einstieg

- Main.tscn und MainMenu.tscn.
- MainMenuUI mit vier Menüaktionen.
- MenuBackdrop mit einfacher Old-Yard-Geometrie und Kamerafahrt.
- Continue-Status über GameSession/SaveService.
- Einstellungen nur mit tatsächlich vorhandenen Optionen.

**Abnahme:** Start, Neues Spiel, Fortsetzen-Status und Beenden funktionieren; Menü-Hintergrund ist unabhängig.

### Phase 2 — Spieler und Kamera

- Player.tscn mit CharacterBody3D, Kollisionsform und Platzhaltermodell.
- PlayerController mit kamerabezogener Bewegung.
- GameplayCamera.tscn mit orthografischer Perspektive, Follow und Zoom.
- Explizite Zuweisung CameraAnchor/Kamera-Referenz.
- Blockout-Geometrie und Kollision.

**Abnahme:** Bewegung, Beschleunigung, Bremsen, Drehung, Kollision, Follow und Zoom erfüllen die vorhandenen Einzelspezifikationen.

### Phase 3 — Interaktion

- InteractionDetector und Kollisionsfilter.
- Gemeinsamer Interaktionsvertrag.
- Drei Testobjekte.
- PlayerInteractor mit Kandidatenbewertung und stabiler Auswahl.
- Hervorhebung und InteractionPrompt.

**Abnahme:** Pickup, Inspect und Use sind unterscheidbar; Zielwechsel, ungültige Referenzen und Rückmeldungen funktionieren.

### Phase 4 — Zustand und Persistenz

- P0-Zustandsmodell in GameSession.
- SaveService mit JSON, Version und Validierung.
- Wiederherstellung anhand stabiler IDs.
- Entwickler-Speicheraktion F5.
- Fehlerfälle für fehlende, beschädigte und nicht unterstützte Spielstände.

**Abnahme:** Speichern, Neustart und Fortsetzen stellen Spieler und Testobjekte zuverlässig wieder her.

### Phase 5 — Integration und Blockout-Abnahme

- DebugOverlay anschließen.
- Zwölf Integrationstests aus `p0-system-integration.md`.
- Sechs räumliche Bedienungstests aus `p0-gameplay-blockout.md`.
- Fehlerprotokoll und offene Parameter aktualisieren.
- P0 erst nach Erfüllung der Freigabekriterien abschließen.

**Abnahme:** P0 ist reproduzierbar, stabil und bereit für die P1-Entscheidung.

## 8. Implementierungsregeln

- Keine leeren Klassen oder Dateien nur für eine vermeintlich vollständige Architektur anlegen.
- Keine zusätzlichen Autoloads, Manager oder globalen Singletons ohne konkrete P0-Notwendigkeit.
- Keine Node-Pfade als versteckte globale Kopplung verwenden; Referenzen explizit übergeben.
- Keine Gameplay-Logik in UI-Skripte legen.
- Keine Datei-I/O außerhalb von SaveService.
- Keine Node- oder Szenenserialisierung.
- Jede implementierte Komponente wird unmittelbar mit einem kleinen Funktionstest geprüft.
- Bei Abweichungen zwischen Dokumenten wird die Spezifikation vor der Implementierung korrigiert, nicht stillschweigend im Code umgangen.
- Der P0-Blockout bleibt Testumgebung; keine Produktionsassets oder späteren Gameplay-Systeme vorziehen.

## 9. Abhängigkeiten und noch zu prüfende Details

Vor dem ersten Implementierungsschritt sind folgende Punkte im Godot-Projekt einmal technisch zu verifizieren:

- Exakte Godot-Projektversion 4.7.2 Stable.
- Verfügbarkeit und Verhalten der benötigten Input-Events für Mausrad-Zoom.
- Kollisionslayer und -masken für Spieler, Levelgeometrie und Interaktionsobjekte.
- Verhalten von Autoload-Initialisierung und Szenenwechsel im konkreten Projekt.
- Ob die Menü-Kamerafahrt als AnimationPlayer-Animation oder über PathFollow-Parameter umgesetzt wird.
- Ob die gemeinsame Interaktionsschnittstelle als Basisklasse oder Godot-typischer Vertrag implementiert wird.

Diese Verifikationen sind Implementierungsdetails. Sie rechtfertigen keine zusätzlichen Gameplay-Systeme.

## 10. Abnahmekriterien für Implementierungsbereitschaft

- Projektstruktur und Dateinamen sind eindeutig.
- Jede Szene besitzt eine definierte Root-Node und klare Aufgabe.
- Jeder Controller ist einer konkreten Node zugeordnet.
- Autoloads sind auf GameSession und SaveService begrenzt.
- Input-Map-Aktionen und Besitzer sind festgelegt.
- Initialisierungsreihenfolge verhindert ungültige Zwischenzustände.
- Implementierungsphasen besitzen jeweils überprüfbare Abnahmen.
- Es sind keine zusätzlichen P0-Gameplay-Systeme erforderlich.
- Die bestehenden Einzelspezifikationen bleiben konsistent und referenziert.

---

**Leitgedanke:** Die Projektstruktur soll die P0-Umsetzung beschleunigen und verständlich halten. Sie ist kein Selbstzweck und wird nur dort erweitert, wo ein konkreter P0-Baustein sie benötigt.


## 11. Umsetzungsstand und Abweichungen

P0 ist im Repository umgesetzt und durch automatisierte Tests abgesichert (siehe [Prototyp-Abnahme](prototype-acceptance.md)). Gegenüber der Zielstruktur aus Abschnitt 2 gelten folgende, im Decision Log begründete Ergänzungen:

| Bereich | Ergänzung | Grund |
|---|---|---|
| `scripts/menu/` | `MainMenuUI.gd`, `MenuBackdrop.gd` | UI-Signale bzw. Ausrichtung der Menükamera; keine Gameplay-Logik |
| `scripts/interaction/` | `InteractionContext.gd`, `InspectTestObject.gd`, `UseTestObject.gd` | Explizite Abhängigkeiten für Zielaktionen; konkrete Testaktionen |
| `scripts/ui/` | `InteractionPrompt.gd`, `FeedbackToast.gd`, `InspectPanel.gd`, `InputHints.gd` | Darstellung von Prompt, Rückmeldung und Untersuchungstext |
| `ui/hud/`, `ui/interaction/` | `FeedbackToast.tscn`, `InspectPanel.tscn` | Rückmeldung „was ist passiert“ und schließbare Inspect-Anzeige |
| `scenes/world/` | `YardBlockout.tscn` | Gemeinsamer Blockout für Menü-Hintergrund und Spielszene |
| `assets/` | Platzhaltermodelle, Theme, Umgebung | Lesbare Low-Poly-Platzhalter |
| `localization/` | `scrapstead.csv` (en/de) | Verbindliche Mehrsprachigkeit |
| `tools/` | `build_blockout.gd`, `capture_screens.gd` | Reproduzierbarer Blockout, visuelle Kontrolle |
| `tests/` | Headless-Testrunner und Testsuiten | Automatisierte Abnahme |
| Input Map | `debug_toggle_overlay` (F3) | Overlay laut Integrationsspezifikation ein-/ausblendbar |

`p0_defaults.gd` wurde nicht angelegt, da kein Startwert an mehreren Stellen benötigt wurde (Abschnitt 2.1). Ein `MainController.gd` existiert, weil Main den Wechsel ins Menü verzögert auslösen muss.

Mit P1 wurde `PickupTestObject` durch das allgemeine `ScrapItem` ersetzt, und die Input Map um `drop_item` (Q) und `pause_menu` (Esc) erweitert. Details: [P1: Erste Gameplay-Schleife](p1-gameplay-loop.md).
