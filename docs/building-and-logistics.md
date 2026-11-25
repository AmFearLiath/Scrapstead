# Scrapstead — Bauen, Platzierung und Maschinenverbindungen

## Ziel und Leitgedanke

Scrapstead bietet dem Spieler weitgehende Freiheit bei der Gestaltung und Organisation seines Schrottplatzes. Es gibt keine fest zugewiesenen Bauplätze für einzelne Gebäude oder Maschinen.

**Grundsatz: Freies Bauen mit nachvollziehbaren funktionalen Einschränkungen.**

Der Spieler entscheidet, wo Gebäude, Maschinen, Lager, Wege, Zäune und Dekorationen platziert werden. Das Spiel prüft, ob die gewählte Anordnung baulich und funktional sinnvoll ist.

Die Komplexität soll aus den Möglichkeiten der Gestaltung entstehen, nicht aus komplizierter Bedienung oder verpflichtendem Logistik-Mikromanagement.

## 1. Grundstück und Baufläche

- Das Grundstück bildet die äußere Grenze der verfügbaren Baufläche.
- Neue Flächen können im Spielverlauf erworben oder freigeschaltet werden.
- Innerhalb des eigenen Grundstücks gibt es keine fest vorgeschriebenen Gebäude- oder Maschinenplätze.
- Die im Startgrundstück-Layout definierten Zonen sind Orientierungshilfen für Leveldesign und Entdeckungsdramaturgie, keine verbindlichen Bauzonen.
- Der Spieler darf diese Bereiche anders nutzen, umgestalten und mit eigenen Strukturen versehen.

## 2. Platzierung und Baufreiheit

Grundsätzlich frei platzierbar sind:

- Gebäude und Gebäudemodule
- Maschinen und Produktionsanlagen
- Lager und Materialablagen
- Wege und Transportstrecken
- Zäune, Beleuchtung und Dekoration
- Weitere funktionale Einrichtungen

Die Platzierung soll ein verständliches Raster und Drehungen unterstützen. Rastergröße, freie oder rastergebundene Platzierung und Kollisionsregeln werden im Prototyp getestet.

### Funktionale Platzierungsprüfungen

Eine Platzierung kann abhängig vom Objekt geprüft werden auf:

- ausreichende Grundfläche und geeigneten Untergrund
- Überschneidungen mit anderen Objekten
- benötigte Bedien- und Wartungsflächen
- Zugänglichkeit von Ein- und Ausgabepunkten
- Arbeitsradius und freie Arbeitsbereiche
- notwendige Abstände oder Sicherheitsbereiche
- Erreichbarkeit durch Spieler und Mitarbeiter

Nicht jedes Objekt benötigt jede Prüfung. Anforderungen müssen aus dem jeweiligen Objektprofil hervorgehen und für den Spieler sichtbar und verständlich sein.

## 3. Maschinenprofile und Anschlusspunkte

Maschinen können definierte funktionale Anschlusspunkte besitzen:

- **Eingang:** Hier nimmt die Maschine Material oder Vorprodukte entgegen.
- **Ausgang:** Hier gibt sie Produkte, Reststoffe oder sortierte Materialien ab.
- **Bedienpunkt:** Hier interagiert der Spieler oder ein Mitarbeiter mit der Maschine.
- **Arbeitsbereich:** Hier sammelt, verarbeitet oder bewegt die Maschine Objekte.

Nicht jede Maschine benötigt alle Anschlusspunkte. Eine selbstständig arbeitende Maschine kann beispielsweise nur einen Arbeitsbereich und einen Ablagepunkt benötigen.

Die Anschlusspunkte werden im Baumodus sichtbar, sobald der Spieler eine Maschine auswählt oder eine Verbindung erstellen möchte.

## 4. Einfache Maschinenverbindungen

Bestimmte Maschinen sollen in sinnvoller räumlicher Nähe zueinander stehen können, damit der Spieler einfache Versorgungs- und Transportwege einrichten kann.

Das Verbindungssystem soll intuitiv sein:

1. Der Spieler wählt den Ausgang einer Maschine.
2. Er zieht eine Verbindung zum Eingang einer anderen Maschine.
3. Das Spiel sucht automatisch eine geeignete Route.
4. Ist die Route frei und funktional möglich, wird die passende Transportstrecke erstellt.
5. Ist keine Route möglich, zeigt das Spiel den Grund und – soweit möglich – eine verständliche Alternative.

Die Routenführung soll möglichst automatisch erfolgen. Der Spieler muss keine einzelnen Segmente von Hand zusammensetzen oder Transportnetze technisch planen.

### Routenregeln

- Verbindungen nutzen ein einfaches Raster- oder Wegesystem.
- Das Spiel sucht einen freien, gültigen Verlauf zwischen Start und Ziel.
- Bestehende Gebäude, Maschinen und unpassierbare Hindernisse werden berücksichtigt.
- Die Route darf erforderliche Bedien-, Wartungs- und Bewegungsflächen nicht unbrauchbar machen.
- Eine blockierte Route wird nicht stillschweigend erstellt.
- Der Spieler kann Verbindungen entfernen oder neu anlegen.
- Bei späteren Änderungen an der Umgebung muss das Spiel erkennen, wenn eine bestehende Verbindung nicht mehr gültig ist, und eine verständliche Reparaturmöglichkeit anbieten.

Die genaue Routenfindung, Rasterauflösung und Darstellung werden technisch erst nach Auswahl und Test der Engine festgelegt.

## 5. Verbindungstypen

