# Scrapstead — Core-Gameplay-Matrix

**Version:** 0.1  
**Status:** Produktionskonkretisierung / Arbeitsgrundlage für MVP und Prototyp  
**Geltungsbereich:** Kernaktionen, minimale vollständige Umsetzung, Abhängigkeiten und optionale Erweiterungen.

---

## 1. Zweck

Die Core-Gameplay-Matrix übersetzt den Produktionsumfang in konkrete Spielerhandlungen. Sie beantwortet für jedes Kernsystem:

- Was tut der Spieler tatsächlich?
- Was muss die erste vollständige Version mindestens leisten?
- Welche anderen Systeme sind dafür erforderlich?
- Was darf später ergänzt werden?
- Wann wird das System im Entwicklungsfahrplan benötigt?

Die Matrix ist keine zusätzliche Feature-Wunschliste. Sie ist ein Filter: Alles, was nicht für die beschriebene Spielerfahrung benötigt wird, bleibt optional oder außerhalb des Kernumfangs.

**Grundsatz:** Erst die kleinste vollständige und befriedigende Spielhandlung bauen. Danach nur erweitern, wenn ein echter Mehrwert nachweisbar ist.

## 2. Verbindliche Spielschleife

Die Kernschleife besteht aus fünf miteinander verbundenen Abschnitten:

1. **Entdecken:** Der Spieler erkundet den Old Yard und später die Region, erkennt interessante Objekte und findet Aufträge oder Hinweise.
2. **Bergen:** Der Spieler nimmt kleine Gegenstände auf oder löst bei größeren Objekten eine passende Bergungsinteraktion aus.
3. **Verwerten:** Der Spieler verkauft Fundstücke direkt oder entscheidet bei ausgewählten Objekten über Sortierung, Demontage oder Aufbereitung.
4. **Verbessern:** Credits und gefundene Ressourcen werden in Werkzeuge, Transport, Arbeitsbereiche, Mitarbeiter und Maschinen investiert.
5. **Gestalten und erweitern:** Der Spieler organisiert den Schrottplatz, delegiert Wiederholungen, erkundet neue Orte und arbeitet auf den Hauptabschluss hin.

Scrappy, Bewohner, Aufträge und Weltveränderungen geben diesen Tätigkeiten Persönlichkeit und Zusammenhang. Sie ersetzen die Schleife nicht.

## 3. Prioritätsdefinitionen

| Kürzel | Bedeutung |
|---|---|
| **Kern** | Muss in der ersten vollständigen Spielversion vorhanden sein. |
| **MVP** | Minimalversion, die im frühen Prototyp nachgewiesen werden muss. |
| **Optional** | Darf nach funktionierendem Kern ergänzt werden; nicht für den Abschluss erforderlich. |
| **Nicht im Kern** | Wird für die erste vollständige Version ausdrücklich nicht geplant. |

Phasen beziehen sich auf [Produktionsumfang und Entwicklungsfahrplan](production-scope-and-roadmap.md).

## 4. Matrix der Kernmechaniken

### 4.1 Bewegung, Erkundung und Interaktion

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Bewegung | Zu Fuß über Gelände und durch Gebäude gehen | Zuverlässige isometrische Bewegung, Kollisionen, Interaktion in erreichbarer Nähe | Welt, Kamera, Eingabe | 0–1 | Zusätzliche Bewegungsanimationen und Komfort |
| Kamera | Umgebung überblicken und interessante Orte erkennen | Lesbare isometrische Kamera mit kontrollierter Zoom-/Bewegungsfunktion | Weltgeometrie, UI | 0–1 | Weitere Kameramodi |
| Interaktion | Gegenstände und Einrichtungen untersuchen oder benutzen | Kontextaktion mit verständlichem Feedback; erreichbare Objekte werden eindeutig hervorgehoben | Bewegung, Interaktionsobjekte | 1 | Umfangreichere Interaktionsvarianten |
| Erkundung | Grundstück und zugängliche Gebiete absuchen | Handgefertigte Fundorte, klare Orientierung und sinnvolle Entdeckungen | Welt, Gegenstände, Aufgaben | 1–2, 5 | Zusätzliche Geheimnisse, Fundserien, optionale Gebiete |
| Objektinspektion | Wert, Zustand oder Material eines Fundes erkennen | Kompakte Objektinformation mit Name, Kategorie und relevanten Eigenschaften | Gegenstandsdaten, UI | 1 | Erweiterte Diagnose und seltene Eigenschaften |

