# Scrapstead — MVP- und Prototypenplan

**Version:** 0.2  
**Status:** Vorproduktionsplanung / technische und spielerische Validierung  
**Geltungsbereich:** Erste spielbare Prototypen bis zum Vertical Slice  
**Engine:** Godot Engine 4.7.2 Stable mit GDScript (beschlossen). Forward+ ist die vorgesehene Startkonfiguration und wird in P0 auf der Zielhardware geprüft.

---

## 1. Zweck und Abgrenzung

Dieser Plan übersetzt die Core-Gameplay-Matrix, den Produktionsumfang und die bestehenden Startgrundstücks-, Progressions- und Architekturkonzepte in eine konkrete Reihenfolge kleiner, überprüfbarer Prototypen.

Er soll drei Fragen beantworten:

- Was muss zuerst tatsächlich spielbar sein?
- Welche Systeme müssen dafür real existieren und welche dürfen zunächst vereinfacht werden?
- An welchen Ergebnissen entscheiden wir, ob der nächste Entwicklungsschritt gerechtfertigt ist?

Der Plan ist keine vollständige technische Implementierungsspezifikation und kein Auftrag, alle beschriebenen Systeme sofort zu bauen.

**Verbindliche Leitlinie:** Wir validieren zuerst die kleinste befriedigende Spielschleife. Scrappy, Mitarbeiter, Maschinen, regionale Simulation und umfangreicher Baumodus werden erst ergänzt, wenn die vorherigen Schritte ihren Zweck nachweislich erfüllen.

### 1.1 Zwei unterschiedliche Ziele

| Begriff | Zweck | Umfang |
|---|---|---|
| **Gameplay-Prototyp** | Prüft, ob eine einzelne Spielmechanik oder Kernschleife funktioniert und Spaß macht | Platzhaltergrafik, minimale UI, wenige Objekte, begrenzter Spielbereich |
| **Vertical Slice** | Beweist, dass ein repräsentativer Ausschnitt des Spiels in zusammenhängender Qualität funktioniert | Zusammenhängendes Spielerlebnis mit finalitätsnaher Darstellung, Audio, UI, Story und Progression |

Ein funktionierender Prototyp ist noch kein Vertical Slice. Umgekehrt darf ein Vertical Slice nicht als Vorwand dienen, bereits die gesamte Spielwelt oder alle Systeme zu produzieren.

---

## 2. Prototyp-Übersicht und Freigabereihenfolge

| Stufe | Bezeichnung | Kernnachweis | Freigabe für |
|---|---|---|---|
| **P0** | Technisches Fundament | Bewegung, Kamera, Interaktion und minimale Persistenz funktionieren zuverlässig | P1 |
| **P1** | Erste Gameplay-Schleife | Sammeln/Bergen → Verkaufen → Credits → sinnvolles Upgrade funktioniert | P2 |
| **P1b** | Optionale Verwertung | Eine Verarbeitung ist verständlich und bleibt eine echte Alternative zum Direktverkauf | P2-Abschluss |
| **P2** | Einstieg und Scrappy | Erste Stunde, Entdeckungsdramaturgie und Scrappys Wiederherstellung funktionieren | P3 |
| **P3** | Delegation und erste Maschine | Eine wiederholte Aufgabe kann sinnvoll abgegeben und eine einfache Maschine genutzt werden | P4 |
| **P4** | Vertical Slice Old Yard | Ein repräsentativer, zusammenhängender Spielabschnitt trägt Spielgefühl, Präsentation und Progression | Produktion des restlichen Kerns |

Die Stufen sind Qualitäts- und Lernschritte, keine starren Kalenderphasen. Eine Stufe wird nicht allein deshalb freigegeben, weil sie technisch funktioniert. Sie muss auch die festgelegten Spielerziele erfüllen.

---

## 3. P0 — Technisches Fundament

### Ziel

P0 baut nicht nur einen technischen Testraum, sondern bereits den ersten erkennbaren Einstieg in Scrapstead. Beim Start sieht der Spieler ein Hauptmenü mit dem Scrapstead-Logo und einer animierten Kamerafahrt durch den Old Yard. Von dort gelangt er in die technische Testszene.

Damit werden zwei Dinge parallel geprüft: die technische Grundlage des Spiels und der erste Eindruck, den das Spiel vermitteln soll. Der Menüauftritt bleibt bewusst kompakt und darf die Entwicklung der Kernmechaniken nicht verzögern.

### Benötigte Szenen und Objekte

**A. Hauptmenü / Startbildschirm**
- Ein eigener Menübildschirm mit dem Scrapstead-Logo.
- Eine Hintergrundszene des Old Yard als frühes 3D-Blockout.
- Eine animierte, ruhige Kamerafahrt entlang einer vorbereiteten Kameraroute durch den Hof.
- Eine klare Menüfläche mit den Funktionen „Neues Spiel“, „Fortsetzen“, „Einstellungen“ und „Beenden“.
- „Fortsetzen“ ist deaktiviert bzw. nicht verfügbar, solange kein gültiger Spielstand existiert.
- Ein einfacher Übergang vom Menü in die Gameplay-Szene.

**B. Technische Testszene**
- Eine einfache Testfläche mit klaren Kanten und wenigen Höhenunterschieden.
- Ein Spielerobjekt mit Platzhaltermodell.
- Eine isometrische Gameplay-Kamera.
- Drei Testobjekte: ein aufnehmbares Kleinteil, ein untersuchbares Objekt und eine benutzbare Einrichtung.
- Eine einfache Interaktionsanzeige.
- Ein minimaler Debug-/Statusbereich, der bei Bedarf Position, Zielobjekt und Interaktionszustand sichtbar macht.

