# Scrapstead — P0-Gameplay-Blockout

**Version:** 0.1  
**Status:** Räumlicher Testplan für P0; Positionen und Maße sind im Prototyp zu validieren  
**Engine:** Godot 4.7.2 Stable / GDScript  
**Grundlage:** `starting-yard-blockout.md`, `starting-yard-layout-discovery.md` und die drei P0-Steuerungsspezifikationen

---

## 1. Ziel

Der P0-Gameplay-Blockout verbindet PlayerController, GameplayCameraController und PlayerInteractor in einer gemeinsamen, reproduzierbaren Testumgebung.

Er verwendet den Old Yard als räumliche Grundlage. Es wird keine zweite, unabhängige Testarena entworfen.

Der Blockout soll beantworten:

- Funktioniert die Spielerbewegung in der vorgesehenen isometrischen Perspektive?
- Sind Beschleunigung, Bremsen und visuelle Ausrichtung kontrollierbar?
- Folgt die Kamera ruhig und bietet der Zoom sinnvolle Nähe und Übersicht?
- Bleiben Spieler und Interaktionsobjekte bei kleinen und großen Umgebungsobjekten lesbar?
- Erkennt und wählt das Interaktionssystem die richtigen Ziele?
- Sind Hervorhebung und Interaktionshinweis eindeutig?
- Funktionieren Pickup, Inspect und Use zuverlässig?
- Sind Wege, Engstellen und Hindernisse für die weitere Entwicklung geeignet?

P0 ist ein technischer und spielerischer Nachweis. Es ist noch kein fertiges Startgebiet und kein Content- oder Grafikproduktionsschritt.

## 2. Räumliche Grundlage

Der bestehende Grundstücksentwurf wird als Ausgangspunkt übernommen:

| Eigenschaft | P0-Ausgangspunkt |
|---|---:|
| Grundstücksbreite | 48 m |
| Grundstückstiefe | 36 m |
| Gesamtfläche | 1.728 m² |
| Blockout-Raster | 1 × 1 m |
| Weltmaßstab | 1 Layout-Meter = 1 Weltmeter |
| Koordinatenursprung | Südwestliche Grundstücksecke |
| X-Achse | West nach Ost |
| Z-Achse | Süd nach Nord |
| Y-Achse | Höhe |

Die fünf bestehenden Funktionszonen bleiben als Orientierung erhalten:

| Zone | Bereich | P0-Nutzung |
|---|---|---|
| E – Einfahrt und Verkauf | X 2–16 / Z 1–11 | Startbereich und erste Interaktion |
| C – Büro und Werkstatt | X 3–17 / Z 13–23 | Gebäudevolumen und Sichtblockade |
| A – Alte Lagerzone | X 2–17 / Z 25–34 | Hindernisse und alternative Laufwege |
| D – Freie Arbeitsfläche | X 22–44 / Z 6–19 | Bewegungsfläche und Übersichtstest |
| B – Verwilderter Schrotthof | X 23–46 / Z 21–34 | große Objekte und Sichtbarkeitstest |

Die Zonen sind Funktionsbereiche und keine abgeschlossenen Räume. Der Spieler darf sich frei zwischen ihnen bewegen.

## 3. Testszene und Geometrie

Die P0-Szene enthält nur Geometrie, die einen konkreten Testzweck erfüllt.

### 3.1 Grundfläche und Grenzen

- Eine ebene Bodenfläche als Startpunkt.
- Grundstücksgrenzen als einfache, gut sichtbare Blockout-Elemente.
- Ein Tor bzw. eine erkennbare Öffnung im südlichen Bereich.
- Keine dekorativen Details, Vegetation oder finalen Bodenmaterialien.
- Die Grenzen sollen den vorgesehenen Spielbereich zeigen, ohne die Kamera unnötig zu verdecken.

### 3.2 Wege

Die vorhandenen Wegvorschläge dienen als Startwerte:

| Wegtyp | Blockout-Breite |
|---|---:|
| Hauptweg | 3,0 m |
| Nebenweg | 2,0 m |
| Stationszugang | 1,5–2,0 m |
| Engstelle | möglichst mindestens 1,5 m |

