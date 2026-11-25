# Scrapstead — Quest-, Missions- und Ereignissystem

**Version:** 0.1  
**Status:** Konzeptentwurf / Grundlage für Content- und Prototypplanung  
**Geltungsbereich:** Aufträge, persönliche Geschichten, Entdeckungsaufgaben, Gemeinschaftsprojekte und regionale Ereignisse.

## 1. Zielbild

Das Aufgaben- und Ereignissystem verbindet die Bewohner, die Welt, die Wirtschaft und die Kernaktivitäten von Scrapstead. Aufgaben sollen nicht wie eine losgelöste Checkliste wirken, sondern aus nachvollziehbaren Situationen entstehen.

Ein Bewohner benötigt Hilfe. Ein Betrieb hat eine Lieferung erwartet. Auf einem verlassenen Gelände wurde etwas entdeckt. Die Stadt plant einen Markt. Ein alter Industriebereich soll wieder zugänglich gemacht werden. Der Spieler entscheidet, worauf er sich einlässt und wie er ein Problem löst.

Das System muss handgefertigte Geschichten ebenso unterstützen wie wiederkehrende, variierende Aufträge und zeitlich begrenzte Ereignisse.

**Leitgedanke:** Aufgaben geben dem Spieler einen Anlass, die Systeme von Scrapstead auf unterschiedliche Weise zu nutzen – sie ersetzen nicht das eigentliche Spiel.

## 2. Designprinzipien

1. **Aus der Welt heraus:** Jede Aufgabe hat einen nachvollziehbaren Auftraggeber, Anlass oder Fundkontext.
2. **Bestehendes Gameplay nutzen:** Aufgaben kombinieren Sammeln, Erkundung, Bergung, Transport, Handel, Verarbeitung, Reparatur, Bauen und Automatisierung.
3. **Mehrere Lösungswege zulassen:** Wo sinnvoll, darf der Spieler selbst sammeln, einkaufen, verarbeiten, liefern lassen oder automatisieren.
4. **Optionalität respektieren:** Optionale Aufgaben dürfen den Hauptfortschritt nicht blockieren.
5. **Keine Aufgabenflut:** Wenige gut platzierte Angebote statt permanenter Benachrichtigungen und endloser Listen.
6. **Klarheit vor Überraschung:** Ziel, Anforderungen, Frist und Belohnung sind verständlich. Entdeckungen dürfen Geheimnisse bewahren, aber keine versteckten Pflichtbedingungen enthalten.
7. **Wiederholung variieren:** Wiederkehrende Aufträge verändern Kontext, Material, Route oder Rahmenbedingungen statt bloß Mengen hochzuschrauben.
8. **Konsequenzen sichtbar machen:** Wichtige Aufgaben verändern Orte, Betriebe, Beziehungen oder verfügbare Möglichkeiten.
9. **Kein täglicher Zwang:** Verpasste optionale Aufgaben führen nicht zu dauerhaften Nachteilen.
10. **Datengetrieben und lokalisierbar:** Aufgaben, Ziele, Texte und Belohnungen sind von der Spiellogik getrennt.

## 3. Die drei Aufgabenebenen

### 3.1 Hauptmissionen und Fortschrittsaufgaben

Sie führen den Spieler durch die zentrale Entwicklung:
- den geerbten Schrottplatz kennenlernen und arbeitsfähig machen;
- erste Werkzeuge und Arbeitsabläufe verbessern;
- Scrappy wiederherstellen;
- erste Hilfe einstellen und Maschinen einsetzen;
- den Betrieb ausbauen;
- neue Gebiete und Standorte erschließen;
- regionale Liefer- und Recyclingverbindungen aufbauen;
- das regionale Netzwerk und die finale Herausforderung erreichen.

Hauptmissionen vermitteln Systeme schrittweise. Sie sollen nicht jede einzelne Aktion vorschreiben. Ein Ziel wie „Richte eine zuverlässige Sortierung ein“ kann mehrere gültige Maschinen- und Layoutlösungen erlauben.

### 3.2 Persönliche und regionale Geschichten