**MVP-Nachweis:** Eine kleine Testfläche, auf der Spieler sich bewegen, mehrere Gegenstände erkennen, untersuchen und aufnehmen kann.

### 4.2 Sammeln, Bergen und Transportieren

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Kleinteile sammeln | Lose Gegenstände aufnehmen | Einfache Aufnahme mit klarer Kapazitäts- oder Inventarrückmeldung | Interaktion, Inventar | 1 | Sammelwerkzeuge und Sammelboni |
| Große Objekte bergen | Werkzeug oder passende Aktion einsetzen | Wenige klar unterscheidbare Bergungsaktionen; Voraussetzung und Ergebnis sind sichtbar | Werkzeuge, Objektprofile | 1 | Zusätzliche Werkzeugtypen und Spezialaktionen |
| Tragen und Abliefern | Gesammelte Gegenstände zu einem Ziel bringen | Verständliche Tragekapazität und ein definierter Ablage-/Verkaufsort | Inventar, Weltobjekte | 1 | Handkarren und weitere Transporthilfen |
| Objektzustand | Erkennen, ob ein Objekt intakt, beschädigt oder zerlegt ist | Nur Zustände, die eine echte Gameplay-Entscheidung auslösen | Gegenstandsdaten, Verarbeitung | 1, 4 | Detaillierte Qualitäts- und Zustandsstufen |
| Weltfund-Regeneration | Wiederkehrende Quellen erneut nutzen | Begrenzte, kontrollierte Nachfüllung gewöhnlicher Fundquellen; Storyfunde bleiben geschützt | Weltzustand, Zeit | 4–5 | Unterschiedliche Nachfüllprofile und regionale Ereignisse |

**MVP-Nachweis:** Ein kleines Fundstück kann aufgehoben werden; ein größeres Objekt erfordert eine passende Aktion; beide können zum Verkaufsbereich gebracht werden.

### 4.3 Inventar, Lager und Gegenstandsdaten

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Persönliches Inventar | Kleine Funde mitführen | Begrenzte, verständliche Aufnahme von Gegenständen oder Sammelstapeln | Gegenstandsdaten, UI | 1 | Zusätzliche Sortier- und Filterfunktionen |
| Betriebslager | Gegenstände am Schrottplatz ablegen und wieder entnehmen | Wenige klar erkennbare Lagerbereiche mit standortgebundenem Bestand | Gegenstandsdaten, Grundstück | 1, 4 | Spezialisierte Lager und Komfortfilter |
| Materialbestand | Rohmaterialien und Komponenten verwalten | Mengenbasierte Bestände mit klaren Kategorien und Kapazitätsregeln, wo nötig | Verarbeitung, Lager | 4 | Qualitätsgetrennte Bestände und weitere Materialgruppen |
| Schutzobjekte | Wichtige Storyfunde behalten | Quest- und Schlüsselobjekte können nicht versehentlich verkauft, verbraucht oder durch Regeneration entfernt werden | Aufgaben, Inventar, Save | 2 | Erweiterte Sammlungsverwaltung |
| Datenkatalog | Gegenstände eindeutig definieren | Stabile IDs, Kategorien, Basiswert, Interaktions- und Ergebnisdaten | Datenformat | 0–1 | Umfangreiche Eigenschaften und Varianten |

**MVP-Nachweis:** Ein Gegenstand bleibt nach Aufnahme, Ablage, Verkauf und erneutem Laden konsistent erhalten bzw. verändert seinen Zustand korrekt.

