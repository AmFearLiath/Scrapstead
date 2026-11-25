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


## 25.11.2026 — Organische Bindung zwischen Scrappy und dem Spieler

**Beschluss:** Scrappys Beziehung zum Spieler entwickelt sich natürlich durch gemeinsame Erlebnisse und wird nicht als explizites Freundschafts- oder Loyalitätslevel dargestellt.

- Die wachsende Bindung zeigt sich durch Vertrauen, Vertrautheit, gemeinsame Erinnerungen, Running Gags und kleine Verhaltensänderungen.
- Scrappy muss den Spieler nicht ausdrücklich als besten Freund bezeichnen. Die Beziehung soll durch Handlungen, Dialoge und Situationen spürbar werden.
- Scrappy bleibt eine eigenständige Figur: Er darf widersprechen, necken, eigene Interessen verfolgen und gelegentlich Abstand halten.
- Große emotionale Aussagen werden sparsam eingesetzt und an konkrete gemeinsame Erlebnisse gebunden.
- Die Beziehung wird nicht durch einen sichtbaren Fortschrittsbalken oder eine zu optimierende Kennzahl abgebildet.
- Begründung: Die Bindung soll sich verdient und glaubwürdig anfühlen. Spieler sollen sie selbst entdecken, statt sie als Systemwert abzulesen.


## 25.11.2026 — Scrappys ereignisbasiertes Gedächtnis

**Beschluss:** Scrappy erhält ein persistentes, ereignisbasiertes Gedächtnissystem mit mehreren Erinnerungsebenen. Die Umsetzung erfolgt regelbasiert und benötigt kein dauerhaft laufendes Sprachmodell.

- Das Spiel erzeugt strukturierte Ereignisse für relevante Aktionen und Situationen. Scrappys Gedächtnis verarbeitet diese Ereignisse und entscheidet anhand von Kontext, Wiederholung und Bedeutung, ob eine Erinnerung gespeichert wird.
- Das Gedächtnis umfasst Kurzzeit-, Langzeit-, persönliche und besonders bedeutsame Erinnerungen.
- Kurzzeitdaten dürfen verfallen. Wichtige gemeinsame Erlebnisse, persönliche Erfahrungen und Erinnerungen an Walt bleiben langfristig erhalten.
- Erinnerungen können miteinander verknüpft und später durch passende Orte, Gegenstände, Personen oder Situationen aktiviert werden.
- Wiederkehrende Erlebnisse können Vorlieben, Gewohnheiten und Running Gags prägen.
- Scrappy darf unwichtige Details humorvoll falsch erinnern oder seine eigene Rolle überhöhen. Die tatsächliche Spielhistorie und wichtige Fakten bleiben davon unberührt.
- Das Gedächtnis wird mit dem Spielstand gespeichert und verwendet stabile, sprachunabhängige IDs sowie lokalisierte Dialogreferenzen.
- Die Verarbeitung erfolgt ereignisbasiert und nicht durch permanente Analyse der Spielwelt.
- Das Grundsystem verwendet Regeln, Tags, Gewichtungen und vorbereitete Dialogvarianten. Ein externes oder lokales LLM ist optional und keine technische Voraussetzung.
- Das Gedächtnis bleibt modular und unabhängig von Bewegungs-, Animations- und Dialogsystem.
- Begründung: Scrappy soll eine glaubwürdige gemeinsame Vergangenheit und eigene Lebenserfahrung entwickeln können, ohne dass dafür ein aufwendiger KI-Agent oder permanente Sprachmodell-Inferenz notwendig ist.

## 25.11.2026 — Situationsabhängige Kontaktaufnahme durch Scrappy

**Beschluss:** Scrappy darf den Spieler eigenständig und situationsabhängig ansprechen.

- Kontaktaufnahmen entstehen aus nachvollziehbaren Anlässen, etwa einer Entdeckung, einer eigenen Idee, einer Erinnerung oder dem Wunsch, etwas mitzuteilen.
- Scrappy berücksichtigt die aktuelle Beschäftigung des Spielers und wartet normalerweise bei ungünstigem Timing.
- Interessante oder wichtige Beobachtungen dürfen eine gelegentliche Unterbrechung rechtfertigen.
- Der Spieler kann reagieren, das Gespräch vertagen oder es ignorieren.
- Scrappy kann aus wiederholten Reaktionen lernen und Häufigkeit sowie Zeitpunkt seiner Kontaktversuche anpassen.
- Ignorieren verursacht weder Beziehungsverlust noch Gameplay-Nachteile.
- Wiederholungsabstände und Prioritäten verhindern aufdringliche oder ständig wiederkehrende Kontaktversuche.
- Begründung: Scrappy soll wie eine eigenständige Figur wirken, die aus eigenem Antrieb etwas mitteilen möchte, dabei aber die Aufmerksamkeit und Handlungsfreiheit des Spielers respektiert.


## 25.11.2026 — Scrappys Bewegung und Interaktion mit der Welt

**Beschluss:** Scrappy wird als Begleiter und eigenständiger Bewohner des Schrottplatzes umgesetzt. Seine Bewegung umfasst Begleiten, eigenständige Aktivitäten, Assistenz und selbst gewählte Aufenthaltsorte.

