# Scrapstead — Entscheidungsprotokoll

Dieses Dokument hält die derzeit verbindlichen Designentscheidungen fest. Neue Entscheidungen werden mit Datum, Kontext, Beschluss und Auswirkungen ergänzt.

## 25.11.2026 — Projektidentität und grundlegendes Design

- Name: Scrapstead.
- Slogan: Every Scrap Has a Story.
- Genre: Cozy Automation Tycoon.
- Kamera: Isometrisches 3D.
- Gameplay: Kombination aus manueller Arbeit und Automatisierung.
- Atmosphäre: Gemütlich, humorvoll, skurril.
- Grafikstil: Stylized Low-Poly / Miniatur-Diorama.
- Grundprinzip: Simple Core, Endless Possibilities.
- Scrappy ist Begleiter und Maskottchen.

## 25.11.2026 — Sammelsystem

**Beschluss:** Hybrides Sammelsystem.

- Kleine, lose Gegenstände können direkt aufgehoben werden.
- Größere oder feststeckende Objekte benötigen Werkzeuge oder Ausrüstung.
- Begründung: Direkte Interaktionen halten das Spiel flott. Werkzeuge schaffen sinnvolle Fortschrittsmöglichkeiten.

## 25.11.2026 — Schrottwirtschaft

**Beschluss:** Direktverkauf plus optionale Wertverarbeitung.

- Gewöhnlicher Schrott kann direkt und mit geringerem, aber verlässlichem Erlös verkauft werden.
- Ausgewählte Gegenstände können sortiert, zerlegt oder verarbeitet werden und dadurch potenziell bessere Erträge, Komponenten oder Entdeckungen liefern.
- Verarbeitung ist optional und nicht verpflichtend.
- Begründung: Das Spiel bleibt zugänglich und bietet trotzdem sinnvolle Entscheidungen.

## 25.11.2026 — Unternehmensentwicklung

**Beschluss:** Schrittweise, selbst erarbeitete Delegation.

- Der Spieler erledigt zu Beginn fast alle Arbeiten selbst.
- Bessere Werkzeuge und Transportkapazität kommen zuerst.
- Danach kann der Spieler den ersten Mitarbeiter einstellen.
- Anschließend spart er auf die erste Maschine.
- Mitarbeiter und Maschinen übernehmen nach und nach klar definierte Aufgaben.
- Automatisierung wächst schrittweise und steht nicht sofort zur Verfügung.
- Begründung: Jede Investition soll verdient und sichtbar bedeutsam sein.

## 25.11.2026 — Scrappys Herkunft und Anpassung

**Beschluss:** Der Spieler findet zunächst nur Scrappys Kopf unter Schrott.

- Eine besondere Komponente aus dem roten Werkzeugkasten stellt den Kopf wieder her.
- Der Spieler baut Scrappy aus gefundenen Körper-, Bewegungs-, Arm-, Sensor- und Dekorationsteilen zusammen.
- Konstruktionen können praktisch, albern oder rein kosmetisch sein.
- Scrappy bleibt loyal, trocken-humorvoll und gelegentlich etwas geschwätzig.
- Seine Persönlichkeit hängt nicht von den verbauten Teilen ab.

## 25.11.2026 — Einfachheit

**Beschluss:** Das Spiel bleibt einfach bedienbar und bietet dennoch viele Möglichkeiten.

- Komplexität entsteht durch die Kombination verständlicher Systeme.
- Kein verpflichtendes Mikromanagement, keine komplizierte Logistikprogrammierung, keine überladenen Menüs und keine unnötig große Ressourcen-Taxonomie.
- Neue Systeme werden schrittweise eingeführt.

## 25.11.2026 — Erste Fortschrittsfolge

**Beschluss:** Der Betrieb wächst durch schrittweise, selbst erarbeitete Delegation.