Nicht jede Materialbewegung muss über dieselbe Infrastruktur laufen. Für den Einstieg werden drei verständliche Möglichkeiten vorgesehen:

### Direkte Übergabe

Zwei Maschinen stehen nah genug beieinander, um Material direkt zu übergeben. Eine separate Transportstrecke ist nicht erforderlich.

### Automatische Transportstrecke

Der Spieler verbindet den Ausgang einer Maschine mit dem Eingang einer anderen. Das Spiel erstellt die passende Strecke automatisch.

Die optische Ausführung kann abhängig von Maschinen und Material variieren, beispielsweise Förderband, Rutsche, Rohr oder einfache Übergabestrecke. Diese Varianten müssen nicht sofort als unterschiedliche komplexe Logistiksysteme umgesetzt werden.

### Manueller Transport

Wenn keine Maschinenverbindung besteht, können Spieler oder Mitarbeiter Material weiterhin manuell transportieren. Eine fehlende Verbindung darf den Betrieb nicht grundsätzlich blockieren, sofern die Maschine auch manuell versorgt werden kann.

## 6. Funktionale Anforderungen statt willkürlicher Verbote

Beispiele für mögliche Anforderungen:

| Einrichtung | Funktionale Anforderungen |
|---|---|
| Magnet-Sammler | Freier Arbeitsradius und erreichbarer Ablagepunkt |
| Sortieranlage | Materialzufuhr und zugänglicher Ausgabebereich |
| Schredder | Materialzufuhr, Bedienfläche und Platz für Ausgabe |
| Schmelzofen | Materialzufuhr, Ausgabe und erforderlicher Sicherheitsabstand |
| Lager | Erreichbare Ein- und Ausgabepunkte |
| Werkstatt | Zugängliche Arbeits- und Bedienflächen |

Die Anforderungen sind beispielhaft und müssen für jede Maschine konkret definiert werden. Abstände, Reichweiten und Kapazitäten werden nicht pauschal festgelegt, sondern pro Objekt sinnvoll bestimmt und im Prototyp überprüft.

## 7. Feedback im Baumodus

Der Baumodus soll Probleme früh und verständlich sichtbar machen:

- Gültige Platzierung und gültige Verbindung werden visuell bestätigt.
- Ungültige Bereiche und blockierte Routen werden hervorgehoben.
- Der Spieler erhält einen konkreten Grund, beispielsweise „Ausgang blockiert“ oder „Bedienfläche nicht erreichbar“.
- Wo möglich, zeigt das Spiel direkt, welche Änderung das Problem lösen würde.
- Vorschau und tatsächliches Ergebnis müssen übereinstimmen.

Vermeide rein technische Fehlermeldungen und unnötige Bestätigungsdialoge.

## 8. Designgrenzen

Das Bausystem soll nicht zu einem komplexen Fabrik-Simulationswerkzeug werden.

Für den ersten Prototyp ausdrücklich nicht erforderlich:

- manuelles Verlegen hunderter einzelner Förderbandsegmente
- komplexe Verteilungslogik und Prioritätsregeln
- detaillierte elektrische Netze
- Rohrdruck, Durchfluss oder vergleichbare technische Simulationen
- verpflichtende Verkabelung jeder Maschine
- starre Bauplätze oder vorgeschriebene Produktionslayouts

Solche Systeme können später nur dann ergänzt werden, wenn sie einen klaren Spielwert bieten und die Bedienbarkeit nicht beeinträchtigen.

## 9. Prototyp-Prüfkriterien

Der erste Bausystem-Prototyp soll folgende Fälle abdecken:

1. Ein Gebäude und mehrere Maschinen können frei innerhalb der Grundstücksgrenzen platziert werden.
2. Der Spieler kann Objekte drehen und bei Bedarf neu positionieren.
3. Eine Maschine zeigt ihre funktionalen Bereiche und Anschlusspunkte.
4. Der Spieler kann zwei kompatible Maschinen durch eine einfache Aktion verbinden.
5. Das Spiel erstellt eine gültige Route automatisch, wenn ein freier Weg existiert.
6. Eine blockierte Route wird erkannt und verständlich erklärt.
7. Eine bestehende Verbindung kann entfernt und neu angelegt werden.
8. Maschinen können weiterhin manuell versorgt werden, sofern ihr Profil dies erlaubt.
9. Bedien- und Bewegungsflächen bleiben trotz freier Gestaltung sinnvoll nutzbar.

## 10. Offene Punkte

Folgende Details bleiben bewusst offen, bis ein Prototyp getestet wurde:

- Rastergröße und Platzierungsgenauigkeit
- Verhalten bei Überlappungen und knappen Abständen
- konkrete Anschlusspunkt- und Maschinenprofil-Daten
- Darstellung und Varianten der Transportstrecken
- Regeln für Kreuzungen und mehrere mögliche Routen
- Verhalten bei nachträglicher Blockierung einer Verbindung
- Zugänglichkeit durch Mitarbeiter und mögliche Fahrzeugtypen
- Engine-spezifische Umsetzung und Performance

## Zusammenfassung

Scrapstead setzt auf freie Grundstücksgestaltung statt fest zugewiesener Bauplätze. Funktionale Anforderungen sorgen dafür, dass Gebäude, Maschinen und Transportwege sinnvoll zusammenarbeiten. Maschinenverbindungen werden vom Spieler einfach angelegt; die passende Route erstellt das Spiel automatisch.

**Der Spieler plant den Betrieb. Das Spiel kümmert sich um die komplizierte Streckenführung.**
