# Scrapstead – Grundstücksgeometrie und Blockout-Spezifikation

**Version:** 0.1  
**Status:** Maßstabs- und Layoutvorschlag für den ersten Blockout  
**Bereich:** Erstes Grundstück / Start-Schrottplatz  
**Bezug:** Lage- und Entdeckungsplan des Startgrundstücks

> Alle Maße in diesem Dokument sind vorläufige Entwurfswerte. Sie bilden eine überprüfbare Ausgangsbasis für den ersten spielbaren Blockout und sind noch keine endgültigen Produktionsmaße.

## 1. Ziel

Dieses Dokument überführt den funktionalen Lageplan in einen räumlich nachvollziehbaren Maßstab. Es definiert Grundstücksgröße, Koordinatensystem, Zonen, Wege, Gebäude-Footprints, Maschinenstellfläche und erste Bewegungsabstände.

Der Blockout soll zuerst folgende Fragen beantworten:

- Wirkt das Grundstück aus der isometrischen Kamera kompakt und lesbar?
- Sind die wichtigsten Bereiche schnell erreichbar?
- Gibt es genügend Platz zum Sammeln, Tragen und Rangieren?
- Können später Mitarbeiter und Handwagen die Wege nutzen?
- Hat die erste Maschine einen sinnvollen Platz?
- Funktioniert die Entdeckungsdramaturgie ohne künstliche Wegsperren?

Noch nicht Teil dieses Schritts sind finale Gebäudeformen, Dekoration, Materialien, Beleuchtung oder detaillierte Assets.

## 2. Maßstab und Grundstücksgröße

### 2.1 Vorgeschlagene Grundfläche

| Eigenschaft | Entwurfswert |
|---|---:|
| Breite (West–Ost) | 48 m |
| Tiefe (Süd–Nord) | 36 m |
| Gesamtfläche | 1.728 m² |
| Blockout-Raster | 1 × 1 m |
| Koordinatenursprung | Südwestliche Grundstücksecke |
| Weltmaßstab | 1 Layout-Meter = 1 Weltmeter |

Die Fläche ist als kompakter Startbetrieb gedacht. Sie bietet Raum für die fünf bereits definierten Funktionsbereiche, ohne dass lange Laufwege oder große ungenutzte Flächen entstehen müssen.

### 2.2 Koordinatensystem

Für die Planung gilt:

- X-Achse: Westen nach Osten, von 0 bis 48 m.
- Z-Achse: Süden nach Norden, von 0 bis 36 m.
- Y-Achse: Höhe.
- Grundstücksgrenzen liegen auf X = 0, X = 48, Z = 0 und Z = 36.

Alle nachfolgenden Zonenangaben sind als ungefähre Rechteckbereiche zu verstehen. Die tatsächliche Form darf durch Zäune, Schrotthaufen und Gebäude leicht unregelmäßig werden.

## 3. Funktionale Zonen und Positionen

| Bereich | Ungefährer Bereich (X / Z) | Vorgesehene Größe | Hauptfunktion |
|---|---|---:|---|
| E – Einfahrt und Verkauf | X 2–16 / Z 1–11 | ca. 14 × 10 m | Eingang, Annahme, erste Verkäufe |
| C – Büro und Werkstatt | X 3–17 / Z 13–23 | ca. 14 × 10 m | Werkbank, Werkzeuge, Scrappy-Reparatur |
| A – Alte Lagerzone | X 2–17 / Z 25–34 | ca. 15 × 9 m | Kisten, Fässer, Suchquellen |
| D – Freie Arbeitsfläche | X 22–44 / Z 6–19 | ca. 22 × 13 m | Ablage, Sortierung, erste Maschine |
| B – Verwilderter Schrotthof | X 23–46 / Z 21–34 | ca. 23 × 13 m | Schrotthaufen, sperrige Objekte, Scrappys Fundort |

Zwischen den Zonen bleiben bewusst offene Übergänge. Die Grenzen sind Orientierungshilfen, keine Mauern oder zwingenden Barrieren.

## 4. Schematische Blockout-Draufsicht

Norden liegt oben. Die Darstellung ist schematisch und nicht maßstabsgetreu.

