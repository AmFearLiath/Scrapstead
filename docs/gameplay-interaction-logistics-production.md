# Scrapstead — Interaktion, Transport, Lager, Produktion und Energie

**Version:** 0.1  
**Status:** Konzeptzwischenstand / vor Prototyp-Validierung  
**Stand:** 25.11.2026

Dieses Dokument bündelt die Entscheidungen zur praktischen Durchführung zentraler Gameplay-Aktivitäten. Es konkretisiert das GDD und die Gameplay- und Wirtschaftsspezifikation. Es beschreibt gewünschtes Spielverhalten, keine bereits validierte technische Implementierung. Zahlen, Reichweiten, Kapazitäten, Kosten und konkrete Contentlisten bleiben bis zu Prototyp- und Balancingtests offen.

## 1. Leitprinzip

**Balanced Gameplay:** Bergen, Erkunden, Verarbeiten, Bauen und Wirtschaften sollen gleichberechtigte, miteinander verbundene Aktivitäten bleiben. Keine einzelne Tätigkeit darf das gesamte Spiel dominieren oder zur Pflicht für alle Spielstile werden.

Die fünf Aktivitäten bilden einen zusammenhängenden Kreislauf:

1. Entdecken und beschaffen.
2. Bergen und transportieren.
3. Prüfen, sortieren und verarbeiten.
4. Verkaufen und wirtschaften.
5. Bauen, erweitern und automatisieren.

Der Spieler kann Schwerpunkte setzen. Alle Bereiche bleiben auch im späteren Spiel relevant; Automatisierung reduziert Wiederholungen, ersetzt aber nicht die Entscheidungen und kreativen Möglichkeiten des Spielers.

## 2. Interaktion und Zerlegung

### 2.1 Hybride Interaktion

- Einfache Tätigkeiten werden über direkte Kontextaktionen ausgeführt: aufheben, einsammeln, verschieben oder unkompliziert zerlegen.
- Interessante Tätigkeiten können aktive Interaktionen enthalten: Werkzeuge ansetzen, Gehäuse öffnen, Bauteile lösen, schneiden oder Komponenten ausbauen.
- Große oder komplexe Arbeiten können aus mehreren nachvollziehbaren Schritten bestehen.
- Nicht jede Schraube und nicht jeder Handgriff wird zu einem eigenen Minispiel.

Die Komplexität richtet sich nach Objektgröße, Seltenheit, Wert und Aufbau. Gewöhnlicher Schrott bleibt schnell zugänglich. Besondere, seltene oder wertvolle Objekte dürfen eine bewusst ausführlichere Interaktion bieten.

### 2.2 Mehrwert sorgfältiger Arbeit

Sorgfältiges Zerlegen kann zwei Arten von Ertrag verbessern:

- **Materialausbeute:** Mehr oder besser verwertbares Rohmaterial bleibt erhalten.
- **Komponentenerhalt:** Wertvolle Bauteile können unbeschädigt ausgebaut und verkauft, wiederverwendet oder in eigenen Konstruktionen eingesetzt werden.

Komplexität muss einen verständlichen Mehrwert bieten. Der Spieler soll vor oder während der Arbeit erkennen können, warum sich ein sorgfältiges Vorgehen lohnt. Fehler dürfen Zeit kosten oder den Ertrag reduzieren, sollen aber keine unverhältnismäßigen Bestrafungsschleifen auslösen.

### 2.3 Werkzeuge

Werkzeuge sind sowohl Zugangsvoraussetzung als auch Effizienz- und Qualitätsfaktor:

- Bestimmte Arbeitsschritte erfordern ein geeignetes Werkzeug oder eine passende Ausrüstung.
- Bessere oder spezialisierte Werkzeuge können Arbeit beschleunigen, Ertrag erhöhen oder empfindliche Komponenten besser schützen.
- Die Werkzeugauswahl bleibt überschaubar und über klar erkennbare Einsatzzwecke verständlich.
- Fehlende Werkzeuge werden am Objekt bzw. an der Aktion nachvollziehbar angezeigt.

### 2.4 Werkzeugherstellung und begrenztes modulares Crafting

Werkzeuge können gekauft, selbst hergestellt und verbessert werden.