- Scrappy folgt dem Spieler bei Bedarf mit angemessenem Abstand und vermeidet es, Wege oder Arbeitsbereiche zu blockieren.
- Wenn der Spieler beschäftigt ist, darf Scrappy die Umgebung erkunden, Gegenstände untersuchen, eigene Tätigkeiten verfolgen oder an geeigneten Orten verweilen.
- Bei kompatiblen Maschinen und Aufgaben kann Scrappy selbstständig eine Assistenzposition aufsuchen, sofern seine Module und Fähigkeiten ausreichen.
- Fortbewegungsmodule besitzen eigene funktionale Eigenschaften und Animationen. Vorgesehen sind Räder, Ketten, Beine und als mögliche spätere Erweiterung ein Schwebemodul.
- Der Spieler bestimmt durch den Einbau das Fortbewegungsverhalten. Ein automatischer Wechsel zwischen Fortbewegungsarten ist nicht vorgesehen.
- Fortbewegungsmodule dürfen Vorteile bieten, aber keine wichtigen Spielbereiche oder Inhalte ausschließlich hinter einer bestimmten Konfiguration sperren.
- Scrappy interagiert mit Gegenständen, Maschinen, Gebäuden und NPCs. Die Interaktionen sind durch Fähigkeiten, Objekt-Tags und Kontext begrenzt.
- Kleine, unkritische Fundstücke darf Scrappy für eigene Projekte oder Untersuchungen bewegen, sofern passende Regeln dies erlauben.
- Wertvolle, verkaufsfähige, questrelevante oder anderweitig wichtige Gegenstände bleiben ohne ausdrückliche Erlaubnis des Spielers geschützt.
- Scrappy erhält gut lesbare Grundanimationen für Leerlauf, Neugier, Nachdenken, Aufregung, Verlegenheit, Arbeit, soziale Interaktion und Ruhe.
- Sein Verhalten wird über ein leichtgewichtiges Prioritäts- und Zustandsmodell gesteuert. Notfälle und direkte Spielerinteraktionen haben Vorrang vor persönlichen Aktivitäten und Leerlauf.
- Navigation, Animationen und Interaktionen bleiben modular. Ein Behavior Tree oder eine überschaubare Zustandsmaschine sind mögliche Umsetzungsoptionen; die endgültige Wahl erfolgt im Prototyp.
- Begründung: Scrappy soll als physisch präsente Figur mit eigenen Bewegungsgewohnheiten und Interaktionen glaubwürdig wirken. Seine Eigenständigkeit darf weder die Spielerfreiheit noch den reibungslosen Betrieb des Schrottplatzes beeinträchtigen.

## 25.11.2026 — Schutzregeln für Scrappys eigenständige Aktivitäten

**Beschluss:** Scrappys Eigeninitiative wird durch klare Berechtigungs- und Prioritätsregeln begrenzt.

- Scrappy darf kleine, unkritische Gegenstände für eigene Aktivitäten verwenden.
- Wertvolle, verkaufsfähige, questrelevante und wichtige Ressourcen werden nicht ungefragt aufgenommen, verbraucht, bewegt oder verbaut.
- Weitergehende Eigeninitiative kann der Spieler bei Bedarf ausdrücklich erlauben.
- Scrappy erledigt keine kritischen Aufgaben oder wichtigen Entdeckungen eigenmächtig.
- Er blockiert keine Wege, Maschinenzugänge oder Arbeitsbereiche dauerhaft.
- Eigenständige Tätigkeiten sind unterbrechbar und werden bei höher priorisierten Spielerinteraktionen oder Notfällen kontrolliert beendet.
- Begründung: Scrappys Eigenleben soll charmant und überraschend sein, aber niemals zum Verlust von Ressourcen, Kontrolle oder Spielfortschritt führen.


## 25.11.2026 — Scrappys Energieversorgung ohne Wartungsdruck

**Beschluss:** Scrappy besitzt einen internen Energiespeicher und kann selbstständig aufladen. Energieversorgung ist kein Pflicht- oder Bestrafungssystem.

- Energie wird hauptsächlich für optionale Werkzeuge, besondere Fähigkeiten und aufwendige Assistenzfunktionen benötigt.
- Folgen, Kommunikation, grundlegende Bewegung und normale Interaktionen bleiben auch bei niedrigem Energiestand verfügbar.
- Scrappy kann bei niedrigem Energiestand selbstständig eine erreichbare Ladestation aufsuchen.
- Eine einfache Lademöglichkeit ist früh verfügbar. Spätere Ladestationen können Komfort und Ladegeschwindigkeit verbessern.
- Wenn keine Ladestation verfügbar ist, kann Scrappy an einer sicheren Ruheposition in einen sparsamen Zustand wechseln und langsam Energie zurückgewinnen.
- Aufladen geschieht automatisch. Der Spieler muss den Vorgang weder starten noch überwachen.
- Energiemangel darf Scrappy nicht dauerhaft deaktivieren, aus dem Spiel entfernen oder den Spielfortschritt blockieren.
- Energieintensive Module können mehr verbrauchen; Effizienz, Kapazität und Ladegeschwindigkeit können durch Upgrades verbessert werden. Konkrete Werte werden im Prototyp getestet.
- Der Energiestand wird nicht als dauerhaft präsente Pflichtanzeige inszeniert. Hinweise bleiben selten und kontextbezogen.
- Humor entsteht durch Scrappys übertriebene technische Selbsteinschätzung, kleine Ladeanimationen, bevorzugte Ladestationen und trockene Kommentare. Ladezeiten oder Ladeprobleme werden nicht künstlich verlängert.
- Begründung: Energieversorgung verleiht Scrappy technische Glaubwürdigkeit und bietet zusätzliche Charakter- und Humor-Momente, ohne ihn zu einem Tamagotchi oder einer weiteren Verwaltungsaufgabe für den Spieler zu machen.

## 25.11.2026 — Scrappys Alltag und Eigeninitiative

**Beschluss:** Scrappy erhält einen eigenen, ereignis- und interessenbasierten Alltag ohne starren Stundenplan.

- Aktivitäten umfassen Erkunden, Beobachten, Tüfteln, soziale Begegnungen, Ruhe und persönliche Projekte.
- Projekte dürfen dekorativ, erzählerisch oder charakterbildend sein und müssen keinen wirtschaftlichen Nutzen besitzen.
- Aktivitäten sind unterbrechbar und können später fortgesetzt oder aufgegeben werden.
- Scrappy darf freigegebene Kleinteile für eigene Projekte nutzen, aber keine wichtigen Ressourcen oder Gegenstände.
- Eigeninitiative und Kontaktfrequenz sind konfigurierbar.
- Leerlauf und Stille sind ausdrücklich gültige Verhaltensweisen.
- Begründung: Scrappy soll eigenständig wirken, ohne eine zusätzliche Lebenssimulation oder Pflegepflicht zu erzeugen.

## 25.11.2026 — Fähigkeits- und Erfahrungsmodell

**Beschluss:** Scrappys Fähigkeiten folgen einem Hardware-Erfahrung-Persönlichkeit-Modell.

