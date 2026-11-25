# Scrapstead — Produktionsumfang und Entwicklungsfahrplan

**Version:** 0.1  
**Status:** Produktionsleitplanke / Vorschlag für den verbindlichen Kernumfang  
**Projektphase:** Vorproduktion  
**Zielplattform:** PC  
**Ziel für den Hauptdurchlauf:** vorläufig 30–40 Stunden  
**Leitgedanke:** Ein vollständiges, gutes Spiel ist wichtiger als ein grenzenloses Spiel.

---

## 1. Zweck dieses Dokuments

Scrapstead besitzt bereits Konzepte für Wirtschaft, Erkundung, Charaktere, Aufträge, Mitarbeiter, Maschinen, Bau, Logistik, Scrappy und regionale Entwicklung. Diese Konzepte beschreiben Möglichkeiten und Systemrichtungen. Sie sind nicht automatisch eine Verpflichtung, alles davon in der ersten vollständigen Spielversion umzusetzen.

Dieses Dokument setzt deshalb einen Produktionsrahmen:

- Was muss für ein vollständiges Scrapstead enthalten sein?
- Was ist optional und darf bei Zeit- oder Qualitätsdruck entfallen?
- Was wird bewusst nicht Teil des Kernspiels?
- In welcher Reihenfolge werden Systeme entwickelt?
- Welche Kriterien müssen erfüllt sein, bevor der nächste Umfangsschritt beginnt?
- Wie schützen wir das Ziel eines realistisch abschließbaren Spiels?

Es ergänzt das GDD und die Systemspezifikationen. Bei Umfangskonflikten gilt diese Produktionsleitplanke für die erste vollständige Spielversion. Bestehende Detailkonzepte bleiben als mögliche spätere Ausbaustufen erhalten.

## 2. Produktionsgrundsatz

**Scrapstead ist ein persönliches Recycling-, Erkundungs- und Aufbau-Spiel mit überschaubarer Tycoon-Tiefe.**

Der eigene Schrottplatz ist der zentrale und am stärksten simulierte Ort. Die Region liefert Figuren, Geschichten, Materialquellen, Dienstleistungen, Aufträge und sichtbare Veränderungen. Sie wird nicht als vollständige Wirtschaft simuliert.

Die drei Erlebnisbereiche bleiben erhalten:
- **Cozy:** ein persönlicher Ort, Atmosphäre, Figuren, kleine Geschichten und sichtbarer Wandel.
- **Aufbau und Automation:** ein wachsender Betrieb, sinnvolle Investitionen, Mitarbeiter und Maschinen.
- **Sandbox:** kreative Gestaltung des eigenen Schrottplatzes und einfache, flexible Maschinenanordnung.

Keiner dieser Bereiche darf zum Selbstzweck ausufern. Der Spieler soll seinen Schrottplatz gestalten und verbessern, nicht ein komplexes Unternehmen verwalten müssen.

### 2.1 Verbindliche Scope-Regeln

1. Der Old Yard bleibt das Zentrum des Spiels.
2. Neue Systeme müssen einen konkreten Beitrag zum Spielspaß oder zum Abschluss leisten.
3. Ein bestehendes System wird bevorzugt erweitert, statt ein weiteres Subsystem einzuführen.
4. Kein System wird allein deshalb umgesetzt, weil es technisch interessant wäre.
5. Automatisierung nimmt Wiederholungen ab, ersetzt aber nicht Erkundung, Entdeckung und Entscheidungen.
6. Regionale Betriebe bleiben funktionale Anlaufstellen, keine vollständigen Simulationen.
7. Optionale Inhalte dürfen den Hauptabschluss nicht blockieren.
8. Der Kern muss ohne tägliche Login-Pflichten, dauernde Marktbeobachtung oder Pflicht-Mikromanagement funktionieren.
9. Erst wird eine kleine Version vollständig und spielbar. Danach wird erweitert.
10. Neue Ideen werden gegen Umfang, Aufwand, Testbarkeit und Produktionsrisiko geprüft.

## 3. Zielbild der ersten vollständigen Spielversion

Die erste vollständige Version soll eine in sich geschlossene Spielerfahrung bieten:

Der Spieler erbt Walts heruntergekommenen Schrottplatz, lernt Gegenstände zu bergen und zu verkaufen, stellt Scrappy wieder her, verbessert Werkzeuge und Arbeitsbereiche, gewinnt erste Unterstützung durch einen Mitarbeiter, setzt Maschinen ein und entwickelt einen funktionierenden Recyclingbetrieb. Durch Erkundung, Kontakte und Aufträge wird die umliegende Region zugänglich. Am Ende entsteht ein kleines regionales Recycling-Netzwerk, dessen Zusammenspiel in einer finalen Herausforderung sichtbar wird.

Nach dem Hauptabschluss kann der Spieler auf dem Schrottplatz weiterspielen, weiterbauen und optionale Ziele verfolgen.

### 3.1 Was das Spielgefühl tragen muss

- Ein befriedigender Sammel- und Bergungskreislauf.
- Ein verständlicher Direktverkauf mit verlässlichem Einkommen.
- Eine echte, aber optionale Wertsteigerung durch ausgewählte Verarbeitung.
- Sichtbare Entwicklung des eigenen Grundstücks.
- Eine kleine Zahl sinnvoller Mitarbeiter- und Maschinenfunktionen.
- Eine handgefertigte, kompakte Region mit wiedererkennbaren Orten.
- Wenige Figuren, die man gerne wiedertrifft.
- Scrappy als eigenständiger, erinnerungswürdiger Begleiter.
- Ein nachvollziehbarer Hauptfortschritt mit einem echten Abschluss.

Wenn diese Punkte nicht funktionieren, werden weitere Systeme nicht begonnen.

## 4. Umfangskategorien

### 4.1 Muss hinein — Kernumfang

Diese Inhalte sind Voraussetzung für die erste vollständige Spielversion.

#### A. Spieler, Welt und Grundstück
- Isometrische 3D-Spielwelt im festgelegten stylized Low-Poly / Cozy-Diorama-Stil.
- Eine kompakte, handgefertigte Hauptregion mit Old Yard als Heimatbasis.
- Zu Fuß erkundbare Umgebung und klar lesbare Interaktionsobjekte.
- Ein vollständig nutzbarer und ausbaubarer Hauptschrottplatz.
- Eine begrenzte Zahl regionaler Orte mit unterschiedlichen Funktionen.
- Sichtbare Veränderungen durch Aufräumen, Ausbau und ausgewählte Weltprojekte.

#### B. Kerninteraktionen
- Kleine Gegenstände aufnehmen.
- Größere Gegenstände mit passenden Werkzeugen oder Interaktionen bergen.
- Gegenstände untersuchen und ihren grundsätzlichen Wert bzw. ihre Eigenschaften erkennen.
- Gegenstände direkt verkaufen.
- Eine kleine Auswahl an Gegenständen optional sortieren, demontieren oder aufbereiten.
- Gegenstände, Materialien und Komponenten verständlich lagern und bewegen.

#### C. Wirtschaft
- Credits als einzige zentrale Spielwährung.
- Stabile Grundpreise.
- Verständliche Einnahmen und Ausgaben.
- Eine begrenzte Auswahl an Käufen, Werkzeugverbesserungen und Investitionen.
- Einige wiederkehrende und einmalige Aufträge.
- Keine Pflicht zur Verarbeitung: Direktverkauf bleibt eine tragfähige Einnahmequelle.
- Einfache, transparente Betriebskosten für relevante Investitionen.

#### D. Fortschritt und Unternehmensaufbau
- Klarer Hauptmissions- bzw. Fortschrittspfad.
- Werkzeug- und Transportverbesserungen.
- Mindestens ein Mitarbeiter mit einer klar begrenzten Aufgabe.
- Eine kleine Auswahl an Maschinen mit klar unterscheidbaren Funktionen.
- Einfache Arbeitsbereiche und verständliche Aufgabenprioritäten.
- Begrenzte Grundstückserweiterung.
- Einfache Maschinenverbindungen, sofern sie für die enthaltenen Maschinen benötigt werden.
- Ein erreichbarer finaler Spielabschnitt, der den Aufbau des Betriebs zusammenführt.

#### E. Scrappy
- Wiederherstellung in der frühen Spielphase.
- Erkennbare Persönlichkeit und kontextbezogene Reaktionen.
- Begleiterverhalten und einfache Interaktionen mit Welt und Spieler.
- Ein begrenztes, gut sichtbares Modul- und Anpassungssystem.
- Einige funktionale Fähigkeiten, die an tatsächlich benötigte Gameplay-Aktionen gebunden sind.
- Einfache Ereignis- und Erinnerungsauswahl für wiederkehrende Reaktionen.
- Keine autonome Kontrolle über wichtige Ressourcen, Entscheidungen oder Storyfortschritt.