Diese Aufgaben entstehen aus Bewohnern, Unternehmen, Orten und besonderen Funden:
- persönliche Anliegen einzelner Figuren;
- Wiedereröffnung oder Verbesserung lokaler Betriebe;
- Geschichten über alte Industrieanlagen und die Region;
- mehrteilige Entdeckungen;
- Beziehungen und gemeinsame Projekte.

Sie vertiefen die Welt und bieten oft einzigartige Belohnungen, sind aber grundsätzlich optional.

### 3.3 Wiederkehrende Aufträge und Dienstleistungen

Sie halten die Wirtschaft und den Betriebsalltag in Bewegung:
- Materiallieferungen;
- Abholung und Transport;
- Sortier- und Verarbeitungsaufträge;
- Bergung und Räumung;
- Beschaffung bestimmter Gegenstände;
- Reparatur und Wiederverwendung;
- regionale Versorgungsaufträge.

Sie müssen variieren und dürfen nicht zur monotonen Pflichtarbeit werden. Ihre Belohnung soll in einem nachvollziehbaren Verhältnis zu Aufwand, Risiko, Transport und Materialwert stehen.

## 4. Auftrags- und Missionsarten

Ein Auftrag kann mehrere Kategorien kombinieren. Die Kategorie beschreibt die dominante Aktivität, nicht eine starre technische Schublade.

| Typ | Typische Aktivität | Beispiel |
|---|---|---|
| Beschaffung | Material oder Gegenstände organisieren | Ersatzteile für eine Werkstatt besorgen |
| Bergung | Objekt an einem Ort finden und sichern | Alte Hebevorrichtung aus einer Halle bergen |
| Abholung | Bereitgestellte Lieferung aufnehmen | Schrottcontainer bei einem Betrieb abholen |
| Transport | Waren zwischen Orten bewegen | Holz und Metall zum Gemeinschaftsprojekt liefern |
| Sortierung | Materialgruppen trennen | Gemischte Lieferung für einen Händler sortieren |
| Verarbeitung | Material oder Komponenten aufbereiten | Metallplatten für eine Reparatur herstellen |
| Reparatur / Wiederverwendung | Gegenstand oder Anlage instand setzen | Werkstattpresse wieder funktionsfähig machen |
| Räumung | Fläche oder Gebäude freimachen | Zugang zu einem Lager räumen |
| Erkundung | Ort oder Information entdecken | Hinweise auf einen verschollenen Frachtwagen finden |
| Lieferung / Handel | Waren verkaufen oder bereitstellen | Eine vereinbarte Menge an einen Abnehmer liefern |
| Bau / Infrastruktur | Anlage oder Gemeinschaftsort errichten | Sammelstelle im Ort einrichten |
| Betrieb / Automatisierung | Produktions- oder Logistiklösung etablieren | Regelmäßige Versorgung einer Außenstelle organisieren |

### 4.1 Keine unnötigen Minispiele

Ein Auftrag führt keine neue Minispielmechanik ein, nur um seine Aufgabenliste künstlich aufzublähen. Neue Interaktionen sind nur gerechtfertigt, wenn sie eine dauerhafte, wiederverwendbare Gameplay-Funktion darstellen.

## 5. Quellen und Annahme

Aufgaben können aus mehreren Quellen kommen:
- direkte Gespräche mit Bewohnern;
- lokale Aushänge oder Auftragstafeln;
- Unternehmen und Lieferanten;
- entdeckte Orte, Objekte und Dokumente;
- Gemeinschaftsprojekte;
- regionale Ereignisse;
- Scrappys Beobachtungen und Hinweise;
- später optional Telefon, Funk oder digitale Unternehmenskanäle.

### 5.1 Annahmeregeln

- Ein Angebot kann angenommen, abgelehnt oder zunächst ignoriert werden.
- Einfache Aufträge dürfen direkt angenommen werden.
- Größere Verträge zeigen vor Annahme Umfang, Vergütung, Kosten, Frist und mögliche Risiken.
- Bei wiederkehrenden Aufträgen kann der Spieler eine automatische Annahme nur für klar definierte, sichere Regeln konfigurieren.
- Hauptmissionen werden über den Spielfortschritt aktiviert; sie sollen nicht versehentlich dauerhaft verloren gehen.
- Optionale Aufgaben können aus dem aktiven Journal ausgeblendet werden, ohne ihren Status zu verlieren.