- Der Spieler erledigt zu Beginn fast alle Arbeiten selbst.
- Verbesserungen an Werkzeugen und Transport kommen zuerst.
- Der erste Mitarbeiter soll vor der ersten Maschine kommen. Diese Reihenfolge muss im Prototyp überprüft werden.
- Der Mitarbeiter übernimmt eine klar definierte Aufgabe, die der Spieler bereits selbst kennt.
- Die erste Maschine automatisiert anschließend eine ebenso verständliche Aufgabe.
- Exakte Preise, Löhne und Zeitpunkte werden erst im Wirtschaftsprototyp festgelegt.
- Begründung: Jede Investition soll ein spürbarer Schritt zum größeren Betrieb sein und keinen sofortigen Sprung in die Automatisierung darstellen.

## 25.11.2026 — Hybrides Sammeln und optionale Verarbeitung

- Kleine, lose Gegenstände können direkt aufgehoben werden.
- Größere oder feststeckende Objekte benötigen passende Werkzeuge oder Ausrüstung.
- Gewöhnlicher Schrott kann direkt verkauft werden.
- Ausgewählte Gegenstände können sortiert, zerlegt oder verarbeitet werden, um potenziell mehr Wert zu erzielen.
- Verarbeitung bleibt optional und darf nicht zur Pflichtaufgabe werden.

## 25.11.2026 — Vollständig mehrsprachige Entwicklung

**Beschluss:** Scrapstead wird vom ersten Produktionsinhalt an mehrsprachig entwickelt.

- Jeder spielerseitige Text muss über einen Lokalisierungsschlüssel eingebunden werden. Fest codierte Anzeigetexte sind nicht zulässig.
- Spiel-IDs, Speicherdaten, Asset-Bezeichner und Spiellogik sind unabhängig von der Sprache.
- Deutsch und Englisch sind die ersten Referenzsprachen.
- Weitere Sprachen müssen ohne Änderungen an Spiellogik oder Inhalts-IDs ergänzt werden können.
- Benutzeroberfläche, Schriftarten, Formatierungen, Untertitel, Barrierefreiheitstexte und Inhaltsprüfung berücksichtigen Mehrsprachigkeit von Anfang an.
- Fehlende Übersetzungen und abweichende Schlüssel müssen automatisiert erkannt werden.
- Begründung: Eine nachträgliche Internationalisierung würde vermeidbare Architektur-, Inhalts- und UI-Änderungen verursachen.

## 25.11.2026 — Gegenstandskatalog des Startgrundstücks

**Beschluss:** Der Gegenstandskatalog wird als kompaktes Gameplay-System und nicht als ungeordnete Objektliste aufgebaut.

- Katalogeinträge verwenden stabile, sprachunabhängige IDs und lokalisierte Namens- und Beschreibungsschlüssel.
- Der erste Katalog umfasst lose Schrottteile, sperrige Objekte, zerlegbare Geräte, Entdeckungsquellen, wertvolle Fundstücke und standardisierte Verarbeitungsergebnisse.
- Direktverkauf bleibt für verkäufliche Gegenstände möglich.
- Verarbeitung ist optional und gezielt.
- Wirtschaftswerte bleiben bis zum Balancing des Prototyps relative Stufen.
- Die Scrappy-Kernkomponente wird garantiert im roten Werkzeugkasten platziert und ist kein zufälliger Fortschrittsblocker.
- Begründung: Ein fokussierter Katalog soll den grundlegenden Spielablauf vermitteln und abwechslungsreiche Möglichkeiten bieten, ohne das erste Grundstück zu überladen.

## 25.11.2026 — Lage- und Entdeckungsplan des Startgrundstücks

**Beschluss:** Das Startgrundstück wird in funktionale, aber frei begehbare Bereiche gegliedert.

- Einfahrt und Annahme bilden den leicht verständlichen Einstieg.
- Büro und Werkstatt bilden den funktionalen Ausgangspunkt.
- Eine freie Arbeitsfläche reserviert Platz für erste Sortieraktionen und Maschinen.
- Lager- und Schrottbereiche bieten Gegenstände unterschiedlicher Größe und Zugänglichkeit.
- Scrappys Kopf und der rote Werkzeugkasten sind eigenständige, miteinander verbundene Entdeckungen.
- Die Wegeführung und Objektverteilung vermitteln die ersten Spielmechaniken, ohne ein starres Tutorial zu erzwingen.
- Begründung: Die räumliche Anordnung soll Orientierung, Erkundung, Spielfortschritt und die Geschichte des Grundstücks miteinander verbinden.