Das Crafting folgt einem kontrollierten Hybridmodell:

1. **Grundrezepte:** Ein Bauplan definiert das Grundgerät und seine benötigten Materialien bzw. Komponenten.
2. **Modulare Erweiterungen:** Ausgewählte Geräte besitzen eine begrenzte Zahl vorbereiteter Erweiterungsplätze.
3. **Verbesserungen:** Bestehende Eigenschaften können über verständliche Upgrades verbessert werden.

Beispiel: Ein Trennschleifer wird über ein Grundrezept gebaut. Je nach Modell können Motor, Trennscheibe oder eine zusätzliche Schutz-/Kühlungserweiterung ausgewählt werden.

Ausdrücklich nicht vorgesehen sind frei kombinierbare Einzelteile ohne Regeln, beliebige Leistungswerte, riesige Kompatibilitätsmatrizen oder eine Pflicht, jedes Gerät selbst zu konstruieren. Der Spieler soll Entscheidungen treffen, keine technischen Datenblätter ausfüllen. Das Prinzip begrenzter, vorbereiteter Module kann auch bei Maschinen, Fahrzeugen und Scrappys Hardware genutzt werden, sofern es zum jeweiligen System passt.

## 3. Transport und Fahrzeuge

### 3.1 Hybrides Transportsystem

Der Transport wächst mit dem Unternehmen:

- **Persönliches Inventar:** Kleine Gegenstände, Werkzeuge und Fundstücke.
- **Handtransport:** Einzelne mittelgroße Gegenstände, Kisten oder handhabbare Teile.
- **Fahrzeuge:** Größere Distanzen, schwere Gegenstände und Materialtransporte.
- **Maschinen und Hilfsmittel:** Gabelstapler, Kräne, Hebezeuge und industrielle Transporttechnik für schwere oder sperrige Ladung.

Nicht jedes Objekt muss einzeln getragen oder verladen werden. Die Interaktion wird nach Größe, Gewicht und Bedeutung abgestuft.

### 3.2 Beladung und Darstellung

**Hybrides Beladesystem:**

- Kleinteile werden abstrakt über Kapazität und Gewicht geladen.
- Mittlere Gegenstände können sichtbar auf der Ladefläche dargestellt werden, ohne millimetergenaue manuelle Platzierung zu verlangen.
- Große und besondere Objekte werden sichtbar und mit passender Ausrüstung verladen.
- Entladen erfolgt je nach Ladung automatisch oder über eine gezielte Interaktion.

Die sichtbare Ladung ist eine Darstellung des Simulationszustands. Nicht jedes Stück muss als dauerhaft physikalisch simuliertes Einzelobjekt existieren. Visuelle Ladezustände müssen dennoch mit dem tatsächlichen Bestand und der Kapazität übereinstimmen.

### 3.3 Keine direkte Fahrzeugsteuerung

Der Spieler steuert Fahrzeuge nicht selbst. Fahrzeuge sind Teil des Unternehmens- und Logistiksystems und werden über Aufträge, Routen und Betriebsregeln verwaltet.

Die Fahrzeugsimulation bleibt bewusst zugänglich und abstrakt. Fahrzeugklasse, Ladung, Gewicht, Zustand, Untergrund und Streckenbedingungen beeinflussen Transportdauer, Kapazität und Eignung. Eine vollständige Fahrphysik oder manuelle Fahrsteuerung ist nicht Ziel des Spiels.

### 3.4 Fahrzeugbetrieb und Personal

Für jedes Fahrzeug kann der Betrieb passend zur Aufgabe organisiert werden:

- **Autonom:** Geeignete Fahrzeuge erledigen Aufträge ohne zugewiesenen Fahrer.
- **Personalgebunden:** Ein qualifizierter Mitarbeiter bedient das Fahrzeug.
- **Situationsabhängig:** Das System nutzt je nach Auftrag, Fahrzeugtyp und Personalverfügbarkeit eine passende Betriebsform.

Nicht jedes Fahrzeug benötigt zwingend einen Mitarbeiter. Spezialfahrzeuge und anspruchsvolle Bergungen können Personal erfordern oder durch qualifizierte Mitarbeiter effizienter werden. Konkrete Fahrzeugklassen und Fähigkeiten bleiben auszuarbeiten.