- Hardware schaltet Funktionen frei und definiert ihre Voraussetzungen.
- Erfahrung verbessert vorhandene Funktionen durch tatsächliche Nutzung.
- Persönlichkeit beeinflusst Ausdruck, Interessen und Verhalten, nicht die technischen Voraussetzungen.
- Es gibt keinen universellen Charakterlevel und keine Pflicht-Skillpunkte.
- Fähigkeiten werden in Wahrnehmung, Weltinteraktion, Spielerassistenz, autonome Aktivitäten, soziale Fähigkeiten, persönliche Entwicklung und Spezialfunktionen gegliedert.
- Erfahrung wird tätigkeitsbezogen und in wenigen verständlichen Stufen gespeichert.
- Begründung: Technische Entwicklung soll nachvollziehbar sein und organisch aus Scrappys tatsächlichen Erlebnissen entstehen.

## 25.11.2026 — Modulare Konstruktion und persönliche Ausstattung

**Beschluss:** Scrappy wird aus vorbereiteten, standardisierten und kompatiblen 3D-Komponenten zusammengesetzt.

- Montagepositionen, Anschlüsse, Ausrichtungen, Animationspunkte und Kompatibilitätsregeln sind standardisiert.
- Linker und rechter Arm können unabhängig bestückt werden; koordinierte Tätigkeiten benötigen kompatible Kombinationen.
- Beliebige Geometriegenerierung, freie Gelenkerzeugung und unkontrollierte Skalierung sind nicht vorgesehen.
- Technische Module und persönliche kosmetische Gegenstände besitzen getrennte Systeme.
- Scrappy besitzt ein eigenes persönliches Inventar und darf innerhalb der Spielereinstellungen selbstständig Gegenstände kombinieren und tragen.
- Bedeutsame Erinnerungsstücke sind geschützt.
- Begründung: Hohe Individualisierung soll mit einem realistisch produzierbaren Asset- und Animationsumfang vereinbar bleiben.

## 25.11.2026 — Körperdesign und Ausdruck

**Beschluss:** Scrappys visuelle Identität verbindet einen stabilen mechanischen Kern mit asymmetrischen, wiederverwendeten Schrottteilen.

- Kompakte Proportionen, relativ großer Kopf und niedriger Schwerpunkt.
- Zwei große, leicht asymmetrische optische Sensoren, mechanische Blenden, beweglicher Kopf und charakteristische Antenne bilden die wiedererkennbare Ausdrucksgrundlage.
- Stimme und Persönlichkeit bleiben unabhängig von Hardware.
- Räder, Ketten, Beine und Schwebemodule erhalten eigene Bewegungsprofile.
- Animationen werden aus wiederverwendbaren Schichten und standardisierten Ankerpunkten kombiniert.
- Begründung: Scrappy muss aus der isometrischen Kameradistanz erkennbar und emotional lesbar bleiben, auch mit wechselnder Ausstattung.

## 25.11.2026 — Technische Architektur und Prototypumfang von Scrappy

**Beschluss:** Scrappy wird als eigenständiges, datengetriebenes und ereignisbasiertes System umgesetzt.

- Module, Fähigkeiten, Wahrnehmung, Gedächtnis, Absichten, Aktivitäten, Navigation, Ausdruck und Kommunikation bleiben getrennte Systembausteine.
- Autonome Entscheidungen werden priorisiert, begrenzt und nur bei relevanten Ereignissen oder in kontrollierten Intervallen getroffen.
- Ein dauerhaft laufendes LLM ist keine Voraussetzung.
- Sicherheit, direkte Spielerinteraktion und ausdrücklich erteilte Aufträge haben Vorrang vor persönlichen Aktivitäten.
- Der erste Prototyp konzentriert sich auf Folgen, einfache Erkundung, eine persönliche Aktivität, Grundausstattung, eine Moduländerung, begrenzte Erinnerungen und automatisches Aufladen.
- Dialogtexte, vollständige Sprachproduktion und umfangreiche Animationsvarianten bleiben spätere Arbeitspakete.
- Begründung: Der Prototyp soll Scrappys Kernversprechen nachweisen, bevor der volle Content- und Produktionsumfang entsteht.


## Ergänzung: Produktionsumfang und Scope-Grenzen

**Leitentscheidung:** Scrapstead soll als vollständiges, überschaubares Spiel fertiggestellt werden. Die erste vollständige Version konzentriert sich auf den Old Yard, eine kompakte Region, wenige regionale Anlaufstellen, Scrappy, begrenzte Mitarbeiter- und Maschinenfunktionen sowie einen klaren Hauptabschluss.

Die bisherigen Systemspezifikationen sind ein Ideen- und Detailpool, keine automatische Verpflichtung zur Umsetzung sämtlicher beschriebenen Funktionen. Optionale Erweiterungen werden erst nach Stabilisierung des Kerns freigegeben. Bei Umfangsdruck werden zusätzliche Figuren, Ereignisse, Maschinenvarianten, Spezialstandorte und erweiterte Simulation zuerst reduziert oder verschoben.

Die Hauptspielzeit von 30–40 Stunden bleibt ein vorläufiges Balancing-Ziel. Sie darf nicht durch künstliche Wartezeiten oder Pflicht-Mikromanagement erzeugt werden.

Verbindliche Produktionsleitplanke: [Produktionsumfang und Entwicklungsfahrplan](production-scope-and-roadmap.md).


## Ergänzung: Core-Gameplay-Matrix

**Leitentscheidung:** Jede Kernmechanik erhält eine klar begrenzte minimale vollständige Umsetzung, definierte Abhängigkeiten, eine Entwicklungsphase und einen MVP-Nachweis. Optionale Erweiterungen sind keine Release-Verpflichtungen.

Der erste aussagekräftige Prototyp prüft Bewegung, Interaktion, Sammeln, eine größere Bergungsaktion, Direktverkauf, Credits, ein Upgrade und optional eine einfache Verarbeitung. Erst nach erfolgreicher Validierung werden Scrappy, Delegation, Maschinen und Region schrittweise ergänzt.

Referenz: [Core-Gameplay-Matrix](core-gameplay-matrix.md).

## 25.11.2026 — Stufenweise MVP- und Prototypenvalidierung

**Beschluss:** Scrapstead wird vor der breiteren Produktion in klar getrennten Prototypstufen validiert. Der erste aussagekräftige Gameplay-Prototyp konzentriert sich auf Sammeln, Bergen, Direktverkauf, Credits und ein erstes sinnvolles Upgrade.