## 25.11.2026 — Sprache der Entwicklungsdokumentation

**Beschluss:** Die interne Scrapstead-Entwicklungsdokumentation wird auf Deutsch geführt.

- Neue Konzepte, Spezifikationen, Entscheidungsprotokolle und Planungsdokumente werden auf Deutsch erstellt.
- Technische Bezeichner, stabile IDs, Code-Symbole und Lokalisierungsschlüssel bleiben sprachneutral bzw. in ihrer technischen Schreibweise erhalten.
- Die Spielinhalte selbst bleiben vollständig mehrsprachig.
- Bestehende englische Dokumente werden bei ihrer Überarbeitung schrittweise auf Deutsch umgestellt.
- Begründung: Die gemeinsame Konzeptions- und Entwicklungsarbeit soll sprachlich einheitlich und gut lesbar bleiben, ohne die internationale Ausrichtung des Spiels zu beeinträchtigen.

## 25.11.2026 — Grundstücksgeometrie und erster Blockout

**Beschluss:** Der erste maßstäbliche Layout-Test verwendet vorläufig ein rechteckiges Grundstück von 48 × 36 Metern.

- Die Fläche umfasst 1.728 m².
- Das Blockout-Raster beträgt zunächst 1 × 1 Meter.
- Ein Layout-Meter entspricht zunächst einer Welt-Einheit von einem Meter.
- Die Funktionsbereiche erhalten feste ungefähre Koordinatenbereiche, bleiben aber offen miteinander verbunden.
- Der Hauptweg ist zunächst mit 3 Metern Breite geplant; Nebenwege mit 2 Metern.
- Für die erste Maschine wird ein Stellplatz von bis zu 5 × 4 Metern zuzüglich Bedien- und Ablageflächen reserviert.
- Diese Werte sind Testannahmen und werden anhand von Kamera, Laufwegen, Handwagen und Interaktionen überprüft.
- Begründung: Ein gemeinsamer Maßstab macht Grundstücksplanung, Assetgrößen und Gameplay-Abstände nachvollziehbar und früh testbar.


## 25.11.2026 — Freies Bauen und funktionale Maschinenverbindungen

**Beschluss:** Scrapstead verwendet ein freies Bausystem mit nachvollziehbaren funktionalen Einschränkungen.

- Innerhalb der Grundstücksgrenzen gibt es keine fest zugewiesenen Bauplätze für Gebäude oder Maschinen.
- Die bisherigen Zonen des Startgrundstücks dienen als Orientierung für Leveldesign und Entdeckungsdramaturgie, nicht als verbindliche Bauzonen.
- Gebäude, Maschinen, Lager, Wege, Zäune und Dekorationen sollen grundsätzlich frei platzierbar sein.
- Funktionale Anforderungen wie Grundfläche, Bedienzugang, Arbeitsradius, Ein- und Ausgabepunkte sowie erforderliche Abstände werden objektabhängig geprüft.
- Maschinen können definierte Ein- und Ausgabepunkte besitzen.
- Der Spieler kann kompatible Maschinen durch eine einfache Aktion verbinden. Das Spiel erstellt automatisch eine passende Route, sofern ein freier und gültiger Weg existiert.
- Blockierte oder ungültige Routen werden verständlich erklärt.
- Direkte Übergabe, automatische Transportstrecke und manueller Transport sind gleichberechtigte Möglichkeiten.
- Komplexe manuelle Förderbandplanung und verpflichtendes Logistik-Mikromanagement gehören nicht zum Ziel des ersten Prototyps.
- Rastergröße, Routenführung und konkrete Maschinenanforderungen bleiben bis zum Prototyp-Test offen.
- Begründung: Der Spieler soll seinen Betrieb selbst gestalten können. Das Spiel stellt sicher, dass die Gestaltung funktional bleibt, ohne die kreative Freiheit durch starre Bauplätze oder komplizierte Logistik zu beschneiden.