### Tatsächlich benötigte Funktionen

1. Starten des Spiels in das Hauptmenü.
2. Darstellung des Scrapstead-Logos in einer gut lesbaren, ausreichend freien Bildzone.
3. Eine vorbereitete Kamerafahrt, die als Hintergrund kontinuierlich und ohne sichtbaren Sprung wiederholt werden kann. Sie darf nicht mit der steuerbaren Gameplay-Kamera gekoppelt sein.
4. Menübedienung mit Maus und Tastatur.
5. „Neues Spiel“ lädt die P0-Testszene bzw. startet einen frischen Prototypzustand.
6. „Fortsetzen“ lädt einen vorhandenen Prototyp-Spielstand und ist andernfalls deaktiviert.
7. „Einstellungen“ öffnet zunächst nur die tatsächlich vorhandenen Basisoptionen; nicht implementierte Optionen werden nicht vorgetäuscht.
8. „Beenden“ schließt das Spiel kontrolliert.
9. Ein klarer Übergang vom Menü in die Gameplay-Szene.
10. Spielerbewegung in der vorgesehenen isometrischen Ansicht.
11. Die Gameplay-Kamera folgt dem Spieler und erlaubt die vorgesehenen Zoom-/Bewegungsoptionen.
12. Kollision mit Boden und Hindernissen.
13. Erkennen erreichbarer Interaktionsziele.
14. Eindeutige Hervorhebung des aktuell ausgewählten bzw. erreichbaren Ziels.
15. Kontextabhängige Interaktion mit den Testobjekten.
16. Ein einfacher Spielzustand, der beim Speichern und Laden erhalten bleibt.
17. Saubere Trennung zwischen Menü-Kamerafahrt, Gameplay-Kamera, Gameplay-Zustand und visueller Darstellung.

### Vereinfachungen

- Der Hintergrund des Hauptmenüs verwendet denselben Old-Yard-Blockout oder eine kleine, eigens dafür arrangierte Teilansicht.
- Die Kamerafahrt besteht aus wenigen vorbereiteten Wegpunkten und benötigt noch keine dynamische Kameralogik.
- Logo zunächst als fertige Bilddatei bzw. temporärer sauberer Schriftzug; finale Logoanimation und aufwendige Effekte sind nicht erforderlich.
- Einfache Menüanimationen und Übergänge; keine komplexen Partikeleffekte.
- Platzhaltermodelle und einfache Materialien in der Hintergrundszene.
- Keine vollständige Eingabe-Neubelegung.
- Keine umfangreiche Einstellungsseite; zunächst nur tatsächlich verfügbare Optionen.
- Kein komplexes Inventar.
- Kein Quest- oder Dialogsystem.
- Keine Mitarbeiter- oder Scrappy-Navigation.

### Abnahmekriterien

- Das Spiel startet zuverlässig im Hauptmenü.
- Scrapstead-Logo und Menüoptionen sind klar lesbar und überlagern die Kamerafahrt nicht ungünstig.
- Die Hintergrundkamera bewegt sich ruhig, ohne sichtbare Sprünge oder störende Durchdringungen.
- Die Kamerafahrt läuft unabhängig von der Gameplay-Kamera.
- Neues Spiel, Fortsetzen (bei vorhandenem Spielstand), Einstellungen und Beenden verhalten sich entsprechend ihrem sichtbaren Zustand.
- Der Übergang vom Menü in die Gameplay-Szene funktioniert zuverlässig.
- Bewegung fühlt sich aus der isometrischen Gameplay-Kamera präzise und kontrollierbar an.
- Die Gameplay-Kamera verdeckt keine wichtigen Interaktionsobjekte dauerhaft.
- Interaktionen werden zuverlässig dem beabsichtigten Objekt zugeordnet.
- Hindernisse und Reichweiten sind nachvollziehbar.
- Speichern und Laden erzeugen keinen widersprüchlichen Grundzustand.
- Die technische Basis erlaubt weitere Testmechaniken, ohne bereits eine große Architektur vorauszusetzen.

**Stop-Kriterium:** Wenn Menüstart, Szenenübergang, Bewegung, Kamera oder Interaktion nicht zuverlässig funktionieren, wird kein Wirtschaftssystem darauf aufgebaut.

---

## 4. P1 — Erste vollständige Gameplay-Schleife

### Ziel

Der Spieler soll auf einer kleinen Fläche selbstständig etwas finden, bergen, verkaufen, Credits erhalten und eine erste Verbesserung erwerben können.

Dies ist der wichtigste frühe Nachweis für Scrapstead. Die Schleife muss ohne Scrappy, Mitarbeiter, Maschinen, regionale Wirtschaft oder komplexen Baumodus funktionieren.

### Spielbereich

Ein stark vereinfachter Ausschnitt des Old Yard:

- Start- und Bewegungsfläche.
- Kleine lose Fundstücke.
- Ein größerer Schrottgegenstand.
- Ein klar erkennbarer Verkaufs-/Annahmebereich.
- Ein einfacher Upgrade-Punkt, beispielsweise Werkbank oder Verkaufsbrett.
- Ein begrenzter Bereich für optionale Verarbeitung in P1b.

