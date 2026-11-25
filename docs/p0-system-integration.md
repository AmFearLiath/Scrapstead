# Scrapstead — P0-Systemintegration und Ablauf

**Version:** 0.1  
**Status:** Technischer Bauplan für P0; vor der Implementierung zu validieren  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel und Geltungsbereich

Dieses Dokument verbindet die vorhandenen P0-Spezifikationen zu einem durchgängigen technischen Ablauf. Es definiert Zuständigkeiten, Kommunikationswege, Datenübergaben, Lebenszyklen und Fehlerreaktionen.

Es konkretisiert ausschließlich:

- Einstieg über `Main.tscn` und `MainMenu.tscn`.
- Neues Spiel und Fortsetzen.
- Laufenden P0-Spielzustand.
- Spielerbewegung und Gameplay-Kamera.
- Interaktionsablauf und HUD-Rückmeldung.
- Speichern und Wiederherstellen.
- Debug-Ausgaben und reproduzierbare Tests.

Es führt keine zusätzlichen Gameplay-Systeme ein. Insbesondere gibt es keinen globalen SceneManager, Event-Bus, Service-Locator, Inventarservice oder generischen Framework-Layer.

## 2. Verbindliche Architekturregeln

1. **GameSession besitzt den sitzungsweiten P0-Zustand.** Welt-Nodes und UI sind nicht die maßgebliche Quelle für persistente Daten.
2. **SaveService ist ausschließlich für Persistenz zuständig.** Er liest und schreibt Daten, entscheidet aber nicht über Gameplay.
3. **Szenen koordinieren ihren lokalen Lebenszyklus.** Die Gameplay-Szene stellt den Zustand aus GameSession her und überträgt relevante Änderungen zurück.
4. **PlayerController, GameplayCameraController und PlayerInteractor bleiben fachlich getrennt.**
5. **HUD und DebugOverlay stellen Daten dar.** Sie führen keine Gameplay-Regeln aus und verändern den Spielzustand nicht eigenständig.
6. **Signale melden Ereignisse, Methoden führen gezielte Anfragen aus.** Für P0 wird kein globaler Nachrichtenbus benötigt.
7. **Referenzen werden explizit über Szenenaufbau oder Initialisierung übergeben.** Keine Suche nach beliebigen Nodes über globale Pfade.
8. **Speicherdaten enthalten stabile IDs und einfache Werte.** Keine Nodes, Ressourceninstanzen oder kompletten Szenenbäume serialisieren.
9. **Fehler werden sichtbar behandelt.** Ein fehlgeschlagener Ladevorgang darf nicht in einen scheinbar gültigen Fortsetzen-Zustand übergehen.

## 3. Zuständigkeiten und Kommunikationsrichtung

| Bestandteil | Besitzt / verantwortet | Darf direkt ansprechen |
|---|---|---|
| `Main` | Einstieg und Übergabe an Hauptmenü | MainMenu-Szene |
| `MainMenuController` | Menüeingaben und Menüstatus | GameSession; Menü-UI |
| `GameSession` | Laufenden P0-Spielzustand und Start-/Fortsetzen-Ablauf | SaveService; Szenenwechsel |
| `SaveService` | Save-Datei, Versionierung, Validierung und Datei-I/O | Keine Gameplay-Nodes |
| `OldYardTest` | Aufbau der Testwelt und Wiederherstellung der Weltobjekte | GameSession; lokale HUD-Elemente |
| `PlayerController` | Eingabe, Bewegung, physischer Zustand und visuelle Ausrichtung | Gameplay-Kamera-Referenz nur für Bewegungsbasis |
| `GameplayCameraController` | Follow, Perspektive und Zoom | Spieler-/Kameraanker |
| `PlayerInteractor` | Kandidaten, Zielauswahl und Interaktionsablauf | InteractionDetector; Interaktionsziele; InteractionPrompt |
| Interaktionsziel | Eigene Aktion und lokalen Objektzustand | Rückgabe an aufrufenden PlayerInteractor |
| `HUD` / `InteractionPrompt` | Anzeige von Kontext und Rückmeldung | Keine Gameplay-Dienste |
| `DebugOverlay` | Anzeige diagnostischer Werte | Lesende Referenzen bzw. Debug-Signale |

**Kommunikationsrichtung:** Menü → GameSession → SaveService bzw. Gameplay-Szene. Innerhalb der Gameplay-Szene kommunizieren spezialisierte Komponenten über direkte, explizite Referenzen und Signale. UI bleibt am Ende der Darstellungskette.

## 4. Globale Dienste

### 4.1 GameSession

