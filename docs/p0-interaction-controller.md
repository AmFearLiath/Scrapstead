# Scrapstead — P0-Spezifikation: PlayerInteractor / InteractionController

**Version:** 0.1  
**Status:** Technischer Bauplan für P0; Reichweiten und Auswahlgewichtung werden im Blockout abgestimmt  
**Engine:** Godot 4.7.2 Stable / GDScript

---

## 1. Ziel

Der PlayerInteractor erkennt gültige Interaktionsziele in der Nähe des Spielers, wählt ein eindeutiges aktives Ziel aus, stellt dessen Verfügbarkeit sichtbar dar und löst die passende Aktion aus.

Die Interaktion soll ohne pixelgenaues Anvisieren funktionieren. Der Spieler bewegt sich durch die isometrische Welt und erhält verständliches Feedback darüber, welches Objekt er gerade erreichen und verwenden kann.

Diese Spezifikation konkretisiert ausschließlich das P0-Interaktionssystem. Sie führt weder Inventar, Wirtschaft, Questlogik noch den vollständigen Baumodus ein.

## 2. Benennung und Verantwortlichkeit

In der bestehenden Szenenarchitektur heißt die Komponente `PlayerInteractor`. Dieser Name bleibt bestehen.

**PlayerInteractor ist die P0-Interaktionssteuerung.** Es wird keine zusätzliche parallele Klasse `InteractionController` eingeführt.

Der PlayerInteractor übernimmt:

- Erkennen möglicher Interaktionsziele über den InteractionDetector.
- Prüfen, ob ein Ziel gültig und aktuell verfügbar ist.
- Bewerten und Auswählen eines aktiven Ziels.
- Verwalten des aktuell hervorgehobenen Ziels.
- Anzeigen bzw. Aktualisieren des passenden Interaktionshinweises.
- Entgegennehmen der Interaktionseingabe.
- Aufrufen der Aktion am Zielobjekt.
- Reagieren auf Erfolg, Ablehnung oder ungültig gewordene Ziele.

Nicht seine Aufgabe:

- Bewegung oder Drehung des Spielers.
- Kamerabewegung, Zoom oder Zielausrichtung.
- Inventarverwaltung oder Tragekapazität.
- Verkauf, Verarbeitung oder Wirtschaft.
- Quest- und Fortschrittsregeln.
- Speichern und Laden auf Dateiebene.
- Allgemeine UI-Verwaltung außerhalb der Interaktionsrückmeldung.

Das Zielobjekt bleibt für seine konkrete Aktion und die fachlichen Voraussetzungen verantwortlich. Der PlayerInteractor entscheidet, welches Ziel angesprochen wird – nicht, wie dessen Gameplay-Aktion intern funktioniert.

## 3. Szenenstruktur

Die bestehende Player-Szene wird verwendet:

```text
Player (CharacterBody3D)
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── PlaceholderModel
├── InteractionDetector (Area3D)
│   └── CollisionShape3D
└── PlayerInteractor (Node)
```

### InteractionDetector

- `Area3D` erkennt Körper bzw. Bereiche potenzieller Interaktionsziele.
- Die CollisionShape3D definiert den zunächst kreisförmigen bzw. kugelförmigen Erkennungsbereich.
- Der Detector sammelt Kandidaten, führt aber keine Auswahlentscheidung und keine Interaktion aus.
- Kollisionslayer und -masken werden so begrenzt, dass nur relevante Interaktionsobjekte erfasst werden.

### PlayerInteractor

- Liegt als Node unter dem Player.
- Erhält eine Referenz auf den InteractionDetector.
- Erhält bei Bedarf Referenzen auf den Interaktionshinweis und das Spieler-Visual.
- Verwaltet Kandidaten, aktuelles Ziel und den Interaktionsablauf.
- Ist unabhängig von konkreten Testobjekt-Szenen.

Die Darstellung eines Ziels und die Interaktionslogik bleiben getrennt.

## 4. Erkennung möglicher Ziele

Ein Objekt wird nur dann Kandidat, wenn es:

- sich innerhalb des InteractionDetector-Bereichs befindet,
- als interaktionsfähig gekennzeichnet ist,
- aktuell gültig und in der Szene verfügbar ist,
- nicht ausdrücklich deaktiviert oder bereits verbraucht wurde,
- die jeweilige Aktion grundsätzlich anbieten kann.

