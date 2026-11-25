# Scrapstead — Technische Architektur

**Version:** 0.2  
**Status:** Vorgeschlagene Architektur; durch Prototypen zu validieren

## 1. Engine

Vorgeschlagen: Godot 4.x mit 3D-Rendering und isometrischer Kamera. Die genaue Engine-Version und Rendering-Entscheidungen werden bei Einrichtung der Entwicklungsumgebung bestätigt.

## 2. Architekturprinzipien

- Datengetriebene Definitionen für Gegenstände, Materialien, Maschinen, Rezepte, Upgrades, Mitarbeiter und Scrappy-Module.
- Simulationszustand strikt von Darstellung und Animation trennen.
- Kleine, testbare Gameplay-Systeme.
- Komposition und wiederverwendbare Komponenten bevorzugen.
- Keine vorzeitige Abstraktion oder Überarchitektur.
- Content-Erstellung und Erweiterung einfach halten.
- Zeitabhängige Simulation muss deterministisch bzw. reproduzierbar genug sein, um Offline-Zeiträume kontrolliert nachzuberechnen.

## 3. Vorgeschlagene Systemgrenzen

- GameState / SessionManager.
- Welt-, Regions- und Grundstücksverwaltung.
- Spielersteuerung und Interaktionen.
- Gegenstände, Materialien und Inventare.
- Sammlung und Werkzeuge.
- Wirtschaft, Preise und Transaktionen.
- Beschaffung, Lieferungen und Aufträge.
- Verarbeitung und Rezepte.
- Mitarbeiter, Arbeitsbereiche und Aufgabenverteilung.
- Arbeitszeiten und Schichtplanung.
- Maschinen und Automatisierung.
- Fahrzeuge und standortübergreifende Logistik.
- Scrappy: Module, Fähigkeiten, Gedächtnis, Absichten und Aktivitäten.
- Progression, Ziele und Abschlussbedingungen.
- Statistik- und Ereigniserfassung.
- Zeit- und Offline-Simulation.
- Speichern und Laden.
- UI, Audio und Lokalisierung.

## 4. Simulationsmodell

Wirtschaftliche Abläufe verwenden zentrale Simulationsschritte und/oder ereignisbasierte Aktualisierungen. Maschinenanimationen spiegeln den Simulationszustand wider; sie sind niemals die maßgebliche Quelle für Produktionsergebnisse.

Die Weltzeit, Produktionszeit und Tagesereignisse müssen klar getrennt modelliert werden. Ein Zeitgeber bzw. Simulationskern verarbeitet relevante Vorgänge. Systeme melden Ereignisse und aktualisieren ihre Zustände anhand der simulierten Zeit.

## 5. Offline-Fortschritt

Der konzeptionelle Standard ist begrenzter Offline-Fortschritt mit maximal 24 Stunden.

- Beim Speichern werden Weltzeit, relevanter Simulationszustand und ein vertrauenswürdiger Zeitstempel persistiert.
- Beim Laden wird die vergangene Zeit ermittelt und auf die erlaubte Offline-Dauer begrenzt.
- Freigegebene Maschinenproduktion, Lagerbewegungen, geplante Lieferungen, Schichtarbeit und ausgewählte Scrappy-Aktivitäten werden kontrolliert nachberechnet.
- Neue Aufträge, wichtige Storyereignisse und Entscheidungen, die eine Spielerfreigabe benötigen, werden nicht autonom abgeschlossen.
- Offline-Berechnung muss Grenzfälle wie volle Lager, fehlende Eingaben, Personalmangel, geschlossene Betriebe und Produktionsstopps berücksichtigen.
- Die Berechnung darf keine unbegrenzten Schleifen oder unkontrollierten Ereigniskaskaden erzeugen.
- Beim nächsten Start wird ein Abwesenheitsbericht aus den berechneten Ereignissen erstellt.
- Alternative Modi wie Simulation pausieren oder vollständiger Offline-Fortschritt bleiben als spätere Einstellungsmöglichkeiten offen.