#### F. Region und Figuren
- Eine kompakte Hauptregion mit mehreren klar unterscheidbaren Teilgebieten.
- Fünf regionale Anlaufstellen als maximaler Kernentwurf; Funktionen dürfen zusammengelegt werden.
- Eine kleine Besetzung wiederkehrender Hauptfiguren und einige Hintergrundbewohner.
- Persönliche und regionale Aufgaben.
- Ein begrenztes Gemeinschaftsprojekt mit sichtbarer Veränderung.
- Einfache Weltzustände: geschlossen, geöffnet, repariert, zugänglich oder erweitert.
- Keine vollständige Simulation fremder Betriebe.

#### G. Aufträge und Erzählung
- Walts Erbschafts- und Schrottplatzgeschichte.
- Scrappys Wiederherstellung und ein klarer persönlicher Handlungsbogen.
- Hauptaufgaben, einige persönliche Geschichten und wiederkehrende Aufträge.
- Erkundungsfunde und Umgebungs-Erzählung.
- Journal und Karte mit zurückhaltender Aufgabenanzeige.
- Keine harten Fristen für Hauptmissionen oder persönliche Geschichten.

#### H. Technische und qualitative Basis
- Zuverlässiges Speichern und Laden.
- Schutz wichtiger Storyobjekte und Questfortschritte.
- Versionierbare Speicherdaten.
- Deutsch und Englisch über Lokalisierungsschlüssel.
- Barrierearme, verständliche UI-Rückmeldungen und einstellbare Lautstärke.
- Performance- und Stabilitätsbudget für die Zielhardware.
- Tutorial- und Einstiegserlebnis, das die Kernaktionen ohne lange Textwände vermittelt.

### 4.2 Kann hinein — optionale Erweiterungen

Diese Inhalte dürfen erst begonnen werden, wenn der Kernumfang stabil und vollständig spielbar ist. Sie werden einzeln priorisiert und können ohne Ersatz entfallen.

- Weitere regionale Figuren und zusätzliche persönliche Geschichten.
- Zusätzliche Aufträge und wiederkehrende Vertragsvarianten.
- Weitere temporäre regionale Ereignisse und Marktstände.
- Zusätzliche kosmetische Scrappy-Teile und persönliche Gegenstände.
- Weitere Scrappy-Module und spezialisierte Fähigkeiten.
- Zusätzliche Maschinenvarianten und ausgewählte Produktionsrezepte.
- Zusätzliche Grundstücksdekorationen und Gebäudemodule.
- Ein weiterer kleiner Außenstandort mit einer klaren Funktion.
- Zusätzliche Sammlungen, Fundserien und optionale Entdeckungen.
- Erweiterte Statistiken und optionale Meisterziele.
- Begrenzter Offline-Fortschritt bis maximal 24 Stunden.
- Optionale Schichtmodelle über den einfachen Grundbetrieb hinaus.
- Weitere Komfortfunktionen und Quality-of-Life-Verbesserungen.

**Freigaberegel:** Eine optionale Erweiterung wird nur aufgenommen, wenn sie den Kern nicht verzögert, die vorhandenen Systeme stabil bleiben und ein klarer Spielwert erkennbar ist.

### 4.3 Vorerst nicht im Produktionsumfang

Diese Inhalte werden nicht für die erste vollständige Spielversion geplant. Sie dürfen nicht stillschweigend in den Kernumfang rutschen.

#### Wirtschaft und Management
- Vollständige Simulation aller regionalen Unternehmen.
- Konkurrenz-, Marktanteils-, Aktien- oder Übernahmesimulation.
- Steuern, Kredite, Bilanzen oder komplexe Buchhaltung.
- Vollständig simulierte NPC-Lager und NPC-Personalplanung.
- NPC-zu-NPC-Lieferketten als eigenständiges Wirtschaftssystem.
- Unbegrenzte Filial- und Außenstandortketten.
- Komplexe Preisprognosen oder permanente Marktüberwachung.

#### Produktion und Logistik
- Fabrik-Simulation mit dutzenden spezialisierten Produktionsstufen.
- Manuelle Programmierung komplexer Förderband- oder Verteilsysteme.
- Detaillierte Fahrzeugphysik und direkte Fahrzeugsteuerung.
- Vollständige Verkehrssimulation.
- Komplexe Energie-, Rohr-, Druck- oder Netzwerksimulation.
- Pflicht zur vollständigen Energieautonomie.
- Mehrere Lager- und Qualitätsverwaltungsebenen, wenn sie keinen klaren Spielwert liefern.