### 4.4 Verkauf, Wirtschaft und Investitionen

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Direktverkauf | Gegenstände gegen Credits verkaufen | Verkauf an einem klaren Ort oder über eine einfache Verkaufsinteraktion; Preis vor Bestätigung erkennbar | Inventar, Preise, Credits | 1 | Weitere Abnehmer und Angebotsvarianten |
| Preislogik | Wert von Gegenständen verstehen | Stabile Basiswerte und nachvollziehbare Preisregeln | Gegenstandsdaten, Wirtschaft | 1 | Wenige zeitlich begrenzte Nachfrageereignisse |
| Kontostand | Credits erhalten und ausgeben | Eine zentrale Währung; Transaktionen werden korrekt verbucht | Save, UI | 1 | Erweiterte Statistik |
| Einkaufen | Werkzeuge oder freigeschaltete Waren erwerben | Begrenztes Angebot mit Preis, Verfügbarkeit und verständlichem Nutzen | Credits, Händler/Shop-UI | 1–2 | Händlerangebote und Sonderaktionen |
| Upgrades | Arbeitsweise verbessern | Kleine, sichtbare Auswahl von Werkzeug- und Transportverbesserungen | Wirtschaft, Progression | 1 | Weitere Upgrade-Stufen |
| Betriebskosten | Mitarbeiter und ausgewählte Maschinen finanzieren | Transparente, moderate Kosten; kein stiller oder irreversibler finanzieller Softlock | Zeit, Wirtschaft | 3–4 | Erweiterte Kostenübersicht |
| Nachfrageereignis | Gelegentliche bessere Verkaufschance nutzen | Optionales, klar angekündigtes Ereignis; Grundverkauf bleibt immer sinnvoll | Markt, Aufträge | 5 | Mehr Ereignisvarianten |

**MVP-Nachweis:** Spieler verkauft Gegenstände, erhält Credits und kann eine erste sinnvolle Verbesserung kaufen.

### 4.5 Sortierung, Demontage und Aufbereitung

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Direktverwertung | Gegenstand ohne Verarbeitung verkaufen | Für gewöhnliche Gegenstände jederzeit verfügbar und wirtschaftlich tragfähig | Verkauf | 1 | Weitere Abnehmer |
| Sortierung | Gemischtes Material trennen | Eine einfache Station mit wenigen Eingaben und klaren Ausgaben | Lager, Maschine/Interaktion | 3–4 | Zusätzliche Materialklassen |
| Demontage | Ausgewählte Gegenstände zerlegen | Begrenzte Gegenstandsauswahl mit vorhersehbaren Material-/Komponentenergebnissen | Objektprofile, Werkzeuge/Station | 4 | Detaillierte Komponenten bei besonderen Objekten |
| Aufbereitung | Sortierte Materialien weiterverwerten | Wenige einfache Rezepte mit klar erkennbarem Mehrwert | Maschine, Materialbestand | 4 | Weitere Produkte und Qualitätsstufen |
| Wiederverwendung | Komponenten erneut einsetzen oder verkaufen | Nur ausgewählte Komponenten erhalten einen zweiten Nutzen | Gegenstandsdaten, Bau/Upgrade | 4 | Größere Komponentenbibliothek |

**MVP-Nachweis:** Ein ausgewählter Gegenstand kann optional zerlegt oder verarbeitet werden. Der Spieler sieht Aufwand und Ergebnis. Der Direktverkauf bleibt eine valide Alternative.

