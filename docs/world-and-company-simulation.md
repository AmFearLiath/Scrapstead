# Scrapstead — Welt-, Unternehmens- und Simulationskonzept

**Version:** 0.2  
**Status:** Konzeptzwischenstand  
**Stand:** 25.11.2026

Dieses Dokument bündelt die im aktuellen Konzeptionsabschnitt getroffenen Entscheidungen zur langfristigen Spielstruktur, Welt, Wirtschaft, Personalorganisation, Zeit und Ressourcenverarbeitung. Es ergänzt das GDD und die detaillierten Systemspezifikationen. Zahlen und Beispiele, die nicht ausdrücklich als verbindlich markiert sind, bleiben vorläufig.

## 1. Spielidentität und langfristige Ausrichtung

Scrapstead verbindet drei gleichwertige Säulen:

- **Cozy:** Persönlicher Schrottplatz, Gestaltung, Atmosphäre, Bewohner und kleine Geschichten.
- **Tycoon:** Unternehmenswachstum, Investitionen, Personal, Produktion, Standorte und Wirtschaft.
- **Sandbox:** Kreative Bau- und Automatisierungsmöglichkeiten sowie individuelle Produktionslösungen.

Der Schwerpunkt entwickelt sich im Spielverlauf, ohne eine Säule zu verdrängen. Das Spiel beginnt als persönlicher Schrottplatz, wächst zu einem Unternehmen und kann sich zu einem regionalen Netzwerk und einer kreativen Automatisierungs-Spielwiese entwickeln.

## 2. Weltstruktur

**Beschluss: Hybridwelt.**

- Eine zusammenhängende Hauptregion ist frei erkundbar.
- Große Spezialstandorte können eigene Karten oder separat geladene Bereiche erhalten.
- Alle Standorte sind Teil eines gemeinsamen Wirtschafts- und Logistiksystems.
- Der ursprüngliche Schrottplatz bleibt das emotionale Zentrum und wird im späten Spiel nicht bedeutungslos.

Erste Gebietsplanung:

1. Old Yard — ursprünglicher Schrottplatz.
2. Scrapstead Town — Kleinstadt, Geschäfte, Bewohner und lokale Aufträge.
3. Industrial Quarter — Werkstätten, Lager und kleinere Fabriken.
4. Railway District — Güterbahnhof und Transportumschlag.
5. Greenbelt — ländliche Umgebung, Landwirtschaft, Wälder und kleinere Betriebe.
6. Quarry & Extraction — Steinbruch und Rohstoffquellen; als späterer Spezialstandort möglich.

Die Region ist als ehemals florierende Industrieregion gedacht, die wirtschaftlich heruntergekommen ist, aber weiterhin von Menschen und kleinen Unternehmen belebt wird. Konkrete Karte, Maßstab und Gebietsgrenzen sind noch offen.

## 3. Fortbewegung und Fahrzeuge

**Beschluss: Zu Fuß und mit Fahrzeugen.**

- Zu Fuß erledigt der Spieler Erkundung, Sammeln, Interaktionen und kleinere Arbeiten.
- Fahrzeuge dienen größeren Entfernungen, schweren Gegenständen und Materialtransporten.
- Fahrzeuge können später verbessert, spezialisiert und individualisiert werden.
- Mögliche Klassen: kleiner Pickup, Pritschenwagen, Gabelstapler und größere Nutzfahrzeuge.
- Fahrzeuge und Transportwege können später Teil automatisierter Logistik werden.

Fahrzeugliste, Fahrphysik, Bedienung und Umfang sind noch nicht festgelegt.

## 4. Bauen und Platzierung

**Beschluss: Hybrides Bausystem.**