## 6. Struktur eines Auftrags

Ein Auftrag besteht aus klaren Daten- und Laufzeitbereichen.

### 6.1 Stammdaten

- stabile ID;
- Titel und Kurzbeschreibung;
- Auftragstypen und Tags;
- Quelle / Auftraggeber;
- betroffene Region und Zielorte;
- Kategorie: Hauptmission, persönliche Geschichte, regional, wiederkehrend, Ereignis;
- Priorität und Sichtbarkeit;
- Voraussetzungen und Freischaltbedingungen.

### 6.2 Ziele

Ein Auftrag kann ein oder mehrere Ziele besitzen:
- Gegenstand oder Menge beschaffen;
- einen Ort erreichen oder untersuchen;
- Objekt bergen;
- Material liefern;
- Maschine oder Gebäude bereitstellen;
- Verarbeitung durchführen;
- Transportverbindung einrichten;
- Gespräch führen oder Information übergeben;
- Zustand einer Welt- oder Unternehmenskomponente erreichen.

Ziele sollen konkrete Bedingungen prüfen, keine unnötig exakten Klickfolgen erzwingen.

### 6.3 Belohnungen und Kosten

Mögliche Belohnungen:
- Credits;
- Material oder Komponenten;
- Werkzeuge, Maschinen oder Baupläne;
- Zugang zu Dienstleistung, Lieferant oder Standort;
- neue Aufträge und Kontakte;
- Verbesserung eines Betriebs oder Ortes;
- kosmetische Gegenstände und Dekoration;
- persönliche Geschichte, Wissen oder Sammlungsobjekte.

Mögliche Kosten:
- eingesetzte Materialien;
- Einkauf oder Transport;
- optionale Investitionen;
- Zeitaufwand;
- Maschinen- und Personalkapazität.

Kosten und Belohnung müssen vor einer verbindlichen Zusage klar sein. Bei Entdeckungsaufgaben darf die Belohnung teilweise unbekannt bleiben, sofern der Spieler vorab nicht zu einer riskanten Ausgabe verpflichtet wird.

## 7. Ziele, Abhängigkeiten und Ablauf

Aufträge können aus linearen oder verzweigten Zielschritten bestehen.

### 7.1 Zieltypen

- **All:** Alle definierten Teilziele müssen erfüllt sein.
- **Any:** Eine von mehreren Lösungsvarianten reicht aus.
- **Count:** Eine Menge oder Anzahl muss erreicht werden.
- **State:** Ein definierter Welt-, Betriebs- oder Objektzustand muss vorliegen.
- **Interaction:** Ein Gespräch, eine Untersuchung oder eine Übergabe muss stattfinden.
- **Delivery:** Eine Menge wird an einem konkreten Zielort bereitgestellt.
- **Discovery:** Ein bestimmter Fund oder Wissensstand wird freigeschaltet.

### 7.2 Alternative Lösungen

Wo sinnvoll, kann ein Ziel mehrere Wege akzeptieren. Beispiel: Für eine Reparatur werden bestimmte Ersatzteile benötigt. Der Spieler kann sie:
- selbst an einem Fundort bergen;
- bei einem Händler kaufen;
- aus eigenem Bestand bereitstellen;
- über einen freigeschalteten Lieferanten beziehen.

Der Auftrag prüft das Ergebnis, nicht zwingend den vorgeschriebenen Weg.

### 7.3 Teilfortschritt

- Teilziele bleiben sichtbar und nachvollziehbar.
- Bereits erbrachte Beiträge werden nicht unnötig zurückgesetzt.
- Bei Lieferaufträgen kann der Spieler Teillieferungen leisten, wenn der Auftrag dies zulässt.
- Fortschritt wird gespeichert und bleibt nach Neustart erhalten.
- Ein Auftrag darf nicht stillschweigend seinen Umfang erhöhen.

## 8. Fristen, Dringlichkeit und Verfall

Zeitlimits werden sparsam eingesetzt.

### 8.1 Fristtypen

