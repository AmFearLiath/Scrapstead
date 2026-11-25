# Scrapstead — Gameplay- und Wirtschaftsspezifikation

**Version:** 0.4  
**Status:** Konzeptstand / vor Prototyp-Validierung

## 1. Grundentscheidungen

- Kleine, lose Gegenstände können direkt aufgehoben werden; größere oder feststeckende Objekte benötigen Werkzeuge oder Ausrüstung.
- Gewöhnlicher Schrott kann direkt verkauft werden.
- Sortierung, Demontage, Aufbereitung und Wiederverwendung sind optionale Wege zur zusätzlichen Wertschöpfung.
- Der Spieler beginnt mit manueller Arbeit. Mitarbeiter, Maschinen und automatisierte Logistik kommen schrittweise hinzu.
- Die Grundwirtschaft bleibt verständlich und relativ stabil. Nachfrage, Sonderaufträge und ausgewählte Preise können dynamisch reagieren.
- Komplexität entsteht durch die Kombination einfacher Systeme, nicht durch Pflicht-Mikromanagement.

## 2. Gegenstände und Ressourcen

Gegenstände werden datengetrieben über stabile IDs definiert. Ein Eintrag kann unter anderem enthalten:

- Sprachunabhängige ID.
- Lokalisierte Namens- und Beschreibungsschlüssel.
- Kategorie und Materialzusammensetzung.
- Größe und Handhabungsklasse.
- Direkter Basisverkaufswert bzw. Wertstufe.
- Mögliche Zerlegungs- und Verarbeitungsergebnisse.
- Benötigte Werkzeuge oder Stationen.
- Seltenheits- und Entdeckungstags.
- Visuelle Asset-Referenz.
- Sammel-, Quest- und Schutzkennzeichnungen.

### 2.1 Vier Ressourcenebenen

1. Fundstücke und Gegenstände.
2. Rohmaterialien.
3. Wiederverwendbare Komponenten.
4. Aufbereitete Produkte und Erzeugnisse.

### 2.2 Erste Materialgruppen

- Metalle: Eisen, Stahl, Aluminium, Kupfer und weitere Metalle.
- Kunststoffe: verschiedene Kunststoffarten und Verbundstoffe.
- Elektronik: Platinen, Kabel, Chips, Sensoren und Bauteile.
- Holz und Naturmaterialien: Holz, Papier und Karton.
- Mineralische Stoffe: Glas, Beton, Keramik und Gestein.
- Besondere Fundstücke: seltene Komponenten, Sammlerstücke und ungewöhnliche Objekte.

Die Liste ist eine konzeptionelle Taxonomie, keine verbindliche Startmenge. Der erste Contentumfang bleibt klein.

## 3. Zerlegung und Verarbeitung

**Beschluss: Hybridmodell.**

- Gewöhnliche Gegenstände werden in wenige verständliche Materialgruppen zerlegt.
- Komplexe, seltene oder wertvolle Gegenstände können detaillierte Komponenten enthalten.
- Ein Gegenstand kann direkt verkauft, sortiert, demontiert, aufbereitet oder als Fundstück behalten werden.
- Nicht jeder Gegenstand benötigt alle Verarbeitungsschritte.
- Komplexe Zerlegung muss einen nachvollziehbaren Mehrwert bieten und darf nicht zum Pflichtweg werden.

Mögliche Verarbeitungsarten:

- Sortierung: Trennung gemischter Materialien.
- Demontage: Zerlegung in Rohmaterialien und Komponenten.
- Aufbereitung: Verbesserung der Materialqualität oder Herstellung standardisierter Zwischenprodukte.
- Wiederverwendung: Reparatur oder erneuter Einsatz brauchbarer Komponenten.

### 3.1 Qualitätsstufen

Als einfache erste Abstufung sind vorgesehen:

- Unsortiert: gemischt oder verunreinigt.
- Sortiert: sauber getrennt und verwertbar.
- Aufbereitet: weiterverarbeitet und für anspruchsvollere Anwendungen geeignet.

