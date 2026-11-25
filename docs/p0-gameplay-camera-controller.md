# Scrapstead — P0-Spezifikation: GameplayCameraController

**Version:** 0.1  
**Status:** Technischer Bauplan für P0; Kamera- und Zoomwerte werden im Blockout abgestimmt  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel

Der GameplayCameraController stellt die feste isometrische Spielperspektive bereit und folgt dem Spieler ruhig und zuverlässig. Die Kamera soll Orientierung und Übersicht bieten, ohne die Aufmerksamkeit durch unnötige Bewegung auf sich zu ziehen.

Die Spezifikation konkretisiert die P0-Kamera aus der Szenenarchitektur. Sie führt keine neue Gameplay-Mechanik ein.

## 2. Verantwortlichkeiten

Der GameplayCameraController übernimmt:

- Feste isometrische Ausrichtung der Gameplay-Kamera.
- Sanftes Folgen eines definierten Spieler-Zielpunkts.
- Begrenzten, stufenlosen Zoom.
- Bereitstellung der aktiven Kamera für kamerabezogene Spielerbewegung.
- Robustes Verhalten, falls das Ziel vorübergehend nicht verfügbar ist.

Nicht seine Aufgabe:

- Spielerbewegung oder Spielerrotation.
- Interaktionszielsuche und Auswahl.
- Automatische Zielverfolgung anderer Objekte.
- Freie Kameradrehung oder Kameraneigung durch Spielereingabe.
- Dynamische Kamerafahrten, Cinematics oder Menüpräsentation.
- Weltgrenzen, Levelstreaming oder komplexe Hindernisvermeidung.

## 3. Szenenstruktur

Die Gameplay-Kamera bleibt eine eigenständige Szene und wird in `OldYardTest.tscn` instanziert.

Vorgesehene Struktur:

```text
GameplayCamera (Node3D)
├── CameraTarget (Node3D)
└── Camera3D
```

- `GameplayCamera` bildet den beweglichen Kamera-Rig und übernimmt das Folgen.
- `CameraTarget` repräsentiert den gewünschten Fokuspunkt in der Welt.
- `Camera3D` ist relativ zum Rig mit einem festen isometrischen Offset und einer festen Rotation angeordnet.
- Das Script `GameplayCameraController.gd` liegt auf dem Root `GameplayCamera`.

Der Zielpunkt wird über eine explizite Referenz auf den Spieler bzw. dessen definierten Kamera-Anker bereitgestellt. Die Kamera soll nicht anhand eines fest codierten Node-Pfads nach dem Spieler suchen.

Der Spieler erhält dafür bei Bedarf einen einfachen Kamera-Anker als untergeordneten Node. Dieser ist ein Referenzpunkt, keine eigene Gameplay-Logik.

## 4. Projektion und Perspektive

**P0-Ausgangspunkt: orthografische Projektion.**

Gründe:
- Größenverhältnisse bleiben unabhängig von der Entfernung stabil.
- Der isometrische Diorama-Look wird unterstützt.
- Objekte und Wege lassen sich gut vergleichen und räumlich lesen.
- Die Kamera erzeugt keine perspektivische Verzerrung bei parallelen Gebäudekanten.

Die Kamera verwendet eine feste Yaw- und Pitch-Ausrichtung. Eine Drehung durch den Spieler ist in P0 nicht vorgesehen.

### Startwerte für den ersten Blockout-Test

| Parameter | Startwert |
|---|---:|
| Projektion | Orthogonal |
| Yaw | 45° |
| Pitch | -35° |
| Orthographic Size | 14 |
| Zoom-Minimum | 9 |
| Zoom-Maximum | 19 |

Die Werte sind Testparameter. Insbesondere Winkel und Orthographic Size müssen mit dem tatsächlichen Maßstab des Old-Yard-Blockouts, der Spielergröße und der Objektgeometrie geprüft werden.

Die konkrete Ausrichtung wird so gewählt, dass die Kamera die Spielfläche gut lesbar zeigt und die Steuerungsrichtungen des PlayerControllers nachvollziehbar bleiben.

## 5. Follow-Verhalten

Die Kamera folgt einem Zielpunkt am Spieler, nicht zwingend dessen Fußpunkt oder dem Root-Ursprung.