- **Ohne Frist:** Standard für persönliche Geschichten, Erkundung und die meisten Aufträge.
- **Weiche Frist:** Eine rechtzeitige Lieferung bietet einen Bonus; später ist die Erfüllung weiterhin möglich.
- **Harte Frist:** Nur für klar angekündigte, zeitlich gebundene Ereignisse oder Verträge, bei denen das Scheitern nachvollziehbar ist.
- **Ereignisfenster:** Ein Angebot oder Markt findet in einem angekündigten Zeitraum statt.

### 8.2 Regeln

- Hauptmissionen erhalten keine harte Frist.
- Persönliche Geschichten verschwinden nicht wegen einer verpassten Uhrzeit.
- Harte Fristen werden vor Annahme klar angezeigt.
- Fristen berücksichtigen Transport- und Produktionszeiten.
- Offline-Fortschritt darf keine überraschenden, irreversiblen Fehlschläge auslösen.
- Bei optionalen zeitgebundenen Inhalten gibt es später neue Gelegenheiten oder alternative Zugänge, wenn die Inhalte relevant bleiben sollen.
- Zeitlimits dürfen nicht als künstliche Druckquelle für tägliches Einloggen dienen.

## 9. Wiederkehrende Aufträge und Variationen

Wiederkehrende Aufträge werden aus kontrollierten Vorlagen erzeugt. Sie sollen nicht endlos dieselbe Aufgabe mit steigenden Mengen wiederholen.

Variationsdimensionen:
- Auftraggeber und Kontext;
- Material- oder Objektgruppe;
- Zielort und Transportstrecke;
- Menge innerhalb eines sinnvollen Bereichs;
- Qualitätsanforderung;
- Zeitfenster oder optionale Bonusfrist;
- benötigter Verarbeitungsschritt;
- verfügbare Transport- oder Lagerkapazität;
- besondere regionale Bedingungen.

### 9.1 Qualitätsregeln

- Jede Variante muss mit dem aktuellen Fortschritt erfüllbar sein.
- Keine Anforderung für noch nicht freigeschaltete Maschinen oder Gebiete, außer der Auftrag ist ausdrücklich als späterer Vertrag markiert.
- Keine zufälligen Mengen, die den wirtschaftlichen Wert oder die Lagerkapazität unverhältnismäßig übersteigen.
- Wiederholte Aufträge bieten unterschiedliche Kombinationen, nicht nur höhere Zahlen.
- Es gibt eine begrenzte Zahl gleichzeitig angebotener Standardaufträge.
- Belohnungen orientieren sich an Materialwert, Arbeitsaufwand, Distanz, Risiko und Opportunitätskosten.

## 10. Persönliche Geschichten und mehrteilige Handlungsstränge

Persönliche Geschichten bestehen aus wenigen, bedeutungsvollen Kapiteln statt einer langen Kette belangloser Aufgaben.

Mögliche Struktur:
1. **Begegnung:** Spieler lernt Figur oder Problem kennen.
2. **Kontext:** Informationen, Gegenstände oder Ursachen werden entdeckt.
3. **Beitrag:** Spieler hilft durch eine passende Gameplay-Aktivität.
4. **Veränderung:** Figur, Betrieb oder Ort reagiert sichtbar.
5. **Nachklang:** Ein späteres Gespräch, eine Erinnerung oder ein neuer Kontakt schließt die Geschichte ab.

Nicht jede Geschichte braucht alle fünf Schritte. Einige können aus einer einzigen Begegnung bestehen; andere können sich über mehrere Regionen erstrecken.

### 10.1 Walt und Scrappy

Walts Geschichte bleibt ein eigener, emotionaler Handlungsstrang. Sie wird über Fundstücke, Werkstattunterlagen, Maschinenreste und Scrappys Erinnerungen vermittelt. Das Quest-System darf die Geschichte strukturieren, aber nicht jede Erinnerung in eine Aufgabenliste verwandeln.

Scrappy kann Hinweise auf Orte, Gegenstände und Zusammenhänge geben. Er darf wichtige Entdeckungen nicht automatisch abschließen oder dem Spieler die eigentliche Erkundung abnehmen.

## 11. Entdeckungsaufgaben und Erkundung

Entdeckungen können Aufgaben erzeugen, ohne dass vorher ein NPC einen Auftrag erteilt.