### 4.6 Bauen und Grundstücksentwicklung

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Platzierung | Einrichtung auf dem eigenen Grundstück platzieren | Gebäude, Lager und Maschinen innerhalb der Grundstücksgrenze platzieren und drehen | Welt, Bauobjekte | 1, 4 | Freiere Platzierungsoptionen |
| Platzierungsprüfung | Gültige Position erkennen | Kollision, Grundstücksgrenze und notwendige Bedienfläche prüfen; konkreten Fehler anzeigen | Objektprofile | 4 | Erweiterte Funktionszonen |
| Grundstücksausbau | Zusätzliche Fläche freischalten | Wenige klar definierte Erweiterungen mit sichtbarer Veränderung | Credits, Progression | 4 | Weitere Grundstücksabschnitte |
| Dekoration | Den eigenen Ort gestalten | Begrenzte Auswahl platzierbarer Dekorationen ohne komplexe Funktionslogik | Baumodus, Assets | 4 | Umfangreiche Dekokataloge |
| Gebäude | Werkstatt oder Lagerbereich nutzen | Wenige funktionale Gebäude bzw. vorgefertigte Gebäudeteile | Bau, Interaktion | 4 | Modulare Gebäudevielfalt |
| Maschinenverbindung | Zwei kompatible Maschinen verbinden | Für Kernmaschinen höchstens eine einfache Verbindungsmethode; Route wird vom Spiel unterstützt | Maschinenanschlüsse, Bau | 4 | Mehr Verbindungstypen und Netzwerke |

**MVP-Nachweis:** Ein funktionales Objekt kann auf dem Yard platziert werden. Ungültige Positionen werden verständlich erklärt. Für die erste Sammel-/Verkaufsrunde ist kein vollständiger Baumodus nötig.

### 4.7 Mitarbeiter und Delegation

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Rekrutierung | Eine Person kennenlernen und einstellen | Ein Mitarbeiter mit klarer Rolle, sichtbaren Kosten und einfacher Einstellung | Figur, Wirtschaft, UI | 3 | Weitere Rekrutierungswege |
| Arbeitsbereich | Arbeitszone oder Zielpunkt festlegen | Ein klarer Bereich oder Ablagepunkt, an dem der Mitarbeiter arbeitet | Grundstück, Aufgaben | 3 | Mehrere Arbeitsbereiche |
| Aufgabenvergabe | Wiederholte Tätigkeit delegieren | Eine einzige zuverlässige Aufgabe; Mitarbeiter bewegt reale Gegenstände oder erledigt einen realen Arbeitsschritt | Gegenstände, Navigation, Save | 3 | Weitere Aufgabenarten |
| Priorität | Arbeitsaufgabe aktivieren oder pausieren | Einfache An/Aus- oder Prioritätsvorgabe | Mitarbeiterzustand | 3 | Mehrere Prioritätsstufen |
| Mitarbeiterentwicklung | Leistung verbessern | Für Kernversion genügt eine einfache Leistungs-/Erfahrungsentwicklung oder ein festes Rollenprofil; keine Skilltree-Pflicht | Arbeitsergebnis | 3–4 | Spezialisierungen und individuelle Vorlieben |

**MVP-Nachweis:** Ein Mitarbeiter übernimmt eine Tätigkeit, die der Spieler vorher selbst ausgeführt hat. Ergebnis, Arbeitsbereich und Kosten sind sichtbar und nachvollziehbar.

### 4.8 Maschinen und Automation

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Maschinenkauf | Maschine als Investition erwerben | Wenige Maschinen mit klarer Funktion, Kosten und Nutzen | Wirtschaft, Progression | 3–4 | Mehr Maschinenfamilien |
| Maschinenplatzierung | Maschine auf dem Yard aufstellen | Platzierung mit Zugangs- und Anschlussprüfung | Baumodus, Objektprofile | 4 | Zusätzliche Aufstellungsvarianten |
| Maschineneingabe | Material zuführen | Für Kernmaschine ein klarer Ablage-/Eingabepunkt oder direkter Arbeitsbereich | Lager, Gegenstände | 3–4 | Fördertechnik |
| Maschinenprozess | Sichtbar und zuverlässig verarbeiten | Ein klarer Input-Output-Prozess; Simulation getrennt von Animation | Daten, Zeit, Bestand | 3–4 | Mehrstufige Rezepte |
| Maschinenausgabe | Ergebnis abholen oder lagern | Ein eindeutiger Ausgabepunkt oder Lagerziel | Lager, Materialbestand | 3–4 | Automatische Verteilung |
| Upgrade | Leistung einer Maschine verbessern | Höchstens wenige leicht verständliche Upgrades | Wirtschaft, Maschine | 4 | Konfigurierbare Module |
| Störung | Maschine bei fehlendem Input oder Blockade stoppen | Klare Statusmeldung und einfache Behebung; keine dauernde Wartungspflicht | Bestand, UI | 4 | Seltene optionale Ereignisse |

