# Scrapstead — Gebäude- und Modulsystem

## Ziel und Leitgedanke

Das Gebäudesystem kombiniert sofort nutzbare Fertiggebäude mit einem modularen Konstruktionssystem.

- Spieler, die schnell bauen möchten, kaufen und platzieren fertige Gebäude.
- Spieler, die gerne gestalten, bauen eigene Gebäude aus einzelnen Bauteilen.
- Fertiggebäude sind keine unveränderlichen Objekte. Sie können umgebaut, erweitert und optisch angepasst werden.

**Grundsatz: Schnell startklar sein oder selbst gestalten können – beides muss gleichwertig möglich sein.**

## 1. Zwei Bauvarianten

### Fertiggebäude

Fertiggebäude werden als vollständige Konstruktion ausgewählt und auf dem Grundstück platziert.

Mögliche Gebäudetypen:

- Werkstatt
- Lagerhalle
- Bürogebäude
- Maschinenhalle
- Verkaufsgebäude
- Überdachungen und Unterstände

Fertiggebäude bieten einen schnellen Einstieg und können bereits eine sinnvolle Grundstruktur mitbringen. Sie sollen dem Spieler keine gestalterische Sackgasse bieten.

### Modularer Gebäudebau

Eigene Gebäude entstehen aus einzelnen Bauteilen.

Vorgesehene Modulgruppen:

- Fundamente und Böden
- Wände und Wandsegmente
- Fenster und Türen
- Dächer und Dachkonstruktionen
- Tore und Hallenöffnungen
- Treppen und Podeste
- Innenausstattung und Einrichtung

Der Umfang und die Vielfalt der Module können mit dem Spielfortschritt wachsen.

## 2. Fertiggebäude verändern und erweitern

Auch ein fertig gekauftes Gebäude soll nachträglich angepasst werden können.

Mögliche Änderungen:

- Türen und Fenster austauschen oder ergänzen
- Räume anbauen
- Dächer verändern
- Überdachungen ergänzen
- Außenbereiche gestalten
- Fassaden und Materialien anpassen
- Innenräume einrichten

Ein Fertiggebäude ist ein vollständiger Ausgangspunkt, aber kein unveränderlicher Gegenstand.

## 3. Modulare Verbindungen und Einrasten

Bauteile besitzen passende Verbindungspunkte. Das Snap-System unterstützt den Spieler beim Zusammensetzen.

- Wandmodule rasten an geeigneten Fundamenten und anderen Wänden ein.
- Türen und Fenster können in passende Wandöffnungen eingesetzt werden.
- Dachmodule erkennen geeignete Wand- und Dachanschlüsse.
- Eckelemente verbinden Wandabschnitte sauber.
- Module können vor der Platzierung gedreht werden.
- Ungültige Kombinationen werden bereits in der Vorschau erkannt.

Einrasten soll die Konstruktion vereinfachen, nicht die Gestaltungsfreiheit unnötig einschränken. Wo es sinnvoll ist, kann der Spieler die automatische Ausrichtung umgehen oder feinere Positionierungen nutzen.

### Bauliche Plausibilität

Module müssen sinnvoll zusammenpassen. Das System prüft beispielsweise:

- ob ein Modul einen passenden Anschluss besitzt
- ob Wand- und Dachsegmente geometrisch zusammenpassen
- ob Öffnungen und eingesetzte Elemente kompatibel sind
- ob Konstruktionen ausreichend gestützt sind, sofern das Spiel später ein solches Stabilitätssystem verwendet

Ein komplexes Statik- oder Ingenieursystem ist für den ersten Prototyp ausdrücklich nicht vorgesehen.

## 4. Konstruktion, Funktion und Gestaltung trennen

Gebäude werden in drei konzeptionelle Ebenen gegliedert:

| Ebene | Inhalt |
|---|---|
| Konstruktion | Fundamente, Böden, Wände, Dächer und Öffnungen |
| Funktion | Werkstatt, Lager, Büro, Produktion und andere Nutzungen |
| Gestaltung | Farben, Materialien, Fenster, Fassaden und Dekoration |

Die Funktion eines Gebäudes soll nicht automatisch von seiner Optik abhängen.

Beispiel: Ein Lager bleibt funktional ein Lager, unabhängig davon, ob es aus Holz, Blech oder Ziegeln gebaut wurde.

