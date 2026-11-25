# Scrapstead — Bewohner, Charaktere und Beziehungen

**Version:** 0.1  
**Status:** Konzeptentwurf / Grundlage für Content- und Questplanung  
**Geltungsbereich:** Bewohner, wiederkehrende Figuren, lokale Unternehmen und soziale Beziehungen in der Hauptregion.

## 1. Zielbild

Scrapstead soll sich wie eine kleine, gewachsene Gemeinschaft anfühlen. Bewohner sind keine Questautomaten und keine austauschbaren Kulissen. Sie haben erkennbare Aufgaben, Gewohnheiten, Interessen und Verbindungen zu Orten und anderen Menschen.

Der Spieler wird nicht durch einen globalen Rufwert zum Helden der Region. Bekanntheit entsteht lokal und nachvollziehbar: durch Begegnungen, verlässliche Zusagen, Hilfe, Zusammenarbeit und sichtbare Veränderungen.

**Leitgedanke:** Die Bewohner brauchen ein Leben, keine vollständige Lebenssimulation.

Das System soll Persönlichkeit und Kontinuität vermitteln, ohne Hunger-, Schlaf-, Toiletten-, Beziehungs- oder Zufriedenheitsmanagement zu einem Pflichtspiel zu machen.

## 2. Designprinzipien

1. **Wiedererkennung vor Menge.** Wenige gut unterscheidbare Figuren sind wertvoller als viele namenlose NPCs.
2. **Ort und Persönlichkeit gehören zusammen.** Figuren haben einen nachvollziehbaren Bezug zu ihrem Wohn-, Arbeits- oder Lieblingsort.
3. **Funktion und Charakter ergänzen sich.** Ein Mechaniker kann Aufträge vergeben und zugleich eine eigene Sicht auf die Dinge haben.
4. **Beziehungen entstehen durch Erlebnisse.** Kein universeller Freundschafts- oder Moralkontostand.
5. **Keine Pflichtpflege.** Spieler dürfen Gespräche, optionale Hilfe und soziale Aktivitäten auslassen.
6. **Reaktionen statt Simulation um ihrer selbst willen.** Bewohner reagieren auf relevante Ereignisse, nicht auf jede Kleinigkeit.
7. **Weltveränderungen bleiben sichtbar.** Hilfe kann einen Laden öffnen, einen Ort verbessern oder neue Begegnungen ermöglichen.
8. **Humor ist charaktergebunden.** Nicht jeder Bewohner ist eine Witzfigur; ruhige und ernste Figuren erhalten Raum.
9. **Mehrsprachigkeit von Anfang an.** Namen, Dialoge, Hinweise und Charaktertexte werden über Lokalisierungsschlüssel verwaltet.

## 3. Bevölkerung in Ebenen

Die Weltbevölkerung wird in drei Content-Ebenen organisiert.

### 3.1 Hauptfiguren

Wiederkehrende, individuell ausgearbeitete Charaktere mit:
- eigenem Namen, Erscheinungsbild und unverwechselbarer Silhouette;
- Persönlichkeit, Sprachstil, Interessen und Eigenheiten;
- festem Bezug zu einem Ort, Betrieb oder Handlungsstrang;
- wiederkehrenden Begegnungen und kontextabhängigen Reaktionen;
- optionalen persönlichen Geschichten oder Auftragsketten;
- Beziehungen zu ausgewählten anderen Figuren.

Hauptfiguren tragen die emotionale und narrative Identität der Region. Ihre Zahl bleibt bewusst überschaubar.

### 3.2 Wiederkehrende Nebenfiguren

Bewohner und Beschäftigte mit klarer Funktion und einem kleinen Persönlichkeitsprofil:
- wiedererkennbarer Name oder eindeutige Rolle;
- ein bis zwei markante Eigenheiten;
- definierter Arbeits- oder Aufenthaltsort;
- begrenzte Gesprächs- und Reaktionsvarianten;
- gegebenenfalls wiederkehrende Aufträge oder Dienstleistungen.

Sie vermitteln Alltag und regionale Dichte, ohne jeweils eine vollständige Questline zu benötigen.

### 3.3 Hintergrundbevölkerung

Vereinfachte Passanten, Kunden, Lieferanten und Besucher:
- vermitteln Aktivität an Straßen, Märkten und Betrieben;
- folgen einfachen, plausiblen Bewegungs- und Aufenthaltsmustern;
- können kurze, situationsbezogene Reaktionen zeigen;
- benötigen keine individuelle Beziehungssimulation oder umfangreiche Dialogdaten.