## 25.11.2026 — Bedienkonzept des Baumodus

**Beschluss:** Das Bausystem erhält einen zentralen, kompakten Baumodus mit kontextabhängigen Werkzeugen.

- Vorgesehene Werkzeuge: Platzieren, Verschieben, Drehen, Verbinden, Entfernen und Inspizieren.
- Platzierungen werden durch eine transparente Vorschau mit objektabhängigen Funktions- und Platzierungsinformationen vorbereitet.
- Bestehende Objekte können verschoben und gedreht werden. Betroffene Maschinenverbindungen müssen vor der Bestätigung sichtbar sein.
- Maschinenverbindungen werden bewusst über ausgewählte Ein- und Ausgabepunkte angelegt.
- Das Spiel berechnet eine passende Transportroute automatisch und zeigt sie vor der Bestätigung.
- Einrasten (Snap) dient der geometrisch sauberen Ausrichtung. Es erzeugt keine ungefragten Maschinenverbindungen.
- Der Baumodus soll Rückgängig und Wiederholen sowie das wiederholte Platzieren gleicher Objekte unterstützen.
- Fehlgeschlagene Aktionen müssen verständlich erklären, woran sie scheitern und möglichst eine Lösung anbieten.
- PC-Tastenbelegung, Raster, Werkzeugleistenlayout und technische Details bleiben bis zum Prototyp-Test vorläufig.
- Begründung: Freies Bauen soll intuitiv und fehlertolerant sein. Das Spiel übernimmt Prüfungen und Routenplanung, ohne dem Spieler die Kontrolle über seine Produktionsstruktur zu nehmen.


## 25.11.2026 — Fertiggebäude und modularer Gebäudebau

**Beschluss:** Das Gebäudesystem kombiniert platzierbare Fertiggebäude mit frei kombinierbaren Bauteilen.

- Fertiggebäude ermöglichen einen schnellen Einstieg und können als vollständige Konstruktionen platziert werden.
- Zusätzlich kann der Spieler eigene Gebäude aus Fundamenten, Böden, Wänden, Fenstern, Türen, Dächern und weiteren Modulen zusammensetzen.
- Fertiggebäude sind nicht unveränderlich. Sie können umgebaut, erweitert und optisch angepasst werden.
- Bauteile besitzen passende Verbindungspunkte und rasten bei kompatiblen Konstruktionen automatisch ein.
- Konstruktion, Gebäudefunktion und Gestaltung werden konzeptionell getrennt. Die Optik eines Gebäudes bestimmt nicht automatisch seine Funktion.
- Gebäude sollen nutzbare Innenräume besitzen, in denen Maschinen, Werkbänke und Lager untergebracht werden können.
- Baupläne zum Speichern und Wiederverwenden eigener Konstruktionen sind als spätere Komfort- und Community-Funktion vorgesehen.
- Komplexe Statik, umfangreiche Materialeigenschaften und Bauplan-Sharing sind nicht Bestandteil des ersten Prototyps.
- Begründung: Spieler sollen zwischen schnellem, unkompliziertem Bauen und individueller Gestaltung wählen können, ohne dass eine der beiden Spielweisen benachteiligt wird.


## 25.11.2026 — Schrittweise Freischaltung der Gebäudegestaltung

**Beschluss:** Umfangreiche Gebäude- und Gestaltungsoptionen werden schrittweise mit dem Wachstum des Betriebs freigeschaltet.