- P0 prüft Bewegung, isometrische Kamera, Interaktion und minimale Persistenz.
- P1 prüft die Kernschleife ohne Scrappy, Mitarbeiter, Maschinen, regionale Wirtschaft oder vollständigen Baumodus.
- P1b prüft eine einzelne optionale Verarbeitungsaktion. Direktverkauf muss weiterhin eine sinnvolle Alternative bleiben.
- P2 verbindet den validierten Kern mit der ersten Stunde und Scrappys garantierter Wiederherstellung. Scrappy erhält zunächst nur Begleiter-Grundverhalten und wenige vorbereitete Reaktionen.
- P3 prüft zuerst einen Mitarbeiter mit einer einzigen Aufgabe und anschließend den kleinen Magnetsammler als erste Maschine.
- P4 verbindet die validierten Systeme in einem repräsentativen Vertical Slice des Old Yard.
- Jede Stufe besitzt Abnahmekriterien und muss freigegeben werden, bevor der nächste Umfangsschritt beginnt.
- Die technische Umsetzung bleibt zunächst so einfach wie möglich. Fachliche Datenobjekte und Systemgrenzen werden nur soweit eingeführt, wie sie für den jeweiligen Prototyp erforderlich sind.

**Begründung:** Die wichtigste Produktionsgefahr ist, zu viele Systeme gleichzeitig zu entwickeln und dadurch nicht zu erkennen, ob der eigentliche Spielkern trägt. Kleine, isoliert prüfbare Schritte reduzieren das Risiko und schützen den überschaubaren Gesamtumfang.

Referenz: [MVP- und Prototypenplan](mvp-prototype-plan.md).

## 25.11.2026 — Hauptmenü und animierter Startbildschirm im ersten Prototyp

**Beschluss:** Bereits der erste spielbare Prototyp erhält ein eigenständiges Hauptmenü mit Scrapstead-Logo und einer animierten Kamerafahrt durch den Old Yard.

- Das Spiel startet direkt in das Hauptmenü.
- Im Hintergrund zeigt eine vorbereitete, ruhige Kamerafahrt den Old Yard. Für den frühen Prototyp darf dafür der einfache 3D-Blockout verwendet werden.
- Die Kamerafahrt läuft unabhängig von der Gameplay-Kamera und kann kontrolliert wiederholt werden.
- Das Menü bietet Neues Spiel, Fortsetzen, Einstellungen und Beenden.
- Fortsetzen ist nur bei vorhandenem gültigem Spielstand aktiv.
- Einstellungen werden nur soweit angeboten, wie die Optionen im Prototyp tatsächlich funktionieren.
- Logo, Menü und Hintergrund erhalten eine klare visuelle Hierarchie und bleiben gut lesbar.
- Aufwendige Logoanimationen, Effekte und ein vollständiges Optionsmenü sind nicht Teil dieses frühen Umfangs.

**Begründung:** Der erste Prototyp soll nicht nur eine technische Testumgebung sein, sondern bereits einen erkennbaren ersten Eindruck von Scrapstead vermitteln. Der Aufwand bleibt durch eine vorbereitete Kameraroute und den wiederverwendeten Blockout begrenzt.

Referenzen: [MVP- und Prototypenplan](mvp-prototype-plan.md), [UI- und UX-Spezifikation](ui-ux.md).


## 25.11.2026 — Technische Basis: Godot 4.7.2 Stable und GDScript

**Beschluss:** Scrapstead wird mit Godot Engine 4.7.2 Stable und GDScript entwickelt.

- Das Projekt wird als 3D-Spiel mit isometrischer Kamera aufgebaut.
- Zielplattform zum Einstieg ist PC, zunächst Windows und Linux.
- Forward+ wird als anfängliche Rendering-Konfiguration verwendet und in P0 auf Performance und Hardwarekompatibilität geprüft.
- Godot 3D Physics bildet die Grundlage für Bewegung und Kollision.
- Die Benutzeroberfläche wird mit Godot Control Nodes umgesetzt.
- Godot Resources und strukturierte, versionierte Spieldaten dienen der Datenhaltung; Spielstände werden nicht als gespeicherte Szenen- oder Node-Strukturen behandelt.
- Git wird für die Versionsverwaltung eingesetzt.
- Engine-Version und Skriptsprache sind festgelegt. Rendering-Feinabstimmung und konkrete Bewegungsparameter werden im P0-Prototyp validiert.

**Begründung:** Godot bietet für den geplanten PC-Fokus, die 3D-Szenenstruktur, isometrische Darstellung, Interaktionen und UI eine schlanke integrierte Entwicklungsbasis. GDScript hält die Umsetzung eng an Godot und vermeidet eine zusätzliche .NET-Abhängigkeit.


## 25.11.2026 — P0-Szenenarchitektur und Verantwortlichkeiten

**Beschluss:** Der erste technische Aufbau wird in klar getrennte Szenen und wenige globale Dienste gegliedert.

- `Main.tscn` ist der Einstiegspunkt und übergibt an das Hauptmenü.
- `MainMenu.tscn` enthält die Menüoberfläche und bindet eine eigenständige Hintergrundszene ein.
- `MenuBackdrop.tscn` stellt den Old-Yard-Blockout und die unabhängige Menü-Kamerafahrt dar.
- `OldYardTest.tscn` enthält Testgeometrie, Spieler, Gameplay-Kamera, drei Interaktionsobjekte und HUD.
- `Player.tscn` verwendet `CharacterBody3D`; Modell, Kollision und Interaktionserkennung bleiben getrennt.
- Die Gameplay-Kamera ist eine eigene Szene und bleibt unabhängig von der Menü-Kamera.
- Globale Dienste werden in P0 auf GameSession und SaveService begrenzt. Ein eigener globaler SceneManager wird zunächst nicht eingeführt.
- Interaktionen sind im ersten Prototyp reichweitenbasiert. Das System wählt ein gültiges Ziel in der Nähe; das Zielobjekt führt die konkrete Aktion aus.
- Spielstände enthalten versionierte Daten und stabile Objekt-IDs, keine serialisierten Szenen- oder Node-Strukturen.
- Die lokale Engine-Bereitstellung liegt unter `_engine/` und wird nicht in das Git-Repository aufgenommen.