## 4. Logistik und Transportaufträge

### 4.1 Drei Betriebsweisen

Das Logistiksystem kombiniert drei Ebenen, die parallel genutzt werden können:

- **Einzelaufträge:** Der Spieler erteilt gezielte Transporte oder Bergungen.
- **Feste Routen:** Fahrzeuge verkehren regelmäßig zwischen definierten Standorten.
- **Intelligente Logistik:** Der Spieler definiert Regeln, Ziele und Prioritäten; das System ordnet geeignete Fahrzeuge und Aufträge selbstständig zu.

Die Bedienung beginnt mit einfachen Einzelaufträgen. Feste Routen und intelligente Disposition werden schrittweise mit dem Unternehmenswachstum eingeführt.

### 4.2 Automatische Problemlösung

Unkritische Transportprobleme werden automatisch behandelt:

- Blockierte oder ungeeignete Route: alternative Route suchen.
- Ziellager voll: geeignetes Ausweichlager prüfen.
- Fahrzeug ungeeignet oder nicht verfügbar: anderes passendes Fahrzeug suchen.
- Mitarbeiter fehlt: Verfügbarkeit und autonome Betriebsoption prüfen.

Wenn keine sinnvolle Lösung existiert, wird der Auftrag pausiert und der Spieler informiert. Entscheidungen mit wirtschaftlich erheblicher Auswirkung, geschützten Ressourcen oder irreversiblen Folgen benötigen eine Spielerfreigabe.

Eskalationsstufen:

1. **Automatisch lösen:** System behebt das Problem innerhalb festgelegter Regeln.
2. **Informieren:** Spieler erhält eine Meldung; Eingriff ist nicht zwingend.
3. **Entscheidung erforderlich:** Auftrag wartet auf die Freigabe des Spielers.

### 4.3 Standortübergreifende Materialversorgung

Lagerbestände bleiben standortgebunden. Es gibt kein globales, überall gleichzeitig verfügbares Inventar.

- Produktionsstandorte fordern benötigte Materialien über das Logistiknetz an.
- Daraus entstehen Transportaufträge.
- Transportdauer, Fahrzeugverfügbarkeit, Lagerbestand und Kapazität beeinflussen die Versorgung.
- Produktionsanlagen können auf benötigte Lieferungen warten oder – sofern eingerichtet – auf geeignete Alternativen ausweichen.
- Die Logistik kann Lieferungen bündeln, sofern dies Prioritäten und Fristen nicht verletzt.

### 4.4 Materialpriorisierung

Die Verteilung berücksichtigt mehrere Faktoren:

- Vom Spieler festgelegte Standortpriorität.
- Dringlichkeit und Frist eines Auftrags.
- Produktionsbedarf und Stillstandsrisiko.
- Tatsächliche Materialverfügbarkeit.
- Transportaufwand und sinnvolle Bündelung.

Der Spieler definiert die strategischen Regeln. Das System organisiert die operative Verteilung. Zeitkritische oder ausdrücklich priorisierte Aufträge können temporär Vorrang erhalten. Eine transparente Begründung der Zuteilung ist wichtig, damit die Automatisierung nachvollziehbar bleibt.

## 5. Lagerverwaltung

### 5.1 Hybride Darstellung

- Rohstoffe und große Mengen werden überwiegend abstrakt als Bestände verwaltet.
- Komponenten werden mengenbasiert geführt; besondere oder hochwertige Einzelteile können bei Bedarf individuell identifizierbar sein.
- Wertvolle Funde, Maschinen und große Einzelobjekte können sichtbar in der Spielwelt gelagert werden.
- Lagergebäude, Container, Regale und Lagerflächen bestimmen Kapazität und Eignung.

Die sichtbare Darstellung muss den tatsächlichen Bestand repräsentieren. Eine vollständige physikalische Simulation jedes Rohstoffstücks ist nicht erforderlich.

### 5.2 Kapazität und Spezialisierung

Jedes Lager besitzt eine Gesamtkapazität. Zusätzlich können Materialzonen und spezialisierte Lagerbereiche eingerichtet werden.

