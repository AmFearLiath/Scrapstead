# Scrapstead — P0-Szenenarchitektur

**Version:** 0.2  
**Status:** Technischer Bauplan für P0; vor der Implementierung zu validieren  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel und Grenzen

Dieses Dokument beschreibt die kleinste sinnvolle Szenen- und Systemaufteilung für P0. Es legt fest, welche Szene welche Aufgabe besitzt und wie die zentralen Bestandteile miteinander kommunizieren.

P0 umfasst:

- Start in ein eigenständiges Hauptmenü.
- Logo und ruhige Kamerafahrt durch einen einfachen Old-Yard-Blockout.
- Übergang in eine technische Testszene.
- Spielerbewegung und isometrische Gameplay-Kamera.
- Drei Interaktionsarten: Aufheben, Untersuchen und Benutzen.
- Minimalen Spielzustand mit Speichern und Laden.

Nicht Teil dieser Architektur sind Wirtschaft, Inventar, Quests, Scrappy, Mitarbeiter, Maschinen, vollständiger Baumodus oder regionale Simulation.

## 2. Grundregeln

1. Szenen besitzen ihre Darstellung und lokalen Abläufe. Eine Szene soll nicht die gesamte Spielsitzung verwalten.
2. Globale Dienste bleiben minimal. Nur Daten und Funktionen, die mehrere Szenen tatsächlich benötigen, werden global verfügbar gemacht.
3. Gameplay-Zustand ist nicht an Nodes gebunden. Gespeichert werden stabile IDs und Werte, nicht komplette Szenenbäume.
4. UI löst Aktionen aus, entscheidet aber nicht über Gameplay-Regeln.
5. Die Menü-Kamerafahrt ist unabhängig von Spieler und Gameplay-Kamera.
6. P0-Systeme bleiben klein. Es werden keine generischen Frameworks für noch nicht vorhandene Features gebaut.

## 3. Geplante Projektstruktur

Die Struktur ist eine Zielstruktur. Ordner und Dateien werden erst angelegt, wenn sie im jeweiligen Arbeitsschritt benötigt werden.

```text
Scrapstead/
├── project.godot
├── _engine/                    # lokale Engine-Bereitstellung, nicht ins Git-Repository
├── assets/
│   ├── branding/
│   ├── environment/
│   ├── objects/
│   ├── characters/
│   ├── materials/
│   ├── animations/
│   ├── audio/
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
│   ├── menu/
│   │   └── MainMenuController.gd
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
│   ├── interaction/
│   └── debug/
├── data/
│   └── prototype/
└── docs/
```

Die Engine liegt lokal unter `_engine/`. Der konkrete ausführbare Dateiname kann je nach Betriebssystem und bereitgestelltem Paket variieren. Das Projekt darf nicht fest an einen absoluten lokalen Pfad gebunden werden. Die Engine-Binärdateien werden nicht in das Git-Repository aufgenommen.

## 4. Einstiegspunkt und globale Dienste

### 4.1 Main.tscn

**Root:** `Node`

Aufgaben:
- Initiale Einstiegsszene des Projekts.
- Übergibt an die Hauptmenüszene.
- Enthält selbst keine Spielmechaniken und keine Menügestaltung.

### 4.2 Minimale Autoloads

Für P0 werden höchstens zwei globale Dienste vorgesehen:

**GameSession**
- Hält den aktuellen Prototyp-Spielzustand.
- Initialisiert einen frischen Zustand für „Neues Spiel“.
- Stellt den geladenen Zustand für „Fortsetzen“ bereit.
- Enthält keine UI- oder Szenenlogik.

**SaveService**
- Prüft, ob ein gültiger P0-Spielstand vorhanden ist.
- Speichert und lädt den versionierten Spielzustand.
- Validiert die unterstützte Save-Version.
- Meldet Erfolg oder Fehler an den aufrufenden Ablauf.
- Verwaltet keine Gameplay-Entscheidungen.