**Begründung:** Eine klare Trennung der Verantwortlichkeiten erleichtert Tests und spätere Erweiterungen, ohne für P0 bereits ein großes Framework oder zukünftige Gameplay-Systeme vorwegzunehmen.

Referenz: [P0-Szenenarchitektur](p0-scene-architecture.md).


## 25.11.2026 — P0-Spielersteuerung

**Beschluss:** Die erste Spielersteuerung verwendet eine direkte, kamerabezogene Bewegung mit geglätteter Beschleunigung und Ausrichtung.

- Der Spieler wird über `CharacterBody3D` bewegt.
- WASD und Pfeiltasten bilden die P0-Standardbelegung.
- Bewegungsrichtungen werden aus der horizontal projizierten Ausrichtung der Gameplay-Kamera abgeleitet.
- Diagonale Eingaben werden normalisiert.
- Beschleunigung und Bremsverhalten werden getrennt abgestimmt.
- Das visuelle Modell dreht sich weich in Bewegungsrichtung; der Kollisionskörper wird dadurch nicht mitgedreht.
- Schwerkraft, Bodenstatus und Kollision werden im Physik-Update verarbeitet.
- Sprinten, Springen, Schleichen und Ausweichen sind nicht Bestandteil von P0.
- Die Startwerte für Geschwindigkeit und Beschleunigung sind Testparameter und keine finalen Balancingwerte.

**Begründung:** Die Steuerung soll in der isometrischen Perspektive intuitiv und präzise bleiben. Die Trennung von Bewegungslogik, visueller Ausrichtung, Kamera und Interaktion verhindert unnötige Abhängigkeiten.

Referenz: [P0-PlayerController-Spezifikation](p0-player-controller.md).


## 25.11.2026 — P0-Gameplay-Kamera

**Beschluss:** Die Gameplay-Kamera verwendet für den ersten Prototyp eine feste orthografische isometrische Perspektive mit ruhigem Spieler-Following und begrenztem, stufenlosem Zoom.

- Die Kamera bleibt eine eigenständige Szene und ist von der Menü-Kamerafahrt getrennt.
- Ein definierter Kamera-Anker am Spieler dient als Follow-Ziel.
- Die Kamera folgt weich und framerate-unabhängig; beim Szenenstart wird die Ausgangsposition ohne sichtbaren Schwenk gesetzt.
- Der Zoom erfolgt stufenlos über das Mausrad und verändert ausschließlich die orthografische Größe.
- Kamerawinkel und Ausrichtung bleiben in P0 fest; freie Rotation und Neigung sind nicht vorgesehen.
- Automatische Hindernisvermeidung, dynamische Gebäudetransparenz und Innenraum-Kameraprofile werden nicht in P0 implementiert.
- Winkel, Zoomgrenzen und Glättung sind Startwerte und werden im Old-Yard-Blockout mit kleinen und großen Objekten geprüft.

**Begründung:** Eine feste, gut lesbare Perspektive hält die Steuerung vorhersehbar und reduziert technische Komplexität. Der begrenzte Zoom gibt dem Spieler Übersicht und Nähe, ohne eine zusätzliche freie Kamerasteuerung einzuführen.

Referenz: [P0-GameplayCameraController-Spezifikation](p0-gameplay-camera-controller.md).


## 25.11.2026 — Zentrale Entwicklungswerkstatt und Admin-Tooling

**Beschluss:** Scrapstead erhält eine zentrale Entwicklungswerkstatt als zusammenhängenden Zugang zu den Werkzeugen für Spielkonfiguration, Balancing und Content-Produktion.

- Alle geeigneten Spielwerte, Preise und Formeln sollen konfigurierbar sein, ohne für normale Balancingänderungen Gameplay-Code bearbeiten zu müssen.
- Texte, Lokalisierung, Quests und NPC-Definitionen sollen zentral gepflegt werden.
- Gebäude, modulare Bauteile, Flächen und Karten sollen mit geeigneten Werkzeugen erstellt und bearbeitet werden können.
- Die Werkstatt darf Godot-interne Ressourcen, Szenen, EditorPlugins, Inspector-Erweiterungen, Docks und Tool-Skripte verwenden.
- Bevorzugt wird ein zentraler Einstieg mit spezialisierten Werkzeugen statt eines vollständig selbst entwickelten monolithischen Editors.
- Spiel und Werkstatt verwenden dieselben Datenquellen, stabilen IDs und versionierten Datenverträge.
- Validierung, Referenzprüfung und die Aktualisierung der Werkzeuge bei neuen Gameplay-Systemen sind verbindliche Anforderungen.
- Die Werkstatt ist primär ein Entwicklungswerkzeug und muss nicht Bestandteil des fertigen Spiels sein.
- Ein separates Web-Backend, ein Online-Adminsystem oder ein Laufzeit-Adminbereich wird nicht vorausgesetzt.
- Der Ausbau erfolgt schrittweise zusammen mit den jeweiligen Spielsystemen und darf die Fertigstellung des Kerns nicht blockieren.

**Begründung:** Eine zentrale Verwaltungs- und Produktionsumgebung beschleunigt Balancing und Content-Arbeit, reduziert manuelle Fehler und verhindert verstreute, voneinander abweichende Datenpflege. Durch die Nutzung Godot-nativer Werkzeuge bleibt der Eigenentwicklungsaufwand begrenzt.

Referenz: [Zentrale Entwicklungswerkstatt und Admin-Tooling](development-workbench-and-admin-tooling.md).


## 25.11.2026 — P0-Interaktionssteuerung

**Beschluss:** Die bestehende Komponente `PlayerInteractor` übernimmt die Interaktionssteuerung. Ein zusätzlicher paralleler InteractionController wird nicht eingeführt.