Der Ausschnitt muss nicht das vollständige Grundstück oder bereits alle fünf Layoutzonen abbilden.

### Minimaler Objektumfang

| Objektgruppe | Prototypmenge | Funktion |
|---|---:|---|
| Lose Kleinteile | 4–6 Instanzen aus 2–3 Objektdefinitionen | Aufheben, transportieren und verkaufen |
| Größeres Schrottobjekt | 1 | Eine passende Bergungsaktion demonstrieren |
| Verkaufsstelle | 1 | Gegenstände gegen Credits verkaufen |
| Upgrade-Einrichtung | 1 | Credits gegen eine konkrete Verbesserung tauschen |
| Optionale Verarbeitungsstation | 1 | In P1b eine alternative Verwertung demonstrieren |

Die konkreten Gegenstandstypen werden aus dem bestehenden Starting-Yard-Katalog gewählt. Für den ersten Test ist eine kleine, repräsentative Auswahl wichtiger als viele unterschiedliche Assets.

### Tatsächlich benötigte Funktionen

1. **Objektdefinition:** Jedes Testobjekt besitzt eine stabile ID, Kategorie, Wert und Interaktionsart.
2. **Weltobjektzustand:** Ein Objekt kann vorhanden, aufgenommen, abgelegt, verkauft oder verarbeitet sein.
3. **Aufnahme:** Kleine Gegenstände können mit einer klaren Aktion aufgenommen werden.
4. **Bergung:** Das größere Objekt verlangt eine passende Aktion oder ein einfaches Werkzeug. Voraussetzung und Ergebnis müssen erkennbar sein.
5. **Transport:** Ein minimales Inventar oder eine begrenzte Tragekapazität hält aufgenommene Gegenstände fest.
6. **Verkauf:** Die Verkaufsstelle zeigt vor der Bestätigung den Erlös und verbucht ihn genau einmal.
7. **Credits:** Ein zentraler Kontostand wird erhöht und verringert; Transaktionen bleiben nachvollziehbar.
8. **Upgrade:** Mindestens eine Verbesserung ist kaufbar und verändert eine tatsächlich spürbare Eigenschaft, zum Beispiel die Tragekapazität oder die Sammelgeschwindigkeit.
9. **Feedback:** Jede Aktion zeigt knapp, was passiert ist und was sich geändert hat.
10. **Persistenz:** Weltobjekte, Inventar, Credits und gekaufte Verbesserung überstehen Speichern und Laden.

### Vereinfachungen

- Kein freies Bauen. Die Upgrade-Einrichtung steht fest.
- Keine vollständige Lagerverwaltung; ein kleines Inventar genügt.
- Keine dynamischen Marktpreise. Es gelten feste, leicht verständliche Basiswerte.
- Keine laufenden Betriebskosten.
- Keine Lieferanten, Händlernetzwerke oder externen Firmen.
- Keine automatische Regeneration der Fundstücke im ersten Test.
- Keine Physik-Simulation für jedes Schrottteil.
- Keine aufwendige Qualitäts- oder Materialsimulation.

### Abnahmekriterien

- Ein neuer Spieler erkennt ohne lange Erklärung, dass Gegenstände gesammelt und verkauft werden können.
- Mindestens ein Kleinteil kann zuverlässig aufgenommen und verkauft werden.
- Das große Objekt unterscheidet sich durch eine verständliche Bergungsaktion.
- Verkauf und Credits sind korrekt, transparent und nicht ausnutzbar durch doppelte Transaktionen.
- Das erste Upgrade ist erreichbar und sein Nutzen ist unmittelbar erkennbar.
- Nach dem Upgrade fühlt sich eine relevante Aktion messbar oder wahrnehmbar besser an.
- Der Spieler versteht, warum es sinnvoll sein könnte, weiterzusammeln.
- Der Loop bleibt auch nach mehreren Wiederholungen verständlich und nicht unnötig umständlich.

**P1 gilt erst dann als erfolgreich, wenn die Schleife aus sich heraus funktioniert.** Scrappy oder Story dürfen einen schwachen Kernloop nicht kaschieren.

---

## 5. P1b — Optionale Verwertung

### Ziel

Es wird geprüft, ob Sortieren, Demontieren oder eine einfache Verarbeitung eine interessante Entscheidung ergänzt, ohne den Direktverkauf zu verdrängen.

### Minimaler Umfang

- Eine einzige ausgewählte Gegenstandsdefinition mit Verarbeitungsprofil.
- Eine einfache Werkbank oder Verarbeitungsstation.
- Eine Eingabe und höchstens zwei klar verständliche Ausgaben.
- Eine sichtbare Angabe von Aufwand, Ergebnis und möglichem Wert.
- Direktverkauf desselben Gegenstands bleibt als Alternative verfügbar.

### Vereinfachungen

- Keine Maschinenanimation mit komplexen Einzelteilen.
- Keine mehrstufige Produktionskette.
- Keine Lagerlogistik.
- Keine vollständige Materialtaxonomie.
- Keine Qualitätsstufen, sofern sie für die getestete Entscheidung nicht erforderlich sind.

### Abnahmekriterien

- Der Spieler versteht den Unterschied zwischen sofortigem Verkauf und Verarbeitung.
- Verarbeitung erzeugt einen nachvollziehbaren Mehrwert oder einen anderen klaren Nutzen.
- Die Verarbeitung ist optional und wird nicht zur einzig sinnvollen Einnahmequelle.
- Der zusätzliche Bedienaufwand steht in einem angemessenen Verhältnis zum Ergebnis.

