# Scrapstead — Baumodus und Bauinteraktionen

## Ziel

Der Baumodus soll sich wie ein intuitives Werkzeug anfühlen. Der Spieler gestaltet seinen Betrieb frei und kann Gebäude, Maschinen, Lager, Wege, Transportstrecken und Dekorationen platzieren, verschieben und anpassen.

Die Bedienung soll wenige klare Aktionen bieten. Die funktionalen Regeln werden vom Spiel geprüft und verständlich visualisiert.

**Leitgedanke: Der Spieler entscheidet, was und wo gebaut wird. Scrapstead kümmert sich um Prüfung, Vorschau und automatische Umsetzung.**

## 1. Zentraler Baumodus

Der Baumodus bündelt die Bauaktionen in einer kompakten, jederzeit verständlichen Werkzeugleiste.

Vorgesehene Werkzeuge:

- **Platzieren:** Gebäude, Maschinen und Objekte aufstellen.
- **Verschieben:** Bestehende Objekte umpositionieren.
- **Drehen:** Objekte ausrichten.
- **Verbinden:** Maschinen und Transportwege miteinander verbinden.
- **Entfernen:** Objekte und Verbindungen entfernen.
- **Inspizieren:** Eigenschaften, Anforderungen und Funktionen anzeigen.

Die Werkzeuge sollen kontextabhängig reagieren. Es sind keine tief verschachtelten Untermenüs vorgesehen. Die konkrete Anordnung der Werkzeugleiste und die Frage, ob einzelne Werkzeuge zusammengefasst werden, werden im UI-Prototyp geprüft.

## 2. Platzieren

Ablauf:

1. Der Spieler wählt ein Objekt aus dem Baumenü.
2. Eine transparente Platzierungsvorschau folgt dem Mauszeiger.
3. Das Objekt kann vor der Platzierung gedreht und ausgerichtet werden.
4. Das Spiel prüft Position und funktionale Anforderungen.
5. Die Vorschau zeigt eindeutig, ob die Position gültig ist.
6. Der Spieler bestätigt die Platzierung oder bricht den Vorgang ab.

Die Vorschau kann abhängig vom Objekt folgende Informationen zeigen:

- Grundfläche und tatsächlichen Platzbedarf
- Kollisionsbereiche
- Bedien- und Wartungsflächen
- Arbeitsradius
- Ein- und Ausgabepunkte
- notwendige Abstände und sonstige Anforderungen

Die Vorschau soll nur die für das ausgewählte Objekt relevanten Informationen einblenden, damit der Bildschirm nicht mit Markierungen überladen wird.

### Platzierungsfeedback

- Gültige Positionen werden visuell bestätigt.
- Ungültige Bereiche und Kollisionen werden hervorgehoben.
- Die Ursache einer ungültigen Platzierung wird konkret benannt.
- Das Feedback darf nicht ausschließlich aus einer Farbe bestehen; Symbol oder kurze Textmeldung ergänzen die Darstellung.
- Vorschau und tatsächliches Platzierungsergebnis müssen übereinstimmen.

## 3. Verschieben und Drehen

Bestehende Objekte können neu positioniert und ausgerichtet werden.

- Objekte lassen sich auswählen und verschieben.
- Drehung erfolgt zunächst in festen Winkelschritten, beispielsweise 90 Grad.
- Für geeignete Dekorationen kann später eine feinere Drehung ergänzt werden.
- Raster-Snapping kann die Platzierung erleichtern und bei Bedarf umgangen werden.
- Vor dem Bestätigen werden Kollisionen und funktionale Anforderungen erneut geprüft.

### Bestehende Maschinenverbindungen

Das Verschieben einer verbundenen Maschine kann Transportstrecken ungültig machen.

- Betroffene Verbindungen werden bereits in der Vorschau markiert.
- Das Spiel prüft, ob eine neue gültige Route automatisch erstellt werden kann.
- Ist eine Neuberechnung möglich, wird das Ergebnis vor der Bestätigung gezeigt.
- Ist sie nicht möglich, muss klar erkennbar sein, welche Verbindung betroffen ist und was nach der Aktion nicht mehr funktioniert.
- Verbindungen dürfen nicht unbemerkt gelöscht oder verändert werden.