#### Figuren und Simulation
- Vollständige Lebenssimulation aller Bewohner.
- Hunger, Toilettenbedarf, tägliche Zufriedenheitskrisen oder komplexe Mitarbeiterbedürfnisse.
- Individuelle Tagesabläufe für jede Hintergrundfigur.
- Vollständige autonome KI-Unternehmen.
- Scrappy als LLM-gesteuerter, frei handelnder Agent als notwendige Kernfunktion.
- Pflichtpflege oder Tamagotchi-Mechaniken für Scrappy.

#### Umfang und Plattform
- Multiplayer oder kooperativer Betrieb.
- Modding-Plattform oder Community-Workshop als Release-Voraussetzung.
- Konsolenportierung als Voraussetzung für den ersten Release.
- Prozedural generierte vollständige Spielregion.
- Unbegrenzte Bau- und Produktionsfreiheit ohne funktionale Grenzen.
- Endloser Content-Nachschub als Ersatz für einen definierten Spielabschluss.

Diese Punkte können nach einem erfolgreichen Release neu bewertet werden. Sie sind keine Zusage für spätere Entwicklung.

## 5. Geplanter Content-Rahmen

Die folgenden Zahlen sind Produktionsziele und Obergrenzen für die Planung, keine bereits vorhandenen Inhalte oder endgültig beschlossenen Contentzahlen. Sie sollen verhindern, dass die Welt unkontrolliert wächst.

| Bereich | Zielrahmen für die erste vollständige Version |
|---|---|
| Hauptregion | 1 kompakte, zusammenhängende Region |
| Teilgebiete | 4 Kernbereiche plus 1 kleiner ländlicher Bereich |
| Spezialstandorte | höchstens 1 kleiner, separat geladener Standort, falls für den Abschluss erforderlich |
| Spielerbetrieb | 1 zentraler Schrottplatz |
| Regionale Anlaufstellen | maximal 5, zusammenlegbar |
| Wiederkehrende Hauptfiguren | etwa 5–7 |
| Weitere Bewohner | kleine, begrenzte Hintergrundbesetzung |
| Mitarbeiter | kleine Auswahl; nur wenige funktionale Rollen |
| Maschinen | etwa 6–8 klar unterscheidbare Kernmaschinen |
| Verarbeitungsarten | Sortierung, ausgewählte Demontage und einfache Aufbereitung |
| Materialgruppen | wenige gut lesbare Hauptgruppen |
| Hauptmissionsstruktur | etwa 7–9 Kapitel/Meilensteine |
| Persönliche Geschichten | etwa 3–5 kurze Handlungsstränge |
| Gemeinschaftsprojekte | 1–2 gut sichtbare Projekte |
| Wiederkehrende Aufträge | wenige Vorlagen mit kontrollierten Varianten |
| Hauptspielzeit | ca. 30–40 Stunden als Testziel |

### 5.1 Gebietsplanung

Die bisherige Weltkonzeption nennt Old Yard, Scrapstead Town, Industrial Quarter, Railway District, Greenbelt und Quarry & Extraction.

Für den ersten Produktionsrahmen gilt:
- **Old Yard:** vollständig und mit größter Detailtiefe.
- **Scrapstead Town:** kompakter sozialer und wirtschaftlicher Anlaufpunkt.
- **Industrial Quarter:** wichtigste zusätzliche Quelle für Maschinen, Material und größere Bergungen.
- **Railway District:** begrenzter Bereich für Fracht, Lieferungen und den finalen Netzwerkgedanken.
- **Greenbelt:** kleiner, ruhiger Erkundungsbereich; kann in die Hauptregion integriert oder in der Größe reduziert werden.
- **Quarry & Extraction:** kein Pflichtgebiet. Nur aufnehmen, wenn ein konkreter Teil des Hauptabschlusses davon profitiert; andernfalls spätere Erweiterung.

Die Karte muss nicht alle Gebiete gleich groß oder gleich dicht gestalten. Der Spieler soll lieber eine kompakte, interessante Region erkunden als eine große, dünn gefüllte Karte.

### 5.2 Maschinenumfang

Die Zielgröße von etwa 6–8 Kernmaschinen ist bewusst begrenzt. Jede Maschine muss eine erkennbare Aufgabe erfüllen und einen sinnvollen Unterschied zu manueller Arbeit oder einer anderen Maschine bieten.