**Stop-Kriterium:** Wenn Verarbeitung nur zusätzliche Klicks erzeugt oder Direktverkauf entwertet, wird sie vereinfacht oder vorerst zurückgestellt.

---

## 6. P2 — Einstieg und Scrappy

### Ziel

Nach erfolgreicher Kernschleife wird der Old Yard als erzählerischer Ort erlebbar. Der Spieler soll die ersten 30–60 Minuten erleben können: ankommen, erkunden, arbeiten, Geld verdienen, Scrappy entdecken und den Platz sichtbar verbessern.

Die Zeitangaben bleiben dramaturgische Richtwerte und sind keine Timer.

### Benötigte Spielbereiche und Objekte

- Der für die erste Stunde erforderliche Teil des Old Yard.
- Die fünf funktionalen Bereiche aus dem Layout als räumliche Orientierung, soweit sie für den Einstieg gebraucht werden: alte Lagerzone, verwilderter Schrotthof, Büro/Werkstatt, freie Arbeitsfläche, Annahme/Verkauf.
- Erbschaftsunterlagen, Grundstücksschlüssel und Walts Brief.
- Wenige lose Fundstücke und mindestens ein sperriges Objekt.
- Eine Suchquelle oder ein teilweise verdeckter Fundort.
- Scrappys Kopf als garantierte Entdeckung.
- Roter Werkzeugkasten mit geschützter Kernkomponente als garantierte Entdeckung.
- Eine einfache Reparatur-/Aktivierungsstelle.
- Ein erster sichtbarer Yard-Verbesserungspunkt.

### Tatsächlich benötigte Funktionen

1. Kurze, unterbrechungsarme Einführung in Ort und Situation.
2. Kleine Aufgabenhinweise, die aus der Umgebung und Interaktionen hervorgehen.
3. Objektinspektion mit Name, Kategorie und relevanten Eigenschaften.
4. Schutz von Storygegenständen vor versehentlichem Verkauf oder Verbrauch.
5. Garantierte Entdeckung von Kopf und Kernkomponente.
6. Wiederherstellung Scrappys als klarer erzählerischer Moment.
7. Scrappy folgt dem Spieler in angemessenem Abstand und blockiert keine Wege.
8. Einige vorbereitete, kontextbezogene Dialog- und nonverbale Reaktionen.
9. Eine einfache Möglichkeit, Scrappy warten zu lassen bzw. die Begleitung zu unterbrechen.
10. Einfache persistente Ereignisflags für Entdeckung, Wiederherstellung und erste Begegnungen.
11. Erste Verbesserung des Grundstücks mit sichtbarem Vorher-/Nachher-Effekt.

### Scrappy bewusst begrenzen

Für P2 werden nur folgende Teile seines Konzepts benötigt:

- Folgen und Warten.
- Einige Idle- und Reaktionszustände.
- Wenige vorbereitete Kommentare zu tatsächlichen Situationen.
- Eine kleine Auswahl an Ausdrucksanimationen.
- Schutzregeln für Gegenstände und Spielerentscheidungen.

Noch nicht erforderlich:

- Vollständige autonome Tagesaktivitäten.
- Modulares Hardware-Inventar in voller Breite.
- Persönliche Projekte und umfangreiche Erinnerungsverknüpfung.
- Eigenständige Beschaffung oder Maschinenassistenz.
- Komplexe Fähigkeitsentwicklung.
- Sprachmodell- oder LLM-Integration.
- Vollständige Dialogbibliothek und Voice-Over.

### Abnahmekriterien

- Spieler können den Einstieg in eigenem Tempo erleben.
- Die Kernschleife bleibt ohne Tutorial-Pop-up-Kette verständlich.
- Walts Geschichte wird über Ort, Brief und Fundstücke vermittelt, ohne den Spielfluss zu überladen.
- Scrappys Wiederherstellung ist zuverlässig und emotional nachvollziehbar.
- Scrappy wirkt bereits als Figur und nicht nur als Bedienhilfe.
- Er stört weder Bewegung noch Interaktionen.
- Wichtige Fundstücke können nicht versehentlich verloren gehen.
- Am Ende der ersten Stunde bestehen mehrere verständliche Gründe weiterzuspielen.

---

## 7. P3 — Delegation und erste Maschine

### Ziel

Erst nachdem die manuelle Kernschleife und der Einstieg funktionieren, wird die Progressionsfantasie getestet: Der Spieler verdient sich Hilfe und kann eine wiederholte Tätigkeit abgeben.

### Reihenfolge

Die bestehende Progressionsplanung sieht den ersten Mitarbeiter vor der ersten Maschine vor. Diese Reihenfolge bleibt der Ausgangspunkt:

1. Spieler führt eine Tätigkeit selbst aus.
2. Spieler lernt eine Person kennen und stellt sie ein.
3. Mitarbeiter erhält genau eine Aufgabe und einen klaren Arbeitsbereich.
4. Spieler beobachtet, ob die Delegation wirklich Zeit und Arbeit spart.
5. Erst danach wird die erste Maschine eingeführt.

### P3a — Erster Mitarbeiter

**Minimaler Umfang:**
- Eine rekrutierbare Figur.
- Ein einfaches Rollen-/Aufgabenprofil.
- Ein definierter Arbeitsbereich oder Zielpunkt.
- Eine einzige Aufgabe, vorzugsweise das Einsammeln oder Transportieren freigegebener Gegenstände.
- Eine sichtbare Kostenangabe.
- Ein einfacher Status: arbeitet, wartet, blockiert.
- Spieler kann Aufgabe pausieren oder Mitarbeiter entlassen.