- Gebäude und große Anlagen nutzen Raster, definierte Bauflächen oder standardisierte Anschlussregeln.
- Maschinen werden innerhalb zulässiger Bereiche flexibel platziert.
- Lager, Wege, Dekorationen und kleinere Objekte erhalten weitgehende Gestaltungsfreiheit.
- Raster ist eine Orientierung und Präzisionshilfe, keine starre Einschränkung aller Objekte.
- Funktionsprüfungen berücksichtigen Kollisionen, Zugang, Arbeitsbereiche, Ein- und Ausgaben sowie Transportverbindungen.
- Das Spiel unterstützt Verbindungen und Routenplanung, statt manuelle Logistikprogrammierung vorauszusetzen.

Die bestehende Bauspezifikation bleibt für Details maßgeblich; dieser Beschluss ersetzt nicht die dort bereits dokumentierten Regeln zu Verbindungspunkten, Snap, Bauwerkzeugen und modularen Gebäuden.

## 5. Wirtschaft und Markt

**Beschluss: Stabile Grundwirtschaft mit dynamischen Marktchancen.**

- Grundpreise bieten einen verlässlichen wirtschaftlichen Boden.
- Nachfrage, Sonderaufträge und ausgewählte Materialpreise können dynamisch variieren.
- Marktereignisse sollen interessante Entscheidungen ermöglichen, aber keine ständige Beobachtungspflicht erzeugen.
- Direktverkauf bleibt dauerhaft brauchbar.
- Verarbeitung bietet situativ zusätzliche Wertschöpfung, wird aber nicht für jedes Objekt verpflichtend.

## 6. Beschaffung

**Beschluss: Vier miteinander kombinierte Beschaffungswege.**

1. Eigener Schrottplatz und wiederkehrender Nachschub.
2. Anlieferungen durch Privatpersonen und Unternehmen.
3. Aktive Beschaffung und Erkundung durch den Spieler.
4. Einkauf, Lieferverträge und eigene Transportnetzwerke.

Die Gewichtung entwickelt sich: Der Spieler übernimmt am Anfang viel selbst. Später tragen Mitarbeiter, Lieferanten, Scrappy und automatisierte Logistik zunehmend zur Versorgung bei.

### 6.1 Scrappy als Beschaffungshelfer

Scrappy wird aktiv eingebunden, bleibt aber eigenständiger Begleiter und kein austauschbarer Logistikroboter.

Abhängig von Hardware, Fähigkeiten und Erfahrung kann er:

- Interessante Fundorte erkunden und melden.
- Materialien und Gegenstände analysieren.
- Kleine, freigegebene Gegenstände bergen.
- Beim Transport und Beladen helfen.
- Lieferungen prüfen und Auffälligkeiten melden.
- Vorschläge zu Beschaffung und Lagerung machen.

Wichtige Ressourcen, wertvolle Gegenstände und wirtschaftliche Entscheidungen bleiben geschützt. Scrappy darf sie nicht ohne Zustimmung des Spielers verändern.

## 7. Mitarbeiter

**Beschluss: Individuelle Persönlichkeiten mit funktionalen Eigenschaften.**

Mitarbeiter besitzen Namen, Erscheinungsbilder, Eigenheiten, Vorlieben und kleine persönliche Verhaltensweisen. Zugleich haben sie Fähigkeiten und Erfahrung, die sich durch tatsächliche Arbeit entwickeln.

Neue Mitarbeiter können über Bewerbungen, persönliche Begegnungen, Empfehlungen und besondere Ereignisse gewonnen werden.

### 7.1 Einfache Arbeitsorganisation

**Beschluss: Hybrid mit autonomer Aufgabenverteilung, ausdrücklich ohne unnötige Komplexität.**

Der Spieler definiert Arbeitsbereiche, Personalzuordnung und Prioritäten. Mitarbeiter organisieren geeignete konkrete Tätigkeiten innerhalb dieser Vorgaben selbst.

Die Bedienung soll sich auf wenige verständliche Einstellungen beschränken. Der Spieler soll nicht jeden Mitarbeiter und jeden Arbeitsschritt einzeln dirigieren müssen.

Keine komplexe Lebenssimulation, keine täglichen Bedürfnisbalken und keine Personal-Mikroverwaltung.

