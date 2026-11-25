# Scrapstead — Game Design Document

**Version:** 1.5  
**Status:** Pre-production / Konzeptionsstand  
**Genre:** Cozy Automation Tycoon mit Sandbox-Charakter / Incremental Simulation  
**Plattformziel:** Zunächst PC  
**Perspektive:** Isometrisches 3D  
**Visueller Stil:** Stylized Low-Poly / Cozy Diorama  
**Tagline:** Every Scrap Has a Story.

## 1. High Concept

Der Spieler erbt einen heruntergekommenen Schrottplatz und baut daraus Schritt für Schritt einen erfolgreichen Recyclingbetrieb auf. Aus manueller Arbeit, kleinen Verkäufen und ersten Werkzeugverbesserungen entwickelt sich ein Unternehmen mit Mitarbeitern, Maschinen, mehreren Standorten und zunehmend automatisierten Abläufen.

Scrapstead verbindet drei gleichberechtigte Identitäten:

- **Cozy:** Ein persönlicher, gestaltbarer Ort mit Charakter, Bewohnern, kleinen Geschichten und einer warmen Atmosphäre.
- **Tycoon:** Ein wachsendes Unternehmen mit Investitionen, Personal, Produktion, Aufträgen, Standorten und wirtschaftlichen Entscheidungen.
- **Sandbox:** Kreative Freiheit beim Bauen, Einrichten, Kombinieren und Automatisieren eigener Betriebsabläufe.

Der ursprüngliche Schrottplatz bleibt auch im späten Spiel das emotionale Zentrum. Das langfristige Ziel ist der Aufbau eines regionalen Recycling-Netzwerks.

Scrappy, ein eigenwilliger modularer Roboter, wird zum Begleiter und eigenständigen Bewohner des Betriebs.

## 2. Design-Pfeiler

1. **Einfacher Einstieg, langfristige Tiefe.** Einzelne Aktionen und Systeme sind verständlich. Komplexität entsteht durch ihre Kombination.
2. **Sichtbarer Fortschritt.** Grundstücke, Gebäude, Maschinen, Mitarbeiter und Scrappy verändern sich erkennbar.
3. **Manuell beginnen, sinnvoll delegieren.** Automatisierung nimmt Wiederholungen ab, nicht die Entscheidungsfreiheit.
4. **Cozy, Tycoon und Sandbox gehören zusammen.** Atmosphäre, Wirtschaft und Kreativität bleiben über den gesamten Spielverlauf relevant.
5. **Bedeutsame Entscheidungen ohne Pflicht-Mikromanagement.** Der Spieler steuert Ziele und Prioritäten, nicht jeden einzelnen Arbeitsschritt.
6. **Spielerfreiheit.** Sammeln, Verkaufen, Verarbeiten, Bauen und Optimieren bieten unterschiedliche gültige Spielweisen.
7. **Lebendige Figuren.** Scrappy, Mitarbeiter und Bewohner besitzen erkennbare Eigenheiten, ohne eine komplexe Lebenssimulation zu erzwingen.
8. **Vollständig mehrsprachig von Anfang an.** Alle spielerseitigen Inhalte verwenden Lokalisierungsschlüssel. Deutsch und Englisch sind die ersten Referenzsprachen.

## 3. Kernspielschleife

Erkunden → Beschaffen → Sammeln → Verkaufen oder Verarbeiten → Verdienen → Investieren → Delegieren → Automatisieren → Expandieren.

Beschaffung und Verarbeitung bieten mehrere gleichberechtigte Wege. Gewöhnliche Gegenstände können direkt verkauft werden. Ausgewählte Gegenstände lassen sich sortieren, zerlegen, aufbereiten oder als Komponenten wiederverwenden. Verarbeitung ist eine Chance auf zusätzliche Wertschöpfung, keine Pflicht für jedes Objekt.