Nicht jede Materialart muss alle Qualitätsstufen verwenden.

## 4. Sammeln und Handhabung

### 4.1 Kleine Gegenstände
Kurze Interaktion zum Aufheben. Aufnahme in ein noch festzulegendes Trageinventar oder einen geeigneten Sammelbehälter.

### 4.2 Große Gegenstände
Kontextaktionen wie Hebeln, Schneiden, Demontieren oder Anheben. Erforderliche Werkzeuge und Ausrüstung müssen klar erkennbar sein.

### 4.3 Feedback
- Verständliche Hervorhebung interaktiver Objekte.
- Kurze Animation und Audio-/visuelles Feedback.
- Klare Rückmeldung bei fehlendem Werkzeug oder erreichter Kapazität.

## 5. Wirtschaft

Credits sind die primäre Währung.

### 5.1 Einnahmequellen
- Direktverkauf von gemischtem Schrott oder Einzelobjekten.
- Verkauf sortierter Materialien.
- Verkauf verarbeiteter Produkte.
- Sonderaufträge.
- Seltene Funde und Sammlerstücke, sofern passend.

### 5.2 Ausgaben
- Werkzeuge und Verbesserungen.
- Trage- und Transportkapazität.
- Mitarbeiter und Schichtbetrieb.
- Maschinen und Maschinenverbesserungen.
- Lager, Gebäude und Arbeitsbereiche.
- Fahrzeuge und Transport.
- Grundstücke und neue Standorte.
- Betriebskosten, soweit sie nachvollziehbar und fair sind.

### 5.3 Dynamische Nachfrage
- Grundpreise bilden ein verlässliches wirtschaftliches Sicherheitsnetz.
- Nachfrageereignisse und Sonderaufträge können zeitweise bessere Erlöse bieten.
- Marktschwankungen sind eine Gelegenheit, keine Pflicht zur ständigen Beobachtung.
- Keine dauerhaften Preisabstürze, die den Spielfortschritt blockieren.
- Lagerung kann strategische Entscheidungen ermöglichen, ohne den Spieler zum Spekulieren zu zwingen.

## 6. Beschaffung

Vier Quellen ergänzen sich:

1. Eigene Grundstücke und wiederkehrender Schrottnachschub.
2. Lieferungen von Privatpersonen und Unternehmen.
3. Aktive Beschaffung und Erkundung durch den Spieler.
4. Einkauf, Lieferverträge und eigene Transportnetzwerke.

Die Gewichtung verschiebt sich im Verlauf: Anfangs ist der Spieler stark selbst beteiligt; später übernehmen Mitarbeiter, Lieferanten, Scrappy und automatisierte Logistik einen wachsenden Anteil.

### 6.1 Scrappy in der Beschaffung
Scrappys Beitrag hängt von installierter Hardware, Fähigkeiten und Erfahrung ab. Mögliche Aufgaben sind Erkundung, Materialanalyse, Bergung kleiner Gegenstände, Transportassistenz, Lieferprüfung und Beschaffungshinweise.

Scrappy darf keine geschützten Ressourcen verbrauchen oder wichtige Beschaffungsentscheidungen ohne Freigabe treffen. Seine Aktivitäten bleiben sichtbar, nachvollziehbar und unterbrechbar.

## 7. Mitarbeiter und Arbeitsorganisation

Mitarbeiter sind individuelle Figuren mit funktionalen Eigenschaften. Sie besitzen Persönlichkeit, Eigenheiten und Vorlieben, aber keine komplexe Bedürfnis- oder Lebenssimulation.

Fähigkeiten entwickeln sich durch tatsächliche Arbeit. Mitarbeiter können sich beispielsweise auf Sammlung, Transport, Sortierung, Verarbeitung, Maschinenbedienung oder Logistik spezialisieren.

### 7.1 Rekrutierung
- Bewerbungen.
- Persönliche Begegnungen in der Region.
- Empfehlungen durch Mitarbeiter, Geschäftspartner und Bewohner.
- Besondere Ereignisse.