## 8. Schichtsystem

**Beschluss: Optionaler Schichtbetrieb bei ausreichender Personalstärke.**

- Arbeitsbereiche können im Ein-, Zwei- oder perspektivisch Dreischichtbetrieb organisiert werden.
- Schichten werden einfach pro Betriebsbereich konfiguriert.
- Mitarbeiter werden automatisch zugeordnet.
- Qualifikation, Verfügbarkeit und Ruhezeiten werden berücksichtigt.
- Personalmangel führt zu nachvollziehbar reduzierter Leistung.
- Vollautomatisierte Maschinen können unabhängig von einer besetzten Schicht weiterlaufen.
- Nachtbetrieb kann zusätzliche Personal- und Betriebskosten verursachen.

Die gezeigten Schichtzeiten und Mitarbeiterzahlen aus Beispielen sind keine festgelegten Balancewerte.

## 9. Zeitmodell

**Beschluss: Kontinuierliche Echtzeit mit Tag-Nacht-Rhythmus und täglichen Wirtschaftsereignissen.**

Die Welt und ihre Systeme laufen kontinuierlich. Tageswechsel können Abrechnungen, Lieferungen, Marktveränderungen und andere Ereignisse auslösen. Arbeitszeiten und Schichtbetrieb bestimmen, welche Tätigkeiten zu welchen Zeiten verfügbar sind.

## 10. Offline-Fortschritt

**Konzeptionelle Präferenz: Begrenzter Offline-Fortschritt mit maximal 24 Stunden.**

- Freigegebene Maschinenproduktion, Lagerbewegungen, geplante Lieferungen, Schichtarbeit und ausgewählte Scrappy-Aktivitäten können weiterlaufen.
- Neue Aufträge, wichtige Storyereignisse und Entscheidungen mit Spielerfreigabe pausieren.
- Der nächste Spielstart zeigt einen Abwesenheitsbericht mit Produktion, Einnahmen, Ausgaben und Ereignissen.
- Die Simulation wird beim Wiederstart anhand der vergangenen Zeit berechnet, nicht durch eine laufende Spielinstanz.
- Schutzregeln verhindern ungewollte Verluste und irreversible Entscheidungen.

Diese Einstellung ist die aktuelle Präferenz für die weitere Konzeption. Alternative Modi (pausieren oder vollständig simulieren) können später als Optionen geprüft werden. Der begrenzte Modus ist noch nicht durch einen Prototyp validiert.

## 11. Ressourcenmodell

**Beschluss: Modulares Vier-Ebenen-Modell.**

1. Fundstücke und Gegenstände.
2. Rohmaterialien.
3. Wiederverwendbare Komponenten.
4. Aufbereitete Produkte und Erzeugnisse.

Erste Materialgruppen:

- Metalle.
- Kunststoffe.
- Elektronik.
- Holz und Naturmaterialien.
- Mineralische Stoffe.
- Besondere Fundstücke und seltene Komponenten.

Die Kategorien sind ein Startgerüst und keine finale vollständige Materialliste.

## 12. Zerlegung und Verarbeitung

**Beschluss: Hybridmodell.**

- Gewöhnliche Gegenstände werden vereinfacht in wenige Materialgruppen zerlegt.
- Komplexe, seltene oder wertvolle Gegenstände können detaillierte Einzelkomponenten besitzen.
- Nicht jeder Gegenstand benötigt eine vollständige Komponentenliste oder mehrere Verarbeitungsschritte.
- Verarbeitung kann Sortierung, Demontage, Aufbereitung und Wiederverwendung umfassen.
- Eine einfache Qualitätsabstufung kann unsortiert, sortiert und aufbereitet unterscheiden.

Ziel ist eine zugängliche alltägliche Verarbeitung mit besonderen Detailmöglichkeiten für interessante Objekte. Das System bleibt datengetrieben und erweiterbar.

## 13. Hauptabschluss und Meisterabschluss

