# Scrappy — Begleiter- und modularer Roboter-Spezifikation

**Version:** 0.2  
**Status:** Konzept  
**Zugehörige Hintergrundgeschichte:** [Walt Wren und die Geschichte hinter dem Schrottplatz](lore-walt-wren.md)

## 1. Charakterkonzept

Scrappy ist ein liebenswerter, eigenwilliger und etwas in die Jahre gekommener Schrottplatzroboter. Der Spieler findet zunächst nur seinen Kopf unter einem Schrotthaufen. Eine besondere Kernkomponente aus dem roten Werkzeugkasten stellt seine grundlegenden Systeme wieder her. Anschließend baut der Spieler Scrappy nach und nach aus gefundenen Schrottteilen zusammen.

Scrappy ist Begleiter, Helfer, gelegentlicher Guide, Kommentator und das emotionale Gesicht von Scrapstead.

Scrappy wurde von Walter „Walt“ Wren gebaut und über lange Zeit erweitert. Ursprünglich war er als praktischer Helfer gedacht, entwickelte sich aber zum persönlichen Begleiter seines Erbauers. Scrappy erinnert sich an Walt und den Schrottplatz, sein Speicher ist nach dem Unfall jedoch unvollständig.

## 2. Persönlichkeit

- Loyal und neugierig.
- Trockener, gelegentlich frecher Humor.
- Selbstbewusst, auch bei zweifelhaftem Wissen.
- Stolz auf seine improvisierte Konstruktion.
- Gelegentlich ein liebenswerter Quasselkopf, aber niemals dauerhaft aufdringlich.
- Seine Persönlichkeit bleibt unabhängig von den eingebauten Komponenten.
- Er bezeichnet sich gern als technischen Leiter des Schrottplatzes und stellt Walts frühere Rolle gelegentlich etwas eigenwillig dar.

Scrappy darf den Spieler necken, aber nicht herabsetzen. Seine Kommentare sollen Situationen bereichern, nicht den Spielfluss unterbrechen.

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

## 7. Reaktionen und Dialoge

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

## 10. Designregel

Scrappy darf immer leistungsfähiger werden, aber niemals seinen Charme verlieren. Seine Persönlichkeit ist wichtiger als seine Werte.

**Scrappy ist kein Werkzeug mit Dialogen. Er ist eine Figur, die zufällig aus Schrott besteht.**