### 7.2 Arbeitsbereiche
Der Spieler weist Mitarbeiter Arbeitsbereichen zu und steuert die Organisation über wenige verständliche Vorgaben:

- Personalzuordnung bzw. Personalstärke.
- Priorität des Arbeitsbereichs.
- Allgemeine Arbeitsweise oder bevorzugte Aufgaben.

Mitarbeiter wählen innerhalb dieser Grenzen geeignete verfügbare Aufgaben selbst. Das System berücksichtigt Fähigkeiten, Erfahrung, Verfügbarkeit, Wege, Maschinenkompatibilität und Prioritäten.

Keine komplexen Dienstpläne oder permanente Einzelzuweisung jeder Aufgabe.

## 8. Schichtsystem

Mit ausreichender Personalstärke kann der Spieler einzelne Betriebsbereiche im Schichtbetrieb führen.

- Optionale Zwei- und Dreischichtmodelle.
- Einfache Konfiguration pro Betriebsbereich.
- Automatische Zuordnung geeigneter Mitarbeiter.
- Ruhezeiten und Verfügbarkeit werden berücksichtigt.
- Personalengpässe werden verständlich angezeigt.
- Automatisierte Maschinen können auch ohne dauerhaft besetzte Schicht laufen.
- Nachtbetrieb kann zusätzliche Personal- und Betriebskosten verursachen.

Konkrete Schichtlängen, Zuschläge und Personalwerte sind offen und werden später balanciert.

## 9. Welt, Standorte und Transport

Die Hauptregion ist zusammenhängend und frei erkundbar. Große Spezialstandorte können eigene Karten erhalten. Alle Standorte sind über ein gemeinsames Wirtschafts- und Logistiksystem verbunden.

Der Spieler bewegt sich zu Fuß und nutzt Fahrzeuge für größere Entfernungen und Transporte. Später können eigene Fahrzeuge und Transportwege automatisiert werden.

Das Bausystem ist hybrid: Raster und definierte Bauflächen unterstützen Gebäude und große Anlagen; Maschinen, Lagerbereiche, Wege und Dekorationen bieten innerhalb funktionaler Grenzen mehr Freiheit.

## 10. Zeit und Offline-Fortschritt

Die Simulation läuft kontinuierlich mit Tag-Nacht-Rhythmus und täglichen wirtschaftlichen Ereignissen.

Der bevorzugte Offline-Standard für die weitere Konzeption ist:

- Begrenzter Offline-Fortschritt.
- Maximale Offline-Zeit: 24 Stunden.
- Freigegebene Produktion, Lagerbewegungen, geplante Lieferungen, Schichtarbeit und ausgewählte Scrappy-Aktivitäten können simuliert werden.
- Neue Aufträge, wichtige Storyereignisse und Entscheidungen mit Spielerfreigabe pausieren.
- Beim nächsten Start wird ein Abwesenheitsbericht angezeigt.
- Die Offline-Simulation wird aus der vergangenen Zeit berechnet, nicht durch eine laufende Spielinstanz.

Die Einstellung soll später um alternative Modi ergänzt werden können. Schutz vor ungewollten Verlusten und irreversiblen Ereignissen ist unabhängig vom Modus erforderlich.

## 11. Fortschrittsleiter

1. Manuelles Sammeln und Direktverkauf.
2. Erste Werkzeugverbesserung.
3. Bessere Trage- und Transportkapazität.
4. Erster Mitarbeiter mit einer einfachen Aufgabe.
5. Erste Maschine.
6. Erste Sortier- oder Verarbeitungsstation.
7. Weitere Mitarbeiter und Spezialisierungen.
8. Größere Arbeitsbereiche und neue Gegenstandstypen.
9. Fahrzeuge, Lieferungen und zusätzliche Standorte.
10. Vernetzte Produktion und fortgeschrittene Automatisierung.

Die genaue Reihenfolge kann im Prototyp angepasst werden. Das Gefühl, jeden Fortschritt selbst verdient zu haben, bleibt verbindlich.

## 12. Spielende und Auswertung