Die technische Erkennung erfolgt über eine klar definierte Interaktionsschnittstelle bzw. einen gemeinsamen Basistyp. Konkrete Zielobjekte stellen darüber ihre verfügbaren Aktionen und ihren aktuellen Zustand bereit.

P0 benötigt dafür keine umfangreiche generische Interaktions-Framework-Architektur. Eine kleine, eindeutige Schnittstelle reicht aus.

Ein Kandidat kann während des Spiels ungültig werden, beispielsweise weil er entfernt, aufgenommen oder deaktiviert wurde. Der PlayerInteractor muss solche Änderungen erkennen und den Kandidaten aus der Auswahl entfernen.

## 5. Zielauswahl

Der PlayerInteractor hält höchstens ein aktives Interaktionsziel gleichzeitig.

Die Auswahl erfolgt in mehreren Schritten:

1. Ungültige und nicht verfügbare Kandidaten entfernen.
2. Kandidaten außerhalb der zulässigen Reichweite ausschließen.
3. Die verbleibenden Ziele anhand ihrer Distanz zum Spieler bewerten.
4. Bei annähernd gleicher Distanz die Blickrichtung des Spielers als sekundäres Kriterium berücksichtigen.
5. Bei weiterhin gleichwertigen Kandidaten eine stabile, reproduzierbare Entscheidung treffen.

**Grundregel:** Nähe ist das primäre Auswahlkriterium. Die Blickrichtung hilft bei der Auflösung knapper Fälle, darf aber ein deutlich näher gelegenes Ziel nicht überraschend verdrängen.

Die Auswahl darf nicht bei jeder kleinen Positionsänderung zwischen zwei fast gleichwertigen Objekten flackern. Dafür wird eine kleine Auswahlstabilität vorgesehen: Das bisherige Ziel darf bei nahezu gleichem Bewertungswert bevorzugt bleiben, solange es weiterhin gültig und erreichbar ist.

Die konkrete Gewichtung und eventuelle Hysterese werden im Blockout abgestimmt.

### Kein pixelgenaues Maus-Targeting in P0

- Ein Objekt muss nicht exakt mit dem Mauszeiger getroffen werden.
- Die Auswahl erfolgt über den Spielerbereich und die festgelegten Bewertungskriterien.
- Ein Mauszeiger darf in P0 nicht unbemerkt ein anderes Ziel als das hervorgehobene Ziel auslösen.

Ein optionales Maus-Targeting kann später geprüft werden, wenn das Spielgefühl oder der Baumodus es erfordert. Es ist keine P0-Voraussetzung.

## 6. Reichweite und Erreichbarkeit

Die Reichweite wird über den InteractionDetector und eine zusätzliche Prüfung des tatsächlichen Abstands abgesichert.

- Die Reichweite wird zunächst als Testparameter geführt.
- Der Abstand wird anhand eines definierten Interaktionspunkts bzw. einer geeigneten Objektposition geprüft.
- Große Objekte dürfen nicht allein deshalb unbenutzbar sein, weil ihr Ursprung weit von der Spielerposition entfernt liegt. Für solche Objekte muss später ein geeigneter Interaktionspunkt oder eine Interaktionsfläche definiert werden.
- P0-Testobjekte dürfen zunächst einen einfachen zentralen Interaktionspunkt verwenden.
- Ein Ziel außerhalb der Reichweite verliert seine aktive Auswahl und Hervorhebung.

Sichtlinien- bzw. Sichtblockierungsprüfungen werden nicht automatisch als Pflicht eingeführt. Im ersten Blockout wird geprüft, ob eine einfache Distanz- und Kandidatenlogik zuverlässig funktioniert. Wenn Wände oder massive Hindernisse zu offensichtlich falschen Interaktionen führen, wird eine gezielte Sichtlinienprüfung ergänzt.

## 7. Hervorhebung des aktiven Ziels

Das aktuell ausgewählte Ziel wird sichtbar hervorgehoben.

Die Hervorhebung soll:

- aus der isometrischen Kameraperspektive erkennbar sein,
- das Ziel eindeutig markieren,
- dessen Material und ursprüngliche Darstellung nicht dauerhaft verändern,
- beim Zielwechsel sauber entfernt und am neuen Ziel gesetzt werden,
- beim Verlust oder Entfernen des Ziels zuverlässig zurückgesetzt werden.

Für P0 genügt eine einfache, gut lesbare Hervorhebung. Möglich sind beispielsweise eine Kontur, ein dezenter Emissions-/Farbakzent oder eine einfache Markierung am Objekt.