Die zentralen Gameplay-Aktivitäten – Bergen, Erkunden, Verarbeiten, Bauen und Wirtschaften – erhalten eine ausgewogene Bedeutung. Der Spieler kann eigene Schwerpunkte setzen; keine einzelne Aktivität wird zur Pflicht für alle Spielstile.

## 4. Spielverlauf und Progression

Die Entwicklung soll sich verdient und schrittweise anfühlen:

1. Der Spieler erledigt fast alle Arbeiten selbst.
2. Werkzeuge und Transportkapazität werden verbessert.
3. Scrappy wird entdeckt und wiederhergestellt.
4. Der erste Mitarbeiter übernimmt eine einfache, bereits bekannte Tätigkeit.
5. Die erste Maschine automatisiert eine klar verständliche Aufgabe.
6. Weitere Arbeitsbereiche, Maschinen, Mitarbeiter und Verarbeitungsschritte kommen hinzu.
7. Der ursprüngliche Betrieb wächst und neue Standorte werden erschlossen.
8. Beschaffung, Transport und Produktion werden zunehmend vernetzt und automatisiert.
9. Das Unternehmen entwickelt sich zu einem regionalen Recycling-Netzwerk.

Die frühe Reihenfolge Mitarbeiter vor erster Maschine ist eine gewünschte Dramaturgie und wird im Prototyp überprüft. Exakte Preise, Löhne, Produktionsraten und Zeitpunkte werden erst durch spielbare Tests festgelegt.

## 5. Wirtschaftliche Grundsätze

- Credits sind die primäre Währung.
- Direktverkauf bietet verlässliche, unkomplizierte Einnahmen.
- Sortierung, Demontage und Verarbeitung können zusätzliche Wertschöpfung ermöglichen.
- Die Grundwirtschaft bleibt verständlich und relativ stabil.
- Nachfrage, Sonderaufträge und ausgewählte Materialpreise können sich dynamisch verändern.
- Marktschwankungen sollen Chancen eröffnen, aber keine permanente Marktbeobachtung erzwingen.
- Investitionen müssen Kosten und Nutzen nachvollziehbar kommunizieren.
- Keine künstlichen Wartewände, Strafspiralen oder wirtschaftlichen Softlocks.
- Konkrete Werte werden anhand spielbarer Prototypen ausbalanciert.

## 6. Mitarbeiter

Mitarbeiter sind individuelle Figuren und zugleich funktionale Bestandteile des Betriebs. Sie sollen keine gesichtslosen Arbeitskräfte sein, aber auch keine komplexe Lebenssimulation auslösen.

Jeder Mitarbeiter kann besitzen:

- Name, Erscheinungsbild und erkennbare Persönlichkeit.
- Kleine Eigenheiten, Vorlieben und Abneigungen.
- Fähigkeiten, Erfahrung und mögliche Spezialisierungen.
- Bevorzugte Tätigkeiten und nachvollziehbare Arbeitsleistung.
- Einen verständlichen Lohn bzw. Betriebskostenbeitrag.
- Kleine Reaktionen, Gewohnheiten und soziale Interaktionen.

Fähigkeiten entwickeln sich durch tatsächlich ausgeführte Tätigkeiten. Ein Sortierer wird mit Erfahrung zuverlässiger, ein Fahrer mit bestimmten Strecken vertrauter. Ein komplizierter Skilltree ist nicht vorgesehen.

Neue Mitarbeiter kommen über Bewerbungen, persönliche Begegnungen, Empfehlungen und besondere Ereignisse zur Belegschaft.

Der Spieler organisiert Mitarbeiter über Arbeitsbereiche und wenige verständliche Vorgaben:

- Personalstärke bzw. Personalzuordnung.
- Priorität des Arbeitsbereichs.
- Allgemeine Arbeitsweise oder bevorzugte Aufgaben.

Innerhalb dieser Vorgaben verteilen Mitarbeiter geeignete Aufgaben selbstständig. Fähigkeiten, Erfahrung, Verfügbarkeit, Arbeitsbereich und Prioritäten werden berücksichtigt. Der Spieler verwaltet das Unternehmen, nicht jeden einzelnen Arbeitsschritt.