- Das Ziel bewegt sich mit dem Spieler.
- Der Kamera-Rig nähert sich dem Ziel weich und kontinuierlich.
- Die Glättung ist zeitbasiert und unabhängig von der Bildrate.
- Bei Stillstand bleibt die Kamera ruhig.
- Kleine Richtungswechsel lösen keine abrupten Kamerabewegungen aus.
- Es gibt in P0 kein automatisches Look-ahead und kein dynamisches Nach-vorne-Schwenken.

Das Follow-Verhalten soll Verzögerung spürbar reduzieren, ohne dass die Kamera dem Spieler sichtbar hinterherhinkt. Der Spieler bleibt im normalen Spielbetrieb ungefähr im zentralen Bildbereich.

Für einen neu gestarteten Level bzw. eine erstmalige Zielzuweisung darf die Kamera direkt auf die Startposition gesetzt werden. So wird ein sichtbarer Kameraschwenk vom Weltursprung zum Spieler vermieden.

### Startwert für den ersten Test

| Parameter | Startwert |
|---|---:|
| Follow-Glättung / Interpolationsgeschwindigkeit | 8,0 |

Der konkrete Wert wird im Blockout abgestimmt. Die Implementierung soll eine exponentielle bzw. anderweitig framerate-unabhängige Glättung verwenden und keine feste Positionsänderung pro Frame.

## 6. Zoom

Der Spieler kann die Kamera mit dem Mausrad stufenlos innerhalb fester Grenzen zoomen.

- Mausrad nach oben: näher heranzoomen.
- Mausrad nach unten: weiter herauszoomen.
- Zoom verändert ausschließlich die orthografische Größe.
- Die Kamera behält ihre Ausrichtung und ihren Fokuspunkt.
- Zoom bleibt auf den festgelegten Minimal- und Maximalwert begrenzt.
- Eingaben außerhalb der Grenzen haben keinen weiteren Effekt.
- Der Zoom springt nicht in diskreten Stufen.

### Startwert für den ersten Test

| Parameter | Startwert |
|---|---:|
| Zoom-Schritt pro Mausrad-Ereignis | 1,0 |
| Zoom-Interpolation | 10,0 |
| Minimum | 9 |
| Standard | 14 |
| Maximum | 19 |

Der Ziel-Zoomwert wird von der aktuell dargestellten Größe getrennt gehalten und weich angenähert. Dadurch entsteht keine harte Größenänderung bei jedem Mausrad-Ereignis.

Eine Einstellung für Zoomgeschwindigkeit oder invertiertes Mausrad ist in P0 nicht zwingend erforderlich. Die Werte werden zunächst direkt im Prototyp abgestimmt.

## 7. Eingabe und Input Map

Für P0 werden zwei Aktionen ergänzt:

| Action | Standardbelegung | Funktion |
|---|---|---|
| `camera_zoom_in` | Mausrad hoch | Heranzoomen |
| `camera_zoom_out` | Mausrad runter | Herauszoomen |

Der Controller verarbeitet nur diese Kameraeingaben. Bewegungsaktionen bleiben vollständig beim PlayerController.

Wenn die Anwendung den Mausfokus verliert oder eine UI-Eingabe die Mausradaktion beansprucht, darf daraus keine unerwartete Zoombewegung entstehen. Die konkrete Eingabepriorität wird beim Zusammenspiel mit HUD und UI geprüft.

## 8. Zusammenspiel mit PlayerController

- PlayerController verwendet die aktive Gameplay-Kamera als Richtungsreferenz für die Bewegung.
- GameplayCameraController folgt dem Spieler, steuert aber nicht dessen Bewegung.
- Die Kamerabasis für die Bewegungsberechnung bleibt auch bei orthografischer Projektion gültig.
- Da P0 keine Kameradrehung erlaubt, bleibt die Steuerungsorientierung konstant.
- Zoom verändert nicht die Bewegungsrichtung.
- Menü-Kamera und Gameplay-Kamera bleiben vollständig getrennt.

Die Kamera darf keine direkte Abhängigkeit auf PlayerController benötigen. Eine Referenz auf den Kamera-Anker bzw. das Zielobjekt reicht aus.

## 9. Sichtbarkeit, Hindernisse und große Objekte

Die isometrische Übersicht muss auch bei großen Schrottobjekten, Maschinen und Gebäuden brauchbar bleiben.