## 4. Maschinen verbinden

Für das Anlegen von Maschinenverbindungen gibt es ein eigenes Werkzeug.

Ablauf:

1. Der Spieler aktiviert **Verbinden**.
2. Maschinen zeigen ihre verfügbaren Ein- und Ausgabepunkte.
3. Der Spieler wählt einen kompatiblen Ausgang.
4. Danach wählt er den gewünschten Eingang einer Zielmaschine.
5. Das Spiel berechnet eine mögliche Route.
6. Die geplante Strecke wird als Vorschau dargestellt.
7. Der Spieler bestätigt oder bricht ab.

### Automatische Routenführung

Das Spiel übernimmt die Streckenplanung:

- Es sucht einen freien und gültigen Weg zwischen den gewählten Anschlusspunkten.
- Es berücksichtigt Gebäude, Maschinen, Hindernisse und notwendige Bewegungsflächen.
- Es vermeidet unnötige Umwege, soweit das ohne komplizierte Einstellungen möglich ist.
- Es kann geeignete vorhandene Wege oder Transportabschnitte berücksichtigen.
- Eine blockierte oder unmögliche Route wird nicht stillschweigend angelegt.
- Der Spieler erhält eine verständliche Rückmeldung und nach Möglichkeit einen Hinweis auf eine Alternative.

Die konkrete Routenfindung, Rasterauflösung und Priorisierung mehrerer möglicher Wege bleiben technische Prototypfragen.

### Einrasten (Snap)

Einrasten und Verbinden sind unterschiedliche Vorgänge:

- Eine Transportstrecke kann an geeigneten freien Strecken- oder Anschlusspunkten sauber einrasten.
- Das Einrasten richtet Segmente optisch und geometrisch passend aus.
- Ein Einrasten darf nicht ungefragt eine neue Maschinenverbindung oder Produktionskette aktivieren.
- Eine Maschinenverbindung entsteht nur durch eine bewusste Aktion des Spielers.

Diese Trennung verhindert versehentliche Änderungen an der Produktionsstruktur.

## 5. Baumenü und Objektinformationen

Das Baumenü soll übersichtlich bleiben und keine unstrukturierte Gesamtliste aller verfügbaren Objekte darstellen.

Vorgesehene Kategorien:

- Gebäude
- Maschinen
- Lager und Ablagen
- Transport und Verbindungen
- Wege und Gelände
- Zäune und Begrenzungen
- Dekoration

Eine Objektansicht zeigt kompakt:

- Name und visuelle Vorschau
- Kaufpreis oder sonstige Baukosten
- Platzbedarf
- Funktion und kurze Beschreibung
- benötigte Anschlüsse
- besondere Platzierungs- oder Betriebsanforderungen
- Freischaltbedingung, falls noch nicht verfügbar

Gesperrte Objekte können sichtbar sein, müssen aber eindeutig erklären, wodurch sie freigeschaltet werden. Die Darstellung darf den Spieler nicht mit Informationen überladen.

## 6. Vorgeschlagene PC-Bedienung

Die folgenden Eingaben sind ein erster Vorschlag für den Prototyp, keine endgültige Tastenbelegung.

| Eingabe | Vorgeschlagene Aktion |
|---|---|
| Linksklick | Auswählen oder Platzieren bestätigen |
| Rechtsklick | Aktuellen Vorgang abbrechen oder Auswahl aufheben |
| Mausrad | Ausgewähltes Objekt drehen |
| R | Objekt drehen |
| Shift | Feinere Rasterbewegung |
| Strg | Raster-Snapping umschalten |
| Escape | Aktuellen Vorgang abbrechen |
| Delete | Ausgewähltes Objekt entfernen |

Alle wichtigen Aktionen müssen später anpassbar sein. Die Bedienung soll auch ohne das Auswendiglernen vieler Tastenkombinationen verständlich bleiben.

