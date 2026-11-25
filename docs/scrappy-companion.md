# Scrappy — Begleiter- und modularer Roboter-Spezifikation

**Version:** 0.2  
**Status:** Konzept  
**Zugehörige Hintergrundgeschichte:** [Walt Wren und die Geschichte hinter dem Schrottplatz](lore-walt-wren.md)

## 1. Charakterkonzept

Scrappy ist ein liebenswerter, eigenwilliger und etwas in die Jahre gekommener Schrottplatzroboter. Der Spieler findet zunächst nur seinen Kopf unter einem Schrotthaufen. Eine besondere Kernkomponente aus dem roten Werkzeugkasten stellt seine grundlegenden Systeme wieder her. Anschließend baut der Spieler Scrappy nach und nach aus gefundenen Schrottteilen zusammen.

Scrappy ist Begleiter, Helfer, gelegentlicher Guide, Kommentator und das emotionale Gesicht von Scrapstead.

Scrappy wurde von Walter „Walt“ Wren gebaut und über lange Zeit erweitert. Ursprünglich war er als praktischer Helfer gedacht, entwickelte sich aber zum persönlichen Begleiter seines Erbauers. Scrappy erinnert sich an Walt und den Schrottplatz, sein Speicher ist nach dem Unfall jedoch unvollständig.

## 2. Persönlichkeit

- Loyal, neugierig und grundsätzlich hilfsbereit.
- Im Alltag trocken, sachlich und gelegentlich besserwisserisch.
- Kann überraschend frech, bissig oder überschwänglich reagieren, wenn eine Situation ihn aus der Fassung bringt.
- Selbstbewusst bis zur gelegentlichen Selbstüberschätzung; er hält sich für deutlich kompetenter, als es seine tatsächlichen Fähigkeiten immer rechtfertigen.
- Stolz auf seine improvisierte Konstruktion und seine vermeintlich herausragende technische Expertise.
- Er besitzt eine eigene Meinung und äußert sie gelegentlich ungefragt, ohne zum permanenten Kommentator zu werden.
- Seine Persönlichkeit bleibt unabhängig von den eingebauten Komponenten.
- Er bezeichnet sich gern als technischen Leiter des Schrottplatzes und stellt Walts frühere Rolle gelegentlich etwas eigenwillig dar.
- Hinter der frechen Fassade ist er herzlich, loyal und emotional verletzlich.

Scrappy darf den Spieler necken, aber niemals herabsetzen. Seine Kommentare sollen Situationen bereichern, nicht den Spielfluss unterbrechen. Sein Humor lebt von Kontrasten: trockene Sachlichkeit, plötzliche Ausbrüche und unerwartet ehrliche oder stille Momente.

## 3. Modularer Aufbau

Vorgesehene Modulplätze:

- Kopf / Gesicht.
- Körper.
- Fortbewegung.
- Linkes Werkzeug / linker Arm.
- Rechtes Werkzeug / rechter Arm.
- Sensoren / Antenne.
- Kosmetische Accessoires.

Die erste Version verwendet klare Anschlusspunkte und kompatible Modulkategorien statt eines vollständig freien Physik-Bausystems.

## 4. Teile und Attribute

Jedes Teil kann folgende Daten definieren:

- Stabile ID und Lokalisierungsschlüssel für Name und Beschreibung.
- Slot-Typ.
- Visuelles Modell.
- Funktionale Tags.
- Gameplay-Effekt, falls vorhanden.
- Seltenheit / Fundquelle.
- Freischaltbedingungen.
- Optionale Dialog-Tags.

Teile können auf dem Schrottplatz gefunden, durch Fortschritt verdient oder bei besonderen Ereignissen erhalten werden. Pay-to-win-Mechaniken sind nicht vorgesehen.

## 5. Nützliche, alberne und kosmetische Konstruktionen

Konstruktionen können sein:

- Funktional: Ein Magnetarm hilft beim Sammeln von Metall.
- Zweckorientiert: Ein größerer Körper erhöht die Transportkapazität.
- Mobilitätsbezogen: Räder oder Ketten verändern die Fortbewegung.
- Albern: Unterschiedliche Räder, übergroße Antennen oder ein Kühlschrank als Körper.
- Kosmetisch: Farbe, Aufkleber, Hüte und ungewöhnliche Accessoires.

Ein Teil muss nicht optimal sein, um interessant zu sein. Humor und Selbstausdruck sind zentrale Ziele.

## 6. Fähigkeiten

Scrappy erhält Fähigkeiten, wenn der Spieler passende Teile findet und Fortschrittsmeilensteine erreicht. Beispiele:

- Nahegelegene wertvolle Gegenstände hervorheben.
- Ausgewählte Kleinteile einsammeln.
- Eine kleine Ladung transportieren.
- An einer kompatiblen Station assistieren.
- Besondere Objekte oder versteckte Fundorte erkennen.

Fähigkeiten müssen einfach verständlich bleiben und dürfen den Spieler nicht überflüssig machen.

## 7. Reaktionen, Eigeninitiative und Dialoge

### Eigenständigkeit und Initiative

Scrappy ist kein passives Werkzeug, das ausschließlich auf Eingaben des Spielers wartet. Er soll den Eindruck vermitteln, auch unabhängig vom Spieler eine eigene kleine Existenz zu führen.

Mögliche Verhaltensweisen:

- Interessante Gegenstände, Maschinen oder Veränderungen in der Umgebung selbstständig untersuchen.
- Den Spieler gelegentlich auf ungewöhnliche Fundstücke, Gefahren oder bemerkenswerte Details aufmerksam machen.
- An passenden Stellen kleine eigene Tätigkeiten oder Projekte verfolgen, etwa ein Fundstück genauer untersuchen oder versuchen, ein herumliegendes Teil zu identifizieren.
- Auf bereits erlebte Situationen zurückkommen und frühere Entscheidungen oder wiederkehrende Fehler des Spielers kommentieren.
- Eigene kleine Vorlieben, Vermutungen und Interessen zeigen, ohne wichtige Spielhandlungen eigenmächtig auszuführen.

Scrappys Initiative bleibt unterstützend und darf weder Kontrolle noch Entdeckungsfreude des Spielers ersetzen. Er nimmt keine wichtigen Gegenstände ungefragt an sich, löst keine kritischen Aufgaben selbstständig und drängt sich nicht dauerhaft in den Vordergrund. Häufigkeit und Intensität seiner Aktionen müssen zurückhaltend und konfigurierbar bleiben.

### Timing und Kommunikationsformen

Scrappys Kommunikation wird in drei grundlegende Formen gegliedert:

- **Situative Kommentare:** kurze Reaktionen auf Aktionen, Konstruktionen, Funde, Maschinen und Ereignisse.
- **Initiative Kommentare:** gelegentliche eigene Gesprächsanfänge oder Hinweise, wenn Scrappy etwas Interessantes bemerkt oder mitteilen möchte.
- **Erinnerungsmomente:** besondere Reaktionen auf Orte, Gegenstände und Situationen, die Erinnerungen an Walt oder Scrappys Vergangenheit auslösen.

Nicht jede Aktion benötigt eine Reaktion. Stille ist ein bewusst eingesetztes Gestaltungsmittel. Kommentare müssen abwechslungsreich sein, Wiederholungen vermeiden und dürfen den Spielfluss nicht stören.

Scrappy kann kontextbezogen reagieren auf:

- Neue Teile und ungewöhnliche Kombinationen.
- Seltene Entdeckungen.
- Den ersten Mitarbeiter und neue Maschinen.
- Maschinenpannen.
- Meilensteine des Spielers.
- Die Rückkehr zum Schrottplatz.
- Orte und Gegenstände, die Erinnerungen an Walt auslösen.

### Erinnerungen an Walt

Scrappys Speicher ist nach dem Unfall unvollständig. Erinnerungen können durch Orte, Werkzeuge, Maschinen und bestimmte Gegenstände ausgelöst werden.

- Erinnerungen erzählen kleine Geschichten statt langer Lore-Monologe.
- Sie können humorvoll, herzlich oder gelegentlich nachdenklich sein.
- Scrappy darf Details verwechseln oder seine eigene Rolle überhöhen.
- Widersprüche müssen als beschädigte Erinnerung oder Charakterzug erkennbar bleiben.
- Erinnerungen ergänzen Walts Charakter, statt ihn nachträglich zu verändern.
- Optionale Erinnerungen dürfen keine grundlegenden Spielfunktionen blockieren.

### Dialogregeln

- Dialoge sind kontextbezogen, abwechslungsreich und möglichst überspringbar.
- Wiederholungen werden durch Varianten und Wiederholungsabstände begrenzt.
- Nicht jede Aktion benötigt einen Kommentar.
- Emotionale Momente dürfen ohne Pointe stehen bleiben.
- Deutsch und Englisch sollen denselben Charakter und dieselbe Wirkung transportieren; Wortspiele dürfen lokal angepasst werden.

## 8. Visuelles Design

- Klobige, gut lesbare Silhouette.
- Wiederverwendete Schrottmaterialien und nicht zusammenpassende Komponenten.
- Ausdrucksstarke Augen beziehungsweise Gesichtselemente.
- Leicht unbeholfene Bewegung und mechanische Eigenheiten.
- Gute Erkennbarkeit aus der isometrischen Kameradistanz.
- Der modulare Aufbau soll sichtbar und charmant wirken, nicht wie ein beliebiger Roboter-Baukasten.

## 9. Umfang des ersten Prototyps

- Ein Kopf, der gefunden und wiederhergestellt wird.
- Ein einfacher Grundkörper.
- Ein Fortbewegungsmodul.
- Ein kosmetisches Accessoire.
- Ein nützliches Werkzeugmodul.
- Einfaches Folgen des Spielers.
- Eine kleine Auswahl kontextbezogener Dialoge.
- Einfache, slotbasierte Anpassungsoberfläche.
- Erste Reaktionen auf mindestens einen Ort oder Gegenstand aus Walts Vergangenheit.

## 10. Designregeln

- Scrappy darf immer leistungsfähiger werden, aber niemals seinen Charme verlieren. Seine Persönlichkeit ist wichtiger als seine Werte.
- Eigeninitiative macht ihn lebendig, darf aber niemals die Handlungsfreiheit des Spielers einschränken.
- Humor braucht Timing. Scrappy muss nicht jede Situation kommentieren.
- Er darf frech sein, aber niemals verletzend oder herablassend gegenüber dem Spieler.
- Emotionale Momente dürfen ohne Witz, Kommentar oder Pointe stehen bleiben.
- Scrappy soll durch wiederkehrende Erlebnisse, Erinnerungen und Running Gags eine glaubwürdige gemeinsame Geschichte mit dem Spieler entwickeln.

**Scrappy ist kein Werkzeug mit Dialogen. Er ist eine Figur, die zufällig aus Schrott besteht – und gelegentlich vergisst, dass sie selbst auch aus Schrott besteht.**
