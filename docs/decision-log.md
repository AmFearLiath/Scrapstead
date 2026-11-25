# Scrapstead — Entscheidungsprotokoll

Dieses Dokument hält die derzeit verbindlichen Designentscheidungen fest. Neue Entscheidungen werden mit Datum, Kontext, Beschluss und Auswirkungen ergänzt.

## 25.11.2026 — Projektidentität und grundlegendes Design

- Name: Scrapstead.
- Slogan: Every Scrap Has a Story.
- Genre: Cozy Automation Tycoon.
- Kamera: Isometrisches 3D.
- Gameplay: Kombination aus manueller Arbeit und Automatisierung.
- Atmosphäre: Gemütlich, humorvoll, skurril.
- Grafikstil: Stylized Low-Poly / Miniatur-Diorama.
- Grundprinzip: Simple Core, Endless Possibilities.
- Scrappy ist Begleiter und Maskottchen.

## 25.11.2026 — Sammelsystem

**Beschluss:** Hybrides Sammelsystem.

- Kleine, lose Gegenstände können direkt aufgehoben werden.
- Größere oder feststeckende Objekte benötigen Werkzeuge oder Ausrüstung.
- Begründung: Direkte Interaktionen halten das Spiel flott. Werkzeuge schaffen sinnvolle Fortschrittsmöglichkeiten.

## 25.11.2026 — Schrottwirtschaft

**Beschluss:** Direktverkauf plus optionale Wertverarbeitung.

- Gewöhnlicher Schrott kann direkt und mit geringerem, aber verlässlichem Erlös verkauft werden.
- Ausgewählte Gegenstände können sortiert, zerlegt oder verarbeitet werden und dadurch potenziell bessere Erträge, Komponenten oder Entdeckungen liefern.
- Verarbeitung ist optional und nicht verpflichtend.
- Begründung: Das Spiel bleibt zugänglich und bietet trotzdem sinnvolle Entscheidungen.

## 25.11.2026 — Unternehmensentwicklung

**Beschluss:** Schrittweise, selbst erarbeitete Delegation.

- Der Spieler erledigt zu Beginn fast alle Arbeiten selbst.
- Bessere Werkzeuge und Transportkapazität kommen zuerst.
- Danach kann der Spieler den ersten Mitarbeiter einstellen.
- Anschließend spart er auf die erste Maschine.
- Mitarbeiter und Maschinen übernehmen nach und nach klar definierte Aufgaben.
- Automatisierung wächst schrittweise und steht nicht sofort zur Verfügung.
- Begründung: Jede Investition soll verdient und sichtbar bedeutsam sein.

## 25.11.2026 — Scrappys Herkunft und Anpassung

**Beschluss:** Der Spieler findet zunächst nur Scrappys Kopf unter Schrott.

- Eine besondere Komponente aus dem roten Werkzeugkasten stellt den Kopf wieder her.
- Der Spieler baut Scrappy aus gefundenen Körper-, Bewegungs-, Arm-, Sensor- und Dekorationsteilen zusammen.
- Konstruktionen können praktisch, albern oder rein kosmetisch sein.
- Scrappy bleibt loyal, trocken-humorvoll und gelegentlich etwas geschwätzig.
- Seine Persönlichkeit hängt nicht von den verbauten Teilen ab.

## 25.11.2026 — Einfachheit

**Beschluss:** Das Spiel bleibt einfach bedienbar und bietet dennoch viele Möglichkeiten.

- Komplexität entsteht durch die Kombination verständlicher Systeme.
- Kein verpflichtendes Mikromanagement, keine komplizierte Logistikprogrammierung, keine überladenen Menüs und keine unnötig große Ressourcen-Taxonomie.
- Neue Systeme werden schrittweise eingeführt.

## 25.11.2026 — Erste Fortschrittsfolge

**Beschluss:** Der Betrieb wächst durch schrittweise, selbst erarbeitete Delegation.

- Der Spieler erledigt zu Beginn fast alle Arbeiten selbst.
- Verbesserungen an Werkzeugen und Transport kommen zuerst.
- Der erste Mitarbeiter soll vor der ersten Maschine kommen. Diese Reihenfolge muss im Prototyp überprüft werden.
- Der Mitarbeiter übernimmt eine klar definierte Aufgabe, die der Spieler bereits selbst kennt.
- Die erste Maschine automatisiert anschließend eine ebenso verständliche Aufgabe.
- Exakte Preise, Löhne und Zeitpunkte werden erst im Wirtschaftsprototyp festgelegt.
- Begründung: Jede Investition soll ein spürbarer Schritt zum größeren Betrieb sein und keinen sofortigen Sprung in die Automatisierung darstellen.