## 7. Ungültige Aktionen und verständliche Rückmeldungen

Beispiele:

| Situation | Erwartete Rückmeldung |
|---|---|
| Maschine kollidiert mit Gebäude | Platzierung verhindern und Kollisionsbereich markieren |
| Bedienfläche ist blockiert | Benötigten Freiraum anzeigen |
| Ausgang ist nicht kompatibel | Verbindung verhindern und Kompatibilitätsproblem erklären |
| Transportweg ist blockiert | Hindernis und mögliche Alternativroute zeigen |
| Verbundene Maschine wird verschoben | Betroffene Verbindungen in der Vorschau markieren |
| Bestehende Verbindung wird ungültig | Betroffene Maschinen und Transportproblem anzeigen |

Fehlermeldungen sollen aus Spielersicht formuliert sein. Statt technischer Meldungen wie „Invalid node path“ wird erklärt, was konkret nicht funktioniert und welche Handlung helfen könnte.

## 8. Rückgängig und Wiederholen

Bauaktionen sollen möglichst sicher ausprobiert werden können.

Vorgesehen sind:

- **Rückgängig:** Die letzte unterstützte Bauaktion wird zurückgenommen.
- **Wiederholen:** Eine rückgängig gemachte Aktion wird wiederhergestellt.

Zu den unterstützten Aktionen sollen gehören:

- Platzieren
- Verschieben
- Drehen
- Entfernen
- Maschinenverbindungen anlegen oder entfernen

Außerdem soll der Spieler mehrere gleiche Objekte nacheinander platzieren können, ohne jedes Mal erneut das Baumenü öffnen zu müssen.

Die genaue Historienlänge und technische Umsetzung werden später festgelegt. Wichtig ist, dass die Funktion auch bei verbundenen Maschinen keine inkonsistenten Zustände erzeugt.

## 9. Prototyp-Prüfkriterien

Der erste Bedienungsprototyp soll zeigen, dass:

1. der Baumodus schnell erreichbar und leicht verständlich ist;
2. Objekte mit transparenter Vorschau frei platziert werden können;
3. Platzierungsanforderungen bereits vor der Bestätigung sichtbar sind;
4. Objekte gedreht, verschoben und entfernt werden können;
5. kompatible Maschinen über ihre Anschlusspunkte verbunden werden können;
6. eine mögliche Transportroute automatisch berechnet und vor der Bestätigung angezeigt wird;
7. Einrasten keine unbeabsichtigten Maschinenverbindungen erzeugt;
8. ungültige Aktionen verständlich erklärt werden;
9. betroffene Verbindungen beim Verschieben einer Maschine erkennbar bleiben;
10. Rückgängig und Wiederholen keine fehlerhaften Maschinen- oder Transportzustände hinterlassen;
11. mehrere gleiche Objekte nacheinander platziert werden können.

## 10. Offene Entscheidungen

Folgende Punkte bleiben bis zu UI- und Gameplay-Tests offen:

- endgültige Form und Position der Werkzeugleiste
- Rastergröße und Verhalten bei freier Platzierung
- Drehschritte und Feinrotation
- endgültige PC-Tastenbelegung
- konkrete Darstellung von Arbeits-, Bedien- und Wartungsflächen
- Routenpriorisierung und Verhalten bei mehreren möglichen Wegen
- genaue Regeln für Einrasten und Segmentverbindungen
- Umfang und Grenzen der Rückgängig-Historie
- Verhalten bei Änderungen an bereits genutzten Transportstrecken

## Zusammenfassung

Der Baumodus bietet eine zentrale, kompakte Werkzeugleiste und eine klare Platzierungsvorschau. Maschinen werden bewusst über ihre Anschlusspunkte verbunden; Scrapstead berechnet die passende Transportstrecke automatisch. Einrasten hilft bei der sauberen Ausrichtung, erzeugt aber keine ungefragten Produktionsverbindungen.

**Freies Gestalten, verständliches Feedback und möglichst wenig Bedienaufwand stehen im Mittelpunkt.**