Unterschiedliche Materialien können später zusätzliche Eigenschaften wie Baukosten, Haltbarkeit oder Witterungsschutz erhalten. Diese Eigenschaften sind kein notwendiger Bestandteil des ersten Prototyps.

## 5. Innenräume

Gebäude sollen nicht nur als äußere Kulisse existieren. Geschlossene Gebäude können betreten und genutzt werden.

Mögliche Funktionen:

- Maschinen und Werkbänke im Innenraum aufstellen
- Material in Innenlagern aufbewahren
- Räume funktional einrichten
- Zugang über Türen und Tore
- Produktionsketten in größeren Hallen aufbauen

Die Innenraumdarstellung und Kameraübergänge müssen so gestaltet werden, dass der Spieler die Übersicht behält. Die konkrete technische Lösung – beispielsweise Ausblenden von Dachteilen oder ein transparenter Schnitt – bleibt offen.

## 6. Fortschritt, Einstieg und Freischaltungen

Das Gebäudesystem wächst mit dem Betrieb. Die umfangreichen Gestaltungsoptionen sind bewusst nicht alle von Beginn an verfügbar.

**Designregel: Erst den Spieler ins Spiel ziehen, dann nach und nach mehr kreative Möglichkeiten eröffnen.**

Der Spielstart konzentriert sich auf die unmittelbare Kernschleife:

- das Grundstück erkunden
- Schrott sammeln und verkaufen
- erste Werkzeuge und Arbeitsabläufe kennenlernen
- Scrappy entdecken und wiederherstellen
- die vorhandene Werkstatt und vorhandene Einrichtungen nutzen
- erste sichtbare Verbesserungen am Betrieb erreichen

Zu Beginn soll der Spieler keine umfangreiche Bauteilbibliothek, Materialverwaltung oder komplexe Gestaltungsoberfläche vor sich haben.

### Vorgeschlagene Freischaltungsfolge

| Fortschrittsphase | Neue Möglichkeiten |
|---|---|
| Spielstart | Vorhandene Gebäude nutzen, einfache Objekte und fertige Einrichtungen platzieren |
| Erste Betriebserweiterung | Weitere Fertiggebäude, einfache Überdachungen und funktionale Anbauten |
| Ausbau | Erste modulare Fundamente, Böden, Wände und Dachsegmente |
| Etablierter Betrieb | Mehr Bauteilvarianten, Türen, Fenster und größere Raumaufteilungen |
| Fortgeschrittener Betrieb | Material- und Farbvarianten, Fassaden und Beleuchtung |
| Später Betrieb | Umfangreiche Einrichtung, Dekoration, Baupläne und individuelle Gestaltung |

Die Reihenfolge ist ein Progressionsvorschlag. Konkrete Freischaltzeitpunkte, Preise und Voraussetzungen werden anhand des First-Hour-Prototyps und späterer Spieltests festgelegt.

### Freischaltungen in der Spielwelt vermitteln

Neue Möglichkeiten sollen möglichst organisch in der Welt auftauchen:

- Ein Handwerker oder Händler bietet eine neue Gebäudeerweiterung an.
- Ein NPC stellt ein neues Modul oder eine neue Bauteilgruppe vor.
- Scrappy weist gelegentlich auf eine neu verfügbare Möglichkeit hin.
- Eine Investition oder ein sichtbarer Fortschritt eröffnet eine passende Erweiterung.

Die Hinweise sollen hilfreich sein, aber den Spielfluss nicht mit dauernden Pop-ups unterbrechen.

### Keine künstlichen Kreativitätsbarrieren

Die schrittweise Freischaltung dient dem Lern- und Belohnungsrhythmus, nicht dazu, grundlegende Aktionen unnötig zu sperren.

- Der Spieler kann früh sinnvolle funktionale Erweiterungen vornehmen.
- Freigeschaltete Grundfunktionen bleiben dauerhaft verfügbar.
- Neue Inhalte erweitern die Auswahl, statt bereits gebaute Dinge zu entwerten.
- Der Spieler soll nicht erst zahlreiche Level aufsteigen müssen, um eine einfache Tür oder einen zweckmäßigen Anbau zu bauen.

### Gemeinsame Bauteilbibliothek mit begrenztem Aufwand