Keine Hunger- oder Toilettenbedürfnisse, keine täglichen Zufriedenheitskrisen, keine komplexen Hierarchien und keine verpflichtende Personal-Mikroverwaltung.

## 7. Arbeitszeiten und Schichtsystem

Die Welt simuliert kontinuierlich in Echtzeit und besitzt einen Tag-Nacht-Rhythmus. Tageswechsel können Abrechnungen, Lieferungen, Marktänderungen und andere wirtschaftliche Ereignisse auslösen.

Betriebe können zunächst mit üblichen Arbeitszeiten laufen. Mit ausreichender Personalstärke kann der Spieler optionale Schichtmodelle einführen, beispielsweise Zwei- oder Dreischichtbetrieb.

- Schichten werden pro Betriebsbereich einfach konfiguriert.
- Das System ordnet geeignete Mitarbeiter automatisch zu.
- Personalverfügbarkeit, Qualifikation und Ruhezeiten werden berücksichtigt.
- Personalmangel reduziert den Betrieb nachvollziehbar, statt komplizierte Dienstplanverwaltung zu erzwingen.
- Vollautomatisierte Maschinen können unabhängig von einer besetzten Schicht weiterlaufen, sofern der Betrieb entsprechend eingerichtet ist.
- Nachtbetrieb kann zusätzliche Personal-, Energie- oder Betriebskosten verursachen. Höhe und konkrete Regeln bleiben offen.

## 8. Beschaffung und Liefernetzwerk

Scrapstead besitzt vier Materialquellen:

1. Wiederkehrender Nachschub und Fundstücke auf eigenen Grundstücken.
2. Anlieferungen durch Privatpersonen und Unternehmen.
3. Aktive Beschaffung und Erkundung durch den Spieler.
4. Einkauf, Lieferverträge und eigene Beschaffungs- und Transportnetzwerke.

Die Bedeutung verschiebt sich mit dem Fortschritt: Anfangs sammelt und organisiert der Spieler selbst. Später übernehmen Mitarbeiter, Lieferanten, Scrappy und automatisierte Logistik einen wachsenden Teil.

Scrappy kann – abhängig von installierter Hardware, Fähigkeiten und Erfahrung – Fundorte erkunden, Materialien analysieren, kleine Gegenstände bergen, Transporte unterstützen, Lieferungen prüfen und Beschaffungsvorschläge machen. Er darf keine wichtigen wirtschaftlichen Entscheidungen oder geschützten Gegenstände ohne Freigabe des Spielers verändern.

## 9. Welt und Standortstruktur

Die Spielwelt verwendet ein Hybridmodell:

- Eine zusammenhängende, frei erkundbare Hauptregion umfasst den ursprünglichen Schrottplatz, die Kleinstadt, Straßen, Landschaft, kleinere Betriebe und nahegelegene Industriegebiete.
- Große oder spezialisierte Standorte wie Steinbruch, Großfabrik oder Recyclingzentrum können eigene Karten bzw. separat geladene Bereiche erhalten.
- Alle Standorte gehören zu einem gemeinsamen Wirtschaftssystem.
- Material, Aufträge, Lieferungen und wirtschaftliche Entwicklungen können standortübergreifend zusammenwirken.

Die Region ist eine ehemals florierende Industrieregion, die wirtschaftlich heruntergekommen ist, aber weiterhin von Bewohnern, kleinen Betrieben und Lieferanten belebt wird.

Erste konzeptionelle Bereiche:

- Old Yard: ursprünglicher Schrottplatz und emotionales Zentrum.
- Scrapstead Town: Kleinstadt, Geschäfte, Bewohner, Aufträge und Lieferanten.
- Industrial Quarter: Werkstätten, Lager und kleinere Fabriken.
- Railway District: Güterbahnhof und Transportumschlag.
- Greenbelt: ländliche Umgebung, Landwirtschaft, Wälder und kleinere Betriebe.
- Quarry & Extraction: Steinbruch und Rohstoffquellen; als späterer Spezialstandort möglich.