Beispiele:
- ungewöhnliche Spuren führen zu einem verlassenen Fahrzeug;
- mehrere Dokumente erklären die Geschichte eines alten Betriebs;
- ein Fundstück passt zu einer beschädigten Anlage;
- ein Geräusch oder Lichtsignal weist auf einen versteckten Bereich hin;
- ein Bewohner erkennt ein Objekt und erzählt seine Vorgeschichte.

### 11.1 Informationsfortschritt

Das System unterscheidet:
- Hinweis wahrgenommen;
- Fundort entdeckt;
- Objekt oder Dokument untersucht;
- Zusammenhang verstanden;
- Geschichte oder Zugang freigeschaltet.

Nicht jeder Hinweis muss als aktiver Questmarker erscheinen. Das Journal kann entdeckte Informationen dokumentieren, ohne den Spieler permanent zu führen.

### 11.2 Schutz wichtiger Inhalte

Einmalige Storyfunde, wichtige Schlüsselobjekte und kritische Informationen sind garantiert auffindbar und können nicht durch zufällige Regeneration verschwinden. Sie werden nicht versehentlich verkauft, zerlegt oder als gewöhnlicher Bestand verbraucht.

## 12. Gemeinschaftsprojekte

Gemeinschaftsprojekte sind größere, optionale Aufgaben mit sichtbarem regionalem Ergebnis.

Beispiele:
- Bahnhofsvorplatz aufräumen und wiederherstellen;
- kleine Werkstatt wieder eröffnen;
- lokale Sammelstelle einrichten;
- Markt oder Gemeindefest vorbereiten;
- beschädigte Brücke oder Zufahrt instand setzen;
- eine alte Industriehalle für sichere Bergung zugänglich machen.

### 12.1 Beitragsarten

- Materialien bereitstellen;
- Gegenstände oder Komponenten bergen;
- Transporte organisieren;
- Reparaturen oder Bauarbeiten durchführen;
- Finanzierung bereitstellen;
- Lieferanten oder Bewohner koordinieren.

### 12.2 Projektphasen

1. Bedarf wird bekannt.
2. Umfang und benötigte Beiträge werden sichtbar.
3. Spieler leistet Beiträge direkt oder organisiert sie über Betrieb und Mitarbeiter.
4. Projekt wird abgeschlossen.
5. Ort, Betrieb oder Gemeinschaft verändert sich dauerhaft.
6. Folgeangebote, Dienste oder Geschichten können entstehen.

Projekte sollen mehrere Wege zur Beteiligung erlauben. Kein einzelnes Material darf zum unersetzbaren Engpass werden, wenn es alternative Beschaffungswege geben kann.

## 13. Regionale Ereignisse

Ereignisse bringen zeitweise besondere Situationen in die Region. Sie sind keine täglichen Login-Pflichten.

Mögliche Ereignisse:
- Flohmarkt oder regionaler Handelstag;
- gemeinsamer Aufräumtag;
- größere Sonderlieferung;
- vorübergehender Ersatzteilengpass;
- saisonale Nachfrage;
- Wiedereröffnung eines Betriebs;
- ungewöhnliche Fracht am Bahnhof;
- Besuch eines spezialisierten Händlers;
- lokales Fest oder Gemeinschaftsveranstaltung.

### 13.1 Ereignisregeln

- Ereignisse besitzen Beginn, Dauer, betroffene Orte und klare Auswirkungen.
- Nicht jedes Ereignis benötigt aktive Aufgaben. Manche verändern nur Angebot, Nachfrage oder Atmosphäre.
- Wichtige Ereignisse werden angemessen angekündigt.
- Ereignisse erzeugen Chancen, keine Pflicht.
- Verpasste Ereignisse blockieren keine Hauptmission oder essentielle Dienstleistung.
- Ereignisse können wiederkehren, aber nicht exakt identisch ablaufen.
- Zufällige Ereignisse müssen mit Weltzustand, Fortschritt und verfügbaren Ressourcen kompatibel sein.

### 13.2 Weltreaktionen