**Vereinfachungen:**
- Keine Schichten.
- Keine individuellen Skilltrees.
- Keine Bedürfnisse, Stimmungssimulation oder Tagesabläufe.
- Keine komplexe Prioritätsmatrix.
- Keine mehreren Mitarbeiter gleichzeitig.
- Keine vollständige Pfad- oder Verkehrsplanung.

**Abnahmekriterien:**
- Der Mitarbeiter erledigt zuverlässig eine zuvor vom Spieler verstandene Aufgabe.
- Ergebnis und Kosten sind sichtbar.
- Der Mitarbeiter blockiert keine wichtigen Bereiche dauerhaft.
- Der Spieler kann jederzeit eingreifen.
- Die Delegation schafft eine interessante neue Entscheidung, nicht nur eine weitere Verwaltungsmaske.

### P3b — Erste Maschine

Die erste Maschine bleibt gemäß Progressionskonzept der **kleine Magnetsammler**.

**Minimaler Umfang:**
- Eine platzierbare oder zunächst fest positionierte Maschine.
- Ein klar definierter Arbeitsbereich.
- Eine klar definierte Eingabe bzw. Quelle loser Metallteile.
- Ein eindeutiger Ausgabepunkt.
- Ein sichtbarer, reproduzierbarer Prozesszustand.
- Eine einfache Statusanzeige.
- Eine verständliche Kauf- oder Freischaltbedingung.

**Vereinfachungen:**
- Keine Förderbänder.
- Keine verketteten Maschinen.
- Keine automatische Routenplanung.
- Keine komplexen Störungen oder Wartungsaufgaben.
- Keine frei konfigurierbaren Produktionsrezepte.
- Keine vollständige Offline-Produktion.

**Abnahmekriterien:**
- Die Maschine übernimmt eine klar erkennbare repetitive Tätigkeit.
- Input und Output sind verständlich.
- Die Maschine produziert keine Gegenstände aus dem Nichts und dupliziert keine Bestände.
- Der Spieler kann weiterhin manuell arbeiten und bleibt sinnvoll beschäftigt.
- Die Maschine erzeugt einen sichtbaren Mehrwert, ohne das Spiel in einen Leerlauf-Tycoon zu verwandeln.

Die grundlegende Prozesslogik muss vom Maschinenmodell und von Animationen getrennt sein. Animationen stellen den tatsächlichen Simulationszustand dar; sie bestimmen nicht das Produktionsergebnis.

---

## 8. P4 — Vertical Slice: Old Yard

### Ziel

Ein repräsentativer Abschnitt von Scrapstead wird als zusammenhängendes Spielerlebnis in einer Qualität umgesetzt, die das spätere Spiel realistisch repräsentiert.

Der Vertical Slice soll nicht die komplette erste Spielstunde künstlich aufblasen. Er soll die bereits validierten Teile verbinden und die Produktionsqualität für die nächsten Schritte festlegen.

### Inhaltlicher Umfang

- Ein begrenzter, zusammenhängender Ausschnitt des Old Yard.
- Bewegung, Kamera und Interaktion.
- Sammeln, Bergen, Inventar/Transport und Direktverkauf.
- Credits und erste Upgrades.
- Eine optionale Verwertungsentscheidung.
- Die für den Einstieg benötigte Erkundungs- und Entdeckungsfolge.
- Scrappys garantierte Wiederherstellung und Begleiter-Grundverhalten.
- Eine kurze Hauptaufgabenfolge.
- Ein wiederkehrender NPC oder eine Kontaktfigur, sofern der Einstieg dies benötigt.
- Eine sichtbare Verbesserung des Grundstücks.
- Kontext-HUD, Objektinformationen, kurze Aufgabenanzeige und passende Menüs.
- Speichern und Laden des vollständigen Slice-Zustands.
- Repräsentative Audio-, VFX-, Beleuchtungs- und Animationsqualität.

Mitarbeiter und Magnetsammler werden in P3 separat validiert. Sie müssen nicht in den ersten 30–60 Minuten des Vertical Slice auftauchen, wenn dies den Einstieg überlädt. Der Vertical Slice darf sie als klaren Ausblick oder in einem separaten Progressionsabschnitt zeigen.

### Qualitätskriterien

- Der Spieler versteht die wichtigsten Aktionen ohne externe Erklärung.
- Visuelle Lesbarkeit funktioniert aus der tatsächlichen isometrischen Kamera.
- Interaktionen, Feedback und UI sind konsistent.
- Scrappy ist erkennbar, sympathisch und technisch zuverlässig.
- Die Spielschleife ist auch ohne Entwicklerkommentar verständlich.
- Die Darstellung ist repräsentativ für den geplanten Stil, nicht nur ein technischer Test.
- Der Abschnitt lässt sich wiederholt spielen und reproduzierbar testen.
- Die Performance ist auf der festgelegten Zielhardware ausreichend; konkrete Budgets werden nach Engine- und Hardwareentscheidung festgelegt.

---

## 9. Minimale Daten- und Systemstruktur

Die folgenden Begriffe beschreiben fachliche Datenverantwortung, keine endgültigen Klassen-, Dateinamen oder Engine-Implementierungen. Die konkrete technische Form wird nach Wahl und Einrichtung der Engine festgelegt.