## 25.11.2026 — Hybrides Sammeln und optionale Verarbeitung

- Kleine, lose Gegenstände können direkt aufgehoben werden.
- Größere oder feststeckende Objekte benötigen passende Werkzeuge oder Ausrüstung.
- Gewöhnlicher Schrott kann direkt verkauft werden.
- Ausgewählte Gegenstände können sortiert, zerlegt oder verarbeitet werden, um potenziell mehr Wert zu erzielen.
- Verarbeitung bleibt optional und darf nicht zur Pflichtaufgabe werden.

## 25.11.2026 — Vollständig mehrsprachige Entwicklung

**Beschluss:** Scrapstead wird vom ersten Produktionsinhalt an mehrsprachig entwickelt.

- Jeder spielerseitige Text muss über einen Lokalisierungsschlüssel eingebunden werden. Fest codierte Anzeigetexte sind nicht zulässig.
- Spiel-IDs, Speicherdaten, Asset-Bezeichner und Spiellogik sind unabhängig von der Sprache.
- Deutsch und Englisch sind die ersten Referenzsprachen.
- Weitere Sprachen müssen ohne Änderungen an Spiellogik oder Inhalts-IDs ergänzt werden können.
- Benutzeroberfläche, Schriftarten, Formatierungen, Untertitel, Barrierefreiheitstexte und Inhaltsprüfung berücksichtigen Mehrsprachigkeit von Anfang an.
- Fehlende Übersetzungen und abweichende Schlüssel müssen automatisiert erkannt werden.
- Begründung: Eine nachträgliche Internationalisierung würde vermeidbare Architektur-, Inhalts- und UI-Änderungen verursachen.

## 25.11.2026 — Gegenstandskatalog des Startgrundstücks

**Beschluss:** Der Gegenstandskatalog wird als kompaktes Gameplay-System und nicht als ungeordnete Objektliste aufgebaut.

- Katalogeinträge verwenden stabile, sprachunabhängige IDs und lokalisierte Namens- und Beschreibungsschlüssel.
- Der erste Katalog umfasst lose Schrottteile, sperrige Objekte, zerlegbare Geräte, Entdeckungsquellen, wertvolle Fundstücke und standardisierte Verarbeitungsergebnisse.
- Direktverkauf bleibt für verkäufliche Gegenstände möglich.
- Verarbeitung ist optional und gezielt.
- Wirtschaftswerte bleiben bis zum Balancing des Prototyps relative Stufen.
- Die Scrappy-Kernkomponente wird garantiert im roten Werkzeugkasten platziert und ist kein zufälliger Fortschrittsblocker.
- Begründung: Ein fokussierter Katalog soll den grundlegenden Spielablauf vermitteln und abwechslungsreiche Möglichkeiten bieten, ohne das erste Grundstück zu überladen.

## 25.11.2026 — Lage- und Entdeckungsplan des Startgrundstücks

**Beschluss:** Das Startgrundstück wird in funktionale, aber frei begehbare Bereiche gegliedert.

- Einfahrt und Annahme bilden den leicht verständlichen Einstieg.
- Büro und Werkstatt bilden den funktionalen Ausgangspunkt.
- Eine freie Arbeitsfläche reserviert Platz für erste Sortieraktionen und Maschinen.
- Lager- und Schrottbereiche bieten Gegenstände unterschiedlicher Größe und Zugänglichkeit.
- Scrappys Kopf und der rote Werkzeugkasten sind eigenständige, miteinander verbundene Entdeckungen.
- Die Wegeführung und Objektverteilung vermitteln die ersten Spielmechaniken, ohne ein starres Tutorial zu erzwingen.
- Begründung: Die räumliche Anordnung soll Orientierung, Erkundung, Spielfortschritt und die Geschichte des Grundstücks miteinander verbinden.

## 25.11.2026 — Sprache der Entwicklungsdokumentation

**Beschluss:** Die interne Scrapstead-Entwicklungsdokumentation wird auf Deutsch geführt.

- Neue Konzepte, Spezifikationen, Entscheidungsprotokolle und Planungsdokumente werden auf Deutsch erstellt.
- Technische Bezeichner, stabile IDs, Code-Symbole und Lokalisierungsschlüssel bleiben sprachneutral bzw. in ihrer technischen Schreibweise erhalten.
- Die Spielinhalte selbst bleiben vollständig mehrsprachig.
- Bestehende englische Dokumente werden bei ihrer Überarbeitung schrittweise auf Deutsch umgestellt.
- Begründung: Die gemeinsame Konzeptions- und Entwicklungsarbeit soll sprachlich einheitlich und gut lesbar bleiben, ohne die internationale Ausrichtung des Spiels zu beeinträchtigen.