Ein eigener globaler SceneManager ist für P0 nicht erforderlich. Szenenwechsel können über die vorgesehenen Godot-Szenenwechsel-Funktionen ausgelöst werden. Erst wenn mehrere reale Abläufe eine zentrale Szenenverwaltung benötigen, wird diese Abstraktion geprüft.

## 5. Hauptmenü

### 5.1 MainMenu.tscn

**Root:** `Node`

```text
MainMenu (Node)
├── MenuBackdrop (Instanz: MenuBackdrop.tscn)
└── MenuUI (CanvasLayer)
    └── Root (Control)
        ├── Logo (TextureRect oder vergleichbares Control)
        ├── MenuPanel (VBoxContainer)
        │   ├── NewGameButton
        │   ├── ContinueButton
        │   ├── SettingsButton
        │   └── QuitButton
        └── SettingsPanel (Control, zunächst verborgen)
```

Aufgaben:
- Menüelemente darstellen und Eingaben entgegennehmen.
- „Fortsetzen“ anhand der Save-Prüfung aktivieren oder deaktivieren.
- „Neues Spiel“ fordert einen frischen Zustand an und lädt die Testszene.
- „Fortsetzen“ lädt zuerst den gespeicherten Zustand und öffnet danach die Testszene.
- „Einstellungen“ zeigt nur implementierte Optionen.
- „Beenden“ beendet das Spiel kontrolliert.

Das Menü enthält keine eigene Kopie des Speicher- oder Spielzustands. Es fragt die dafür zuständigen Dienste ab.

### 5.2 MenuBackdrop.tscn

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

Aufgaben:
- Zeigt einen einfachen, eigens arrangierten Ausschnitt des Old Yard.
- Bewegt die Menü-Kamera entlang einer vorbereiteten Route.
- Wiederholt die Fahrt kontrolliert und ohne sichtbaren Sprung.
- Bleibt vollständig unabhängig von der Gameplay-Kamera.

Die Kamerafahrt darf zunächst wenige Wegpunkte verwenden. Sie ist eine Präsentationsanimation und keine Simulation der Spielwelt. Die Menüoberfläche liegt als separate UI-Ebene darüber.

## 6. Gameplay-Testszene

### 6.1 OldYardTest.tscn

**Root:** `Node3D`

```text
OldYardTest (Node3D)
├── WorldEnvironment
├── LevelGeometry (Node3D)
│   ├── Ground
│   ├── Walls
│   └── Obstacles
├── TestObjects (Node3D)
│   ├── PickupTestObject
│   ├── InspectTestObject
│   └── UseTestObject
├── Player (Instanz: Player.tscn)
├── GameplayCamera (Instanz: GameplayCamera.tscn)
└── HUD (CanvasLayer)
    └── Root (Control)
        ├── InteractionPrompt
        └── DebugOverlay
```

Aufgaben:
- Enthält Testgeometrie und Testobjekte.
- Platziert den Spieler an der definierten Startposition.
- Stellt die Gameplay-Kamera bereit.
- Zeigt Interaktionshinweise und optionale Debuginformationen.
- Überträgt den aktuellen Zustand beim Laden auf die passenden Weltobjekte.

Die Szene selbst enthält keine dauerhafte Speicherlogik. Sie meldet relevante Zustandsänderungen an den zuständigen Spielzustand.

## 7. Spieler und Kamera

### 7.1 Player.tscn