Der Hauptweg verbindet Einfahrt/Verkauf, Werkstatt und freie Arbeitsfläche. Die Nebenwege ermöglichen Zugang zur Lagerzone und zum Schrotthof.

Die Wege werden zunächst als freie Bodenbereiche erkennbar gemacht. Es ist nicht notwendig, sie bereits als finale Straßen- oder Bodenassets umzusetzen.

### 3.3 Gebäude- und Hindernisvolumen

Für Sicht-, Bewegungs- und Kameratests werden einfache Volumen verwendet:

| Blockout-Element | Ausgangsmaß | Testzweck |
|---|---:|---|
| Büro-/Werkstattblock | ca. 9 × 6 m | große Sichtblockade und Umgehung |
| kleiner Schrotthaufen | ca. 3 × 3 m | Sicht- und Kollisionsprüfung |
| großer Schrotthaufen | ca. 5 × 4 m | Verdeckung und Kameralesbarkeit |
| Wandsegment | ca. 4 m Länge | Kollision und Sichtlinie |
| einzelne Pfosten/Träger | einfache Querschnitte | enge Bewegungsräume |
| Verkaufs-/Annahmeblock | ca. 5 × 4 m | Orientierung und Interaktionsumgebung |

Die Volumen dürfen einfache Boxen, Zylinder oder andere primitive Formen sein. Ihre Silhouette und Kollisionsfläche sind wichtiger als ihre Optik.

## 4. Startposition und Testaufbau

### 4.1 Spielerstart

Vorgeschlagene Startposition:

- Bereich E, nahe der südlichen Einfahrt.
- Ausgangspunkt ungefähr bei X = 8 m, Z = 3 m.
- Blickrichtung ungefähr nach Norden.
- Kamera wird vor dem ersten sichtbaren Frame auf den Spieler ausgerichtet.
- Der erste kleine Interaktionsgegenstand befindet sich in kurzer, gut sichtbarer Laufdistanz.

Die genaue Position wird nach dem ersten Kameratest angepasst.

### 4.2 P0-Testobjekte

Es werden genau drei funktionale Interaktionsobjekte benötigt:

| Testobjekt | Vorgeschlagener Bereich | Aktion | Erwartetes Ergebnis |
|---|---|---|---|
| PickupTestObject | nahe Startposition in E | Pickup | Objekt verschwindet aus der verfügbaren Weltinteraktion |
| InspectTestObject | im erreichbaren Randbereich von E | Inspect | vorbereitete Information wird angezeigt |
| UseTestObject | an einem klar erkennbaren Platz in E oder am Rand von D | Use | sichtbarer Testzustand ändert sich |

Die Objekte erhalten stabile Test-IDs. Ihre Positionen sind Vorschläge, keine finalen Weltkoordinaten.

Es werden keine zusätzlichen funktionalen Interaktionsarten eingeführt. Dekorative Testgeometrie darf vorhanden sein, muss aber vom InteractionDetector ignoriert werden.

### 4.3 Große Testobjekte

Zusätzlich zu den drei Interaktionsobjekten werden nicht-interaktive Großobjekte verwendet:

- Ein großer Schrotthaufen in Zone B.
- Ein einfacher Gebäudeblock in Zone C.
- Ein freistehender großer Gegenstand als Silhouetten- und Sichttest.

Diese Objekte prüfen Kameralesbarkeit, Sichtblockaden, Umgehung und Kollision. Sie müssen nicht interaktiv sein.

## 5. Zusammenspiel der drei P0-Systeme

### 5.1 PlayerController

Prüfpunkte:
- WASD und Pfeiltasten.
- Bewegung relativ zur Kamera.
- Normale und diagonale Bewegung.
- Beschleunigen, Abbremsen und Richtungswechsel.
- Weiche visuelle Ausrichtung.
- Kollision mit Wand, Gebäudeblock und Schrotthaufen.

### 5.2 GameplayCameraController

Prüfpunkte:
- Orthografische isometrische Perspektive.
- Korrekte Startausrichtung ohne sichtbaren Sprung.
- Ruhiges Folgen beim Gehen und bei Richtungswechseln.
- Stillstand ohne unnötige Kamerabewegung.
- Zoom nahe und weit.
- Spieler und Interaktionsobjekte bleiben im normalen Arbeitsbereich erkennbar.
- Große Volumen verdecken nicht dauerhaft die für den Test notwendigen Ziele.