- Der Spielstart konzentriert sich auf Erkunden, Sammeln, Verkaufen, Scrappy und die Nutzung vorhandener Einrichtungen.
- Zu Beginn wird der Spieler nicht mit einer umfangreichen modularen Bauteilbibliothek oder komplexen Gestaltungsoberfläche konfrontiert.
- Fertiggebäude und einfache funktionale Erweiterungen werden früher verfügbar als umfangreiche modulare Gestaltung.
- Modulare Konstruktion, Material- und Farbvarianten, Beleuchtung, Einrichtung und Baupläne werden in späteren Fortschrittsphasen ergänzt.
- Freischaltungen sollen möglichst organisch über NPCs, Händler, Handwerker, Investitionen oder Scrappy vermittelt werden.
- Die Freischaltungen dürfen grundlegende Kreativität nicht unnötig blockieren. Sie erweitern die Möglichkeiten, statt einfache notwendige Aktionen künstlich zu sperren.
- Alle Gebäude und Module sollen langfristig eine gemeinsame, wiederverwendbare Bauteil- und Materialbibliothek nutzen. Das System soll den Entwicklungsaufwand begrenzen und kein separates Gestaltungssystem pro Gebäude erfordern.
- Konkrete Freischaltzeitpunkte und Voraussetzungen werden im First-Hour- und Progressionsprototyp getestet.
- Begründung: Der Einstieg muss unmittelbar fesseln und die Kernspielschleife vermitteln. Umfangreiche kreative Systeme sollen später als motivierende Erweiterung und Belohnung hinzukommen, nicht als Einstiegshürde.


## 25.11.2026 — First-Hour-Experience und Spielstart

**Beschluss:** Der Einstieg vermittelt die Kernmechaniken durch natürliche Interaktionen und eine schrittweise emotionale Dramaturgie.

- Die erste Spielphase führt über Ankommen, erste Arbeit, ersten Verkauf, Scrappys Entdeckung und eine erste sichtbare Betriebsverbesserung.
- Die Zeitangaben von etwa 30 bis 60 Minuten sind Richtwerte, keine Timer oder starren Questvorgaben.
- Der Spieler darf früh frei erkunden und selbst entscheiden, womit er sich beschäftigt.
- Lange Tutorialtexte und häufige Pop-ups werden vermieden. Hinweise erscheinen kurz und kontextbezogen.
- Scrappys Kopf und der rote Werkzeugkasten bilden eine zusammengehörige Entdeckung. Seine Wiederherstellung soll ein besonderer emotionaler Moment sein.
- Umfangreiche Systeme wie modulare Gebäudegestaltung, komplexe Maschinenverbindungen und Bauplanverwaltung werden nicht in der ersten Stunde ausführlich eingeführt.
- Die erste Stunde soll einen frühen wirtschaftlichen Erfolg und eine erste sichtbare Verbesserung des Betriebs ermöglichen.
- Die konkrete Vorgeschichte und der Grund, warum der Schrottplatz dem Spieler gehört, bleiben offen.
- Begründung: Der Einstieg soll Neugier, Entdeckung, Erfolg, Bindung und Stolz vermitteln und den Spieler zum Weiterspielen motivieren, ohne ihn mit Systemen zu überfordern.


## 25.11.2026 — Herkunft des Startgrundstücks

**Beschluss:** Der Spieler hat den Schrottplatz geerbt.

- Die Erbschaft ist der erzählerische Grund, warum der Spieler den heruntergekommenen Betrieb übernimmt.
- Die Identität des früheren Besitzers und dessen Beziehung zum Spieler sind noch nicht festgelegt.
- Auch die konkrete Übergabe – etwa durch Nachlassunterlagen, Schlüssel und eine persönliche Nachricht – bleibt offen.
- Die Vorgeschichte soll kurz bleiben. Die eigentliche Geschichte entfaltet sich auf dem Grundstück durch Gegenstände, Fundstücke, Scrappy und später auftauchende Figuren.
- Begründung: Eine Erbschaft schafft einen glaubwürdigen Einstieg, gibt dem Grundstück eine Vergangenheit und ermöglicht erzählerische Entdeckungen, ohne den Spielstart mit umfangreicher Vorgeschichte aufzuhalten.


## 25.11.2026 — Hintergrundgeschichte: Walter Wren und Scrappy

**Beschluss:** Der frühere Besitzer des Startgrundstücks ist Walter „Walt“ Wren. Scrappy wurde von ihm gebaut und war sein wichtigstes Projekt.