- Einfache Lager können mehrere Materialgruppen aufnehmen.
- Zonen erlauben eine verständliche Zuordnung und Reservierung von Lagerkapazität.
- Spezialisierte Lager und Container eignen sich für bestimmte Materialgruppen oder besondere Anforderungen.
- Erweiterungen erhöhen Kapazität oder verbessern die Eignung.
- Automatische Ein- und Auslagerung berücksichtigt Zonen, Kapazitäten und Prioritäten.

Spezialisierung soll Vorteile bieten, aber nicht jeden Betrieb zu einer kleinteiligen Lagerplanungsaufgabe zwingen.

### 5.3 Lokale Bestände und automatische Versorgung

Jeder Standort verwaltet seine eigenen Bestände. Andere Standorte können Material über das Logistiknetz anfordern, müssen es aber physisch bzw. simuliert geliefert bekommen. Transportzeiten und verfügbare Kapazitäten bleiben relevant.

## 6. Produktion und Verarbeitung

### 6.1 Progressive Tiefe

Das Produktionssystem wächst in Stufen:

1. Einzelmaschinen mit verständlicher Eingabe und Ausgabe.
2. Produktionsketten, in denen das Ergebnis eines Arbeitsschritts zum Eingang des nächsten wird.
3. Modulare Produktionsanlagen aus Maschinen, Fördertechnik, Lagern und weiteren Einrichtungen.

Einzelverarbeitung bleibt dauerhaft sinnvoll. Komplexe Produktionslinien sind eine kreative Option, keine Pflicht für jeden Gegenstand oder jeden Spielstil.

### 6.2 Vorlagen und eigene Produktionslinien

- Das Spiel bietet verständliche Standardabläufe und Produktionsvorlagen.
- Vorlagen können angepasst, erweitert und als eigene Varianten gespeichert werden.
- Spieler können eigene Produktionslinien aus kompatiblen Maschinen und Verarbeitungsschritten entwickeln.
- Das Spiel zeigt fehlende Eingaben, Engpässe, Ausgaben und Verbindungen verständlich an.

Vorlagen geben Orientierung; sie begrenzen nicht die kreative Gestaltung.

### 6.3 Physische und logische Verbindungen

Beide Verbindungstypen können innerhalb derselben Anlage zusammenarbeiten:

- **Physisch:** Förderbänder, Rutschen und geeignete Transporttechnik bewegen Materialien sichtbar.
- **Logisch:** Maschinen und Lager tauschen Materialien über das Produktionssystem aus, ohne dass überall Fördertechnik gebaut werden muss.
- **Lager:** Können als Puffer und Versorgungspunkte dienen.

Logische Verbindungen sind keine kostenlose Fernlogistik. Standortgrenzen, Bestände, Transportkapazitäten und Transportzeiten bleiben bestehen. Physische Fördertechnik dient sowohl der sichtbaren Gestaltung als auch konkreten lokalen Transportfunktionen.

### 6.4 Maschinenbetriebsarten

Der Spieler kann pro Maschine oder Produktionslinie passende Betriebsweisen festlegen:

- **Dauerbetrieb:** Verarbeitet geeignete verfügbare Materialien automatisch.
- **Auftragsbetrieb:** Arbeitet konkrete Mengen- oder Produktionsaufträge ab.
- **Rezeptbetrieb:** Produziert ein festgelegtes Produkt, solange Eingaben und Kapazitäten verfügbar sind.
- **Mischbetrieb:** Kombiniert definierte Aufträge und reguläre Betriebsregeln; nach einem Auftrag kann die Maschine in den Standardbetrieb zurückkehren.

Die Modi sollen zusammenarbeiten und nicht als voneinander isolierte Systeme umgesetzt werden. Einstellungen bleiben pro Maschine bzw. Linie verständlich und überschaubar.

## 7. Energieversorgung

### 7.1 Hybrid aus Netzbezug und Eigenproduktion

**Beschluss:** Externe Energieversorgung und eigene Energieerzeugung ergänzen sich.

- Der regionale Energieversorger stellt eine verlässliche Grundversorgung bereit.
- Der Spieler kann eigene Erzeugungsanlagen errichten, um einen Teil des Bedarfs selbst zu decken.
- Eigenproduktion kann laufende Kosten reduzieren und die Versorgung flexibler machen.
- Vollständige Energieautonomie kann als spätes Ausbauziel möglich sein, ist aber keine Pflicht und darf nicht Voraussetzung für normalen Spielfortschritt werden.