Eine laufende Spielinstanz ist für Offline-Fortschritt nicht erforderlich. Die konkrete Berechnungsmethode (zeitbasierte Aggregation, begrenzte Simulationsschritte oder Hybrid) wird anhand der Systemkomplexität im Prototyp gewählt.

## 6. Personal- und Aufgabensystem

Mitarbeiter erhalten Arbeitsbereichszuordnungen und einfache Prioritätsvorgaben. Eine Aufgabenverteilung bewertet Verfügbarkeit, Qualifikation, Erfahrung, Weg, Kompatibilität und Priorität. Die Simulation soll nicht für jeden Mitarbeiter einen aufwendigen individuellen Lebenszyklus berechnen.

Schichtmodelle werden als Betriebs- und Verfügbarkeitsregeln modelliert. Mitarbeiterzuordnung, Ruhezeiten und Personalbedarf bleiben von der visuellen Darstellung getrennt.

## 7. Statistik und Ereignisprotokoll

Relevante Spielereignisse werden zentral erfasst, damit laufende Statistiken, Abschlussberichte, Auszeichnungen und Balancing-Telemetrie nicht nachträglich aus unvollständigen Zuständen rekonstruiert werden müssen.

Mögliche Ereignistypen:

- Gegenstand gesammelt, verkauft, zerlegt oder verarbeitet.
- Material produziert, verbraucht oder transportiert.
- Maschine gebaut, verbessert, gestartet oder gestoppt.
- Mitarbeiter eingestellt, zugeordnet oder weiterentwickelt.
- Schicht gestartet oder beendet.
- Auftrag angenommen oder abgeschlossen.
- Standort erschlossen.
- Scrappy-Modul installiert oder Fähigkeit genutzt.
- Entdeckung oder besonderer Meilenstein erreicht.

Ereignisse verwenden stabile IDs und strukturierte Daten. Der Statistikdienst aggregiert daraus Laufzeitwerte und speicherbare Abschlussdaten.

## 8. Speicherdaten

Persistiert werden unter anderem:

- Spielerfortschritt und Credits.
- Freigeschaltete Regionen, Standorte und Grundstücke.
- Layout, Gebäude und platzierte Objekte.
- Gegenstände, Materialien und Lagerbestände.
- Maschineninstanzen, Zustände und Produktionsfortschritt.
- Mitarbeiter, Fähigkeiten, Arbeitsbereiche und Schichtzuordnungen.
- Fahrzeuge und Transportaufträge.
- Scrappys Module, Entwicklung, Erinnerungen und persönliche Gegenstände.
- Ziele, Entdeckungen, Ereignisse und Statistiken.
- Spieleinstellungen einschließlich Offline-Modus.
- Letzter simulierter Weltzeitpunkt.

Speicherdaten werden versioniert. Migrationen sind von Anfang an vorzusehen.

## 9. Prototyporientierte Umsetzung

Nicht alle Systeme gleichzeitig bauen. Zuerst die Schleife Sammeln → Verkaufen/Verarbeiten → Investieren auf einem Grundstück validieren. Danach Mitarbeiterdelegation und erste Maschine hinzufügen.

Regionale Expansion, komplexe Schichtplanung, vollständige Offline-Simulation und das komplette Netzwerk werden erst nach Validierung der Kernsysteme implementiert.

## 10. Offene technische Entscheidungen

- Exakte Godot-Version und Rendering-Konfiguration.
- Eingabe- und Bewegungsmodell.
- Rastergröße, freie Platzierung und Bauflächenregeln.
- Inventar- und Transportmodell.
- Simulationsfrequenz und Ereignisaggregation.
- Konkrete Offline-Berechnung und Schutz vor Zeitmanipulation.
- Speicherformat und Migrationsstrategie.
- Zielhardware und Performancebudget.
- Technische Aufteilung zusammenhängender Welt und separat geladener Spezialstandorte.