Ein Ereignis kann:
- neue Aufträge verfügbar machen;
- Nachfrage oder Angebot temporär verändern;
- Bewohner an andere Orte bringen;
- einen Betrieb vorübergehend erweitern;
- einen Fundort oder eine Transportmöglichkeit öffnen;
- nach Abschluss einen dauerhaften Zustand hinterlassen.

## 14. Hauptmissionen und Progressionsintegration

Hauptmissionen führen die zentralen Systeme in einer verständlichen Reihenfolge ein. Sie sollen den Spieler nicht in eine einzige Betriebsstrategie zwingen.

Mögliche Missionskapitel:
1. **Ein neuer Anfang:** Erbschaft, Schrottplatz, erste Gegenstände und erste Verkäufe.
2. **Ordnung im Chaos:** Sammel- und Lagergrundlagen, erste Werkzeuge und Arbeitsbereiche.
3. **Ein kleiner Helfer:** Scrappys Wiederherstellung und erste Unterstützungsfunktionen.
4. **Nicht mehr alles allein:** erste Personalunterstützung und Delegation.
5. **Maschinen machen das Leben leichter:** erste Sortier- und Verarbeitungsmaschinen.
6. **Die Stadt erwacht:** lokale Kontakte, Lieferanten und Gemeinschaftsprojekt.
7. **Mehr als ein Schrottplatz:** Erschließung weiterer regionaler Tätigkeiten und Standorte.
8. **Ein Netzwerk entsteht:** Transport, Lieferverträge und standortübergreifende Abläufe.
9. **Die Region im Kreislauf:** finale Herausforderung und Aufbau des regionalen Recycling-Netzwerks.

Diese Kapitel sind ein dramaturgischer Vorschlag auf Basis der bestehenden Progression. Namen, genaue Reihenfolge und Missionszahl bleiben vorläufig und werden mit dem First-Hour- und Progressionskonzept abgeglichen.

### 14.1 Systemeinführung

- Neue Mechaniken werden in einer sicheren, überschaubaren Situation eingeführt.
- Danach erhält der Spieler Gelegenheit, das System eigenständig einzusetzen.
- Ein Auftrag darf nicht gleichzeitig mehrere neue, komplexe Systeme voraussetzen.
- Bereits bekannte Systeme dürfen in späteren Aufgaben frei kombiniert werden.
- Hinweise und Hilfen können reduziert werden, sobald der Spieler ein System kennt.

## 15. Belohnungsdesign

Belohnungen sollen zur Aufgabe und zum Fortschritt passen.

### 15.1 Belohnungskategorien

- **Wirtschaftlich:** Credits, Material, Komponenten, Auftragsbonus.
- **Funktional:** Werkzeuge, Maschinen, Baupläne, neue Rezepte oder Upgrades.
- **Zugang:** Gebiete, Lieferanten, Dienstleistungen, Betriebsbereiche.
- **Sozial:** Empfehlungen, Vertrauen, persönliche Gespräche, neue Kontakte.
- **Welt:** wiederhergestellte Orte, geöffnete Gebäude, neue Infrastruktur.
- **Kosmetisch:** Dekoration, Kleidung, Sammlungsobjekte und Anpassungen.
- **Wissen:** Kartenhinweise, Hintergrundgeschichte, technische Informationen und Entdeckungen.

Nicht jede Aufgabe muss Credits vergeben. Eine neue Dienstleistung oder ein veränderter Ort kann wertvoller sein als eine Geldsumme.

### 15.2 Keine Belohnungsinflation

- Wiederkehrende Aufträge dürfen die Grundwirtschaft nicht entwerten.
- Einmalige Belohnungen sind auf Fortschritt und Aufwand abgestimmt.
- Zugang und einzigartige Inhalte sind nicht beliebig wiederholbar.
- Belohnungen sollen keine Pflichtschleife erzeugen, die stärker ist als das normale Kerngameplay.

## 16. Journal, Karte und Aufgaben-UX

Das Aufgaben-Interface bleibt kompakt und kontextbezogen.

### 16.1 Journal-Bereiche

- Hauptfortschritt;
- persönliche Geschichten;
- regionale Aufgaben;
- wiederkehrende Aufträge und Verträge;
- Entdeckungen und Hinweise;
- aktive Gemeinschaftsprojekte;
- abgeschlossene Inhalte / Chronik.