Das Hauptspiel endet mit dem Aufbau eines regionalen Recycling-Netzwerks und einer finalen Herausforderung, die das Zusammenspiel der Standorte prüft.

Zielgröße für einen normalen Durchlauf: vorläufig 30–40 Stunden. Diese Zeit ist ein Balancing-Ziel, keine künstliche Wartezeit.

Nach dem Hauptabschluss bleibt freies Weiterspielen möglich. Ein optionaler Meisterabschluss bewertet Wirtschaft, Recycling, Automatisierung, Infrastruktur, Personal und Entdeckungen. Bronze, Silber und Gold bilden die vorgesehenen Leistungsstufen. Konkrete Anforderungen werden später durch Tests festgelegt.

Das Statistiksystem erfasst relevante Ereignisse vom Spielbeginn an: Spielzeit, Spieltage, Umsatz, Gewinn, Ausgaben, Materialmengen, Gegenstände, Mitarbeiter, Maschinen, Produktionslinien, Standorte, Automatisierung, Aufträge und Entdeckungen.

## 13. Balancing-Grundsätze

- Käufe sollen in verständlichen Spielsitzungen erreichbar sein.
- Jede Investition löst ein sichtbares Problem oder eröffnet eine sinnvolle Option.
- Keine exponentiellen Preise, die monotonen Grind erzwingen.
- Verarbeitung ist nicht verpflichtend.
- Vor einer Verarbeitung werden erwartete Ausgaben und Ergebnisse verständlich gezeigt.
- Direkter Verkauf bleibt während des gesamten Spiels brauchbar.
- Mitarbeiter- und Betriebskosten dürfen keine verdeckten finanziellen Fallen erzeugen.
- Werte werden in spielbaren Tests ermittelt, nicht vorab als endgültig angenommen.

## 14. Telemetrie und Prototyp-Tests

Zu erfassen sind unter anderem:

- Zeit bis zum ersten Verkauf.
- Zeit bis zu Werkzeug- und Transportverbesserungen.
- Zeit bis zum ersten Mitarbeiter und zur ersten Maschine.
- Kontostand und Geldfluss im Zeitverlauf.
- Verhältnis Direktverkauf zu Verarbeitung.
- Zeit für Laufwege, Transport, Sammeln und Entdecken.
- Auslastung von Mitarbeitern und Maschinen.
- Engpässe in Arbeitsbereichen und Lieferketten.
- Verständlichkeit des Nutzens der nächsten Investition.
- Offline-Ergebnis und Abweichungen zwischen erwarteter und tatsächlicher Simulation.

## 15. Vertiefende Gameplay-Systeme

Die konkreten Regeln für hybride Interaktionen und Zerlegung, Werkzeuge und begrenztes modulares Crafting, automatisierten Fahrzeugbetrieb, Logistik, standortgebundene Lager, Produktionslinien und Energieversorgung stehen in [Interaktion, Transport, Lager, Produktion und Energie](gameplay-interaction-logistics-production.md).

Die dort beschriebenen Systeme folgen denselben wirtschaftlichen Grundsätzen: einfache Tätigkeiten bleiben schnell, komplexere Tätigkeiten müssen zusätzlichen Nutzen bieten, Automatisierung ist optional und Standortgrenzen bzw. Transportzeiten bleiben relevant.

## 16. Erste Prototyp-Abnahmekriterien

- Ein kleiner Gegenstand kann manuell gesammelt werden.
- Ein großer Gegenstand benötigt sichtbar ein passendes Werkzeug.
- Ein Gegenstand kann direkt verkauft werden.
- Ein ausgewählter Gegenstand kann optional zerlegt oder verarbeitet werden.
- Verkauf und Verarbeitung aktualisieren Credits und Ressourcen korrekt.
- Eine grundlegende Verbesserung kann gekauft werden.
- Ein Mitarbeiter übernimmt eine einfache, sichtbare Aufgabe.
- Eine Maschine besitzt eine klare Funktion.
- Der Spieler wird nie durch eine verpflichtende Verarbeitungskette vom Geldverdienen ausgeschlossen.