```text
NORDEN / Z = 36
┌────────────────────────────────────────────────────────┐
│                                                        │
│  A – ALTE LAGERZONE             B – SCHROTTHOF         │
│  X 2–17                         X 23–46                │
│  ┌───────────────┐              ┌───────────────────┐  │
│  │ Kisten        │              │ Großer Haufen     │  │
│  │ Fässer        │              │ Motorblock        │  │
│  │ Metallschrank│              │ Scrappy-Fundort   │  │
│  └───────────────┘              └───────────────────┘  │
│          │                                │            │
│          │       offener Übergang         │            │
│  C – WERKSTATT                    D – ARBEITSFLÄCHE    │
│  ┌───────────────┐              ┌───────────────────┐  │
│  │ Werkbank      │              │ Freie Ablage      │  │
│  │ Werkzeug      │              │ Sortierfläche     │  │
│  │ Roter Kasten  │              │ Maschinenplatz    │  │
│  └───────────────┘              └───────────────────┘  │
│          │                         │                   │
│          └──────── Hauptweg ───────┘                   │
│                                                        │
│  E – ANNAHME / VERKAUF                                 │
│  ┌───────────────┐                                     │
│  │ Waage /       │                                     │
│  │ Verkaufsplatz │                                     │
│  └───────────────┘                                     │
│                                                        │
│  TOR / EINFAHRT                                        │
└────────────────────────────────────────────────────────┘
SÜDEN / Z = 0
X = 0 WESTEN                                  X = 48 OSTEN
```

## 5. Gebäude und feste Objekte

Die folgenden Footprints sind erste Platzhalter. Sie dienen dazu, Bewegungsräume und Sichtachsen zu testen.

| Objekt | Vorgeschlagener Footprint | Hinweise |
|---|---:|---|
| Büro / Werkstattschuppen | 9 × 6 m | Ein gemeinsamer Baukörper für den ersten Blockout |
| Werkbank | 2,5 × 1 m | Bedienfläche davor freihalten |
| Verkaufs- und Annahmeplatz | 5 × 4 m | Von der Einfahrt gut sichtbar |
| Verkaufswaage / Tresen | 2 × 1,5 m | Mit freier Interaktionsseite |
| Lagerregal | 3 × 1 m | Nicht in Hauptwege hineinragen lassen |
| Roter Werkzeugkasten | ca. 0,8 × 0,5 m | In der Werkstatt, nicht als auffälliger Questmarker |
| Schrotthaufen klein | 3 × 3 m | Teilweise durchsuchbar |
| Schrotthaufen groß | 5 × 4 m | Kann Sichtachsen teilweise unterbrechen |
| Erste Maschine | bis ca. 5 × 4 m | Mit Bedien- und Wartungszugang |

Gebäude und große Objekte müssen nicht exakt rechteckig modelliert werden. Für den Blockout zählt zunächst ihre begehbare Grundfläche.

## 6. Wege, Bewegungsräume und Rangieren

### 6.1 Wegbreiten

| Wegtyp | Vorgeschlagene Breite |
|---|---:|
| Hauptweg | 3,0 m |
| Nebenweg | 2,0 m |
| Zugang zu Werkbank / Maschine | 1,5–2,0 m |
| Engstelle zwischen Dekoration | möglichst mindestens 1,5 m |
| Rangierfläche vor Annahme | mindestens 4 × 4 m |

Der Hauptweg verbindet Einfahrt, Verkaufsbereich, Werkstatt und Arbeitsfläche. Er soll auch mit späterem Handwagen gut nutzbar sein.

### 6.2 Bewegungsflächen

- Vor jeder bedienbaren Station muss eine freie Interaktionsfläche vorhanden sein.
- Große Gegenstände dürfen nicht so platziert werden, dass sie den Hauptweg blockieren.
- Mitarbeiter benötigen ausreichend breite Wege und dürfen nicht an dekorativen Kleinteilen hängen bleiben.
- Handwagen benötigen Kurven und Wendeflächen, nicht nur gerade Korridore.
- Maschinen brauchen neben ihrem Footprint Platz für Einwurf, Ausgabe und Animationen.

Die genauen Kollisionsradien und Bewegungsparameter werden erst mit dem tatsächlichen Controller festgelegt.

## 7. Erste Maschinenfläche

Die freie Arbeitsfläche erhält einen reservierten Stellplatz für den ersten Magnet-Sammler.

Vorgeschlagene Fläche:

- Maschinen-Footprint: bis zu 5 × 4 m.
- Freier Bedienbereich: mindestens 2 m an der zugänglichen Seite.
- Drop-off-Punkt: in kurzer Laufdistanz, vorzugsweise direkt neben dem Maschinenbereich.
- Freier Bewegungsraum: keine festen Props in der unmittelbaren Arbeitszone.

Die Maschine soll den Spieler nicht dazu zwingen, den gesamten Schrottplatz umzubauen. Ihr Platz muss bereits im Startlayout funktionieren.

## 8. Startposition und Kamera

### 8.1 Startposition

Vorgeschlagener Startpunkt:
- In der Nähe der Einfahrt im südlichen Grundstücksbereich.
- Blickrichtung ungefähr nach Norden.
- Erste kleine Schrottobjekte in kurzer Entfernung.
- Annahmebereich in der ersten oder zweiten Kameraperspektive sichtbar.
- Ein interessanter Schrotthaufen als visuelles Erkundungsziel erkennbar.

### 8.2 Kamera-Blockout