GameSession ist ein Autoload und die maßgebliche Quelle für den sitzungsweiten P0-Zustand.

Verantwortlichkeiten:

- Einen neuen, sauberen P0-Zustand erzeugen.
- Einen von SaveService geladenen und validierten Zustand übernehmen.
- Den aktuellen Zustand für die Gameplay-Szene bereitstellen.
- Relevante Zustandsänderungen aus der Gameplay-Szene entgegennehmen.
- Den Zustand zum Speichern an SaveService übergeben.
- Den Szenenwechsel nach erfolgreichem Start bzw. Laden koordinieren.
- Fehler und Statusänderungen über klar benannte Signale melden.

GameSession enthält keine Node-Referenzen auf Spieler, Kamera, HUD oder Testobjekte. Diese Nodes existieren nur innerhalb der aktiven Szene.

Vorgesehene öffentliche Schnittstelle:

| Methode / Signal | Zweck |
|---|---|
| `start_new_game()` | Erzeugt den definierten Anfangszustand und startet die Gameplay-Testszene |
| `continue_game()` | Lädt, validiert und übernimmt einen vorhandenen Spielstand; startet erst danach die Testszene |
| `request_save(snapshot)` | Übernimmt den aktuellen Snapshot und übergibt ihn an SaveService |
| `get_current_state()` | Liefert eine tiefe Kopie bzw. ein nicht direkt veränderbares Abbild des aktuellen Zustands |
| `has_valid_save()` | Liefert den von SaveService ermittelten Fortsetzen-Status |
| `session_started` | Meldet erfolgreich gestartete Sitzung |
| `save_completed(success, message)` | Meldet Ergebnis eines Speichervorgangs |
| `session_error(message)` | Meldet einen verständlichen Fehler ohne ungültigen Szenenstart |

Die endgültigen GDScript-Typen und Signaturen werden bei der Implementierung an Godots konkrete Typmöglichkeiten angepasst. Die Verantwortlichkeiten und Aufrufrichtungen sind verbindlich.

### 4.2 SaveService

SaveService ist ein Autoload ohne Kenntnis von Gameplay-Nodes.

Verantwortlichkeiten:

- Save-Datei im Godot-Benutzerdatenverzeichnis lokalisieren.
- Vorhandensein und Gültigkeit des Spielstands prüfen.
- JSON lesen und schreiben.
- Schema-/Save-Version prüfen.
- Pflichtfelder und grundlegende Datentypen validieren.
- Fehler strukturiert an den Aufrufer zurückgeben.
- Schreibvorgänge kontrolliert abschließen.

SaveService darf weder Szenen laden noch Spielregeln ausführen oder UI-Elemente verändern.

Vorgesehene öffentliche Schnittstelle:

| Methode | Ergebnis |
|---|---|
| `has_valid_save()` | Boolean; nur `true`, wenn Datei lesbar und für diese Version gültig ist |
| `load_game()` | Strukturiertes Ergebnis mit Erfolg, Daten oder Fehlercode/-meldung |
| `save_game(data)` | Strukturiertes Ergebnis mit Erfolg oder Fehlercode/-meldung |

Ein fehlender, beschädigter oder nicht unterstützter Spielstand ist kein gültiger Spielstand. Die Oberfläche darf „Fortsetzen“ dann nicht aktivieren.

## 5. P0-Spielzustand und Snapshot

GameSession verwaltet ein einfaches, versioniertes Datenmodell. Für P0 enthält es mindestens:

| Feld | Inhalt |
|---|---|
| `save_version` | Unterstützte Save-Schema-Version |
| `scene_id` | Stabile Kennung der wiederherzustellenden P0-Szene |
| `player.position` | Weltposition des Spielers |
| `player.facing` | Horizontale Ausrichtung, sofern für Wiederherstellung benötigt |
| `world_objects` | Zuordnung stabiler Objekt-IDs zu ihren persistierbaren Zuständen |
| `settings` | Nur tatsächlich implementierte, persistente Spieleinstellungen |

Für P0 genügt ein kleines JSON-Datenmodell. Ein allgemeines Entity- oder Component-Save-Framework wird nicht gebaut.

### Snapshot-Regel

Die Gameplay-Szene erstellt bei einer Speicheranforderung einen Snapshot aus den dafür freigegebenen Laufzeitwerten. Dieser Snapshot enthält ausschließlich einfache Daten und wird an GameSession übergeben. GameSession aktualisiert damit seinen Sitzungszustand und übergibt eine Kopie an SaveService.

Der Snapshot wird nicht durch das Serialisieren von Nodes, Szenen oder Ressourcen erzeugt.