Hintergrundfiguren dürfen nicht dieselbe Systemtiefe wie Hauptfiguren benötigen.

## 4. Charakterprofil

Jede individuell relevante Figur erhält ein datengetriebenes Profil. Nicht jedes Feld muss bei jeder Figur befüllt sein.

| Feld | Zweck |
|---|---|
| ID | Stabiler interner Schlüssel |
| Name | Anzeigename und Anrede |
| Rolle | Beruf, gesellschaftliche Funktion oder erzählerische Rolle |
| Heimatbereich | Primärer regionaler Bezug |
| Aufenthaltsorte | Arbeitsort, Zuhause, Lieblingsorte und optionale Treffpunkte |
| Persönlichkeit | Wenige klare Eigenschaften statt langer abstrakter Trait-Liste |
| Sprachstil | Wortwahl, Satzlänge, Humor und Gesprächsenergie |
| Interessen | Themen, Tätigkeiten und Gegenstände, auf die die Figur reagiert |
| Fähigkeiten | Fachwissen oder Dienstleistung, sofern spielmechanisch relevant |
| Beziehungen | Ausgewählte Verbindungen zu anderen Figuren |
| Weltreaktionen | Reaktionen auf konkrete Zustände und Ereignisse |
| Questbezug | Verfügbare Aufträge, Bedingungen und Folgen |
| Verfügbarkeit | Einfache Zeit- oder Ereignisregeln für Begegnungen |
| Erinnerungen | Ausgewählte, geschützte Spieler- und Weltinteraktionen |

Persönlichkeit soll über konkrete, spielbare Merkmale beschrieben werden. Beispiel: „geduldig, trocken, ordentlich, misstrauisch gegenüber Versprechen“ ist hilfreicher als eine große Liste unverbundener Adjektive.

## 5. Rollen und regionale Verankerung

Mögliche Rollen für die erste Region:

- **Werkstattbesitzer / Mechaniker:** Reparatur, Ersatzteile, Maschinenwissen und technische Aufträge.
- **Händler / Trödler:** Ankauf, Verkauf, Bewertung und besondere Fundstücke.
- **Landwirt / Gärtnerei:** Naturmaterialien, Lieferungen und regionale Gemeinschaftsprojekte.
- **Ehemaliger Industriearbeiter:** Ortsgeschichte, Industriegelände, alte Anlagen und Bergungshinweise.
- **Bahnhofs- oder Frachtmitarbeiter:** Transport, Lagerung, Lieferaufträge und Zugang zum Railway District.
- **Gemeinschaftskoordinator:** Veranstaltungen, lokale Projekte und Kontakte.
- **Sammler / Antiquitätenhändler:** seltene Objekte, Objektgeschichten und gezielte Suchaufträge.
- **Kleine Ladenbesitzer:** Versorgung, lokale Nachfrage und Veränderungen der Main Street.
- **Lieferant / Spediteur:** Materialbeschaffung, Transportverbindungen und Vertragsangebote.

Die Rollen sind Funktionsvorschläge, keine endgültige NPC-Liste. Mehrere Funktionen können in einer Figur oder einem kleinen Betrieb zusammenfallen.

## 6. Beziehungen zwischen Bewohnern

Die Region soll ein kleines Netz aus nachvollziehbaren Verbindungen besitzen. Beispiele:
- Geschäftspartner und Lieferanten;
- Familien- oder Freundschaftsbeziehungen;
- frühere Kollegen aus der Industrie;
- Nachbarn mit unterschiedlichen Interessen;
- alte Konflikte oder Missverständnisse;
- gegenseitige Hilfe bei regionalen Projekten.

Diese Beziehungen müssen nicht alle als Quest sichtbar werden. Sie können über beiläufige Bemerkungen, gemeinsame Auftritte, Empfehlungen oder Reaktionen auf Ereignisse vermittelt werden.

### 6.1 Beziehungsdaten

Beziehungen zwischen Figuren können über wenige qualitative Zustände und Ereignisverweise beschrieben werden:
- kennt;
- arbeitet zusammen mit;
- vertraut;
- steht in Konflikt mit;
- schuldet einen Gefallen;
- hat gemeinsame Vergangenheit mit.

Nicht jede Beziehung benötigt alle Zustände. Beziehungen werden nicht als komplexe numerische Simulation berechnet.

### 6.2 Keine globale Moralwertung

Es gibt keinen universellen Rufwert, der alle Bewohner gleich reagieren lässt. Eine Zusage gegenüber einem Lieferanten kann für diesen wichtig sein, ohne dass die gesamte Stadt davon automatisch erfährt.

