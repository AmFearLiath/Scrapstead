# Scrapstead — P0-Spezifikation: PlayerController

**Version:** 0.1  
**Status:** Technischer Bauplan für P0; Bewegungswerte werden im Prototyp abgestimmt  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel

Der PlayerController setzt die Bewegung des Spielers in der isometrischen 3D-Testszene um. Die Steuerung soll direkt, vorhersehbar und präzise sein. Die Eingaberichtung orientiert sich an der Gameplay-Kamera und nicht starr an den Weltachsen.

Der Controller ist ausschließlich für Eingabe und physische Bewegung zuständig. Er verwaltet weder Kamera, Interaktion, Inventar noch Spielfortschritt.

## 2. Verantwortlichkeiten

Der PlayerController übernimmt:

- Einlesen der Bewegungsaktionen.
- Berechnen der Bewegungsrichtung relativ zur Gameplay-Kamera.
- Normalisieren diagonaler Eingaben.
- Beschleunigen und Abbremsen.
- Horizontale Bewegung über `CharacterBody3D`.
- Anwenden der Schwerkraft und Bodenbehandlung.
- Ausrichten des visuellen Modells in Bewegungsrichtung.
- Bereitstellen eines reproduzierbaren Spielerzustands für die Sitzung.

Nicht seine Aufgabe:

- Kamerabewegung, Zoom oder Kamerawinkel.
- Interaktionszielsuche und Interaktionsaktionen.
- Animation State Machine oder konkrete Animationsclips.
- Inventar, Gegenstände, Wirtschaft oder Fortschritt.
- Speichern und Laden auf Dateiebene.