Maschinenfamilien werden nicht mit dutzenden Varianten aufgefüllt. Varianten sollen bevorzugt über Upgrades oder Konfiguration entstehen.

Eine mögliche Kernabdeckung:
- Sammeln bzw. magnetische Bergung;
- Sortieren;
- Demontage oder Zerkleinerung;
- einfache Materialaufbereitung;
- Lagerung und Übergabe;
- eine begrenzte Spezialfunktion für den späteren Fortschritt.

Die konkrete Auswahl wird anhand der Kernschleife festgelegt. Nicht jede vorgeschlagene Maschinenfamilie muss umgesetzt werden.

### 5.3 Figurenumfang

Die Region braucht wenige Figuren mit Wiedererkennungswert. Jede wiederkehrende Hauptfigur soll mindestens zwei Funktionen erfüllen, etwa:
- persönliche Geschichte und Dienstleistung;
- Auftraggeber und Weltveränderung;
- Händler und Hinweisgeber;
- Mitarbeiter und soziale Präsenz.

Neue Figuren werden nur ergänzt, wenn ihre Funktion nicht sinnvoll von einer bestehenden Figur übernommen werden kann.

## 6. Zielstruktur für 30–40 Spielstunden

Die Spielzeit ist ein Balancing-Ziel und wird durch Tests validiert. Sie darf nicht durch künstliche Wartezeiten, übergroße Materialmengen oder wiederholte Pflichtaufträge erreicht werden.

Vorläufige Dramaturgie:

| Abschnitt | Richtzeit | Schwerpunkt |
|---|---:|---|
| 1. Ankommen und Erben | 0–1 h | Old Yard, Sammeln, erster Verkauf, Scrappy |
| 2. Den Betrieb verstehen | 1–5 h | Werkzeuge, Lager, erste Investitionen, manuelle Abläufe |
| 3. Nicht mehr alles allein | 5–10 h | erster Mitarbeiter, einfache Delegation, erste Maschine |
| 4. Recycling ausbauen | 10–17 h | Sortierung, ausgewählte Verarbeitung, Ausbau des Yard |
| 5. Die Region kennenlernen | 17–24 h | Stadt, Industriegebiet, Figuren, Lieferanten und Geschichten |
| 6. Verbindungen schaffen | 24–32 h | Fracht, begrenzte Logistik, Gemeinschaftsprojekt, Außenbezug |
| 7. Das Netzwerk vollenden | 32–40 h | finale Investitionen, Zusammenführung der Systeme, Hauptabschluss |

Die Abschnitte sind keine starren Zeitvorgaben. Spieler dürfen schneller oder langsamer sein. Nebeninhalte, Bauen und Erkundung können die Spielzeit erhöhen, ohne für den Abschluss verpflichtend zu sein.

## 7. Entwicklungsfahrplan

Die Entwicklung erfolgt in klaren Phasen. Jede Phase hat einen kleinen, spielbaren Nachweis. Die nächste Phase beginnt nicht allein deshalb, weil ein Dokument fertig ist.

### Phase 0 — Produktionsfundament

**Ziel:** Ein kleines, technisch belastbares Projektgerüst.

Inhalte:
- Engine- und Zielhardwareentscheidung bestätigen.
- Projektstruktur, Eingabe, Kamera und grundlegende Szene.
- Daten- und Ressourcenformat festlegen.
- Save/Load-Grundlage und Lokalisierungsstruktur vorbereiten.
- Ein einfacher Testbereich mit Platzhalter-Assets.

**Abnahme:**
- Projekt startet reproduzierbar.
- Spieler kann sich in einer kleinen Szene bewegen und interagieren.
- Daten können geladen und gespeichert werden.
- Ein Build kann auf der Zielhardware getestet werden.

### Phase 1 — Kernschleife auf dem Old Yard

**Ziel:** Scrapstead macht bereits ohne zusätzliche Systeme Spaß.

Inhalte:
- Kleine und größere Gegenstände.
- Sammeln und Bergen.
- Inventar bzw. Transportgrundlage.
- Direktverkauf und Credits.
- Erste Werkzeugverbesserung.
- Einfacher Grundstücksaufbau.
- Grundlegendes UI-Feedback.

**Abnahme:**
- Spieler versteht Sammeln, Wert und Verkauf.
- Erste Investition ist erreichbar.
- Die Kernschleife ist ohne Questmarker verständlich.
- Kein Softlock und keine unklare Inventar-/Verkaufslogik.