- Walt ist ein freundlicher, eigenwilliger Bastler und früherer Betreiber des Schrottplatzes.
- Seine Erfindungen sind kreativ, improvisiert und gelegentlich fragwürdig, werden aber innerhalb der Spielwelt ernsthaft behandelt.
- Scrappy wurde als praktischer Schrottplatzhelfer gebaut und entwickelte sich zu Walts Begleiter und Gesprächspartner.
- Walt kam bei einem Unfall mit seiner letzten großen Erfindung, der „The Everything-O-Matic 3000“, ums Leben.
- Scrappy wurde beim Versuch, Walt zu erreichen, schwer beschädigt; sein Kopf landete unter einem Schrotthaufen.
- Walt hatte Scrappys Kernkomponente vor dem Testlauf ausgebaut und im roten Werkzeugkasten gesichert. Sie blieb dadurch erhalten.
- Der Spieler erbt den Schrottplatz und erhält Nachlassunterlagen, Schlüssel und einen persönlichen Brief von Walt.
- Die genaue Beziehung zwischen Walt und dem Spieler bleibt offen.
- Scrappys Speicher ist beschädigt. Erinnerungen an Walt werden schrittweise durch Orte, Gegenstände und Maschinen ausgelöst.
- Begründung: Die Geschichte verbindet Erbschaft, Startgrundstück, Scrappy und Umgebungs-Erzählung. Sie schafft emotionale Tiefe, ohne einen langen oder düsteren Prolog zu benötigen.

## 25.11.2026 — Humoridentität von Scrapstead

**Beschluss:** Scrapstead erhält einen warmen, leicht überzogenen Humor mit trockenem Timing und liebenswerter Absurdität.

- Humor entsteht aus vier Säulen: erfinderischer Unsinn, trockener Charakterhumor, Umgebungs- und Fundstückgeschichten sowie liebenswerte Absurdität im Alltag.
- Walt und seine Erfindungen prägen den visuellen und erzählerischen Humor des Grundstücks.
- Scrappy ist selbstbewusst, loyal, gelegentlich besserwisserisch und kommentiert Situationen kontextbezogen.
- NPCs und Mitarbeiter dürfen Eigenheiten besitzen, sind aber glaubwürdige Figuren und keine dauerhaften Witzmaschinen.
- Nicht jede Interaktion braucht einen Witz. Dialoge bleiben kurz und werden nicht auf Kosten des Spielflusses wiederholt.
- Emotionale Momente dürfen ohne Pointe stehen bleiben.
- Deutsche und englische Texte müssen denselben Charakter und dieselbe Wirkung transportieren; Wortspiele dürfen lokal angepasst werden.
- Begründung: Der Humor soll Scrapstead wiedererkennbar machen, ohne gekünstelt, aufdringlich oder beliebig zu wirken.


## 25.11.2026 — Walts Tod durch seine eigene Erfindung

**Beschluss:** Als neuer erzählerischer Entwurf wird festgelegt, dass Walt bei einem Unfall mit seiner eigenen Maschine ums Leben kam.

- Walts letzte große Erfindung ist die „The Everything-O-Matic 3000“, eine überambitionierte Anlage zur automatischen Erkennung, Sortierung und Zerlegung von Schrott.
- Bei einem letzten Testlauf begibt sich Walt zur Behebung einer Verklemmung in das Maschineninnere. Die Anlage startet unerwartet erneut; Walt überlebt den Unfall nicht.
- Der Unfall selbst wird nicht gezeigt. Spieler rekonstruieren die Ereignisse aus Wartungsnotizen, Warnschildern, Maschinenzustand und Scrappys Erinnerungen.
- Scrappy wird beim Versuch, Walt zu erreichen, schwer beschädigt. Seine Kernkomponente war vor dem Testlauf ausgebaut und im roten Werkzeugkasten gesichert.
- Der Humor entsteht aus Walts Erfindung, seiner fragwürdigen Dokumentation und trockenen Betriebsnotizen – nicht aus einer Verspottung seines Todes.
- Die Maschine bleibt zunächst stillgelegt als erzählerisches Relikt auf dem Grundstück. Eine spätere Reparatur oder Nutzung ist noch offen.
- Begründung: Walts Leidenschaft wird auf tragikomische, zur Welt passende Weise Teil seiner Geschichte. Der Unfall verbindet Scrappys Beschädigung, den roten Werkzeugkasten und die Vergangenheit des Schrottplatzes logisch miteinander.