- InteractionDetector erkennt mögliche Ziele im Nahbereich, trifft aber keine Auswahlentscheidung.
- PlayerInteractor prüft Gültigkeit und Verfügbarkeit, bewertet Kandidaten und verwaltet genau ein aktives Ziel.
- Nähe ist das primäre Auswahlkriterium; Blickrichtung dient als sekundäres Kriterium bei annähernd gleicher Distanz.
- Eine kleine Auswahlstabilität verhindert Flackern zwischen gleichwertigen Zielen.
- Das aktive Ziel wird sichtbar hervorgehoben und über einen kompakten HUD-Hinweis mit Name, Aktion und Eingabe kommuniziert.
- P0 verwendet die zentrale Eingabeaktion `interact` (Standard: E).
- Die drei Testaktionen sind Pickup, Inspect und Use.
- Vor Ausführung wird die Gültigkeit des Ziels erneut geprüft.
- Die konkrete Aktion und deren fachliche Voraussetzungen liegen beim Zielobjekt; UI entscheidet nicht über Gameplay-Regeln.
- Reichweiten, Auswahlgewichtung und Hervorhebungsdarstellung werden im Blockout abgestimmt.

**Begründung:** Reichweitenbasierte Interaktion passt zur isometrischen Perspektive und vermeidet pixelgenaues Anvisieren. Die Trennung von Kandidatenerkennung, Zielauswahl, Darstellung und Zielaktion hält die Architektur verständlich und erweiterbar.

Referenz: [P0-PlayerInteractor-Spezifikation](p0-interaction-controller.md).


## 25.11.2026 — P0-Gameplay-Blockout als Old-Yard-Testgrundlage

**Beschluss:** Der gemeinsame P0-Bedienungstest verwendet einen vereinfachten Blockout des Old Yard statt einer unabhängigen Testarena.

- Ausgangspunkt sind die vorläufigen Grundstücksmaße 48 × 36 m, das 1-m-Raster und die fünf Funktionszonen aus der bestehenden Grundstücksplanung.
- P0 ergänzt nur die Geometrie, die für Bewegung, Kollision, Kamera und Interaktion benötigt wird.
- Drei funktionale Testobjekte prüfen Pickup, Inspect und Use.
- Große, nicht-interaktive Volumen prüfen Sichtbarkeit, Kameralesbarkeit und Kollision.
- Reproduzierbare Testabläufe prüfen Erststart, Bewegung, Kamera/Zoom, Zielauswahl, Interaktionen und minimale Persistenz.
- Die Grundstücksmaße bleiben bis zum erfolgreichen Blockout-Test vorläufig.
- P0 enthält weiterhin keine Wirtschaft, Scrappy-Story, Maschinen, Mitarbeiter oder vollständigen Baumodus.

**Begründung:** Die grundlegende Steuerung soll in einem räumlichen Ausschnitt getestet werden, der später tatsächlich zum Spiel gehört. Dadurch können Probleme mit Wegen, Sichtachsen und Objektgrößen früh erkannt werden, ohne bereits Produktionsassets zu erstellen.

Referenz: [P0-Gameplay-Blockout](p0-gameplay-blockout.md).


## 25.11.2026 — P0-Systemintegration und Datenfluss

**Beschluss:** Die P0-Systeme werden über explizite Verantwortlichkeiten und begrenzte Kommunikationswege verbunden.

- GameSession ist die sitzungsweite Quelle des P0-Spielzustands und koordiniert Neues Spiel, Fortsetzen und Speicheranforderungen.
- SaveService übernimmt ausschließlich Dateizugriff, JSON-Serialisierung, Versionsprüfung und Validierung. Er kennt keine Gameplay-Nodes und lädt keine Szenen.
- MainMenuController kommuniziert für Start- und Fortsetzen-Abläufe mit GameSession; es verwaltet keinen eigenen Spielzustand.
- OldYardTest stellt Laufzeitobjekte aus den Sitzungsdaten her und erstellt bei Speicheranforderungen einen Datensnapshot.
- PlayerController, GameplayCameraController und PlayerInteractor behalten getrennte Verantwortlichkeiten und kommunizieren über explizite lokale Referenzen.
- InteractionDetector erkennt Kandidaten; PlayerInteractor wählt und löst Aktionen aus; das Zielobjekt verantwortet seine konkrete Aktion.
- HUD und DebugOverlay bleiben reine Darstellung und Diagnose.
- Persistenz verwendet versionierte einfache Daten und stabile Objekt-IDs, niemals serialisierte Nodes oder Szenenbäume.
- Es wird kein globaler SceneManager, Event-Bus oder Service-Locator eingeführt.
- Für den P0-Persistenztest ist eine temporäre Entwickler-Speicheraktion vorgesehen; automatisches Speichern beim Beenden ist nicht vorausgesetzt.

**Begründung:** Die vorhandenen Einzelspezifikationen benötigen einen klaren gemeinsamen Ablauf. Explizite Datenübergaben und wenige Dienste halten P0 testbar und verhindern, dass die technische Grundlage bereits vor dem ersten Gameplay-Prototyp unnötig komplex wird.

Referenz: [P0-Systemintegration und Ablauf](p0-system-integration.md).


## 25.11.2026 — P0-Implementierungsstruktur und Reihenfolge

**Beschluss:** Die P0-Umsetzung folgt einer konkreten, schlanken Godot-Projektstruktur und wird in überprüfbaren Phasen aufgebaut.

- Szenen, Scripts, UI und Prototypdaten erhalten getrennte, nachvollziehbare Ordner.
- Main, MainMenu, MenuBackdrop, OldYardTest, Player und GameplayCamera bleiben eigenständige Szenen mit klaren Aufgaben.
- PlayerController sitzt auf CharacterBody3D; GameplayCameraController auf dem Kamera-Rig; PlayerInteractor bleibt Kind des Players.
- Ein CameraAnchor am Player stellt den expliziten Follow-Referenzpunkt bereit.
- GameSession und SaveService sind die einzigen P0-Autoloads; SaveService wird vor GameSession registriert.
- Input Map enthält ausschließlich die für P0 erforderlichen Bewegungs-, Interaktions-, Zoom- und temporären Debug-Speicheraktionen.
- Die Implementierung erfolgt nacheinander: Projektbasis, Menü/Einstieg, Spieler/Kamera, Interaktion, Zustand/Persistenz, Integration/Blockout-Abnahme.
- Jede Phase besitzt konkrete Abnahmekriterien. Unfertige oder leere Architekturbausteine werden nicht vorsorglich angelegt.
- Es wird weiterhin kein GDScript implementiert, bevor die ausdrückliche Freigabe zur Umsetzung erfolgt.