### 9.1 Datenobjekte

| Datenobjekt | Minimal benötigte Informationen | Ab P |
|---|---|---|
| **ItemDefinition** | Stabile ID, Lokalisierungsschlüssel, Kategorie, Basiswert, Interaktions-/Handhabungsklasse, optionales Verarbeitungsprofil | P1 |
| **WorldObjectState** | Referenz auf Definition, Weltposition, Zustand, verfügbar/aufgenommen/verarbeitet/verkauft | P1 |
| **PlayerInventory** | Enthaltene Gegenstände oder Stapel, Kapazitätsregel | P1 |
| **Wallet / Transaction** | Credits, Transaktionsbetrag, Grund/Quelle, eindeutige Buchung | P1 |
| **UpgradeDefinition / UpgradeState** | Preis, Voraussetzung, betroffene Eigenschaft, erworbener Zustand | P1 |
| **ProcessingProfile** | Eingabe, Ausgaben, Aufwand bzw. Dauer, alternative Verkaufsoption | P1b |
| **Quest/EventState** | Stabile Ereignis-ID, erfüllt/nicht erfüllt, geschützte Storyflags | P2 |
| **ScrappyState** | Wiederhergestellt, folgt/wartet, einfache Reaktions-/Dialogflags | P2 |
| **EmployeeTaskState** | Mitarbeiter-ID, Aufgabe, Arbeitsbereich, Status, Kosten | P3a |
| **MachineDefinition / MachineState** | Funktion, Input, Output, Arbeitsbereich, Status und Upgradezustand | P3b |
| **SaveGame** | Version, Spielerzustand, Weltobjekte, Inventar, Wallet, Upgrades und freigegebene Progressionszustände | P0–P1, fortlaufend |

### 9.2 Systemverantwortung

| Systembereich | Verantwortung im frühen Prototyp |
|---|---|
| Session / Game State | Laufenden Spielzustand und Szenenwechsel verwalten |
| Player Controller | Eingabe und Bewegung |
| Camera | Isometrische Darstellung und Lesbarkeit |
| Interaction | Erreichbare Ziele, Kontextaktion und Feedback |
| World Objects | Objektzustand und Weltpräsenz |
| Inventory | Aufnahme, Ablage und Kapazität |
| Economy | Preise, Verkauf und Credits-Transaktionen |
| Progression | Upgrades und einfache Freischaltungen |
| Processing | Eine optionale, deterministische Verarbeitungsaktion |
| Persistence | Versioniertes Speichern und Laden |
| Event Log | Relevante Ereignisse für Tests und Debugging |
| UI | HUD, Kontextinformationen, Transaktions- und Upgradefeedback |

**Architekturregel:** Simulationszustand und Animation bleiben getrennt. Ein Verkauf wird durch die Transaktionslogik gebucht, nicht durch eine Animation. Eine Maschine produziert durch ihre Prozesslogik, nicht dadurch, dass ein Animationsclip endet.

---

## 10. Was zunächst simuliert oder weggelassen wird

| Bereich | Frühe Vereinfachung | Erst später erforderlich |
|---|---|---|
| Wirtschaft | Feste Basiswerte und direkte Transaktionen | Nachfrageereignisse, ausgewählte Preisänderungen |
| Welt | Ein kleiner handgebauter Grundstücksausschnitt | Zusammenhängende Region und Spezialstandorte |
| Inventar | Kleine Kapazität, wenige Kategorien | Umfangreiche Lager, Filter und Qualitätsbestände |
| Verarbeitung | Eine einfache alternative Aktion | Rezepte, mehrere Stationen und Materialketten |
| Bau | Feste Testobjekte bzw. einfache Platzierung | Vollständiger freier Baumodus und Maschinenverbindungen |
| Mitarbeiter | Ein Mitarbeiter, eine Aufgabe | Mehrere Rollen, Schichten und Entwicklung |
| Maschinen | Eine Maschine, ein Input-/Output-Prozess | Mehrere Maschinen und automatische Verbindungen |
| Scrappy | Folgen, Warten, vorbereitete Reaktionen | Autonomie, Module, Erinnerungen und persönliche Projekte |
| Quests | Ereignisflags und kurze Aufgabenfolge | Vollständiges Quest-, Event- und Journal-System |
| Regionale Betriebe | Nicht vorhanden | Wenige funktionale Anlaufstellen |
| Zeit | Keine Offline-Simulation | Begrenzter Offline-Fortschritt, falls weiterhin sinnvoll |
| Statistik | Minimales Ereignisprotokoll | Umfassende Betriebs- und Mastery-Statistik |

Vereinfachen bedeutet nicht, spätere Systeme mit falschen Annahmen zu verbauen. Daten und Zuständigkeiten sollen sauber genug sein, um Erweiterungen zu ermöglichen, aber nicht so abstrakt, dass der Prototyp zum Architekturprojekt wird.

---

## 11. Testplan und Messpunkte

### 11.1 Testgruppen

- Interne Tests zur Fehler- und Bedienungsprüfung.
- Frühe externe Tests mit wenigen Personen, sobald die Kernschleife stabil ist.
- Für qualitative Tests ist eine kleine Gruppe von etwa 3–5 Personen ein sinnvoller Startpunkt, keine statistische Aussage über die spätere Zielgruppe.

### 11.2 Zu beobachtende Ereignisse