Alle modularen Gebäudeteile verwenden ein gemeinsames Bau- und Verbindungssystem.

- Bauteile werden in wiederverwendbaren Kategorien und Varianten organisiert.
- Fertiggebäude und modulare Konstruktionen nutzen möglichst dieselben Bauteile und Materialdefinitionen.
- Farben und Materialoberflächen sollen nach Möglichkeit über gemeinsame Materialvarianten statt über individuelle Gebäudesysteme gesteuert werden.
- Funktionen und Gestaltung bleiben getrennt.
- Neue Varianten sollen sich in die bestehende Bibliothek einfügen, ohne für jedes Gebäude ein eigenes Anpassungssystem zu benötigen.

Die gemeinsame Bibliothek ist eine technische und gestalterische Grundlage. Sie muss dem Spieler nicht bereits zu Spielbeginn vollständig offengelegt werden.

## 7. Baupläne und Wiederverwendung

Als Komfort- und Langzeitfunktion soll der Spieler eigene Konstruktionen als Baupläne speichern können.

Vorgesehene Möglichkeiten:

- selbst gebaute Gebäude als Bauplan speichern
- gespeicherte Baupläne wiederverwenden
- Gebäude als Vorlage kopieren und an anderer Stelle platzieren
- Baupläne später exportieren oder mit anderen Spielern teilen

Beim Platzieren eines Bauplans prüft das Spiel erneut Grundstücksgrenzen, Kosten, verfügbare Bauteile und funktionale Anforderungen. Fehlende Voraussetzungen werden vor dem Bau angezeigt.

Der Austausch von Bauplänen ist eine mögliche Grundlage für spätere Community-Funktionen, aber kein Bestandteil des ersten Prototyps.

## 8. Verhältnis zum allgemeinen Bausystem

Das Gebäude- und Modulsystem verwendet dieselben übergeordneten Prinzipien wie der übrige Baumodus:

- freie Platzierung innerhalb der Grundstücksgrenzen
- transparente Vorschau
- verständliche Prüfung funktionaler und baulicher Anforderungen
- automatische Ausrichtung an passenden Verbindungspunkten
- Drehen, Verschieben und Entfernen
- Rückgängig und Wiederholen
- klare Rückmeldung bei ungültigen Kombinationen

Die Gebäudeplatzierung soll sich deshalb nicht wie ein völlig separates Minispiel anfühlen.

## 9. Prototyp-Umfang

Für einen ersten aussagekräftigen Prototyp reichen:

- ein platzierbares Fertiggebäude, beispielsweise eine kleine Werkstatt
- ein kleiner Satz modularer Fundamente und Böden
- einige Wandsegmente und Eckelemente
- eine Tür und ein Fenster
- einfache Dachmodule
- Snap-Verbindungen zwischen kompatiblen Teilen
- die Möglichkeit, das Fertiggebäude zu verändern oder zu erweitern
- ein nutzbarer Innenraum mit mindestens einer platzierbaren Einrichtung

Bauplanspeicherung, umfangreiche Materialeigenschaften, Statik und Community-Austausch bleiben spätere Ausbaustufen.

## 10. Offene Entscheidungen

Folgende Punkte müssen durch Design- und Prototyp-Tests geklärt werden:

- Rastergröße und Maßstab der Gebäudemodule
- erlaubte Winkel und Sonderformen
- Umgang mit unvollständigen oder offenen Gebäuden
- Innenraumkamera und Darstellung verdeckender Bauteile
- Kostenmodell für Fertiggebäude und Einzelmodule
- welche Fertiggebäude bereits mit Funktionen ausgestattet sind
- ob und in welchem Umfang Materialien funktionale Eigenschaften besitzen
- Umfang und Format gespeicherter Baupläne

## Zusammenfassung

Scrapstead kombiniert Fertiggebäude mit einem modularen Gebäudebaukasten. Fertiggebäude ermöglichen einen schnellen Einstieg, während modulare Bauteile individuelle Konstruktionen erlauben. Auch fertige Gebäude können umgebaut und erweitert werden. Ein intelligentes Snap-System unterstützt den Bau, ohne dem Spieler die Gestaltung abzunehmen.

**Schnell bauen können. Frei gestalten können. Jederzeit umbauen können.**