**Begründung:** Die Einzelspezifikationen sind nun ausreichend konkret, um eine reproduzierbare Projektstruktur und einen kontrollierten Implementierungsablauf festzulegen. Die phasenweise Umsetzung verhindert, dass Fehler aus mehreren gleichzeitig entstehenden Systemen schwer zuzuordnen sind.

Referenz: [P0-Implementierungs- und Projektstruktur](p0-implementation-readiness.md).


## 25.11.2026 — P0-Umsetzung: technische Implementierungsentscheidungen

**Kontext:** Bei der Umsetzung von P0 mussten einzelne, in den Spezifikationen bewusst offen gelassene Implementierungsdetails festgelegt werden. Es handelt sich um technische Ergänzungen, nicht um Änderungen an beschlossenen Spielmechaniken.

- **Weltkoordinaten:** Die Layoutkoordinaten der Blockout-Dokumente (X = Ost, Z = Nord) werden in Godot als `Welt-X = Layout-X`, `Welt-Z = −Layout-Z` abgebildet. Godot ist rechtshändig mit −Z als Vorwärtsrichtung; eine 1:1-Übernahme hätte das Grundstück gespiegelt (Osten links von Norden). Norden ist damit −Z, wie in Godots Draufsicht. Die Dokumentkoordinaten bleiben unverändert gültig.
- **Kamera-Yaw:** Der Startwert „45°“ wird als −45° umgesetzt (Blick nach Nordosten über das Grundstück, Einfahrt unten im Bild). Pitch −35°, Orthographic Size 14, Zoom 9–19, Follow 8,0 und Zoom-Glättung 10,0 entsprechen den Startwerten.
- **Physik-Backend:** Das Projekt verwendet explizit das in Godot integrierte Backend „Jolt Physics“ mit `areas_detect_static_bodies = true`. Mit dem Standard-Backend meldete `Area3D` im Test keine `StaticBody3D`-Ziele; die Spezifikation sieht StaticBody3D-Interaktionsziele und einen Area3D-Detector vor. Es wird keine externe Abhängigkeit eingeführt.
- **Kollisionslayer:** 1 = `world` (Levelgeometrie, Stationen), 2 = `player`, 3 = `interactable`. Spieler: Layer 2, Maske 1. InteractionDetector: Layer 0, Maske 3. Große Interaktionsobjekte liegen zusätzlich auf Layer 1.
- **Physik-Interpolation** ist aktiviert; Spieler und Kamera-Rig bewegen sich im Physik-Update, die Darstellung wird interpoliert.
- **Interaktionsvertrag:** `Interactable` ist eine kleine Basisklasse (`class_name`) auf `StaticBody3D`. Abhängigkeiten für Aktionen erhält das Ziel über ein explizites `InteractionContext`-Objekt statt über globale Node-Suche.
- **Hervorhebung:** Ein pulsierender, unbeleuchteter Bodenring am Interaktionspunkt; Materialien der Objekte werden nicht verändert.
- **Einstellungen:** Implementiert sind nur Sprache (Deutsch/English) und Anzeigemodus (Fenster/Vollbild). Sie sind spielstandübergreifend und werden von SaveService in einer separaten Datei `user://settings.json` gespeichert, nicht im Spielstand. Grund: Einstellungen müssen bereits im Hauptmenü ohne Spielstand gelten.
- **Lokalisierung:** Godot-CSV-Übersetzung `localization/scrapstead.csv` (en/de, Fallback en). Controls verwenden Lokalisierungsschlüssel als Text. Ausnahme: Das DebugOverlay ist entwicklerseitig und nicht lokalisiert.
- **Logo:** Temporärer Schriftzug (lokalisierter Label-Schlüssel) mit Zahnrad-Icon statt einer Logo-Bilddatei.
- **Debug-Eingaben:** Zusätzlich zu `debug_save` (F5) gibt es `debug_toggle_overlay` (F3), da das Overlay laut Integrationsspezifikation zur Laufzeit ein-/ausblendbar sein soll. Beide wirken nur in Debug-Builds.
- **Blockout-Erzeugung:** Die Old-Yard-Geometrie und die Platzhaltermodelle werden reproduzierbar durch das Entwicklungswerkzeug `tools/build_blockout.gd` erzeugt. Die erzeugten Szenen werden versioniert, aber nicht von Hand bearbeitet.
- **Tests:** Ein schlanker eigener Headless-Testrunner (`tests/run_tests.gd`) ohne externe Abhängigkeiten führt Unit- und Integrationstests aus.

**Begründung:** Die Festlegungen schließen offene Implementierungsdetails, ohne Verantwortlichkeiten, Szenenarchitektur oder Spielmechaniken zu verändern.


## 25.11.2026 — P1-Umsetzung: erste Gameplay-Schleife

**Kontext:** P0 ist umgesetzt und getestet. P1 ergänzt Sammeln, Bergen, Verkauf, Credits, ein Upgrade und spielerseitiges Speichern. Die folgenden Punkte sind minimale Implementierungsentscheidungen innerhalb des freigegebenen P1-Umfangs; sie ersetzen keine bestehenden Designentscheidungen.

- **Objektauswahl:** Lose Kleinteile `scrap_rusted_bolt`, `scrap_empty_can`, `scrap_wire_coil` (je 2 Instanzen) und der Metallträger `bulk_metal_beam` als Bergungsobjekt – alle aus der Prioritätsliste des Startkatalogs.
- **Prototypwerte:** 3 / 2 / 7 / 20 Credits, Grundkapazität 4 Plätze, Träger 3 Plätze, Großer Tragekorb 30 Credits für +4 Plätze. Die Werte liegen ausschließlich in Resources unter `data/` und gelten als Playtest-Startwerte, nicht als Balancing.
- **Tragekapazität in Plätzen** statt Gewicht: einfachste verständliche Regel; größere Objekte belegen mehrere Plätze.
- **Bergung als Halte-Aktion** (2,5 s) mit sichtbarer Voraussetzung (freie Plätze) statt eines Werkzeugs. Ein Werkzeugsystem bleibt späteren Stufen vorbehalten.
- **Verkauf der gesamten Ladung** pro Vorgang; doppelte Buchungen werden über Transaktions-IDs, Inventar-Revision und gesperrte Bestätigung verhindert.
- **Ablegen (Q)** des zuletzt aufgenommenen Teils als minimale Inventarverwaltung; die Position wird gespeichert.
- **Spielerseitiges Speichern** über ein Pausemenü (Esc). F5 bleibt Entwickleraktion. Automatisches Speichern wird weiterhin nicht eingeführt.
- **Spielstandschema Version 2** mit `wallet`, `inventory`, `upgrades`. Version-1-Stände werden als inkompatibel abgelehnt (keine stille Migration; es existieren keine Spielerstände aus P0).
- **P0-Pickup-Testobjekt** wurde durch das allgemeine `ScrapItem` ersetzt (die Schraube an derselben Stelle). Hinweisbrett (Inspect) und Hofstrahler (Use) bleiben als P0-Interaktionen erhalten.
- **Laufzeitsysteme** (`Wallet`, `CarryInventory`, `UpgradeProgress`) sind kleine Objekte der Gameplay-Szene; es entstehen keine weiteren Autoloads, Manager oder Event-Busse.