Die konkrete Darstellungsart wird im Blockout ausgewählt. Aufwendige Shader, Outline-Systeme oder komplexe Materialvarianten sind keine Voraussetzung.

Die Hervorhebung ist rein visuelles Feedback. Sie verändert weder den Gameplay-Zustand noch die Verfügbarkeit eines Objekts.

## 8. Interaktionshinweis und Eingabe

Wenn ein gültiges Ziel ausgewählt ist, zeigt das HUD einen kompakten Interaktionshinweis.

Der Hinweis enthält mindestens:

- verständlichen Namen bzw. Bezeichner des Ziels,
- verfügbare Hauptaktion,
- zugehörige Eingabe.

P0 verwendet eine zentrale Eingabeaktion:

| Action | Standardbelegung | Funktion |
|---|---|---|
| `interact` | E | Hauptaktion des aktuell ausgewählten Ziels ausführen |

Die Aktion wird über Godots Input Map abgefragt. Die konkrete Belegung ist später änderbar.

Für P0 gilt:
- Pickup-Testobjekt bietet als Hauptaktion **Aufheben**.
- Inspect-Testobjekt bietet als Hauptaktion **Untersuchen**.
- Use-Testobjekt bietet als Hauptaktion **Benutzen**.

Damit prüft P0 drei unterschiedliche Interaktionsarten, ohne bereits ein vollständiges Kontextmenü oder mehrere Aktionsslots zu benötigen.

Ein Ziel darf seine Aktion ablehnen, wenn Voraussetzungen nicht erfüllt sind. Der Spieler erhält dann eine verständliche Rückmeldung. Fehlgeschlagene Aktionen dürfen weder den Objektzustand noch den Spielstand ungewollt verändern.

## 9. Interaktionsablauf

Der Ablauf einer Interaktion ist:

1. InteractionDetector erkennt mögliche Kandidaten.
2. PlayerInteractor prüft Gültigkeit und Verfügbarkeit.
3. PlayerInteractor wählt das aktive Ziel.
4. Die Hervorhebung wird aktualisiert.
5. Das HUD zeigt Name, Aktion und Eingabe.
6. Spieler drückt die Interaktionstaste.
7. PlayerInteractor prüft unmittelbar vor Ausführung erneut, ob das Ziel gültig und erreichbar ist.
8. Die Zielaktion wird aufgerufen.
9. Das Zielobjekt meldet Erfolg oder Ablehnung und aktualisiert bei Erfolg seinen eigenen Zustand.
10. PlayerInteractor aktualisiert Auswahl, Hervorhebung und Hinweis anhand des neuen Zustands.

Die Interaktion darf nicht allein auf einem zuvor ausgewählten Ziel basieren. Vor der Ausführung ist eine erneute Gültigkeitsprüfung erforderlich, damit veraltete Referenzen keine Aktion auslösen.

## 10. P0-Testaktionen

### Pickup

- Das Testobjekt ist zunächst verfügbar.
- Die Aktion markiert das Objekt als aufgenommen bzw. nicht mehr als verfügbares Weltziel.
- Das Objekt wird aus der aktiven Interaktionsauswahl entfernt.
- Ein vollständiges Inventar oder eine Tragekapazität wird nicht implementiert.

### Inspect

- Das Testobjekt zeigt eine kurze, vorbereitete Information.
- Der Weltzustand bleibt unverändert.
- Der Spieler kann die Information wieder schließen bzw. verlassen.
- Es wird kein allgemeines Journal- oder Wissenssystem eingeführt.

### Use

- Das Testobjekt führt eine klar definierte, sichtbare Testaktion aus.
- Der Objektzustand wird bei Bedarf aktualisiert.
- Die Aktion ist wiederholbar oder einmalig, je nach Testdefinition.
- Es wird kein generisches Geräte-, Maschinen- oder Quest-System vorweggenommen.

## 11. Zusammenspiel mit anderen Systemen

### PlayerController
- PlayerController verantwortet Bewegung und visuelle Ausrichtung.
- PlayerInteractor liest Position und Blickrichtung des Spielers.
- PlayerInteractor verändert weder Bewegungsvektor noch Drehung.

### GameplayCameraController
- Die Kamera folgt dem Spieler unabhängig von Interaktionszielen.
- Die Kameraausrichtung wird nicht durch die Zielauswahl verändert.
- Die Kamera dient nicht als Maus-Picking-System.