Die Gebietsliste und konkrete Karte sind noch nicht final.

Die konkreten Erkundungsräume, Landmarken, Fundorte, Bewohner, Aufträge, Ereignisse und regionalen Aktivitäten sind in [Welt, Erkundung und Aktivitäten](world-exploration-activities.md) ausgearbeitet.

## 10. Fortbewegung, Transport und Logistik

Der Spieler bewegt sich zu Fuß für Erkundung, Sammeln, Interaktionen und kleinere Arbeiten. Fahrzeuge dienen größeren Distanzen, schweren Gegenständen und Materialtransporten.

**Fahrzeuge werden nicht direkt vom Spieler gesteuert.** Sie sind Teil des Unternehmens- und Logistiksystems und werden über Einzelaufträge, feste Routen und intelligente Dispositionsregeln organisiert.

- Kleine Gegenstände werden über persönliches Inventar bzw. Sammelbehälter transportiert; größere Gegenstände über Handtransport, Fahrzeuge und Maschinen.
- Kleinteile werden bei Fahrzeugen abstrakt über Kapazität und Gewicht geladen. Mittlere und große Gegenstände können sichtbar auf Ladeflächen dargestellt bzw. verladen werden.
- Fahrzeugklasse, Beladung, Gewicht, Zustand und Streckenbedingungen beeinflussen Eignung und Transportleistung; eine vollständige Fahrphysik ist nicht vorgesehen.
- Fahrzeuge können autonom, personalgebunden oder situationsabhängig betrieben werden.
- Das Logistiksystem kombiniert Einzelaufträge, feste Routen und intelligente Zuordnung.
- Unkritische Transportprobleme werden automatisch gelöst. Bei wichtigen Entscheidungen oder fehlenden Lösungen wird der Spieler informiert bzw. um Freigabe gebeten.
- Lagerbestände bleiben standortgebunden. Versorgung anderer Standorte erfolgt über simulierte Transporte mit realistischen Kapazitäten und Transportzeiten.

Details stehen in [Interaktion, Transport, Lager, Produktion und Energie](gameplay-interaction-logistics-production.md).

## 11. Bauen und Gestaltung

Das Bausystem ist hybrid:

- Gebäude und große Anlagen nutzen definierte Bauflächen, Raster oder standardisierte Anschlussregeln.
- Maschinen können innerhalb zulässiger Bereiche flexibel platziert und ausgerichtet werden.
- Wege, Lagerbereiche, Dekorationen und kleinere Objekte erhalten weitgehende Gestaltungsfreiheit.
- Ein Raster dient als Orientierung und Präzisionshilfe, nicht als universelle Einschränkung.
- Funktionale Regeln prüfen Zugänge, Arbeitsbereiche, Kollisionen, Ein- und Ausgabepunkte sowie Transportverbindungen.
- Produktionsanlagen können physische Fördertechnik und logische Materialverbindungen kombinieren. Einzelmaschinen bleiben ebenso sinnvoll wie komplexe Produktionslinien.
- Die Energieversorgung kombiniert externen Netzbezug mit optionaler Eigenproduktion. Kleine Betriebe nutzen eine vereinfachte Versorgung; größere Anlagen können ein ausbaubares Stromnetz erhalten. Vollständige Energieautonomie ist ein mögliches spätes Ausbauziel, aber keine Pflicht.
- Maschinenverbindungen sollen einfach angelegt werden können; die Routenplanung wird soweit möglich vom Spiel unterstützt.
- Komplexe manuelle Logistikprogrammierung ist kein Pflichtsystem.

Fertiggebäude und modulare Gebäudekonstruktion bleiben kombinierbar. Umfangreiche Gestaltungsmöglichkeiten werden schrittweise eingeführt, ohne grundlegende Kreativität unnötig zu blockieren.

## 12. Ressourcen und Verarbeitung

Das Ressourcensystem ist modular und datengetrieben. Es unterscheidet vier Ebenen:

1. **Fundstücke und Gegenstände:** z. B. Kühlschrank, Fahrrad, Fernseher oder Autowrack.
2. **Rohmaterialien:** z. B. Eisen, Stahl, Aluminium, Kupfer, Kunststoffe, Glas und Holz.
3. **Komponenten:** z. B. Motoren, Zahnräder, Kabel, Platinen, Sensoren und Lager.
4. **Produkte und Erzeugnisse:** z. B. Metallplatten, Kunststoffgranulat, Ersatzteile oder Baugruppen.

Erste Materialgruppen:

- Metalle.
- Kunststoffe.
- Elektronik.
- Holz und Naturmaterialien.
- Mineralische Stoffe.
- Besondere Fundstücke und seltene Komponenten.

Die Zerlegung folgt einem Hybridansatz:

- Gewöhnliche Gegenstände werden in wenige verständliche Materialgruppen zerlegt.
- Komplexe, seltene oder wertvolle Gegenstände können detaillierte Einzelkomponenten besitzen.
- Verarbeitung kann Sortierung, Demontage, Aufbereitung und Wiederverwendung umfassen.
- Qualitätsstufen können unsortiert, sortiert und aufbereitet unterscheiden.
- Nicht jeder Gegenstand benötigt alle Stufen oder eine detaillierte Komponentenliste.

Der Umfang wird schrittweise erweitert. Eine große Materialtaxonomie ist kein Selbstzweck.

Die Interaktion, Werkzeuge, das begrenzte modulare Crafting und die wirtschaftlichen Auswirkungen sorgfältiger Zerlegung sind in [Interaktion, Transport, Lager, Produktion und Energie](gameplay-interaction-logistics-production.md) konkretisiert.

## 13. Zeit und Offline-Simulation

Die Spielwelt läuft kontinuierlich in Echtzeit. Tag-Nacht-Wechsel beeinflussen Atmosphäre, NPC-Verhalten, Arbeitszeiten und ausgewählte Ereignisse. Tägliche Abrechnungen und Lieferereignisse ergänzen die kontinuierliche Simulation.

Offline-Fortschritt ist eine einstellbare Spieleinstellung. Der aktuelle Konzeptstandard ist:

- Modus: begrenzter Offline-Fortschritt.
- Maximale Offline-Zeit: 24 Stunden.
- Freigegebene Produktion, Lagerbewegungen, geplante Lieferungen, Schichtarbeit und ausgewählte Scrappy-Aktivitäten können weiter simuliert werden.
- Neue Aufträge, wichtige Storyereignisse und Entscheidungen mit Spielerfreigabe pausieren.
- Beim nächsten Start erhält der Spieler einen Abwesenheitsbericht mit Produktion, Einnahmen, Ausgaben und besonderen Ereignissen.
- Die Simulation wird beim Wiederstart aus der vergangenen Zeit berechnet; keine laufende Spielinstanz ist erforderlich.
- Schutzregeln verhindern ungewollte Verluste und irreversible Entscheidungen während der Abwesenheit.

Weitere Offline-Modi können als Optionen vorgesehen werden. Die genaue Liste und Balance bleiben zu validieren.

## 14. Spielziel und Abschluss

Scrapstead besitzt ein echtes Hauptende. Der Spieler entwickelt den ursprünglichen Schrottplatz zu einem regionalen Recycling-Netzwerk und bewältigt eine finale Herausforderung, die das Zusammenspiel der Standorte und Betriebsabläufe prüft.

Zielwert für einen normalen Durchlauf: zunächst etwa 30–40 Stunden. Das ist eine Entwicklungsannahme und wird durch Spieltests validiert, nicht durch künstliche Wartezeiten erreicht.

Nach dem Hauptabschluss bleibt freies Weiterspielen möglich. Die Welt und das Unternehmen können weiterentwickelt werden.

Zusätzlich gibt es einen optionalen Meisterabschluss. Er bewertet sechs Kategorien:

- Wirtschaft.
- Recycling.
- Automatisierung.
- Infrastruktur.
- Personal.
- Entdeckungen.

Vorgesehen sind drei Leistungsstufen: Bronze für den regulären Hauptabschluss, Silber für fortgeschrittene Zusatzleistungen und Gold für den Meisterabschluss. Individuelle Auszeichnungen und persönliche Rekorde ergänzen die Bewertung. Die konkreten Schwellenwerte werden später anhand der Spielbalance definiert.

Das Spiel erfasst relevante Statistiken von Beginn an, unter anderem Spielzeit, Spieltage, Umsatz, Gewinn, verarbeitete Mengen, Materialien, Mitarbeiter, Maschinen, Standorte, Produktionslinien, Automatisierung und Entdeckungen.

## 15. Scrappy

Scrappy ist Begleiter, Helfer, eigenständiger Bewohner und wiedererkennbare Figur. Seine technische Ausstattung, persönliche Entwicklung und Persönlichkeit sind getrennte Ebenen.

Er kann den Spieler unterstützen, eigene Aktivitäten verfolgen, Erinnerungen entwickeln und – abhängig von Modulen und Erfahrung – bei Beschaffung, Analyse, Bergung und Logistik mitwirken. Seine Eigeninitiative bleibt begrenzt und konfigurierbar. Wichtige Gegenstände und Entscheidungen bleiben geschützt.

Die ausführliche Spezifikation steht in [Scrappy Companion](scrappy-companion.md). Dialogtexte bleiben ausdrücklich spätere Arbeit.

## 16. UI und UX

- Die Spielwelt bleibt im Mittelpunkt.
- Kompakte HUD-Elemente zeigen wichtige Werte und Ziele.
- Arbeitsbereiche und Betriebsverwaltung bieten wenige verständliche Einstellungen.
- Kosten, Erträge, Produktionsstatus und Probleme werden transparent kommuniziert.
- Neue Systeme werden kontextbezogen und schrittweise erklärt.
- Keine überladenen Menüs und keine verpflichtenden komplexen Produktionsdiagramme.

## 17. Mehrsprachigkeit

Scrapstead wird von Anfang an vollständig mehrsprachig entwickelt.

- Jeder spielerseitige Text wird über Lokalisierungsschlüssel eingebunden.
- Spiel-IDs, Save-Daten, Asset-Bezeichner und Spiellogik sind sprachunabhängig.
- Deutsch und Englisch sind die ersten Referenzsprachen.
- Weitere Sprachen müssen ohne Änderungen an Spiellogik oder Inhalts-IDs ergänzt werden können.
- Layouts berücksichtigen Textausdehnung, Schriftarten, Unicode, Pluralformen sowie locale-aware Zahlen-, Datums- und Währungsformatierung.
- Fehlende Übersetzungen und Schlüsselabweichungen werden automatisiert erkannt.
- Scrappys Humor wird sinngemäß lokalisiert, nicht mechanisch übersetzt.

Details stehen in [Localization & Internationalization Standard](localization.md).

## 18. MVP und Prototypumfang

Der erste Prototyp soll weiterhin eine kleine, überschaubare Spielfläche und die Kernschleife validieren:

- Kleine Gegenstände manuell sammeln.
- Ein großes Objekt mit Werkzeug bearbeiten.
- Direkt verkaufen.
- Einen ausgewählten Gegenstand optional zerlegen oder verarbeiten.
- Eine sinnvolle Verbesserung kaufen.
- Scrappy entdecken und wiederherstellen.
- Einen Mitarbeiter mit einer einfachen Aufgabe einsetzen.
- Eine Maschine mit einer klaren Funktion demonstrieren.

Regionale Expansion, vollständiges Schichtsystem, vollständige Offline-Simulation und umfangreiche Mitarbeiter- oder Materialsysteme gehören nicht automatisch in den ersten Prototyp. Sie werden später schrittweise validiert.

## 19. Nicht-Ziele für den ersten Prototyp