**MVP-Nachweis:** Eine Maschine verarbeitet einen klaren Input zu einem klaren Output. Das Ergebnis ist reproduzierbar, sichtbar und wirtschaftlich verständlich.

### 4.9 Scrappy

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Wiederherstellung | Kopf und Kernkomponente finden und verbinden | Garantierte, geschützte Entdeckungen und kurze Aktivierungsszene | Weltfund, Story, Interaktion | 2 | Weitere Funddetails |
| Begleiter | Scrappy begleitet den Spieler | Folgt in sinnvoller Distanz, blockiert Wege nicht und kann warten | Bewegung, Navigation | 2 | Weitere Bewegungsmodi |
| Persönlichkeit | Scrappy reagiert eigenständig | Kontextbezogene, vorbereitete Dialog- und nonverbale Reaktionen; Wiederholungen begrenzen | Ereignisse, Dialogdaten | 2 | Mehr Dialogvarianten |
| Interaktion | Scrappy untersucht oder kommentiert Objekte | Einige klar definierte Beobachtungs- und Hinweisreaktionen | Weltobjekte, Kontext | 2 | Zusätzliche Fähigkeiten |
| Module | Funktion oder Aussehen verändern | Kleine Auswahl aus wenigen funktionalen Modulen und kosmetischen Teilen; Identität bleibt erhalten | Inventar, Module | 2–4 | Umfangreiches Baukastensystem |
| Erinnerungen | Gemeinsame Erlebnisse wieder aufgreifen | Ereignisflags und begrenzte geschützte Erinnerungen für wiederkehrende Reaktionen | Save, Ereignisse | 2 | Umfangreichere persönliche Entwicklung |
| Autonomie | Eigenständig kleine Aktivitäten verfolgen | Für Kernversion nur harmlose, sichtbare Idle-/Beobachtungsaktivitäten; keine eigenständigen wichtigen Entscheidungen | Aktivitätssystem | Optional | Größere autonome Projekte |

**MVP-Nachweis:** Scrappy wird zuverlässig wiederhergestellt, begleitet den Spieler und reagiert auf einige tatsächliche Spielsituationen. Er darf nicht zum Pflichtpflege- oder Mikromanagementsystem werden.

### 4.10 Aufträge, Figuren und Erzählung

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Hauptfortschritt | Nächstes sinnvolles Ziel verfolgen | Klarer Hauptpfad mit wenigen Kapiteln/Meilensteinen und erreichbarem Abschluss | Questzustand, Save | 2–6 | Alternative Kapitelpfade |
| Persönliche Geschichte | Bewohner kennenlernen und bei konkretem Anliegen helfen | Wenige wiederkehrende Figuren mit kurzen, abgeschlossenen Geschichten | Dialog, Weltzustand | 5 | Weitere Handlungsstränge |
| Liefer-/Beschaffungsauftrag | Material oder Gegenstand an Ziel liefern | Begrenzte Auftragsvorlagen mit klaren Mengen, Zielen und Belohnungen | Inventar, Welt, Wirtschaft | 2–5 | Mehr Varianten |
| Erkundungsentdeckung | Hinweise und Fundorte untersuchen | Einige handgefertigte Entdeckungen, die nicht alle Questmarker benötigen | Welt, Gegenstände, Journal | 2, 5 | Fundserien |
| Gemeinschaftsprojekt | Materialien oder Arbeit für einen Ort beitragen | Ein Projekt mit klaren Beiträgen und sichtbarem Abschlusszustand | Quest, Inventar, Weltzustand | 5–6 | Zweites Projekt |
| Journal/Karte | Aktive Ziele und bekannte Hinweise wiederfinden | Kompakte Übersicht, wenige relevante Marker, keine permanente Vollmarkierung | Questzustand, UI | 2, 5 | Filter und Komfortoptionen |
| Wiederkehrender Auftrag | Eine optionale Tätigkeit erneut erledigen | Wenige kontrollierte Varianten; keine Pflicht für Hauptfortschritt | Wirtschaft, Quest | 5 | Größere Vorlagenbibliothek |