### HUD
- HUD zeigt nur das vom PlayerInteractor bereitgestellte Ziel und dessen Aktion.
- UI entscheidet nicht selbst, welches Ziel ausgewählt ist.
- Versteckte oder nicht verfügbare Ziele werden nicht als aktive Interaktionsoption dargestellt.

### GameSession und SaveService
- PlayerInteractor speichert nicht selbst.
- Relevante Zustandsänderungen werden an den zuständigen Spielzustand übergeben.
- P0-Testzustände werden anhand stabiler Objekt-IDs gespeichert.
- Die konkrete Aktion bleibt von der Dateispeicherung getrennt.

## 12. Debug-Informationen

Das DebugOverlay kann optional anzeigen:

- Anzahl erkannter Kandidaten.
- Aktuelle Ziel-ID und Zielname.
- Distanz zum aktiven Ziel.
- Auswahlbewertung bzw. Auswahlgrund.
- Grund, warum ein Kandidat ausgeschlossen wurde.
- Zustand der Interaktionsaktion.
- Status der Zielreferenz.

Diese Informationen sind Diagnosewerte und keine reguläre HUD-Anzeige.

## 13. Fehler- und Randfälle

- Kein Kandidat in Reichweite: keine Hervorhebung und kein Interaktionshinweis.
- Ziel wird entfernt: Auswahl und Hervorhebung sofort zurücksetzen.
- Ziel wird deaktiviert oder bereits aufgenommen: aus der Auswahl entfernen.
- Ziel verlässt die Reichweite: Auswahl kontrolliert wechseln oder leeren.
- Mehrere gleichwertige Ziele: stabile Auswahl ohne sichtbares Flackern.
- Ziel wird zwischen Anzeige und Tastendruck ungültig: Aktion nicht ausführen und Hinweis aktualisieren.
- Ziel lehnt Aktion ab: verständliches Feedback, kein ungewollter Zustandswechsel.
- Fehlende HUD-Referenz: Interaktionslogik darf nicht abstürzen; Hinweis im Debug-Modus.
- Fehlende oder ungültige Ziel-Schnittstelle: Kandidat ignorieren und Diagnosehinweis ausgeben.

## 14. P0-Abnahmekriterien

- Interaktionsziele werden im definierten Nahbereich zuverlässig erkannt.
- Nicht interaktionsfähige Objekte werden ignoriert.
- Es ist immer höchstens ein Ziel aktiv hervorgehoben.
- Das nächstgelegene geeignete Ziel wird nachvollziehbar ausgewählt.
- Die Blickrichtung löst knappe Auswahlfälle sinnvoll auf.
- Die Zielauswahl flackert nicht bei kleinen Bewegungen.
- Der Spieler erkennt eindeutig, welches Objekt gerade ausgewählt ist.
- Das HUD zeigt die richtige Aktion und Eingabe.
- E führt die passende Aktion des aktiven Ziels aus.
- Pickup, Inspect und Use verhalten sich unterschiedlich und korrekt.
- Ein aufgenommenes oder deaktiviertes Objekt kann nicht erneut interagiert werden.
- Ungültige Ziele lösen keine Aktionen aus.
- PlayerController und GameplayCameraController bleiben unabhängig.
- Interaktionszustände können über GameSession und SaveService gesichert werden, ohne Nodes zu serialisieren.

## 15. Bewusst offene Punkte

Im P0-Blockout werden geprüft und abgestimmt:

- Exakte Erkennungs- und Interaktionsreichweite.
- Form und Höhe des InteractionDetector-Bereichs.
- Distanzmessung und Interaktionspunkt großer Objekte.
- Gewichtung der Blickrichtung bei der Zielauswahl.
- Stärke der Auswahlstabilität / Hysterese.
- Art und Intensität der Hervorhebung.
- Gestaltung und Position des Interaktionshinweises.
- Ob eine gezielte Sichtlinienprüfung nötig ist.
- Ob Maus-Targeting für spätere Systeme einen echten Mehrwert bietet.

Diese Parameter werden mit kleinen Fundstücken, einem großen Schrottobjekt und einem benutzbaren Objekt im Old-Yard-Blockout getestet.

---

**Scope-Hinweis:** P0 validiert ausschließlich Erkennung, Auswahl, Hervorhebung, Hinweis und drei einfache Interaktionsaktionen. Kontextmenüs mit mehreren Aktionen, Inventar, Werkzeuge, Zerlegung, Bauinteraktionen und komplexe Interaktionsketten bleiben späteren Entwicklungsstufen vorbehalten.