## 25.11.2026 — Grundstücksgeometrie und erster Blockout

**Beschluss:** Der erste maßstäbliche Layout-Test verwendet vorläufig ein rechteckiges Grundstück von 48 × 36 Metern.

- Die Fläche umfasst 1.728 m².
- Das Blockout-Raster beträgt zunächst 1 × 1 Meter.
- Ein Layout-Meter entspricht zunächst einer Welt-Einheit von einem Meter.
- Die Funktionsbereiche erhalten feste ungefähre Koordinatenbereiche, bleiben aber offen miteinander verbunden.
- Der Hauptweg ist zunächst mit 3 Metern Breite geplant; Nebenwege mit 2 Metern.
- Für die erste Maschine wird ein Stellplatz von bis zu 5 × 4 Metern zuzüglich Bedien- und Ablageflächen reserviert.
- Diese Werte sind Testannahmen und werden anhand von Kamera, Laufwegen, Handwagen und Interaktionen überprüft.
- Begründung: Ein gemeinsamer Maßstab macht Grundstücksplanung, Assetgrößen und Gameplay-Abstände nachvollziehbar und früh testbar.


## 25.11.2026 — Freies Bauen und funktionale Maschinenverbindungen

**Beschluss:** Scrapstead verwendet ein freies Bausystem mit nachvollziehbaren funktionalen Einschränkungen.

- Innerhalb der Grundstücksgrenzen gibt es keine fest zugewiesenen Bauplätze für Gebäude oder Maschinen.
- Die bisherigen Zonen des Startgrundstücks dienen als Orientierung für Leveldesign und Entdeckungsdramaturgie, nicht als verbindliche Bauzonen.
- Gebäude, Maschinen, Lager, Wege, Zäune und Dekorationen sollen grundsätzlich frei platzierbar sein.
- Funktionale Anforderungen wie Grundfläche, Bedienzugang, Arbeitsradius, Ein- und Ausgabepunkte sowie erforderliche Abstände werden objektabhängig geprüft.
- Maschinen können definierte Ein- und Ausgabepunkte besitzen.
- Der Spieler kann kompatible Maschinen durch eine einfache Aktion verbinden. Das Spiel erstellt automatisch eine passende Route, sofern ein freier und gültiger Weg existiert.
- Blockierte oder ungültige Routen werden verständlich erklärt.
- Direkte Übergabe, automatische Transportstrecke und manueller Transport sind gleichberechtigte Möglichkeiten.
- Komplexe manuelle Förderbandplanung und verpflichtendes Logistik-Mikromanagement gehören nicht zum Ziel des ersten Prototyps.
- Rastergröße, Routenführung und konkrete Maschinenanforderungen bleiben bis zum Prototyp-Test offen.
- Begründung: Der Spieler soll seinen Betrieb selbst gestalten können. Das Spiel stellt sicher, dass die Gestaltung funktional bleibt, ohne die kreative Freiheit durch starre Bauplätze oder komplizierte Logistik zu beschneiden.


## 25.11.2026 — Bedienkonzept des Baumodus

**Beschluss:** Das Bausystem erhält einen zentralen, kompakten Baumodus mit kontextabhängigen Werkzeugen.

- Vorgesehene Werkzeuge: Platzieren, Verschieben, Drehen, Verbinden, Entfernen und Inspizieren.
- Platzierungen werden durch eine transparente Vorschau mit objektabhängigen Funktions- und Platzierungsinformationen vorbereitet.
- Bestehende Objekte können verschoben und gedreht werden. Betroffene Maschinenverbindungen müssen vor der Bestätigung sichtbar sein.
- Maschinenverbindungen werden bewusst über ausgewählte Ein- und Ausgabepunkte angelegt.
- Das Spiel berechnet eine passende Transportroute automatisch und zeigt sie vor der Bestätigung.
- Einrasten (Snap) dient der geometrisch sauberen Ausrichtung. Es erzeugt keine ungefragten Maschinenverbindungen.
- Der Baumodus soll Rückgängig und Wiederholen sowie das wiederholte Platzieren gleicher Objekte unterstützen.
- Fehlgeschlagene Aktionen müssen verständlich erklären, woran sie scheitern und möglichst eine Lösung anbieten.
- PC-Tastenbelegung, Raster, Werkzeugleistenlayout und technische Details bleiben bis zum Prototyp-Test vorläufig.
- Begründung: Freies Bauen soll intuitiv und fehlertolerant sein. Das Spiel übernimmt Prüfungen und Routenplanung, ohne dem Spieler die Kontrolle über seine Produktionsstruktur zu nehmen.