Für P0 gilt:
- Der Spieler muss im normalen Testbereich gut auffindbar bleiben.
- Interaktionsobjekte dürfen nicht dauerhaft durch die Kamera selbst aus dem Bild gedrängt werden.
- Der Zoom muss sowohl nahe Interaktionen als auch die Übersicht über einen größeren Hofbereich ermöglichen.
- Die Kamera darf nicht durch Boden oder feste Testgeometrie positioniert werden.
- Der Blockout muss typische Sichtprobleme mit Wänden, großen Schrottobjekten und Gebäudekörpern sichtbar machen.

**Nicht Bestandteil von P0:**
- Automatisches Ausblenden oder Transparenz von Gebäuden.
- Dynamisches Verschieben der Kamera zur Umgehung von Sichtblockaden.
- Kollisionserkennung mit der Umgebung und automatische Kameraverlagerung.
- Unterschiedliche Kameraprofile pro Gebäude oder Innenraum.
- Freie Rotation oder Neigung.

Solche Systeme werden nur dann später geprüft, wenn echte Spielbereiche zeigen, dass sie notwendig sind. Die erste Lösung ist eine geeignete Blockout-Geometrie und eine gut lesbare feste Perspektive.

## 10. Debug-Informationen

Das DebugOverlay kann optional anzeigen:

- Aktuelle Zielposition.
- Aktuelle Kamera-Rig-Position.
- Aktuellen Orthographic-Size-Wert.
- Ziel-Zoomwert.
- Abstand zwischen Rig und Ziel.
- Status der Zielreferenz.

Diese Informationen sind reine Diagnosewerte und keine reguläre HUD-Anzeige.

## 11. Fehler- und Randfälle

- Fehlt die Zielreferenz beim Szenenstart, darf das Script nicht abstürzen. Es wartet auf eine gültige Zuweisung und gibt im Debug-Modus einen Hinweis aus.
- Wird das Ziel während des Spiels entfernt, stoppt die Follow-Aktualisierung kontrolliert.
- Ein ungültiger Zoomwert wird auf die erlaubten Grenzen geklemmt.
- Die initiale Kameraposition wird vor der ersten sichtbaren Darstellung korrekt gesetzt.
- Sehr niedrige oder hohe Frameraten dürfen das Follow- und Zoomverhalten nicht grundlegend verändern.

## 12. P0-Abnahmekriterien

- Die Kamera zeigt eine konsistente isometrische orthografische Perspektive.
- Die Kamera folgt dem Spieler ruhig und ohne sichtbares Zittern.
- Beim Szenenstart springt die Kamera nicht sichtbar vom Weltursprung zum Spieler.
- Stillstand des Spielers erzeugt keine unnötige Kamerabewegung.
- Der Spieler bleibt im normalen Spielbereich gut auffindbar.
- Mausrad-Zoom funktioniert stufenlos und weich.
- Zoomgrenzen werden zuverlässig eingehalten.
- Zoom verändert weder Kamerawinkel noch Bewegungsrichtung.
- PlayerController kann die aktive Kamera als Bewegungsreferenz verwenden.
- Menü-Kamerafahrt und Gameplay-Kamera beeinflussen einander nicht.
- Große Testobjekte und Gebäudeblöcke werden im Blockout auf Sichtprobleme geprüft.
- Fehlende oder entfernte Zielreferenzen führen nicht zu einem Absturz.

## 13. Bewusst offene Punkte

Im P0-Blockout werden geprüft und bei Bedarf angepasst:
- Exakter Yaw- und Pitch-Winkel.
- Orthographic Size und Zoomgrenzen.
- Höhe und Position des Kamera-Ankers am Spieler.
- Follow-Glättung.
- Zoom-Schrittweite und Zoom-Glättung.
- Sichtbarkeit hinter großen Objekten und Gebäuden.
- Geeigneter Bildausschnitt für Interaktionen und größere Hofbereiche.

Diese Werte werden nicht allein am leeren Testfeld festgelegt. Der Blockout muss Spieler, kleine Fundstücke, große Schrottobjekte und erste Gebäudekörper enthalten.

---

**Scope-Hinweis:** Diese Spezifikation konkretisiert ausschließlich die P0-Gameplay-Kamera. Sie führt weder freie Kamerasteuerung noch komplexe Sichtbarkeits-, Kollisions- oder Innenraumlösungen ein.