## 25.11.2026 — Scrappys Persönlichkeit, Eigeninitiative und Timing

**Beschluss:** Scrappy wird als eigenständiger, aktiver Begleiter mit einer Mischung aus trockenem Humor, Frechheit und emotionaler Tiefe ausgearbeitet.

- Im Normalfall ist Scrappy trocken, sachlich, sarkastisch und gelegentlich besserwisserisch.
- In passenden Situationen kann er überraschend frech, bissig oder überschwänglich reagieren. Diese Ausbrüche sollen durch Kontrast und Timing wirken, nicht durch permanente Lautstärke.
- Scrappy ist selbstbewusst bis zur Selbstüberschätzung und hält seine technische Kompetenz gelegentlich für größer, als sie tatsächlich ist.
- Er bleibt loyal, neugierig, hilfsbereit und hinter seiner frechen Fassade herzlich und verletzlich.
- Scrappy besitzt Eigeninitiative: Er darf interessante Dinge untersuchen, auf Fundstücke oder Auffälligkeiten hinweisen und gelegentlich kleine eigene Tätigkeiten oder Projekte verfolgen.
- Seine Eigeninitiative bleibt unterstützend. Sie darf dem Spieler keine wichtigen Entdeckungen, Entscheidungen oder Aufgaben abnehmen.
- Seine Kommunikation wird in situative Kommentare, selbst initiierte Kommentare und besondere Erinnerungsmomente gegliedert.
- Scrappy reagiert auf Erlebnisse und wiederkehrende Situationen, sodass sich gemeinsame Running Gags und eine persönliche Geschichte mit dem Spieler entwickeln können.
- Er kommentiert nicht jede Aktion. Stille und emotionale Momente ohne Pointe sind ausdrücklich erwünscht.
- Er darf den Spieler necken, aber niemals herabsetzen oder dauerhaft aufdringlich sein.
- Begründung: Scrappy soll sich wie eine eigenständige Figur anfühlen, die auch dann eine Persönlichkeit besitzt, wenn der Spieler gerade nicht mit ihm interagiert. Sein Humor und seine Initiative sollen die Welt bereichern, ohne den Spielfluss oder die Spielerfreiheit zu beeinträchtigen.


## 25.11.2026 — Scrappys persönliche Entwicklung

**Beschluss:** Scrappy wächst im Laufe des Spiels mit dem Spieler. Seine Entwicklung umfasst technische, persönliche, soziale und emotionale Aspekte.

- Technische Entwicklung entsteht durch neue Module, Werkzeuge, Sensoren und Fähigkeiten.
- Persönliche Entwicklung entsteht durch gemeinsame Erlebnisse und kann neue Interessen, Vorlieben, Marotten, Gewohnheiten und eigene Projekte hervorbringen.
- Soziale Entwicklung entsteht durch wiederholte Begegnungen und Situationen mit Mitarbeitern und NPCs.
- Emotionale Entwicklung wird durch gemeinsame Erfolge, Rückschläge, die Bindung zum Spieler und Erinnerungen an Walt geprägt.
- Veränderungen sollen möglichst aus konkreten Erlebnissen hervorgehen und nicht nur über abstrakte Level oder Werte abgebildet werden.
- Scrappy darf sich verändern und dazulernen, behält aber seine grundlegende Identität und Eigenständigkeit.
- Persönliche Entwicklung darf kein Pflicht-, Pflege- oder Mikromanagementsystem werden. Der Spieler muss Scrappy nicht optimieren, um einen vollständigen Begleiter zu erhalten.
- Manche Entwicklungen werden subtil über Verhalten, Animationen, eigene Projekte oder Dialogvarianten sichtbar, ohne ausdrücklich als Belohnung angekündigt zu werden.
- Begründung: Scrappy soll nicht nur mit dem Betrieb leistungsfähiger werden, sondern durch die gemeinsame Reise zu einer vertrauten, eigenständigen Figur heranwachsen.