Für den ersten Test:
- Isometrische bzw. orthografische Kamera als Ausgangspunkt.
- Leichte Neigung, sodass Bodenflächen und Objektoberseiten erkennbar sind.
- Kamera darf wichtige Interaktionsobjekte nicht dauerhaft hinter hohen Haufen verlieren.
- Gebäude und Schrotthaufen müssen bei normaler Spielkamera lesbare Silhouetten behalten.
- Kamera-Randverhalten und Zoom werden separat getestet.

Es werden noch keine endgültigen Winkel, Brennweiten oder Zoomgrenzen festgelegt. Diese hängen vom Controller, der Engine und dem tatsächlichen Artstil ab.

## 9. Sichtachsen und Objektplatzierung

Die Startansicht soll drei Informationen vermitteln:

1. Wo befindet sich der Spieler?
2. Wo kann er den ersten Schrott abgeben?
3. Wo gibt es etwas Interessantes zu entdecken?

Wichtige Objekte dürfen nicht alle auf einer Linie stehen. Der Schrottplatz soll Tiefe haben und organisch wirken.

Regeln:
- Der Verkaufsbereich erhält eine klare visuelle Silhouette.
- Die Werkstatt bleibt als Orientierungspunkt erkennbar.
- Scrappys Kopf wird teilweise verdeckt und nicht direkt als Questobjekt präsentiert.
- Der rote Werkzeugkasten ist auffindbar, aber nicht durch Leuchteffekte hervorgehoben.
- Die freie Maschinenfläche bleibt sichtbar genug, um spätere Nutzung verständlich zu machen.
- Hohe Props werden so verteilt, dass keine komplette Zone aus der Kamera verschwindet.

## 10. Blockout-Phasen

### Phase 1 – Nur Grundstück und Wege

- Rechteckige Grundstücksfläche mit 48 × 36 m anlegen.
- Grundstücksgrenzen und Tor setzen.
- Hauptweg und Nebenwege markieren.
- Startposition und Kamera testen.

### Phase 2 – Große Volumen

- Büro / Werkstatt als einfacher Block.
- Verkaufsbereich als Platzhalter.
- Große Schrotthaufen als einfache Volumen.
- Lagerzone und freie Arbeitsfläche abgrenzen.

### Phase 3 – Gameplay-Objekte

- Erste Kleinteile platzieren.
- Ein sperriges Objekt platzieren.
- Eine durchsuchbare Quelle ergänzen.
- Roten Werkzeugkasten und Scrappys Fundort positionieren.
- Maschinenstellplatz markieren.

### Phase 4 – Bewegungs- und Sichttest

- Spielerwege ablaufen.
- Handwagen-Breite simulieren.
- Engstellen und Kollisionen prüfen.
- Interaktionsreichweiten testen.
- Kamera aus Startposition und typischen Arbeitspositionen prüfen.

### Phase 5 – Erst nach erfolgreichem Test

- Gebäudeformen ausarbeiten.
- Bodenmaterialien und Höhenunterschiede ergänzen.
- Dekoration und kleine Props hinzufügen.
- Beleuchtung und Atmosphäre gestalten.

## 11. Abnahmekriterien

Der Blockout ist erfolgreich, wenn:

- Das Grundstück aus der Spielkamera kompakt und verständlich wirkt.
- Die Einfahrt und der Verkaufsbereich schnell gefunden werden.
- Die erste Sammelrunde keine unnötig langen Laufwege erzeugt.
- Die Werkstatt erreichbar und als funktionaler Ort erkennbar ist.
- Scrappys Fundort eine Entdeckung bleibt, aber nicht künstlich versteckt ist.
- Die freie Arbeitsfläche eine Maschine samt Bedien- und Ablagebereich aufnehmen kann.
- Hauptwege mit einem späteren Handwagen nutzbar bleiben.
- Mitarbeiter später zwischen den Hauptbereichen navigieren können.
- Wichtige Objekte nicht durch Gebäude oder Schrotthaufen verdeckt werden.
- Das Grundstück nicht leer, aber auch nicht überladen wirkt.

## 12. Offene Entscheidungen nach dem Blockout

Folgende Punkte werden erst nach dem ersten Kameratest endgültig festgelegt:

- Ob 48 × 36 m die passende Grundstücksgröße sind.
- Ob die Werkstatt größer oder kleiner ausfallen muss.
- Ob die freie Arbeitsfläche ausreichend Platz für spätere Erweiterungen bietet.
- Ob das Grundstück eher rechteckig oder mit abgeschrägten / unregelmäßigen Grenzen gestaltet wird.
- Ob die Kamera eine feste orthografische Projektion oder eine perspektivische isometrische Ansicht verwendet.
- Ob der Startpunkt und der Verkaufsbereich optimal zueinander liegen.

**Wichtig:** Diese Spezifikation ist eine Testgrundlage. Falls der Blockout zeigt, dass Wege, Kamera oder Flächen nicht funktionieren, werden die Maße angepasst, bevor Detail-Assets produziert werden.