**MVP-Nachweis:** Eine kurze Hauptmissionsfolge und mindestens ein optionaler Auftrag funktionieren mit persistentem Fortschritt. Der erste Welt-Prototyp kann mit einem Aushang und einem Lieferauftrag beginnen.

### 4.11 Region und regionale Betriebe

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| Hauptregion | Zwischen wenigen Orten reisen | Kompakte, handgefertigte Region mit Old Yard und den für den Abschluss notwendigen Kernorten | Welt, Navigation | 5 | Weitere Teilgebiete |
| Regionale Anlaufstelle | Kaufen, verkaufen, Dienstleistung oder Auftrag nutzen | Wenige spezialisierte Orte mit klarer Funktion; keine vollständige Betriebssimulation | Figuren, Wirtschaft, UI | 5 | Weitere Dienste |
| Weltzustand | Sichtbar einen Ort verändern | Wenige diskrete Zustände, z. B. geschlossen/geöffnet oder beschädigt/repariert | Quest, Welt | 5 | Mehr Varianten |
| Lieferverbindung | Lieferung zwischen Orten organisieren | Für Kernabschluss genügt ein klarer, begrenzter Lieferauftrag; keine vollständige Routenplanung erforderlich | Auftrag, Zeit, Transport | 6 | Automatisierte Routen |
| Außenstandort | Eine zusätzliche Betriebsfunktion nutzen | Nur falls für die finale Herausforderung nötig; ein klarer Zweck und begrenzte Bestände | Welt, Lager, Quest | 6 | Weitere Standorte |

**MVP-Nachweis:** Ein zweiter Ort bietet einen konkreten Grund für einen Besuch und einen nachvollziehbaren Zusammenhang mit dem Old Yard.

### 4.12 UI, Speichern und Lokalisierung

| Mechanik | Spielerhandlung | Minimale vollständige Umsetzung | Abhängigkeiten | Phase | Erweiterungen |
|---|---|---|---|---|---|
| HUD | Credits, Interaktionshinweise und aktive Ziele sehen | Kompaktes HUD mit nur relevanten Informationen | UI, Spielzustand | 1 | Anpassbare HUD-Layouts |
| Kontextfeedback | Verstehen, warum etwas möglich oder unmöglich ist | Kurze, konkrete Meldung statt technischer Fehlermeldung | Interaktion, Bau, Inventar | 1 | Erweiterte Hilfen |
| Speichern/Laden | Spielstand zuverlässig fortsetzen | Manuelles und/oder automatisches Speichern mit versionierten Daten und Schutz kritischer Zustände | Alle persistenten Systeme | 0–1 | Mehrere Komfortslots |
| Lokalisierung | Sprache wechseln und Texte korrekt sehen | Deutsch und Englisch über Schlüssel; keine fest codierten Spieltexte | UI, Daten, Dialoge | 0–7 | Weitere Sprachen |
| Audio/Feedback | Aktionen und Fortschritt wahrnehmen | Wesentliche Interaktionen besitzen klares visuelles und akustisches Feedback | Animation, Audio, UI | 1–7 | Umfangreiche Audio-Politur |

**MVP-Nachweis:** Ein Spielstand kann gespeichert, geladen und fortgesetzt werden, ohne Gegenstände, Credits oder Missionsfortschritt zu duplizieren oder zu verlieren.

## 5. Minimaler vollständiger Spielablauf

Der Kern muss als durchgehender Ablauf funktionieren, bevor optionale Inhalte wachsen:

1. Spieler kommt auf dem Old Yard an und versteht die Grundsituation.
2. Spieler erkundet das Grundstück und findet kleine Gegenstände.
3. Spieler sammelt Gegenstände und bringt sie zum Verkaufsbereich.
4. Spieler verkauft Fundstücke und erhält Credits.
5. Spieler kauft eine erste sinnvolle Werkzeug- oder Transportverbesserung.
6. Spieler entdeckt Scrappys Kopf und die geschützte Kernkomponente und stellt ihn wieder her.
7. Spieler nutzt Scrappy als Begleiter und erlebt seine Persönlichkeit.
8. Spieler lernt eine einfache optionale Sortier-/Demontageentscheidung kennen.
9. Spieler stellt einen Mitarbeiter ein und delegiert eine bekannte Wiederholungstätigkeit.
10. Spieler kauft und betreibt eine erste Maschine.
11. Spieler erweitert und organisiert den Old Yard mit wenigen funktionalen Einrichtungen.
12. Spieler erkundet die Kernregion, trifft wiederkehrende Figuren und erledigt ausgewählte Aufträge.
13. Spieler verändert mindestens einen regionalen Ort durch ein Gemeinschaftsprojekt.
14. Spieler organisiert eine begrenzte Lieferung oder Verbindung zwischen Orten.
15. Spieler bewältigt eine finale Herausforderung, die bekannte Systeme kombiniert.
16. Spieler erreicht den Hauptabschluss und kann danach frei weiterspielen.

Dieser Ablauf ist ein Produktionsgerüst. Die konkrete Missionserzählung und Reihenfolge werden im Quest- und Progressionsdesign festgelegt. Die Kernmechaniken müssen dabei dieselben bleiben.

## 6. Abhängigkeiten und Reihenfolge

Systeme sollen in folgender Reihenfolge aufgebaut werden, weil spätere Mechaniken auf früheren Ergebnissen beruhen:

| Reihenfolge | Voraussetzung | Darauf aufbauend |
|---|---|---|
| 1 | Bewegung, Kamera, Interaktion | Sammeln und Erkundung |
| 2 | Gegenstandsdaten und Inventar | Transport, Verkauf, Lager |
| 3 | Credits, Preise und Transaktionen | Upgrades, Händler, Betriebskosten |
| 4 | Werkzeuge und Objektprofile | Große Bergung und optionale Demontage |
| 5 | Persistente Welt- und Questzustände | Scrappy, Hauptmissionen, Storyschutz |
| 6 | Grundstück, Platzierung und Lager | Mitarbeiterbereiche und Maschinen |
| 7 | Aufgaben-/Bestandslogik | Mitarbeiterdelegation und Maschinenprozesse |
| 8 | Kernbetrieb und Spielbalance | Regionale Expansion und Außenbezug |
| 9 | Region, Figuren und Weltzustände | Gemeinschaftsprojekt und finale Herausforderung |
| 10 | Stabiler Kern | optionale Erweiterungen und Politur |

Eine spätere Funktion darf nicht auf einer nur provisorischen, unzuverlässigen Grundlage aufgebaut werden, wenn diese Grundlage für den Hauptabschluss relevant ist.

## 7. Nicht-Funktionsumfang der Kernversion

Folgende Ideen werden in der Core-Gameplay-Matrix nicht als notwendige Mechaniken geführt:

- vollständige Lebenssimulation von Mitarbeitern und Bewohnern;
- komplexe Personalplanung und verpflichtende Schichten;
- vollautonome NPC-Unternehmen;
- komplexe Börsen-, Kredit-, Steuer- oder Konkurrenzsimulation;
- direkte Fahrzeugsteuerung und vollständige Verkehrssimulation;
- komplexe manuelle Förderband-, Strom- oder Rohrnetzplanung;
- unbegrenzte Filialen und Außenstandorte;
- Scrappy-Pflege, Hunger oder Energie als tägliche Pflicht;
- LLM-basierte Autonomie als Voraussetzung für Scrappy;
- Multiplayer, Modding-Plattform oder prozedurale Gesamtregion;
- umfangreiche Meisterziele als Voraussetzung für das Hauptende.

Diese Inhalte können später gesondert bewertet werden, sind aber nicht Teil der Mindestanforderung für ein vollständiges Spiel.

## 8. Definition of Done je Kernmechanik

Eine Mechanik gilt nicht als fertig, nur weil sie technisch einmal funktioniert.