| Ereignis | Warum messen? |
|---|---|
| Erste Bewegung / erste Interaktion | Bedienbarkeit und Einstieg |
| Erstes inspiziertes Objekt | Verständlichkeit der Objektinteraktion |
| Erstes aufgenommenes Objekt | Sammelverständnis |
| Erste erfolgreiche Bergung | Verständlichkeit der Werkzeug-/Großobjektaktion |
| Erster Verkauf | Verständlichkeit der Wirtschaftsschleife |
| Erstes Upgrade | Erreichbarkeit und Motivation |
| Erste optionale Verarbeitung | Attraktivität der Alternative |
| Scrappy gefunden / wiederhergestellt | Funktioniert Entdeckungsdramaturgie? |
| Scrappy folgt / wird angehalten | Begleiterkomfort |
| Mitarbeiter erledigt erste Aufgabe | Wert der Delegation |
| Maschine erzeugt ersten Output | Verständlichkeit der Automation |

### 11.3 Qualitative Fragen

- Was glaubst du, ist deine wichtigste Tätigkeit auf diesem Schrottplatz?
- War klar, was du mit einem gefundenen Gegenstand tun kannst?
- War der Verkauf nachvollziehbar?
- Hattest du einen Grund, das erste Upgrade zu kaufen?
- War Verarbeitung interessant oder fühlte sie sich wie zusätzliche Pflicht an?
- Was hat dich neugierig gemacht, weiterzuspielen?
- Hat Scrappy geholfen, ohne dich zu stören?
- Hat die Delegation tatsächlich eine lästige Wiederholung abgenommen?

Fragen sollen nach dem Spielen gestellt werden und nicht währenddessen ständig Hinweise geben.

### 11.4 Erfolg nicht nur an Zeit messen

Zeit bis zum ersten Verkauf oder Upgrade ist ein Diagnosewert, kein Selbstzweck. Ein Spieler, der länger erkundet und trotzdem selbstständig versteht, was zu tun ist, ist nicht automatisch ein schlechter Test.

Wichtiger sind:
- Versteht der Spieler die Möglichkeiten?
- Kann er seine nächsten Schritte selbst ableiten?
- Ist die Belohnung nachvollziehbar?
- Möchte er freiwillig noch eine Runde spielen?
- Entsteht aus einer Verbesserung eine neue interessante Entscheidung?

---

## 12. Risiken und Gegenmaßnahmen

| Risiko | Gegenmaßnahme |
|---|---|
| Zu viele Gegenstandstypen zu früh | Mit wenigen repräsentativen Definitionen starten |
| Inventar wird zum Verwaltungsproblem | Kapazität und UI im Kernloop testen, Lager erst später erweitern |
| Verarbeitung entwertet Direktverkauf | Beide Optionen parallel testen und Werte nachjustieren |
| Sammeln fühlt sich repetitiv an | Objektvielfalt, kurze Wege und sichtbare Ziele testen, nicht früh mehr Systeme hinzufügen |
| Upgrades sind nur Zahlen | Jede erste Verbesserung muss eine konkrete Aktion spürbar verändern |
| Scrappy wird zu früh zu komplex | P2 auf Folgen, Warten und wenige Reaktionen begrenzen |
| Mitarbeiter-/Maschinenlogik wächst aus | Eine Aufgabe bzw. ein Prozess pro Prototyp |
| Baumodus blockiert Kernentwicklung | Erst nach Kernloop und Progressionsnachweis ausbauen |
| Architektur wird überdimensioniert | Nur tatsächlich benötigte Systemgrenzen implementieren |
| Inhalte kaschieren schwache Mechaniken | Jede Stufe isoliert testen, bevor Story/Content erweitert wird |

---

## 13. Explizite Nicht-Ziele der frühen Prototypen

Folgende Systeme werden nicht in P0–P2 implementiert:

- Regionale Wirtschaft oder vollständige NPC-Betriebssimulation.
- Aktien, Marktanteile, Unternehmenskonkurrenz oder komplexe Buchhaltung.
- Komplexe Lager- und Transportketten.
- Vollständiger freier Baumodus.
- Förderbänder und Maschinen-Netzwerke.
- Mehrere Mitarbeiter, Schichten und umfassende Skillentwicklung.
- Offline-Fortschritt.
- Scrappys vollständige Autonomie, Erinnerungsarchitektur und Modulsystem.
- Vollständige Quest-, Event- und Beziehungssysteme.
- Multiplayer oder Modding-Plattform.
- Prozedurale Weltgenerierung.

Diese Punkte sind nicht grundsätzlich für alle Zukunft ausgeschlossen. Sie sind für den Nachweis der frühen Kernmechaniken nicht erforderlich.

---

## 14. Freigaberegeln und Definition of Done

Ein Prototyp gilt erst als abgeschlossen, wenn:

1. Sein Kernziel nachweislich erreicht ist.
2. Die festgelegten Abnahmekriterien erfüllt sind.
3. Die wichtigsten Fehlerzustände getestet wurden.
4. Speichern und Laden keine kritischen Zustände beschädigen, sofern die Stufe persistente Daten verwendet.
5. Der nächste Schritt einen klaren Mehrwert auf dem vorhandenen Ergebnis aufbaut.
6. Offene Probleme dokumentiert sind und nicht stillschweigend in die nächste Stufe verschoben werden.

### Harte Freigabepunkte