### 5.3 PlayerInteractor

Prüfpunkte:
- Erkennung der drei Testobjekte.
- Ignorieren nicht-interaktiver Volumen.
- Auswahl des nächstgelegenen geeigneten Ziels.
- Blickrichtung als sekundäres Auswahlkriterium.
- Stabile Auswahl bei mehreren nahen Kandidaten.
- Eindeutige Hervorhebung.
- Korrekte Aktion und Rückmeldung über E.
- Entfernen eines aufgenommenen oder deaktivierten Ziels aus der Auswahl.

## 6. Konkrete Testabläufe

### Test A — Erststart und Orientierung

1. Neues Spiel aus dem Hauptmenü starten.
2. Prüfen, ob Spieler und Kamera korrekt positioniert sind.
3. Sichtbarkeit von Einfahrt, Verkaufsbereich und erstem Testobjekt prüfen.
4. In alle vier Richtungen bewegen.
5. Prüfen, ob die Steuerungsrichtungen dem Bildschirmgefühl entsprechen.

**Erfolg:** Spieler kann sich ohne Erklärung orientieren und die erste Interaktion erreichen.

### Test B — Bewegung und Kollision

1. Gerade Strecken in vier Richtungen laufen.
2. Diagonal laufen und Geschwindigkeit vergleichen.
3. Eingabe loslassen und Bremsverhalten prüfen.
4. Richtungswechsel ausführen.
5. Gegen Wand, Gebäudevolumen und Schrotthaufen laufen.
6. Engstellen und Nebenwege passieren.

**Erfolg:** Bewegung fühlt sich kontrolliert an, diagonale Eingaben sind nicht schneller und Hindernisse blockieren nachvollziehbar.

### Test C — Kamera und Zoom

1. Spieler über den Hauptweg bewegen.
2. Mehrere Richtungswechsel ausführen.
3. Stillstehen und Kameraruhe prüfen.
4. Zoom-Minimum und Zoom-Maximum erreichen.
5. Zwischen Nah- und Fernansicht wechseln.
6. Spieler in Nähe des Werkstattblocks und des großen Schrotthaufens beobachten.

**Erfolg:** Kamera folgt ruhig, Zoom bleibt begrenzt und die Perspektive bietet sowohl Arbeitsnähe als auch ausreichende Übersicht.

### Test D — Interaktion und Zielauswahl

1. PickupTestObject betreten.
2. Hervorhebung und HUD-Hinweis prüfen.
3. E drücken und Aufnahme bestätigen.
4. Prüfen, ob das Objekt nicht erneut auswählbar ist.
5. InspectTestObject auswählen und untersuchen.
6. UseTestObject auswählen und benutzen.
7. Zwei Kandidaten gleichzeitig in Reichweite bringen, sofern ihre Positionen dies zulassen.
8. Kleine Positions- und Richtungsänderungen ausführen.

**Erfolg:** Das aktive Ziel ist nachvollziehbar, die Auswahl flackert nicht und jede Aktion führt ausschließlich den erwarteten Effekt aus.

### Test E — Sichtbarkeit und Lesbarkeit

1. Spieler vor den Werkstattblock bewegen.
2. Spieler an den großen Schrotthaufen bewegen.
3. Kleine Interaktionsobjekte aus verschiedenen Kamerapositionen betrachten.
4. Nah- und Fernzoom vergleichen.
5. Prüfen, ob Silhouetten, Wege und Interaktionshinweise unterscheidbar bleiben.

**Erfolg:** Wichtige Ziele bleiben in den relevanten Spielsituationen auffindbar. Erkannte Sichtprobleme werden dokumentiert, nicht durch ungeplante Kamerasysteme kaschiert.

### Test F — Speichern und Laden

1. Spieler an eine definierte Position bewegen.
2. Einen Pickup ausführen.
3. Spielstand speichern.
4. Spiel neu starten und fortsetzen.
5. Spielerposition und Zustand des Testobjekts prüfen.