### 16.2 Aufgabenanzeige

Ein Eintrag zeigt je nach Aufgabentyp:
- Titel und kurze Beschreibung;
- Auftraggeber und Quelle;
- Zielort;
- Fortschritt und Teilziele;
- benötigte Menge oder Zustand;
- Frist und verbleibende Zeit, falls relevant;
- Belohnung und Kosten;
- optionale oder alternative Lösungswege.

### 16.3 Kartenintegration

- Nur bekannte Orte und tatsächlich entdeckte Ziele werden markiert.
- Spieler kann aktive Ziele ein- und ausblenden.
- Keine permanente Anzeige aller verfügbaren Aufgaben.
- Hinweise können als Gebiet oder Suchradius statt exaktem Punkt dargestellt werden.
- Wichtige Ziele bleiben über Journal und Karte auffindbar.
- Mehrere Aufgaben am selben Ort werden sinnvoll zusammengefasst.

### 16.4 Benachrichtigungen

- Neue Aufgaben werden über ihre Quelle vermittelt.
- Nur wichtige Änderungen erzeugen auffällige Benachrichtigungen.
- Wiederkehrende Aufträge und Marktereignisse können dezent im Unternehmensbereich erscheinen.
- Keine Pop-up-Kaskaden und keine dauernden Unterbrechungen laufender Tätigkeiten.

## 17. Scrappy im Aufgaben- und Ereignissystem

Scrappy ist Hinweisgeber, Begleiter und gelegentlicher Unterstützer – kein Questmanager.

Er kann:
- interessante Objekte und Orte bemerken;
- Hinweise auf ungewöhnliche Geräusche, Spuren oder Maschinen geben;
- sich an frühere Funde und Bewohner erinnern;
- kleine, freigegebene Gegenstände bergen;
- bei passenden Aufgaben analysieren oder assistieren;
- auf Ereignisse und Veränderungen reagieren.

Er darf nicht:
- Hauptmissionen ohne Spieler abschließen;
- wichtige Storyobjekte eigenmächtig bewegen oder verbrauchen;
- versteckte Entdeckungen vollständig vorwegnehmen;
- ständig neue Aufgaben erzwingen;
- mit wiederholten Hinweisen nerven, wenn der Spieler gerade etwas anderes tut.

## 18. Technische Systemstruktur

Vorgeschlagene logische Bausteine:

- **Quest Registry:** statische Auftragsdefinitionen, IDs, Kategorien und Versionen.
- **Quest State Manager:** Status, Fortschritt, Annahme, Abschluss und Abbruch.
- **Objective Evaluator:** prüft Zielbedingungen anhand von Spielereignissen.
- **Prerequisite Resolver:** Voraussetzungen, Abhängigkeiten und Freischaltungen.
- **Reward Resolver:** prüft und vergibt Belohnungen atomar.
- **Contract Generator:** erzeugt kontrollierte Varianten wiederkehrender Aufträge.
- **Event Scheduler:** plant regionale Ereignisse und Zeitfenster.
- **World State Integration:** setzt sichtbare Zustände von Orten, Betrieben und Figuren.
- **Journal / Map Presenter:** stellt Ziele und Hinweise dar.
- **Localization Resolver:** lädt lokalisierte Texte und Variablen.

### 18.1 Ereignisbasierte Fortschrittsprüfung

Gameplay-Systeme melden relevante Ereignisse, beispielsweise:
- Gegenstand entdeckt;
- Objekt geborgen;
- Material eingelagert;
- Lieferung abgeschlossen;
- Maschine installiert;
- Produktion gestartet;
- Auftrag erfüllt;
- Bewohner getroffen;
- Ort wiederhergestellt.

Der Objective Evaluator prüft, ob aktive Ziele betroffen sind. Aufträge sollen nicht permanent Inventar, Welt und Maschinenzustände vollständig durchsuchen müssen.

### 18.2 Zustandsmodell

Ein Auftrag kann folgende Zustände besitzen:
- locked;
- available;
- active;
- completed;
- failed;
- abandoned;
- expired.

Nicht jeder Auftrag nutzt jeden Zustand. Hauptmissionen können beispielsweise nicht abgebrochen oder endgültig verfallen.