- **P0 → P1:** Bewegung, Kamera und Interaktion sind zuverlässig.
- **P1 → P1b/P2:** Sammeln, Bergen, Verkauf, Credits und Upgrade bilden eine verständliche und befriedigende Schleife.
- **P1b → P2:** Verarbeitung ist eine echte optionale Entscheidung oder wird bewusst zurückgestellt.
- **P2 → P3:** Der Einstieg funktioniert; Scrappy ist technisch zuverlässig und erzählerisch überzeugend.
- **P3 → P4:** Delegation und erste Maschine sind verständlich, nützlich und nicht übermäßig verwaltungsintensiv.
- **P4 → weitere Produktion:** Der Vertical Slice repräsentiert die gewünschte Qualität und lässt sich mit vertretbarem Aufwand erweitern.

Bei einem nicht erfüllten Freigabepunkt wird zuerst vereinfacht, korrigiert oder neu getestet. Es werden nicht einfach weitere Systeme ergänzt.

---

## 15. Konkrete nächste Arbeitspakete

Die unmittelbar folgende Reihenfolge ist:

1. **P0-Szenen- und Interaktionsblockout:** Testfläche, Spieler, Kamera und drei Interaktionsobjekte.
2. **P0-Bedienungstest:** Bewegung, Sichtbarkeit, Reichweite, Kollision und Kamera prüfen.
3. **P1-Objektauswahl:** Aus dem vorhandenen Startkatalog wenige konkrete Kleinteile und ein großes Bergungsobjekt bestimmen.
4. **P1-Loop-Blockout:** Aufnahme, Inventar, Verkaufsstelle, Credits und ein Upgrade verbinden.
5. **P1-Playtest:** Ohne Scrappy und ohne Story testen, ob die Kernschleife trägt.
6. **P1b-Entscheidung:** Optionale Verarbeitung anhand des Tests hinzufügen oder zurückstellen.
7. **P2-Planung:** Erst nach Freigabe die vollständige erste Stunde und Scrappy integrieren.

Noch nicht festgelegt werden Engine-Version, konkrete Szenendateien, Programmiersprachen-Details, genaue Klassen-/Dateinamen oder technische Zahlenbudgets. Diese Entscheidungen folgen aus dem P0-Aufbau und der bestätigten Entwicklungsumgebung.

---

## Zusammenfassung

Scrapstead wird nicht als Gesamtpaket gebaut. Wir beweisen zuerst Bewegung und Interaktion, danach die kleine Schleife aus Sammeln, Bergen, Verkaufen und Verbessern. Erst wenn diese Schleife funktioniert, kommen optionale Verwertung, Scrappy, Mitarbeiter, Maschinen und schließlich ein repräsentativer Vertical Slice hinzu.

Der erste echte Erfolg ist nicht eine große Welt oder eine beeindruckende Automatisierungsanlage. Es ist ein kleiner Schrottplatz, auf dem es bereits Spaß macht, ein paar Dinge aufzuheben, sie sinnvoll zu verwerten und den eigenen Betrieb ein kleines Stück besser zu machen.

**Erst den Kern spielenswert machen. Dann Scrapstead wachsen lassen.**


## Ergänzung: P0-Szenenarchitektur

Die Szenen- und Systemverantwortlichkeiten für P0 sind in der [P0-Szenenarchitektur](p0-scene-architecture.md) als Bauplan beschrieben. Sie konkretisiert den bestehenden P0-Umfang, erweitert ihn aber nicht um zusätzliche Gameplay-Systeme.


## Ergänzung: P0-Spielersteuerung

Die Spielerbewegung wird gemäß der [P0-PlayerController-Spezifikation](p0-player-controller.md) kamerabezogen umgesetzt. Die Spezifikation konkretisiert den bestehenden P0-Nachweis für Bewegung und Kollision, ohne Sprinten, Springen oder weitere Bewegungsmechaniken in den Prototyp aufzunehmen.


## Ergänzung: P0-Gameplay-Kamera

Die isometrische Gameplay-Kamera wird gemäß der [P0-GameplayCameraController-Spezifikation](p0-gameplay-camera-controller.md) umgesetzt. Sie konkretisiert den vorhandenen P0-Nachweis für Kamera und Bewegung: orthografische Perspektive, ruhiges Spieler-Following und begrenzter stufenloser Zoom. Freie Kameradrehung und komplexe Sichtbarkeits- oder Hindernisvermeidungssysteme bleiben ausdrücklich außerhalb von P0.


## Ergänzung: P0-Interaktionssteuerung

Die Interaktionssteuerung wird gemäß der [P0-PlayerInteractor-Spezifikation](p0-interaction-controller.md) umgesetzt. P0 validiert Kandidatenerkennung, stabile Zielauswahl, Hervorhebung, HUD-Hinweis und die drei Testaktionen Pickup, Inspect und Use. Ein vollständiges Inventar, Kontextmenüs, Zerlegung und Bauinteraktionen sind nicht Teil dieses Nachweises.


## Ergänzung: P0-Gameplay-Blockout und Bedienungstest

Der gemeinsame räumliche Testaufbau für Spieler, Gameplay-Kamera und Interaktion ist in der [P0-Gameplay-Blockout-Spezifikation](p0-gameplay-blockout.md) beschrieben. Er nutzt den bestehenden Old-Yard-Grundstücksentwurf als Grundlage und definiert reproduzierbare Testabläufe sowie P0-Abnahmekriterien. P1 beginnt erst nach erfolgreicher Validierung von Bewegung, Kamera, Interaktion und minimaler Persistenz.