Referenz: [P1: Erste Gameplay-Schleife](p1-gameplay-loop.md).


## 25.11.2026 — P1b: Optionale Zerlegung des defekten Radios

**Beschluss:** P1b wird mit genau einer Verarbeitung umgesetzt und bleibt optional.

- Eingabe: `device_broken_radio` (Direktverkauf 12 Cr, 2 Plätze), Fundort Lagerzone A.
- Station: Zerlegetisch in der freien Arbeitsfläche D; Aufwand 3,5 s Halten.
- Ausgaben: `mat_copper_wire` und `mat_electronic_parts` (je 8 Cr, je 1 Platz) – zusammen 16 Cr.
- Rezept als Resource `ProcessingProfile` (`data/processing/`), höchstens zwei Ausgaben.
- Die Ausgaben sind vorbereitete Weltplatzierungen mit stabilen IDs (Zustand `pending`), damit Speicherung und Verkauf ohne neues System funktionieren.
- Direktverkauf bleibt möglich und ist für das Upgrade nicht nötig.

**Begründung:** Die Verarbeitung soll eine verständliche Entscheidung zwischen schnellem Direktverkauf und mehr Ertrag für mehr Aufwand zeigen, ohne Produktionsketten oder Lagerlogistik einzuführen. Die Bewertung des Mehrwerts erfolgt im Playtest.

Referenz: [Prototyp-Abnahme](prototype-acceptance.md).


## 25.11.2026 — P1-Vertiefung: Bestellkatalog, Werkzeuge, Suchquellen, Inspektion

**Kontext:** Nach dem ersten Anspielen bewertet die Projektleitung das Spielgefühl als gut. P1 gilt aber noch nicht als spielerisch freigegeben; die Schleife wird vor P2 vertieft.

**Beschluss (Projektleitung):**

- Suchquellen, ein erstes Werkzeug, ein zweites Transport-Upgrade und Objekt-Inspektion werden ergänzt.
- Werkzeuge, Ausrüstung und Transportmittel werden **im Büro über einen Bestellkatalog gekauft** („Hinterhof-Versand“). Die **Werkbank dient später dem Herstellen**; Crafting wird erst in einer späteren Stufe umgesetzt, bis dahin ist die Werkbank nur untersuchbar.
- Der Metallträger erfordert ein **Hebemittel (Flaschenzug)**; der **Handkarren** ist das separate zweite Transport-Upgrade und setzt den Großen Tragekorb voraus.
- Alle neuen Texte folgen der Humoridentität von Scrapstead.

**Implementierungsentscheidungen:**

- Brechstange 12 Cr, Großer Tragekorb 30 Cr, Flaschenzug 25 Cr, Handkarren 40 Cr (+4 Plätze). Werte sind Playtest-Startwerte.
- Vier einmalige Suchquellen mit festgelegtem Inhalt; zwei davon erfordern die Brechstange. Funde fallen sichtbar vor die Quelle, keine Zufallsverteilung, keine Regeneration (Matrix: Regeneration erst Phase 4–5).
- Gekaufte Ware erscheint sofort an einer Lieferstelle vor dem Büro; das HUD zeigt besessene Werkzeuge.
- Inspektion über eine zweite Eingabe (R); sie verändert nie den Zustand.
- Spielstandschema bleibt Version 2, da nur neue IDs und Zustandswerte hinzukommen.

Referenz: [P1: Erste Gameplay-Schleife, Abschnitt 14](p1-gameplay-loop.md).


## 25.11.2026 — Art Direction „Walts Flickwerk-Diorama“ und Blender-Pipeline

**Beschluss (Projektleitung):** Scrapstead erhält einen eigenen, unverwechselbaren und professionellen Grafikstil, passend zu Witz und Charme des Spiels. Als erster Schritt wird ein Art-Direction-Prototyp umgesetzt.

- Leitidee: Miniatur-Diorama eines Schrottplatzes, auf dem alles schon einmal repariert wurde. Walts Flicken, Klebeband und zweckentfremdete Teile sind das visuelle Erkennungsmerkmal; neue Dinge sind sauber und gerade, damit Fortschritt sichtbar wird.
- Toon-Shading mit drei Lichtstufen, pflaumenfarbenen Schatten, warmem Lichtsaum und dunkelbraunen Umrissen; dezenter Tilt-Shift-Effekt.
- Keine Bildtexturen, sondern eine feste Palette als Vertex-Farben bzw. Shaderparameter.
- Modelle entstehen reproduzierbar per Python-Skript in Blender 4.2 und werden als glTF importiert; Godot ersetzt das Exportmaterial beim Import durch das gemeinsame Toon-Material.
- Figuren mit hohem Charakteranspruch, Animation, Key Art und finales Logo sollen später durch menschliche Artists entstehen oder verfeinert werden.

**Technische Entscheidungen:** Gebäude und Deko des Hofs werden als Modellinstanzen in den generierten Blockout eingebunden; Kollisionen bleiben einfache Boxen. Benannte Zustandsgruppen (`Closed`, `Open`, `Beam`, `Debris`) kommen direkt aus Blender. Meshes werden pro Gruppe zusammengefasst, um Draw Calls zu begrenzen.

Referenz: [Art Direction](world-art-assets.md).