Informationen verbreiten sich nur, wenn es einen plausiblen Weg gibt: persönliche Empfehlung, gemeinsamer Betrieb, öffentliches Ereignis oder sichtbare Veränderung.

## 7. Beziehung zwischen Spieler und Bewohnern

Die Beziehung zum Spieler entwickelt sich aus konkreten Begegnungen:
- Gespräche und wiederholte Kontakte;
- eingehaltene oder bewusst abgelehnte Zusagen;
- erfüllte Aufträge;
- Hilfe bei persönlichen oder gemeinschaftlichen Anliegen;
- gemeinsame Projekte und sichtbare Verbesserungen;
- besondere Entdeckungen oder Ereignisse.

Das Spiel muss nicht jede Begegnung in Punkte umrechnen. Für die meisten Figuren reichen wenige qualitative Stufen oder konkrete Ereignisflags, etwa:
- noch unbekannt;
- bekannt;
- verlässlich;
- vertraut.

Diese Zustände sind interne Hilfen für Dialog- und Inhaltsvarianten. Sie müssen nicht als Balken, Prozentwert oder Rang angezeigt werden.

### 7.1 Konsequenzen

Eine gewachsene Beziehung kann ermöglichen:
- neue oder bessere Aufträge;
- Empfehlungen an andere Bewohner;
- Zugang zu einem Lieferanten oder einer Dienstleistung;
- Hinweise auf besondere Fundorte;
- Einladung zu einem Ereignis;
- persönliche Gespräche oder kleine Geschichten;
- Unterstützung bei einem Gemeinschaftsprojekt.

Beziehungen dürfen keine unverzichtbaren Kernsysteme hinter versteckten Sympathiewerten versperren. Kritische Grundfunktionen erhalten alternative Zugänge.

### 7.2 Ablehnung und Ignorieren

Der Spieler darf Aufträge ablehnen, Gespräche abbrechen oder optionale Anliegen ignorieren. Daraus entstehen keine künstlichen Bestrafungsketten.

Wenn eine Zusage ausdrücklich gemacht wurde, darf ihre Nichterfüllung eine nachvollziehbare Reaktion der direkt betroffenen Figur auslösen. Das bleibt lokal, transparent und verhältnismäßig. Eine verpasste optionale Aufgabe darf nicht dauerhaft alle späteren Inhalte blockieren.

## 8. Alltag und Präsenz

Bewohner sollen an plausiblen Orten auftauchen, ohne dass eine vollständige Tagesablauf-Simulation erforderlich ist.

Das System nutzt wenige verständliche Aufenthaltszustände:
- bei der Arbeit;
- an einem bekannten öffentlichen Ort;
- unterwegs zwischen zwei relevanten Orten;
- bei einem Ereignis;
- vorübergehend nicht verfügbar.

Für wichtige Figuren können einfache Zeitfenster oder Ereignisbedingungen gelten. Nebenfiguren und Hintergrundbevölkerung verwenden vereinfachte Regeln.

### 8.1 Spielerfreundliche Verfügbarkeit

- Wichtige Dienste dürfen nicht durch zufällige Abwesenheit dauerhaft unzugänglich werden.
- Dialoge und Aufträge können bei Bedarf an einem zweiten Kontaktpunkt verfügbar sein.
- Zeitabhängige Begegnungen werden angekündigt oder wiederholbar angeboten, wenn sie relevant sind.
- Keine täglichen Pflichtbesuche und keine Bestrafung für verpasste Zeitfenster.
- Offline-Fortschritt löst keine unbeaufsichtigten sozialen Krisen aus.

## 9. Unternehmen und lokale Wirtschaft

Unternehmen sind mehr als Verkaufsmenüs. Sie geben Orten Identität und verbinden Bewohner mit dem Wirtschaftssystem.

### 9.1 Betriebstypen

- Einzelhandel und Versorgung;
- Werkstätten und Reparaturbetriebe;
- Landwirtschaft und Naturprodukte;
- Schrott- und Materialhandel;
- Industrie und Lagerhaltung;
- Transport und Fracht;
- Sammler, Trödler und Spezialhandel;
- gemeinschaftlich getragene Einrichtungen.

### 9.2 Unternehmensprofil

Ein relevanter Betrieb kann besitzen:
- eindeutige ID, Name und Standort;
- Betreiber und zugeordnete Figuren;
- Geschäftstyp und angebotene Waren/Dienstleistungen;
- Öffnungs- oder Verfügbarkeitsregeln;
- Nachfrage- und Bestandszustände;
- verfügbare Aufträge und Lieferbeziehungen;
- Ausbau- oder Wiedereröffnungszustand;
- sichtbare Weltzustände.