### Stabile Objekt-IDs

Jedes persistierbare Testobjekt besitzt eine eindeutige, sprachunabhängige ID. Die ID identifiziert die konkrete Platzierung in der Testszene, nicht nur den Typ des Objekts. Zwei gleichartige Objekte benötigen unterschiedliche Instanz-IDs.

Beim Wiederherstellen ordnet OldYardTest die gespeicherten Zustände den im Szenenaufbau vorhandenen IDs zu. Unbekannte IDs werden protokolliert und ignoriert; fehlende Zustände erhalten den definierten Anfangszustand. P0 benötigt dafür keine dynamische Weltgenerierung.

## 6. Lebenszyklus: Spielstart

### 6.1 Programmstart

1. Godot startet `Main.tscn`.
2. Main übergibt an `MainMenu.tscn`.
3. MainMenuController initialisiert den Menüstatus.
4. Das Menü fragt GameSession nach `has_valid_save()`.
5. Continue wird nur bei gültigem Spielstand aktiviert.
6. Die Menü-Kamerafahrt läuft unabhängig von allen Gameplay-Systemen.

Die Gültigkeitsprüfung muss beim Anzeigen des Menüs erfolgen. Der Buttonstatus ist nur eine UI-Abbildung und keine Sicherheitsgarantie für den späteren Ladevorgang.

### 6.2 Neues Spiel

1. Spieler wählt „Neues Spiel“.
2. MainMenuController ruft `GameSession.start_new_game()` auf.
3. GameSession erzeugt den vollständigen definierten P0-Anfangszustand.
4. GameSession wechselt zu `OldYardTest.tscn`.
5. OldYardTest liest den Zustand aus GameSession.
6. OldYardTest initialisiert Spieler und Testobjekte.
7. Die Gameplay-Kamera richtet sich ohne sichtbaren Startschwenk auf den Spieler aus.
8. HUD und DebugOverlay verbinden ihre lokalen Datenquellen.
9. Die Sitzung gilt als gestartet.

Ein neues Spiel darf nicht versehentlich Zustände aus einem zuvor geladenen Spiel übernehmen.

### 6.3 Fortsetzen

1. Spieler wählt „Fortsetzen“.
2. MainMenuController ruft `GameSession.continue_game()` auf.
3. GameSession fordert SaveService zum Laden auf.
4. SaveService liest und validiert die Datei.
5. Bei Fehler bleibt das Menü aktiv; der Fehler wird angezeigt und Continue wird erneut geprüft/deaktiviert.
6. Bei Erfolg übernimmt GameSession den geladenen Zustand.
7. Erst danach wird `OldYardTest.tscn` geladen.
8. OldYardTest stellt Spieler und Testobjekte anhand der stabilen IDs wieder her.
9. Die Kamera wird auf die wiederhergestellte Spielerposition gesetzt, ohne sichtbares Nachziehen vom Szenenursprung.
10. HUD und DebugOverlay verbinden ihre lokalen Datenquellen.

**Wichtig:** Die Gameplay-Szene wird nicht gestartet, bevor ein gültiger Zustand übernommen wurde.

## 7. Lebenszyklus: Gameplay-Szene

Beim Betreten von OldYardTest:

1. Statische Testgeometrie und fest platzierte Testobjekte werden instanziiert.
2. Die Szene liest GameSession-Zustand.
3. Der Spieler erhält Position und Ausrichtung.
4. Testobjekte erhalten ihre gespeicherten Zustände.
5. Der PlayerInteractor erhält seine Referenzen auf Detector und Prompt.
6. Die Gameplay-Kamera erhält ihren Follow-Anker.
7. Erst nach abgeschlossener Initialisierung werden Eingaben und Interaktionen freigegeben.

Beim Verlassen der Szene:

- Lokale Signale und Referenzen werden getrennt bzw. durch den Szenenlebenszyklus freigegeben.
- Die Szene hinterlässt keine Node-Referenzen in GameSession oder SaveService.
- Persistente Zustände bleiben ausschließlich als Daten in GameSession erhalten.

## 8. Kommunikation der Gameplay-Komponenten

### 8.1 PlayerController ↔ GameplayCameraController

- PlayerController erhält eine Referenz auf die Gameplay-Kamera bzw. deren Bewegungsbasis.
- Er verwendet ausschließlich die horizontale Kameraausrichtung zur Berechnung der Bewegungsrichtung.
- GameplayCameraController folgt dem definierten Spieler-Kameraanker.
- Die Kamera liest Spielerposition; sie schreibt keine Bewegungswerte in den PlayerController.
- Keine gegenseitige Steuerung und keine globale Suche nach Nodes.