## 3. Szenenstruktur

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── PlaceholderModel
├── InteractionDetector (Area3D)
│   └── CollisionShape3D
└── PlayerInteractor (Node)
```

Der PlayerController wird als Script am Root `Player` geführt. Die visuelle Ausrichtung wird auf `VisualRoot` angewendet, nicht auf den gesamten CharacterBody3D. Dadurch bleiben Kollisionskörper und Bewegungsrichtung unabhängig von Modellachsen und späteren Animationsdetails.

## 4. Eingabe

Die Eingaben werden über Godots Input Map definiert. Der Controller fragt ausschließlich benannte Aktionen ab.

| Action | Standardbelegung | Funktion |
|---|---|---|
| `move_up` | W / Pfeil hoch | In Richtung oberer Bildschirmbereich |
| `move_down` | S / Pfeil runter | In Richtung unterer Bildschirmbereich |
| `move_left` | A / Pfeil links | Nach links |
| `move_right` | D / Pfeil rechts | Nach rechts |

Die Belegung ist ein P0-Standard und soll später über die Einstellungen neu zuweisbar sein. Eine vollständige Rebinding-Oberfläche ist nicht Bestandteil von P0.

P0 enthält zunächst kein Sprinten, Springen, Schleichen oder Ausweichen. Diese Aktionen werden nicht vorsorglich in die Eingabestruktur aufgenommen.

## 5. Kamerabezogene Bewegungsrichtung

Die Eingabe wird relativ zur horizontal projizierten Ausrichtung der Gameplay-Kamera berechnet:

1. Horizontale Vorwärtsrichtung aus der Kamera-Basis ableiten.
2. Horizontale Rechtsrichtung aus der Kamera-Basis ableiten.
3. Eingabe-X mit Rechtsrichtung und invertiertes Eingabe-Y mit Vorwärtsrichtung kombinieren.
4. Ergebnis auf die XZ-Ebene projizieren.
5. Bewegungsvektor normalisieren.

Damit bedeutet „oben“ immer Bewegung in Richtung des oberen Bildschirmbereichs, auch wenn die Kamera später leicht anders ausgerichtet wird.

Die Kamera muss dafür nicht gedreht werden können. Die Berechnung hält die Steuerung lediglich unabhängig von einer fest codierten Weltachsenannahme.

Wenn die Kamera-Referenz fehlt oder ihre horizontale Richtungsbasis degeneriert, darf der Controller nicht abstürzen. In diesem Fall verwendet er eine definierte Weltachsen-Fallbackrichtung und gibt im Debug-Modus einen Hinweis aus.

## 6. Bewegungsverhalten

Das Bewegungsgefühl basiert auf drei getrennt abstimmbaren Eigenschaften:

- **Maximalgeschwindigkeit:** begrenzt die horizontale Laufgeschwindigkeit.
- **Beschleunigung:** bestimmt, wie schnell der Spieler die Zielgeschwindigkeit erreicht.
- **Bremsverhalten:** bestimmt, wie schnell der Spieler nach Loslassen der Eingabe stoppt.

Die Bewegung soll direkt reagieren, aber nicht abrupt und mechanisch wirken. Beim Loslassen wird aktiv abgebremst; der Spieler soll nicht unkontrolliert weitergleiten.

### Startwerte für den ersten Test

Die folgenden Werte sind ausschließlich Ausgangspunkte für den ersten Blockout-Test:

| Parameter | Startwert |
|---|---:|
| Laufgeschwindigkeit | 4,5 m/s |
| Beschleunigung | 18 m/s² |
| Bremsbeschleunigung | 22 m/s² |
| Drehgeschwindigkeit des Modells | 10 rad/s |

Diese Werte sind keine endgültigen Designentscheidungen. Sie werden anhand von Laufwegen, Interaktionsreichweite, Kameradistanz und subjektivem Steuerungsgefühl abgestimmt.

Die horizontale Geschwindigkeit wird pro Physikschritt zur Zielgeschwindigkeit hin angepasst. Diagonale Eingaben dürfen keine höhere Maximalgeschwindigkeit erzeugen als gerade Eingaben.

## 7. Physik und Kollision

- Root Node bleibt `CharacterBody3D`.
- Bewegung wird im Physik-Update verarbeitet.
- Horizontale Bewegung wird über `velocity` und `move_and_slide()` umgesetzt.
- Schwerkraft wird angewendet, solange der Körper nicht auf dem Boden steht.
- Der Spieler kann nicht durch einfache Hindernisse oder Wände laufen.
- Die Kollisionsform bleibt unabhängig vom visuellen Platzhaltermodell.
- P0 verwendet keine physikbasierte Schub- oder Impulssteuerung.
- Treppen, komplexe Rampen, dynamische Körper und bewegliche Plattformen sind keine P0-Anforderungen.

Die Testfläche soll zunächst eben sein. Kleine Höhenunterschiede und Rampen werden nur ergänzt, wenn sie zur Prüfung der grundlegenden Boden- und Kollisionsbehandlung benötigt werden.

## 8. Ausrichtung und Animation

- Bei aktiver Bewegung richtet sich `VisualRoot` weich in Bewegungsrichtung aus.
- Bei Stillstand bleibt die letzte gültige Blickrichtung erhalten.
- Die Drehung des Modells verändert weder Kollisionskörper noch Bewegungsrichtung.
- Ein Animationssystem ist in P0 nicht erforderlich.
- Ein Platzhaltermodell muss lediglich die Ausrichtung sichtbar machen.

Das Modell soll nicht bei jeder kleinen Richtungsänderung hart springen. Die Drehung wird zeitbasiert geglättet und darf nicht von der Bildrate abhängig sein.

## 9. Zusammenspiel mit Kamera und Interaktion

- PlayerController kennt die Gameplay-Kamera nur als Bewegungsreferenz.
- GameplayCameraController folgt dem Spieler, steuert aber nicht dessen Bewegung.
- PlayerInteractor liest die Spielerposition und verwaltet Interaktionsziele unabhängig.
- Der Controller löst keine Interaktion aus und verändert keine Objektzustände.
- Die Position des CharacterBody3D bleibt die maßgebliche Spielerposition.

Damit können Bewegung, Kamera und Interaktion einzeln getestet und später verändert werden.

## 10. Speicherung

Der PlayerController stellt die für P0 benötigten Bewegungsdaten bereit:

- Weltposition.
- Bei Bedarf die aktuelle horizontale Ausrichtung.

Die Speicherung erfolgt durch GameSession und SaveService. Der Controller schreibt keine Dateien und kennt das JSON-Speicherformat nicht.

Beim Laden wird die Position durch die Gameplay-Szene bzw. GameSession gesetzt. Danach wird die Physik initialisiert, bevor die normale Eingabeverarbeitung fortgesetzt wird. Ein gespeicherter Zustand darf den Spieler nicht in einer Wand oder außerhalb der Testfläche platzieren; für P0 genügt eine einfache Validierung gegen die Testfläche und eine sichere Startposition als Fallback.

## 11. Debug-Anzeige

Der optionale DebugOverlay kann während P0 anzeigen:

- Eingabevektor.
- Berechnete Welt-Bewegungsrichtung.
- Horizontale Geschwindigkeit.
- Bodenstatus.
- Aktuelle Spielerposition.
- Aktuelle Blickrichtung.

Die Anzeige ist nur für Entwicklung und Tests vorgesehen und wird im normalen Spiel standardmäßig nicht eingeblendet.

## 12. P0-Abnahmekriterien

- WASD und Pfeiltasten bewegen den Spieler erwartungsgemäß.
- Die Bewegungsrichtung ist relativ zur Kamera ausgerichtet.
- Diagonale Bewegung ist nicht schneller als gerade Bewegung.
- Loslassen der Eingabe führt zu einem kontrollierten Stopp.
- Richtungswechsel fühlen sich unmittelbar und nachvollziehbar an.
- Das Modell dreht sich weich in Bewegungsrichtung.
- Bei Stillstand bleibt die letzte Ausrichtung erhalten.
- Kollisionen verhindern das Durchlaufen einfacher Hindernisse.
- Bewegung bleibt bei unterschiedlichen Bildraten reproduzierbar.
- Fehlende Kamera-Referenz führt nicht zu einem Absturz.
- Die Spielerposition kann durch GameSession/SaveService gesichert und wiederhergestellt werden.

## 13. Bewusst offene Punkte

Nach dem ersten spielbaren Test werden abgestimmt:

- Laufgeschwindigkeit und Beschleunigung.
- Bremsgefühl und Drehgeschwindigkeit.
- Kollisionsform und Körperhöhe.
- Verhalten an kleinen Höhenunterschieden.
- Ob später Sprinten oder weitere Bewegungsaktionen sinnvoll sind.
- Ob eine Maus- oder Gamepad-Bewegungssteuerung zusätzlich benötigt wird.

Diese Punkte werden nicht vorab durch zusätzliche Systeme gelöst. P0 soll zuerst eine gute, einfache Grundbewegung beweisen.