**Root:** `CharacterBody3D`

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── PlaceholderModel
├── InteractionDetector (Area3D)
│   └── CollisionShape3D
└── PlayerInteractor
```

Aufgaben:
- PlayerController verarbeitet Bewegungseingaben und Bewegung in der horizontalen Spielebene.
- Kollisionen werden durch den CharacterBody3D und seine Kollisionsform behandelt.
- VisualRoot trennt Modell und spätere Animationen vom Bewegungs- und Kollisionskörper.
- InteractionDetector erkennt mögliche Interaktionsziele im festgelegten Umkreis.
- PlayerInteractor wählt ein gültiges Ziel aus und löst die angeforderte Interaktion aus.

### 7.2 GameplayCamera.tscn

Die Kamera ist eine eigenständige Szene und folgt dem Spieler über eine Referenz auf das Spielerziel.

Aufgaben:
- Isometrische bzw. orthografische Ausgangsperspektive.
- Sanftes Folgen des Spielers.
- Begrenzter Zoom.
- Keine freie Kameradrehung in P0.
- Keine Kopplung an die Menü-Kamerafahrt.

Konkreter Winkel, Zoomgrenzen, Follow-Verzögerung und Bewegungswerte werden im Blockout getestet und nicht vorab als endgültige Zahlen festgelegt.

## 8. Interaktionsmodell

P0 verwendet eine **reichweitenbasierte Interaktion**. Ein Spieler muss kein Fadenkreuz exakt auf ein Objekt richten. Das System erkennt gültige Kandidaten innerhalb des Interaktionsbereichs und wählt das passendste erreichbare Ziel. Bei mehreren Kandidaten wird zunächst die Nähe verwendet; eine eindeutige Blickrichtung kann als sekundäres Auswahlkriterium dienen.

Jedes Testobjekt besitzt eine stabile Instanz-ID und stellt eine passende Interaktionsmöglichkeit bereit.

Drei P0-Aktionen:
- **Pickup:** Objekt wird als aufgenommen markiert und ist anschließend nicht mehr als verfügbares Weltobjekt anwählbar.
- **Inspect:** Objektinformationen werden angezeigt; der Weltzustand bleibt unverändert.
- **Use:** Das Objekt führt eine einfache, definierte Testaktion aus und aktualisiert gegebenenfalls seinen Zustand.

Das Interaktionssystem verantwortet Erkennung, Auswahl, Eingabe und Rückmeldung. Das Zielobjekt verantwortet die fachliche Aktion. UI zeigt nur die passende Aktion und das Ergebnis.

## 9. Minimaler Spielzustand und Speichern

Der P0-Spielzustand umfasst:
- Save-Version.
- Aktuelle Prototyp-Szene.
- Spielerposition und bei Bedarf Ausrichtung.
- Zustände der drei Testobjekte anhand stabiler IDs.
- Tatsächlich vorhandene Spieleinstellungen.

Gespeichert wird als versioniertes JSON unter dem Godot-Benutzerdatenverzeichnis, nicht im Projektordner und nicht in `_engine/`.

Regeln:
- Ein fehlender Spielstand bedeutet: „Fortsetzen“ ist deaktiviert.
- Ein ungültiger oder nicht unterstützter Spielstand darf nicht stillschweigend als gültig behandelt werden.
- „Neues Spiel“ setzt den Prototypzustand kontrolliert zurück.
- „Fortsetzen“ lädt zuerst die Daten und stellt danach die Szene wieder her.
- Speichern erfolgt aus einem definierten Zustand; Nodes und Szenen werden nicht serialisiert.
- Die Save-Version wird von Anfang an mitgeführt, auch wenn P0 zunächst nur Version 1 kennt.

## 10. Datenfluss und Szenenwechsel

**Neues Spiel:**
1. Menü fordert GameSession auf, einen frischen P0-Zustand zu erzeugen.
2. Die Testszene wird geladen.
3. Die Szene übernimmt den aktuellen Zustand und stellt Spieler sowie Testobjekte her.

**Fortsetzen:**
1. Menü fragt SaveService nach einem gültigen Spielstand.
2. SaveService lädt und validiert die Daten.
3. GameSession übernimmt den geladenen Zustand.
4. Die Testszene wird geladen und stellt den gespeicherten Zustand wieder her.

**Interaktion:**
1. PlayerInteractor erhält Kandidaten vom InteractionDetector.
2. Das System wählt das beste gültige Ziel.
3. HUD zeigt die verfügbare Aktion.
4. Eingabe löst die Aktion am Zielobjekt aus.
5. Zielobjekt aktualisiert seinen Zustand.
6. GameSession erhält die relevante Zustandsänderung.

**Speichern:**
1. Szene bzw. Gameplay-Systeme übertragen ihren aktuellen Zustand in GameSession.
2. SaveService serialisiert ausschließlich die definierten Daten.
3. SaveService schreibt den versionierten Spielstand und meldet das Ergebnis.

## 11. P0-Abnahmekriterien

- Main.tscn startet zuverlässig das Hauptmenü.
- Menü-Kamerafahrt und Gameplay-Kamera sind getrennt.
- Alle vier Menüoptionen verhalten sich korrekt.
- „Fortsetzen“ ist ohne gültigen Spielstand deaktiviert.
- Neues Spiel beginnt mit einem sauberen Zustand.
- Fortsetzen stellt den gespeicherten P0-Zustand wieder her.
- Spielerbewegung und Kameraführung sind kontrollierbar.
- Hindernisse blockieren die Bewegung nachvollziehbar.
- Interaktionsziele werden in Reichweite zuverlässig erkannt.
- Pickup, Inspect und Use verhalten sich unterschiedlich und korrekt.
- Gespeicherte Objektzustände bleiben nach einem Neustart erhalten.
- Ungültige oder fehlende Speicherdaten führen nicht zu einem falschen Fortsetzen-Zustand.

## 12. Bewusst offene Punkte

Erst durch den P0-Prototyp werden festgelegt:
- Exakte Kameraausrichtung und Zoomgrenzen.
- Bewegungsbeschleunigung und Laufgeschwindigkeit.
- Interaktionsradius und Auswahlgewichtung.
- Konkrete Form der Interaktionshervorhebung.
- Optische Gestaltung des Test-HUD.
- Kameraroute und Dauer der Menüfahrt.
- Ob zusätzliche Optionen wie Vollbild oder Lautstärke bereits im ersten Menü enthalten sind.

Diese offenen Punkte sind bewusste Testparameter und keine Lücken in der Architektur.


## 13. PlayerController

Die konkrete Bewegungslogik, Eingabeaktionen, Physikverantwortung und Abnahmekriterien des Spielers sind in der [P0-PlayerController-Spezifikation](p0-player-controller.md) festgehalten.

Der Controller verwendet kamerabezogene Bewegung, normalisierte diagonale Eingaben und eine getrennte visuelle Ausrichtung. Sprinten, Springen und weitere Bewegungsaktionen gehören nicht zum P0-Umfang.


## 14. GameplayCameraController

Die konkrete Perspektive, Follow-Logik, Zoomsteuerung und die P0-Abnahmekriterien der Gameplay-Kamera sind in der [P0-GameplayCameraController-Spezifikation](p0-gameplay-camera-controller.md) festgehalten.

Die Gameplay-Kamera verwendet als Ausgangspunkt eine orthografische isometrische Perspektive, folgt einem definierten Kamera-Anker am Spieler und bietet einen begrenzten, stufenlosen Mausrad-Zoom. Freie Rotation, automatische Hindernisvermeidung und dynamische Gebäudetransparenz gehören nicht zum P0-Umfang.


## 15. PlayerInteractor / InteractionController

Die konkrete Erkennung, Bewertung und Auswahl von Interaktionszielen sowie Hervorhebung, HUD-Hinweis und Aktionsausführung sind in der [P0-PlayerInteractor-Spezifikation](p0-interaction-controller.md) festgehalten.

Die bestehende Komponente `PlayerInteractor` ist die Interaktionssteuerung. Ein zweiter paralleler InteractionController wird nicht eingeführt. Der InteractionDetector erkennt Kandidaten; PlayerInteractor bewertet und verwaltet das aktive Ziel. Die Testszene prüft Pickup, Inspect und Use.