### 8.2 InteractionDetector → PlayerInteractor

- InteractionDetector meldet erkannte Kandidaten bzw. Änderungen der Kandidatenmenge.
- Er bewertet und priorisiert keine Ziele.
- PlayerInteractor prüft Reichweite, Verfügbarkeit und Interaktionsfähigkeit selbst.
- Bei Austritt, Entfernung oder Deaktivierung eines Ziels wird die Auswahl zeitnah aktualisiert.

### 8.3 PlayerInteractor → Interaktionsziel

- PlayerInteractor ruft eine kleine, gemeinsame Interaktionsschnittstelle am Ziel auf.
- Vor der Aktion werden Zielgültigkeit und Erreichbarkeit erneut geprüft.
- Das Ziel entscheidet über Erfolg oder Ablehnung seiner konkreten Aktion.
- Das Ergebnis enthält mindestens Erfolg/Fehlschlag und eine lokalisierbare Rückmeldung bzw. einen Rückmeldungsschlüssel.
- Das Ziel aktualisiert seinen fachlichen Zustand; PlayerInteractor aktualisiert danach Zielauswahl und Anzeige.

### 8.4 PlayerInteractor → InteractionPrompt

- PlayerInteractor übergibt dem Prompt den aktuell darzustellenden Zielnamen, Aktionsschlüssel und die Eingabeanzeige.
- Bei keinem gültigen Ziel wird der Prompt ausgeblendet.
- Der Prompt sendet keine Gameplay-Befehle an das Ziel.
- Die Eingabe wird vom PlayerInteractor verarbeitet, nicht vom UI-Control.

### 8.5 Gameplay-Szene → GameSession

- Relevante Objektzustandsänderungen werden unmittelbar als Datenänderung an GameSession gemeldet oder beim Snapshot aus den Laufzeitobjekten gelesen.
- Spielerposition und Ausrichtung werden spätestens beim Speichern in den Snapshot übernommen.
- GameSession kennt weder konkrete Testobjektklassen noch Node-Pfade.
- P0 benötigt keinen allgemeinen Event-Bus.

## 9. Speichern und Wiederherstellen

### 9.1 Speichertrigger

Für den P0-Bedienungstest wird eine temporäre, entwicklerorientierte Speicheraktion vorgesehen (Standardtaste F5, sofern sie nicht mit einer bestehenden Editor-/Laufzeitbelegung kollidiert). Sie dient ausschließlich dazu, den Persistenzablauf reproduzierbar zu testen und ist keine endgültige Spielerfunktion.

Ein automatisches Speichern beim Beenden wird in P0 nicht vorausgesetzt. Es wird erst ergänzt, wenn ein verlässlicher Lebenszyklus und ein klarer Zeitpunkt dafür nachgewiesen sind.

### 9.2 Speichern

1. Speicheraktion wird ausgelöst.
2. Gameplay-Szene erstellt einen vollständigen P0-Snapshot.
3. Snapshot wird an GameSession übergeben.
4. GameSession aktualisiert seinen Sitzungszustand.
5. GameSession ruft SaveService auf.
6. SaveService validiert die Daten und schreibt die versionierte JSON-Datei.
7. Das Ergebnis wird über GameSession an HUD/DebugOverlay gemeldet.
8. Ein Fehlschlag lässt den laufenden Spielzustand unverändert und wird sichtbar angezeigt.

### 9.3 Wiederherstellen

- SaveService liefert ausschließlich validierte Daten.
- GameSession übernimmt den Datenstand.
- OldYardTest stellt die Szene anhand stabiler IDs wieder her.
- Nicht bekannte Objekt-IDs führen nicht zum Absturz.
- Ungültige Save-Versionen werden nicht stillschweigend migriert oder überschrieben.
- P0 benötigt zunächst nur eine unterstützte Save-Version; eine echte Migration wird erst bei einer inkompatiblen späteren Datenänderung eingeführt.

## 10. Fehler- und Randfallverhalten