**Beschluss: Scrapstead besitzt ein echtes Hauptende und einen optionalen Meisterabschluss.**

Das Hauptspiel endet mit dem Aufbau eines regionalen Recycling-Netzwerks und einer finalen Herausforderung, die das Zusammenspiel der Standorte und Betriebsabläufe prüft.

- Vorläufiges Ziel für die Hauptspielzeit: 30–40 Stunden.
- Die Zeit ist ein Entwicklungsziel und muss durch Tests validiert werden.
- Nach dem Hauptabschluss bleibt freies Weiterspielen möglich.
- Die Abschlussauswertung zeigt die wichtigsten Statistiken des gesamten Durchlaufs.

Der optionale Meisterabschluss bewertet sechs Kategorien:

1. Wirtschaft.
2. Recycling.
3. Automatisierung.
4. Infrastruktur.
5. Personal.
6. Entdeckungen.

Vorgesehene Stufen:

- Bronze: regulärer Hauptabschluss.
- Silber: fortgeschrittene Zusatzleistungen.
- Gold: Meisterabschluss mit Anforderungen in allen sechs Kategorien.

Zusätzlich sind individuelle Auszeichnungen und persönliche Rekorde vorgesehen. Schwellenwerte und konkrete Herausforderungen bleiben offen, bis die Spielsysteme und Balancewerte getestet werden können.

## 14. Statistiksystem

Relevante Ereignisse sollen vom Spielbeginn an erfasst werden. Geplante Statistikgruppen:

- Zeit: Gesamtspielzeit, Spieltage und Zeiten bis zu wichtigen Meilensteinen.
- Wirtschaft: Umsatz, Gewinn, Ausgaben und besondere Transaktionen.
- Recycling: Mengen, Materialien, zerlegte Objekte und wiederverwendete Komponenten.
- Unternehmen: Standorte, Mitarbeiter, Maschinen und Produktionslinien.
- Automatisierung: automatisierte Prozesse, Durchsatz und manuelle Arbeitsanteile.
- Entdeckungen: Materialien, Fundstücke, Rezepte und besondere Inhalte.
- Scrappy: Module, Fähigkeiten, eigene Projekte und besondere gemeinsame Erlebnisse.

Die Statistikwerte sind zunächst Berichtsdaten. Nicht jede Kennzahl muss in eine Abschlussnote oder Punktzahl einfließen.

## 15. Interaktion, Logistik und Produktion

Die detaillierten Entscheidungen zu Interaktion und Zerlegung, Werkzeugen und Crafting, Fahrzeugbetrieb, Transportaufträgen, Lagerverwaltung, standortübergreifender Versorgung, Produktionslinien und Energie sind in [Interaktion, Transport, Lager, Produktion und Energie](gameplay-interaction-logistics-production.md) dokumentiert.

Grundsatz: Der Spieler steuert Ziele, Prioritäten und Ausbau. Fahrzeuge, Mitarbeiter, Lagerbewegungen und Maschinen übernehmen die operative Ausführung innerhalb nachvollziehbarer Regeln. Komplexität wird schrittweise eingeführt und bleibt – soweit sie nicht für eine konkrete Aktion erforderlich ist – optional.

## 16. Noch offene Ausarbeitung

- Exakte Karte, Maßstab und Freischaltfolge der Region.
- Konkrete Fahrzeugklassen und Fahrmodell.
- Bauflächen-, Raster- und Platzierungsdetails für verschiedene Standorttypen.
- Materialliste, Gegenstandszusammensetzungen und Rezepte.
- Wirtschaftswerte, Nachfragekurven und Vertragsmodelle.
- Personalbedarf, Schichtlängen, Löhne und Betriebskosten.
- Offline-Simulationsregeln und Grenzfälle.
- Finale Abschlussmission und konkrete Meisteranforderungen.
- Statistikdefinitionen und Auszeichnungsregeln.

Diese offenen Punkte werden in den jeweiligen Spezifikationen ausgearbeitet und anhand von Prototypen validiert.