Die Wirtschaft bleibt Teil des bestehenden stabilen Basismodells mit dynamischen Chancen. NPC-Betriebe sollen keine undurchsichtige Konkurrenzsimulation erzeugen.

### 9.3 Veränderungen durch den Spieler

Ein Betrieb kann sich abhängig von konkreten Projekten verändern:
- geschlossen → wieder geöffnet;
- eingeschränkt → regulär verfügbar;
- einfacher Dienst → erweitertes Angebot;
- fehlende Verbindung → an das regionale Liefernetz angeschlossen.

Solche Veränderungen benötigen klare Voraussetzungen und sichtbare Rückmeldung. Sie dürfen nicht ausschließlich durch unsichtbare Zufallswerte ausgelöst werden.

## 10. Aufträge aus Charakteren entwickeln

Aufträge sollen aus der Rolle und Situation einer Figur entstehen, nicht aus einer zufälligen Liste beliebiger Tätigkeiten.

Beispiele:
- Ein Mechaniker benötigt bestimmte Komponenten, um eine alte Hebevorrichtung wieder in Betrieb zu nehmen.
- Eine Ladenbesitzerin bittet um die Bergung eines bestimmten Schildes oder Einrichtungsgegenstands.
- Ein ehemaliger Industriearbeiter kennt einen verschlossenen Wartungsbereich und kann den Zugang erklären.
- Ein Landwirt benötigt Transporthilfe für eine Lieferung.
- Ein Sammler sucht ein Objekt, dessen Geschichte sich über mehrere Hinweise erschließt.
- Der Bahnhofsmitarbeiter organisiert einen ungewöhnlichen Frachtauftrag.

Jeder Auftrag muss zu mindestens einem bestehenden Gameplay-System gehören: Beschaffung, Erkundung, Bergung, Transport, Verkauf, Verarbeitung, Reparatur, Bau oder Gemeinschaftsprojekt.

Nicht jeder Dialog muss einen Auftrag anbieten. Gespräche dürfen Atmosphäre, Wissen, Beziehungen oder Humor vermitteln.

## 11. Dialog und Reaktionen

Dialoge werden kontextabhängig aus vorbereiteten Varianten ausgewählt. Ein vollständiges LLM ist keine Voraussetzung.

Relevanter Kontext kann sein:
- Ort und aktuelle Situation;
- Tageszeit oder Ereignis;
- bisherige Begegnungen;
- Beziehung zum Spieler;
- aktive oder abgeschlossene Aufträge;
- sichtbare Weltveränderungen;
- relevante Entdeckungen;
- Beziehung zu anderen Figuren.

### 11.1 Dialogtypen

- Begrüßung und Wiedererkennung;
- kurze Alltagsgespräche;
- fachliche Auskünfte;
- Auftragsangebote und Rückmeldungen;
- Reaktionen auf Spielerhandlungen;
- Reaktionen auf regionale Veränderungen;
- persönliche Gespräche;
- Ereignis- und Erinnerungsgespräche.

### 11.2 Qualitätsregeln

- Wiederholungen vermeiden oder bewusst variieren.
- Figuren behalten einen konsistenten Sprachstil.
- Keine endlosen Dialogwände für einfache Interaktionen.
- Wichtige Informationen müssen zusätzlich im Journal oder Auftrag sichtbar sein.
- Humor passt zur Figur und Situation.
- Stille und kurze Reaktionen sind zulässig.
- Keine künstliche Gesprächspflicht, um normale Spielsysteme zu bedienen.

## 12. Gemeinschaft und regionale Entwicklung

Einige Bewohner können gemeinsam an sichtbaren Projekten arbeiten. Diese Projekte verbinden persönliche Anliegen und die Entwicklung der Region.

Mögliche Beispiele:
- Reparatur des alten Bahnhofsvorplatzes;
- Wiedereröffnung eines kleinen Ladens;
- Aufräumen eines öffentlichen Platzes;
- Wiederherstellung einer Werkstatt;
- Aufbau einer lokalen Sammelstelle;
- Organisation eines kleinen Marktes.

Projekte bestehen aus klaren Beiträgen wie Materialien, Transport, Reparatur oder Finanzierung. Der Spieler kann mehrere Wege zur Unterstützung haben. Nach Abschluss verändert sich die Welt sichtbar und Bewohner reagieren darauf.