| Situation | Erwartetes Verhalten |
|---|---|
| Kein Spielstand | Continue deaktiviert |
| Beschädigtes JSON | Continue deaktiviert; verständliche Fehlermeldung; Datei nicht als gültig behandeln |
| Nicht unterstützte Save-Version | Laden abbrechen; keine automatische Überschreibung |
| Szenenwechsel schlägt fehl | Fehler melden; keine gestartete Sitzung vortäuschen |
| Testobjekt-ID unbekannt | Debug-Hinweis; restliche Szene weiter laden |
| Gespeicherte Objekt-ID fehlt in Szene | Objekt erhält Anfangszustand; Debug-Hinweis |
| Interaktionsziel wird vor Tastendruck ungültig | Aktion abbrechen, Auswahl und Prompt aktualisieren |
| Interaktionsziel lehnt Aktion ab | Rückmeldung anzeigen; Zustand nicht ungewollt ändern |
| Kamera-Referenz fehlt | PlayerController verwendet dokumentierte Fallbackrichtung und meldet Debug-Hinweis |
| Speichern schlägt fehl | Spiel läuft weiter; Fehler sichtbar machen; letzten gültigen Spielstand nicht als erfolgreich gespeichert melden |

## 11. DebugOverlay

Das DebugOverlay ist ein rein lesendes Diagnosewerkzeug und kann zur Laufzeit ein-/ausblendbar sein.

Für P0 sinnvolle Anzeigen:

- Spielerposition und horizontale Geschwindigkeit.
- Aktuelle Bewegungsrichtung.
- Aktive Interaktionsziel-ID und Distanz.
- Anzahl erkannter Interaktionskandidaten.
- Aktueller Szenen-/Sessionstatus.
- Save-Status und letzte Speicher-/Ladefehlermeldung.

Es darf keine Gameplay-Werte verändern. Temporäre Testaktionen wie Speichern können über eine klar getrennte Debug-Eingabe ausgelöst werden; die Anzeige selbst bleibt passiv.

## 12. Testfälle für die Integration

| ID | Test | Erwartetes Ergebnis |
|---|---|---|
| INT-01 | Start ohne Save | Menü startet; Continue ist deaktiviert |
| INT-02 | Neues Spiel | Frischer Anfangszustand; OldYardTest startet |
| INT-03 | Fortsetzen mit gültigem Save | Spieler- und Objektzustände werden wiederhergestellt |
| INT-04 | Fortsetzen mit beschädigtem Save | Menü bleibt aktiv; verständliche Fehlermeldung |
| INT-05 | Bewegung und Kamera | Bewegung ist kamerabezogen; Kamera folgt ohne Startsprung |
| INT-06 | Interaktionszielwechsel | Genau ein Ziel aktiv; Prompt und Hervorhebung stimmen überein |
| INT-07 | Ziel wird ungültig | Auswahl wird entfernt; keine Aktion auf veralteter Referenz |
| INT-08 | Pickup / Inspect / Use | Zielaktion und Rückmeldung entsprechen dem Aktionstyp |
| INT-09 | Speichern und Neustart | Snapshot wird vollständig und stabil wiederhergestellt |
| INT-10 | Unbekannte Objekt-ID | Kein Absturz; Debug-Hinweis |
| INT-11 | Save-Schreibfehler | Sitzung läuft weiter; Fehler wird gemeldet |
| INT-12 | Szenenwechsel wiederholt | Keine doppelten Signale, Autoloads oder zurückgelassenen Node-Referenzen |

## 13. Abnahmekriterien

P0-Systemintegration ist bereit für die Implementierung, wenn:

- Jeder Bestandteil eine eindeutige Verantwortung besitzt.
- Es nur GameSession und SaveService als globale Dienste gibt.
- Alle Aufrufrichtungen und Datenübergaben nachvollziehbar sind.
- Neues Spiel und Fortsetzen getrennte, fehlerfeste Abläufe besitzen.
- Der SaveService keine Gameplay- oder Szenenlogik enthält.
- Die Gameplay-Szene keine Datei-I/O ausführt.
- Spieler, Kamera, Interaktion und HUD keine gegenseitigen Zuständigkeiten übernehmen.
- Persistente Zustände ausschließlich über stabile IDs und einfache Daten wiederhergestellt werden.
- Alle definierten Fehlerfälle ohne falschen Erfolgszustand behandelt werden.
- Die Integrationstests reproduzierbar ausführbar sind.

## 14. Bewusst offene Implementierungsdetails

Erst bei der Implementierung werden festgelegt:

- Exakte GDScript-Typannotationen und konkrete Rückgabetypen.
- Konkrete JSON-Feldserialisierung und numerische Präzision für Vektoren.
- Exakte Node-Pfade innerhalb der Szenen, sofern sie nicht über exportierte Referenzen übergeben werden.
- Darstellung der Fehlermeldungen im Menü und HUD.
- Ob F5 im finalen Testbuild bestehen bleibt oder durch ein Debug-Menü ersetzt wird.

Diese Details ändern nicht die festgelegten Verantwortlichkeiten und Kommunikationswege.