### 18.3 Speichern und Transaktionen

- Fortschritt und Zielzustände werden zuverlässig gespeichert.
- Belohnungen werden genau einmal vergeben.
- Wiederholte Ereignisse dürfen keinen doppelten Abschluss auslösen.
- Weltveränderung und Questabschluss müssen konsistent bleiben.
- Nach Laden eines Spielstands werden aktive Ziele aus gespeicherten Zuständen rekonstruiert.
- Zufällig erzeugte Aufträge behalten ihre konkreten Anforderungen und Belohnungen nach dem Speichern.

### 18.4 Datenversionierung

Auftragsdefinitionen besitzen stabile IDs und eine Versionskennung. Änderungen an späteren Spielversionen müssen gespeicherte aktive Aufträge sicher migrieren oder kontrolliert ersetzen können. Kritische Storyfortschritte dürfen durch Datenupdates nicht verloren gehen.

## 19. Balancing und Schutzregeln

- Begrenzte Anzahl gleichzeitig aktiver Standardaufträge.
- Hauptmissionen und wichtige persönliche Geschichten sind zuverlässig verfügbar.
- Wiederkehrende Aufträge passen zu Gebiet, Fortschritt, Lager und Maschinenzugang.
- Keine zufälligen Softlocks durch fehlende Materialien oder nicht erreichbare Ziele.
- Keine Fristen, die normale Transport- und Produktionszeiten ignorieren.
- Belohnungen berücksichtigen Aufwand, Kosten, Distanz und Alternativwert.
- Aufgaben dürfen bestehende Spielsysteme nicht durch übermäßig lukrative Sonderregeln entwerten.
- Verpasste optionale Inhalte dürfen nicht zu einer negativen Progressionsspirale führen.
- Ereignisse und Aufträge werden im Offline-Fortschritt nach den bestehenden Schutzregeln behandelt.

## 20. Prototypumfang und Abnahmekriterien

Erster Quest-Prototyp:
- eine kurze Hauptmissionsfolge für die ersten Spielstunden;
- drei bis fünf wiederkehrende Bewohner;
- zwei persönliche bzw. regionale Aufgaben;
- drei Varianten eines wiederkehrenden Liefer- oder Beschaffungsauftrags;
- eine mehrstufige Erkundungsentdeckung;
- ein Gemeinschaftsprojekt mit sichtbarer Weltveränderung;
- ein kleines regionales Ereignis;
- Journal- und Kartenanzeige für aktive Ziele.

Der Prototyp ist erfolgreich, wenn:
1. Spieler verstehen, warum eine Aufgabe existiert und wer davon profitiert.
2. Aufgaben mehrere Kernsysteme sinnvoll verbinden.
3. Alternative Lösungswege funktionieren, wo sie vorgesehen sind.
4. Wiederkehrende Aufträge nicht wie identische Mengenlisten wirken.
5. Optionale Inhalte ohne Nachteil ignoriert werden können.
6. Wichtige Storyfunde nicht verloren gehen oder zufällig blockiert werden.
7. Ereignisse die Welt beleben, ohne tägliche Pflichten zu erzeugen.
8. Belohnungen die bestehende Wirtschaft nicht aushebeln.
9. Journal und Karte Orientierung geben, ohne die Welt mit Markern zu überladen.
10. Der Spieler jederzeit nachvollziehen kann, was als Nächstes möglich ist.

## 21. Offene Ausarbeitung

- Finale Hauptmissionskapitel, Titel und konkrete Missionsinhalte.
- Konkrete persönliche Geschichten der Hauptfiguren.
- Auftragsvorlagen, Variationsregeln und konkrete Zahlen.
- Anzahl gleichzeitig verfügbarer und aktiver Aufträge.
- Eventkalender, Häufigkeiten und regionale Auslöser.
- Belohnungswerte und Frist-Balancing.
- Journal- und Kartenlayout.
- Konkretes Datenformat und technische Implementierung.
- Umgang mit Änderungen aktiver Aufträge bei Updates.

Diese Punkte werden in der Content-Planung und später im spielbaren Prototyp validiert. Die hier beschriebenen Regeln bilden den konzeptionellen Rahmen.