Gemeinschaftsprojekte sind optionale Verstärker der Weltentwicklung, keine tägliche Pflicht oder Voraussetzung für den Hauptabschluss.

## 13. Technische Systemstruktur

Die Konzeption soll später eine datengetriebene Umsetzung ermöglichen.

Vorgeschlagene logische Bausteine:
- **Character Registry:** Identitäten, Profile und Rollen.
- **Presence / Schedule Resolver:** Aufenthaltszustände und Verfügbarkeit.
- **Relationship Store:** qualitative Beziehungen und relevante Ereignisse.
- **World Reaction Evaluator:** prüft, welche Figuren auf Weltzustände reagieren.
- **Dialogue Resolver:** wählt passende Dialogvarianten.
- **Quest / Contract Integration:** verbindet Charaktere mit Aufträgen und Bedingungen.
- **Business Registry:** Betriebe, Betreiber, Waren und Dienstleistungen.
- **Event Dispatcher:** verteilt relevante Welt- und Spielerereignisse.

Ein gemeinsames Ereignisformat verhindert, dass jedes System eigene Sonderregeln für dieselbe Handlung entwickelt. Beispiele: Auftrag erfüllt, Betrieb eröffnet, Lieferung eingetroffen, Ort wiederhergestellt, Fund entdeckt.

### 13.1 Persistenz

Gespeichert werden nur relevante Zustände:
- Charakter- und Betriebszustände;
- wichtige Beziehungsflags;
- bereits erlebte persönliche Ereignisse;
- Quest- und Projektfortschritt;
- notwendige Präsenzzustände.

Hintergrundbewegungen und belanglose Alltagsschritte müssen nicht dauerhaft gespeichert werden.

## 14. Umfang für den ersten Welt-Prototyp

Empfohlener Testumfang:
- drei bis fünf wiederkehrende Bewohner;
- mindestens zwei klar unterscheidbare Persönlichkeiten;
- ein kleiner Betrieb mit Betreiber;
- eine Figur mit wiederkehrendem Dienst oder Handel;
- zwei einfache Aufträge aus unterschiedlichen Rollen;
- eine Beziehung, die sich durch ein konkretes Ereignis verändert;
- ein Gemeinschaftsprojekt mit sichtbarer Veränderung;
- einige Hintergrundfiguren zur Belebung der Main Street.

### Abnahmekriterien

Der Prototyp ist erfolgreich, wenn:
1. Spieler mindestens drei Bewohner nach kurzer Zeit wiedererkennen.
2. Figuren nicht nur beim Annehmen und Abgeben von Aufträgen relevant sind.
3. Ihre Rollen und Persönlichkeiten auch ohne lange Dialoge erkennbar bleiben.
4. Eine erfüllte Zusage eine nachvollziehbare Reaktion auslöst.
5. Beziehungen ohne globale Rufanzeige verständlich bleiben.
6. Optionale soziale Inhalte ignoriert werden können, ohne den Kernfortschritt zu blockieren.
7. Betriebe und Bewohner die Region glaubwürdiger und funktionaler machen.
8. Präsenzregeln keine unnötigen Wartezeiten erzeugen.

## 15. Offene Ausarbeitung

- Finale Hauptfiguren und ihre Namen.
- Konkrete Biografien, Erscheinungsbilder und Sprachprofile.
- Beziehungsnetz zwischen den Hauptfiguren.
- Welche Betriebe von Anfang an aktiv, geschlossen oder eingeschränkt sind.
- Exakte Verfügbarkeitsregeln und Treffpunkte.
- Konkrete Dialogmengen und Lokalisierungsumfang.
- Belohnungen und Bedingungen persönlicher Auftragsketten.
- Welche regionalen Veränderungen dauerhaft oder rückgängig zu machen sind.

Diese Punkte werden im nächsten Schritt anhand einer konkreten NPC-Besetzung und des Quest-/Event-Systems ausgearbeitet.


## Ergänzung: Charaktere und Auftragsintegration

Bewohner und Unternehmen sind natürliche Quellen für persönliche Geschichten, regionale Aufgaben und wiederkehrende Dienstleistungen. Nicht jedes Gespräch erzeugt einen Auftrag. Aufgaben entstehen aus konkreten Anliegen und nutzen vorhandene Gameplay-Systeme. Optionale persönliche Geschichten dürfen keine unverzichtbaren Kernfunktionen blockieren.

Die vollständigen Regeln für Aufträge, Fristen, Ereignisse, Belohnungen und Fortschrittsprüfung stehen in [Quest-, Missions- und Ereignissystem](quest-mission-event-system.md).