- Multiplayer.
- Komplexe manuelle Logistikprogrammierung.
- Pflichtverarbeitung jedes Gegenstands.
- Tiefe Mitarbeiter-Lebenssimulation.
- Komplexes Stromnetzmanagement.
- Große prozedurale Welt.
- Umfangreiche narrative Kampagne.
- Verpflichtendes Wartungs-Mikromanagement.

## 20. Erfolgskriterien

Der Kern funktioniert, wenn neue Spieler die ersten Aktionen ohne Handbuch verstehen, der erste Verkauf belohnend wirkt, das nächste Investitionsziel klar ist und die Entwicklung von manueller Arbeit zu einem selbstständig laufenden Unternehmen Freude bereitet.

Langfristig soll Scrapstead unterschiedliche Spielstile unterstützen: gemütliches Gestalten, wirtschaftliches Optimieren, kreative Automatisierung und das Entdecken einer lebendigen Region.


## Ergänzung: Bewohner und regionale Beziehungen

Bewohner werden als wiederkehrende, individuell erkennbare Figuren mit eigenen Rollen, Interessen und Beziehungen gestaltet. Die Weltbevölkerung ist in Hauptfiguren, wiederkehrende Nebenfiguren und vereinfachte Hintergrundbevölkerung gegliedert. Beziehungen entstehen durch konkrete Begegnungen, eingehaltene Zusagen, gemeinsame Projekte und sichtbare Veränderungen – nicht über einen globalen Ruf- oder Moralwert.

Lokale Unternehmen verbinden Charaktere mit Handel, Dienstleistungen, Lieferketten und regionaler Entwicklung. Optionale soziale Inhalte dürfen den Kernfortschritt nicht blockieren. Eine vollständige Lebenssimulation ist ausdrücklich nicht vorgesehen.

Die detaillierte Konzeption steht in [Bewohner, Charaktere und Beziehungen](characters-residents-relationships.md).


## Ergänzung: Quest-, Missions- und Ereignissystem

Aufgaben gliedern sich in Hauptmissionen, persönliche und regionale Geschichten sowie wiederkehrende Aufträge. Ergänzend beleben zeitlich begrenzte regionale Ereignisse die Welt. Aufgaben entstehen aus Bewohnern, Unternehmen, Entdeckungen und wirtschaftlichen Situationen und verbinden bestehende Gameplay-Systeme.

- Alternative Lösungswege sind möglich, wenn sie zum Auftrag passen.
- Fristen werden sparsam eingesetzt; Hauptmissionen und persönliche Geschichten erhalten keine harten Fristen.
- Wiederkehrende Aufträge verwenden kontrollierte Variationen statt monoton steigender Mengen.
- Gemeinschaftsprojekte erzeugen sichtbare regionale Veränderungen.
- Optionale Aufgaben und Ereignisse blockieren keine Kernprogression.
- Questfortschritt wird ereignisbasiert geprüft und zuverlässig gespeichert.

Die vollständige Spezifikation steht in [Quest-, Missions- und Ereignissystem](quest-mission-event-system.md).


## Ergänzung: Regionalkarte und Weltfreischaltung

Die räumliche Planung konkretisiert die sechs Gebiete als kompakte Industrietal-Region. Die Kernkarte verbindet Old Yard, Scrapstead Town, Industrial Quarter, Railway District und Greenbelt. Quarry & Extraction wird zunächst als Spezialstandort behandelt. Hauptachsen, Landmarken, Zonen und nachvollziehbare Zugangsbedingungen strukturieren die Welt.

Gebiete werden nicht über willkürliche Levelgrenzen freigeschaltet. Erkundung, Infrastrukturprojekte, Reparaturen, Vereinbarungen und Investitionen können neue Bereiche nutzbar machen. Die Welt reagiert mit dauerhaft sichtbaren Zustandsänderungen.

Details und offene Kartenfragen stehen in [Regionalkarte, Gebietsstruktur und Weltfreischaltung](regional-map-and-world-progression.md).