Jede Kernmechanik muss:
1. für den Spieler verständlich sein, ohne externe Dokumentation zu benötigen;
2. eine klare Eingabe und eine nachvollziehbare Rückmeldung besitzen;
3. mit Speichern und Laden korrekt funktionieren, sofern ihr Zustand persistent ist;
4. mit den betroffenen anderen Kernsystemen zusammenarbeiten;
5. Fehler- und Grenzfälle ohne Verlust kritischer Fortschritte behandeln;
6. im UI verständlich kommunizieren, was passiert und warum;
7. auf der Zielhardware stabil und performant laufen;
8. im Spielablauf tatsächlich einen erkennbaren Nutzen besitzen.

## 9. MVP-Prototyp — kleinster aussagekräftiger Test

Der erste spielbare Prototyp muss nicht die ganze Matrix enthalten. Er soll den Kernspaß mit möglichst wenigen Assets und Systemen prüfen.

### Testszene
- Ein kleiner Ausschnitt des Old Yard.
- Spielerfigur und isometrische Kamera.
- Eine Handvoll kleiner Gegenstände.
- Ein großes bergbares Objekt.
- Ein Verkaufsbereich.
- Ein einfaches Upgrade.
- Ein geschützter Scrappy-Fund als kurzer Testablauf kann anschließend ergänzt werden.

### Testhandlungen
- Bewegen und interagieren.
- Kleinteil aufnehmen.
- Großobjekt mit Werkzeug bearbeiten.
- Gegenstand verkaufen.
- Credits erhalten.
- Upgrade kaufen und Effekt erleben.
- Optional einen Gegenstand zerlegen und Ergebnis vergleichen.

### Erfolgskriterien
- Spieler versteht ohne lange Erklärung, was zu tun ist.
- Sammeln und Verkaufen fühlt sich unmittelbar und belohnend an.
- Der erste Kauf ist erreichbar und sichtbar nützlich.
- Der Spieler erkennt einen Grund, weiterzusammeln oder die Umgebung zu erkunden.
- Verarbeitung wirkt wie eine interessante Alternative, nicht wie eine Pflicht.
- Der Test benötigt weder Mitarbeiter, regionale Wirtschaft noch komplexe Logistik.

Erst wenn dieser Test funktioniert, werden Scrappy, Mitarbeiter und Maschinen schrittweise ergänzt.

## 10. Offene Entscheidungen

Die Matrix legt den Mindestumfang fest, ersetzt aber nicht alle späteren Designentscheidungen. Offen bleiben unter anderem:

- Exakte Gegenstands- und Materialmengen.
- Konkrete Werkzeugauswahl und Bergungsaktionen.
- Finale Kernmaschinen und ihre Rezepte.
- Inventar- und Tragekapazitäten.
- Preise, Löhne, Produktionsraten und Investitionskosten.
- Exakte Mitarbeiterrolle für die erste Delegation.
- Konkrete Scrappy-Module der ersten Version.
- Finale Größe und Geometrie der Region.
- Ob der finale Netzwerkabschnitt einen separaten Außenstandort benötigt.
- Exakte Missionskapitel, Figuren und Dialoginhalte.

Diese Werte und Inhalte werden durch Prototypen, Balancing und Contentplanung bestimmt. Sie sollen nicht durch vorzeitige Detailfestlegungen die Produktionsfreiheit einschränken.

---

## Zusammenfassung

Die Kernmechaniken von Scrapstead sind Bewegung und Erkundung, Sammeln und Bergen, Inventar und Lager, Direktverkauf, optionale Verarbeitung, Investitionen, Bauen, ein kleiner Umfang an Delegation und Automation, Scrappy, Aufträge, regionale Figuren und ein klarer Hauptabschluss.

Jede Mechanik erhält eine minimale vollständige Umsetzung und eine Grenze für spätere Erweiterungen. So entsteht ein Spiel, das seine zentralen Versprechen erfüllt, ohne dass jedes denkbare Subsystem gebaut werden muss.

**Erst muss das Spiel als kleines Ganzes funktionieren. Danach darf es größer werden.**