### Phase 2 — Erste Progression und Scrappy

**Ziel:** Die frühe Spielerfahrung bekommt Identität und Motivation.

Inhalte:
- First-Hour-Experience.
- Walts Brief und Umgebungs-Erzählung.
- Scrappys garantierte Entdeckung und Wiederherstellung.
- Begleiterbewegung, einfache Reaktionen und Interaktionen.
- Erste funktionale Scrappy-Anpassung.
- Erste Hauptaufgaben und Journal-Grundlage.

**Abnahme:**
- Einstieg funktioniert im Test ohne lange Erklärung.
- Scrappy wirkt als Figur und nicht nur als Werkzeug.
- Erste Stunde vermittelt mehrere nächste Ziele.
- Storyobjekte sind geschützt und zuverlässig auffindbar.

### Phase 3 — Delegation und erste Maschine

**Ziel:** Der Spieler erlebt den Übergang von manueller Arbeit zu sinnvoller Unterstützung.

Inhalte:
- Ein Mitarbeiter mit einer Aufgabe.
- Ein Arbeitsbereich und einfache Priorität.
- Eine erste Maschine mit klarer Funktion.
- Einfache Lager- und Übergabepunkte.
- Verständliche Kosten und Nutzen.
- Eine kleine, testbare Produktions- oder Sortierfunktion.

**Abnahme:**
- Mitarbeiter und Maschine übernehmen nachvollziehbar reale Aufgaben.
- Der Spieler kann weiterhin sinnvoll selbst arbeiten.
- Kosten erzeugen keine finanzielle Falle.
- Automatisierung reduziert Wiederholung, ohne neue Pflichtverwaltung zu erzeugen.

### Phase 4 — Der vollständige eigene Betrieb

**Ziel:** Der Old Yard bildet das vollständige Kernspiel im Kleinen ab.

Inhalte:
- Begrenzte Auswahl an Maschinen und Verarbeitung.
- Freies Bauen innerhalb funktionaler Grenzen.
- Einfache Maschinenverbindungen.
- Grundstückserweiterung.
- Eine kleine Auswahl an Mitarbeiterrollen.
- Aufträge und Wirtschaftsbalance.
- Visuelle Entwicklung des Betriebs.

**Abnahme:**
- Der Spieler kann einen kleinen, funktionierenden Recyclingbetrieb aufbauen.
- Direktverkauf und Verarbeitung sind beide sinnvoll.
- Keine einzelne Produktionskette ist zwingend für alle Spielweisen.
- Layout und Maschinenverbindungen sind verständlich.

### Phase 5 — Region, Figuren und Geschichten

**Ziel:** Die Welt außerhalb des Schrottplatzes wird relevant, ohne ein zweites Managementspiel zu werden.

Inhalte:
- Kompakte Hauptregion mit Kernbereichen.
- Begrenzte regionale Betriebe und Dienstleistungen.
- Wiederkehrende Bewohner.
- Persönliche und regionale Aufgaben.
- Ein Gemeinschaftsprojekt.
- Entdeckungen und ausgewählte Ereignisse.
- Sichtbare, kontrollierte Weltzustände.

**Abnahme:**
- Jeder Kernbereich bietet einen eigenen Grund für einen Besuch.
- Figuren und Betriebe sind wiedererkennbar.
- Regionale Inhalte ergänzen den Spielerbetrieb.
- Kein fremder Betrieb braucht eine vollständige Simulation.

### Phase 6 — Netzwerk und Hauptabschluss

**Ziel:** Die bisherigen Systeme werden in einer überschaubaren finalen Herausforderung zusammengeführt.

Inhalte:
- Begrenzte Fracht- und Lieferabläufe.
- Ein klar definierter zusätzlicher Standort oder Umschlagpunkt, falls erforderlich.
- Ein Gemeinschafts- oder Infrastrukturprojekt.
- Finale Hauptmission.
- Abschlussbericht und Freispielmodus.
- Optionale Meisterziele nur, soweit sie auf vorhandenen Systemen aufbauen.

**Abnahme:**
- Der Hauptabschluss ist mit dem Kernumfang erreichbar.
- Die finale Herausforderung prüft bekannte Systeme statt neue Großsysteme einzuführen.
- Der Spieler versteht, was er erreicht hat.
- Nach dem Ende kann auf dem Schrottplatz weitergespielt werden.