**Erfolg:** Die gespeicherten Daten stellen den definierten P0-Zustand wieder her. Es werden keine Szenenbäume serialisiert.

## 7. Testprotokoll und Diagnose

Jeder Testlauf hält mindestens fest:

- Build-/Projektstand.
- Testfall und Ausgangszustand.
- Erwartetes Ergebnis.
- Tatsächliches Ergebnis.
- Reproduktionsschritte bei Fehlern.
- Schweregrad und betroffene Komponente.
- Beobachtungen zum Spielgefühl.
- Entscheidung: behoben, akzeptiert, erneut testen oder zurückgestellt.

Das DebugOverlay darf für die Tests folgende Werte anzeigen:

- Spielerposition, Bewegungsrichtung und Geschwindigkeit.
- Bodenstatus und Kollisionsstatus.
- Kamera-Zielposition, Zoom und Follow-Abstand.
- Anzahl erkannter Interaktionskandidaten.
- Aktive Ziel-ID, Distanz und Auswahlgrund.
- Ergebnis der letzten Interaktion.

Debugwerte sind keine reguläre HUD-Anzeige.

## 8. Abnahmekriterien für P0-Gameplay-Blockout

Der Blockout gilt als bestanden, wenn:

1. Die Testszene reproduzierbar startet.
2. Spielerstart und Kamerastart korrekt gesetzt sind.
3. Bewegung in der isometrischen Perspektive verständlich und kontrollierbar ist.
4. Diagonale Bewegung keine zusätzliche Geschwindigkeit erzeugt.
5. Kollisionen mit den vorgesehenen Blockout-Hindernissen funktionieren.
6. Kamera-Follow und Zoom ohne auffälliges Zittern oder Sprünge funktionieren.
7. Spieler und relevante Testobjekte in den geprüften Bereichen lesbar bleiben.
8. Interaktionskandidaten zuverlässig erkannt werden.
9. Zielauswahl und Hervorhebung stabil und eindeutig sind.
10. Pickup, Inspect und Use jeweils korrekt ausgeführt werden.
11. Ungültige Ziele keine Aktionen auslösen.
12. Speichern und Laden den getesteten P0-Zustand zuverlässig wiederherstellen.
13. Die Ergebnisse und noch offenen Probleme dokumentiert sind.

P0 wird nicht freigegeben, wenn Bewegung, Kamera oder Interaktion unzuverlässig sind. In diesem Fall werden die betroffenen Systeme korrigiert und erneut getestet, bevor P1 beginnt.

## 9. Bewusst nicht Teil dieses Blockouts

- Wirtschaft, Verkaufstransaktionen und Credits.
- Vollständiges Inventar und Tragekapazität.
- Bergung großer Objekte mit Werkzeugen.
- Zerlegung und Verarbeitung.
- Scrappy und Storyinszenierung.
- Mitarbeiter und Maschinen.
- Vollständiger Baumodus.
- Finale Materialien, Beleuchtung, Dekoration und Assets.
- Komplexe Sichtlinien-, Transparenz- oder automatische Kamera-Hindernissysteme.

Der Blockout darf diese Bereiche räumlich berücksichtigen, implementiert sie aber nicht.

## 10. Verhältnis zum bestehenden Startgrundstück

Dieser P0-Blockout verwendet die Maße und Funktionszonen aus `starting-yard-blockout.md` als Testgrundlage.

Er ersetzt nicht den bestehenden Lage- und Entdeckungsplan. Storyfunde wie Scrappys Kopf und der rote Werkzeugkasten bleiben in den Startgrundstücksdokumenten beschrieben, werden in P0 jedoch nicht als Gameplay-Inhalte umgesetzt.

Wenn der P0-Test Anpassungen an Maßen, Wegen oder Sichtachsen verlangt, werden diese Änderungen als validierte Blockout-Erkenntnisse dokumentiert und anschließend in die Grundstücksplanung zurückgeführt.

---

**Leitgedanke:** Ein kleiner, reproduzierbarer Ausschnitt des echten Old Yard, der Bewegung, Kamera und Interaktion beweist – bevor wir Wirtschaft, Story oder Detailgestaltung hinzufügen.