Mögliche Erzeugungsarten für die weitere Ausarbeitung: Solaranlagen, Windkraft, Generatoren und standortgerechte alternative Erzeuger. Nicht alle müssen im ersten Spielumfang enthalten sein.

### 7.2 Progressive Infrastruktur

- Kleine Betriebe nutzen eine vereinfachte Stromversorgung ohne manuelle Leitungsplanung.
- Größere Produktionsbereiche können über gemeinsame Versorgungskapazitäten organisiert werden.
- Fortgeschrittene Anlagen können ein ausbaubares Stromnetz mit sichtbaren Leitungen und Verteilung erhalten.
- Maschinen und Anlagen besitzen einen nachvollziehbaren Energiebedarf.
- Kapazitätserweiterungen und Eigenproduktion werden verständlich dargestellt.

### 7.3 Speicherung und Priorisierung

Als kontrollierte Erweiterung sind Energiespeicher und einfache Prioritätsregeln vorgesehen:

- Speicher können Eigenproduktion puffern und Verbrauchsspitzen ausgleichen.
- Kritische Produktions- oder Versorgungsbereiche können priorisiert werden.
- Bei knapper Kapazität werden weniger wichtige Verbraucher zunächst gedrosselt oder pausiert.
- Der Spieler erhält eine verständliche Meldung und klare Ausbauoptionen.

Kein verpflichtendes Mikromanagement einzelner Stromkreise. Zufällige, häufige Stromausfälle oder harte Energie-Softlocks sind nicht vorgesehen. Konkrete Speicherregeln, Kosten und Erzeugungswerte bleiben offen.

## 8. Übergreifende UX- und Balancing-Regeln

1. **Simple Core, Endless Possibilities:** Grundaktionen bleiben einfach; Tiefe entsteht durch Kombination.
2. **Automatisierung ist optional:** Sie nimmt Wiederholungen ab, nicht die Kontrolle über Ziele und Prioritäten.
3. **Keine Pflicht-Mikroverwaltung:** Einzelteile, Mitarbeiter, Fahrzeuge, Lagerplätze und Leitungen müssen nicht ständig manuell verwaltet werden.
4. **Transparente Folgen:** Kapazität, Kosten, Ertrag, Verzögerungen und Engpässe werden verständlich angezeigt.
5. **Sinnvolle Fehlerbehandlung:** Unkritische Probleme werden automatisch gelöst; wichtige Entscheidungen werden eskaliert.
6. **Keine kostenlosen Abkürzungen:** Standortübergreifende Versorgung benötigt Bestände und Transport.
7. **Komplexität nach Bedarf:** Fortschrittliche Systeme werden schrittweise eingeführt und bleiben optional.
8. **Keine Sackgassen:** Direktverkauf und einfache Verarbeitung bleiben wirtschaftlich brauchbar.

## 9. Prototyp- und Validierungshinweise

Die folgenden Punkte müssen in spielbaren Prototypen geprüft werden:

- Ob aktive Zerlegeinteraktionen einen Mehrwert bieten, ohne alltägliche Tätigkeiten zu verlangsamen.
- Ob Werkzeuganforderungen und Ertragsunterschiede verständlich sind.
- Ob sichtbare Ladung bei abstrakter Bestandsführung glaubwürdig bleibt.
- Ob automatische Fahrzeugdisposition nachvollziehbar und zuverlässig funktioniert.
- Ob standortgebundene Bestände Logistik interessant machen, ohne Produktionsstillstände zu erzwingen.
- Ob Produktionsvorlagen und eigene Linien gleichermaßen zugänglich sind.
- Ob physische und logische Verbindungen klar unterscheidbar und kombinierbar sind.
- Ob Energieausbau wirtschaftlich interessant bleibt, ohne Pflicht-Mikromanagement zu erzeugen.

Konkrete Zahlen, Fahrzeug- und Maschinenlisten, Rezepte, Produktionsraten, Energiepreise und Kapazitäten werden erst nach diesen Tests festgelegt.