### Phase 7 — Stabilisierung und Release-Vorbereitung

**Ziel:** Keine neuen großen Systeme. Qualität und Fertigstellung stehen im Vordergrund.

Inhalte:
- Balancing und Wirtschaftstests.
- Performance- und Speicheroptimierung.
- UI/UX-Politur.
- Lokalisierung Deutsch/Englisch.
- Audio, Animationen und visuelle Rückmeldungen.
- Bugfixing, Savegame-Tests und Build-Verifikation.
- Tutorial- und Einstiegstests.
- Release-Kandidaten.

**Abnahme:**
- Der Hauptdurchlauf ist vollständig und ohne bekannte Blocker spielbar.
- Speichern/Laden ist stabil.
- Wirtschaft und Progression erzeugen keine Softlocks.
- Die Zielhardware hält das definierte Performancebudget ein.
- Kerninhalte sind lokalisiert und verständlich.

## 8. Was zuerst gestrichen wird, wenn der Umfang wächst

Wenn Zeit, Budget oder technische Risiken steigen, wird in dieser Reihenfolge reduziert:

1. Zusätzliche kosmetische Scrappy-Varianten.
2. Zusätzliche optionale Bewohner und persönliche Geschichten.
3. Temporäre Ereignisse und zusätzliche Auftragsvarianten.
4. Zusätzliche Maschinenvarianten und Rezepte.
5. Zusätzliche regionale Anlaufstellen oder deren Spezialfunktionen.
6. Greenbelt-Inhalte verkleinern oder zusammenlegen.
7. Separaten Spezialstandort streichen und Funktion in bestehende Region integrieren.
8. Erweiterte Schicht- und Offline-Simulation verschieben.
9. Optionale Meisterziele reduzieren.

Nicht gestrichen werden sollen:
- funktionierende Kernschleife;
- Old Yard als vollständiger Heimatort;
- Scrappys zentrale Einführung;
- nachvollziehbarer Hauptfortschritt;
- ein erreichbarer Hauptabschluss;
- zuverlässiges Speichern/Laden;
- verständliche Wirtschaft ohne Softlocks.

## 9. Feature-Freigabe: Prüffragen

Jede neue Funktion muss vor Aufnahme in den Produktionsumfang folgende Fragen beantworten:

1. Welches konkrete Spielerproblem oder Erlebnis verbessert sie?
2. Ist sie für den Hauptabschluss notwendig?
3. Kann ein vorhandenes System dieselbe Aufgabe bereits erfüllen?
4. Wie viele neue Daten, Assets, UI-Elemente, Regeln und Tests entstehen dadurch?
5. Erzeugt sie wiederkehrende Pflege oder zusätzliche Pflichtentscheidungen?
6. Kann sie optional bleiben, ohne den Spielfortschritt zu beschädigen?
7. Was wird gestrichen oder vereinfacht, wenn sie aufgenommen wird?
8. Ist ihr Nutzen im Prototyp sichtbar und messbar?

Eine Idee ohne klaren Nutzen wird nicht automatisch Teil des Spiels, nur weil sie interessant klingt.

## 10. Risiken und offene Entscheidungen

Diese Punkte müssen vor oder während der Prototypen geklärt werden:

- Exakte Engine und Zielhardware.
- Finale Größe und Geometrie der Hauptregion.
- Welche vier Kernbereiche für den Release unverzichtbar sind.
- Ob Greenbelt Teil der Hauptkarte oder ein kleiner Nebenbereich wird.
- Ob Quarry & Extraction für den Hauptabschluss benötigt wird.
- Finale Anzahl und Rollen der Mitarbeiter.
- Konkrete Auswahl der 6–8 Kernmaschinen.
- Umfang und technische Tiefe der Scrappy-Module.
- Ob Offline-Fortschritt für die erste Version notwendig ist oder später ergänzt wird.
- Ob Schichtbetrieb für den Kernfortschritt erforderlich ist.
- Tatsächliche Spielzeit und Investitionskurve aus Prototyp-Tests.
- Asset- und Animationsaufwand für die modulare Bau- und Maschinenvielfalt.

Diese Entscheidungen werden nicht durch Dokumentation allein finalisiert. Sie benötigen spielbare Tests und einen realistischen Produktionsaufwand.

## 11. Definition von „fertig“

Scrapstead gilt für die erste vollständige Version als inhaltlich fertig, wenn:

- der Spieler vom Erbe bis zum Hauptabschluss durchspielen kann;
- alle Kernsysteme im tatsächlichen Spielablauf zusammenarbeiten;
- die Hauptregion kompakt, verständlich und ausreichend belebt ist;
- der eigene Betrieb sinnvoll ausgebaut und automatisiert werden kann;
- Scrappy eine erkennbare Rolle und Entwicklung besitzt;
- Aufträge, Figuren und Weltveränderungen einen nachvollziehbaren Zusammenhang bilden;
- die Wirtschaft stabil und ohne Pflicht-Mikromanagement funktioniert;
- nach dem Hauptabschluss freies Weiterspielen möglich ist;
- Speichern, Laden, Lokalisierung und Kern-UX zuverlässig funktionieren;
- keine optionalen Features mehr benötigt werden, um das Spiel als vollständig zu erleben.

**Das Ziel ist nicht, jede denkbare Funktion zu besitzen. Das Ziel ist, eine runde, erinnerungswürdige Spielerfahrung abzuliefern.**

---

## Zusammenfassung

Die erste vollständige Version von Scrapstead konzentriert sich auf einen ausgebauten Schrottplatz, eine kompakte Region, wenige wiedererkennbare Figuren und Betriebe, Scrappy, eine begrenzte Auswahl an Mitarbeitern und Maschinen sowie einen klaren Hauptabschluss.

Die bisher erdachten größeren Systeme bleiben als Ideen- und Ausbaupool erhalten. Sie sind keine automatische Verpflichtung.

**Simple Core, Endless Possibilities — aber erst, wenn der Core fertig ist.**


## Ergänzung: Core-Gameplay-Matrix

Die Produktionsplanung wird durch eine Mechanik-Matrix konkretisiert. Für Bewegung, Erkundung, Sammeln, Bergen, Lager, Wirtschaft, Verarbeitung, Bauen, Mitarbeiter, Maschinen, Scrappy, Aufträge, Region und technische Basis sind minimale vollständige Umsetzungen, Abhängigkeiten, Entwicklungsphasen und optionale Erweiterungen definiert.

Der kleinste aussagekräftige MVP-Test bleibt bewusst auf Bewegung, Sammeln, Bergen, Verkauf, Credits, einem Upgrade und optionaler Verarbeitung begrenzt. Mitarbeiter, regionale Wirtschaft und komplexe Logistik sind dafür nicht erforderlich.

Spezifikation: [Core-Gameplay-Matrix](core-gameplay-matrix.md).

## Ergänzung: MVP- und Prototypenplan

Der Entwicklungsfahrplan wird vor der vollständigen Produktion durch klar getrennte Prototypstufen konkretisiert:

- **P0:** Technisches Fundament – Bewegung, Kamera, Interaktion und minimale Persistenz.
- **P1:** Kernschleife – Sammeln, Bergen, Verkaufen, Credits und erstes Upgrade.
- **P1b:** Eine optionale Verwertungsentscheidung, sofern sie den Direktverkauf sinnvoll ergänzt.
- **P2:** Erste 30–60 Minuten und Scrappys Wiederherstellung.
- **P3:** Ein Mitarbeiter mit einer Aufgabe, danach der kleine Magnetsammler.
- **P4:** Vertical Slice des Old Yard.

Jede Stufe besitzt eigene Abnahmekriterien und einen Freigabepunkt. Insbesondere werden Scrappy, Delegation, Maschinen und Region nicht genutzt, um eine noch nicht validierte Kernschleife zu überdecken.

Die konkrete Szenen-/Objektplanung, fachlichen Datenobjekte, Vereinfachungen, Tests und Definition of Done stehen im [MVP- und Prototypenplan](mvp-prototype-plan.md).

## Ergänzung: Hauptmenü als Bestandteil von P0

Der erste Prototyp beginnt bereits mit einem eigenständigen Hauptmenü. Es zeigt das Scrapstead-Logo vor einer ruhigen, vorbereiteten Kamerafahrt durch den Old Yard. Die Kamerafahrt darf den frühen 3D-Blockout verwenden und läuft unabhängig von der Gameplay-Kamera.

Das Menü enthält Neues Spiel, Fortsetzen (nur bei vorhandenem Spielstand), Einstellungen und Beenden. Die Umsetzung bleibt bewusst kompakt: keine aufwendige Logoanimation, keine komplexen Effekte und kein vollständiges Optionsmenü. Details und Abnahmekriterien: [MVP- und Prototypenplan](mvp-prototype-plan.md).
