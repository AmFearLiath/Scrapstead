# Scrapstead — Anlieferungen der Nachbarn (Nachschub)

**Status:** Umgesetzt (26.11.2026, autonome Entwicklungsphase)
**Bezug:** [Wirtschaft, Abschnitt 6 „Beschaffung“](gameplay-economy.md), [Weltfunde 4.3](world-exploration-activities.md), [Prototyp-Abnahme, Empfehlung 3](prototype-acceptance.md), [MVP-Plan P3a](mvp-prototype-plan.md)

## 1. Zweck

Die Fundstücke im Old Yard sind einmalig (P1-Regel: keine Regeneration). Nach rund 115 Cr Erlös endete die Schleife inhaltlich. Die Abnahme empfahl deshalb eine bewusste Entscheidung über **Regeneration oder Nachschub**, bevor Delegation (P3) getestet wird. Ein Mitarbeiter braucht eine wiederkehrende Aufgabe, sonst gibt es nichts zu delegieren.

**Entscheidung:** Der Nachschub kommt nicht als Regeneration der Weltfunde. Er kommt als Beschaffungsweg 2 des Konzepts: **Anlieferungen von Privatpersonen**. Nachbarn laden Kleinkram an einer Abladestelle neben dem Tor ab. Die handgesetzten Funde bleiben einmalig, Storyfunde unberührt.

## 2. Ablauf

1. Freischaltung: Katalogware **„Eingang herrichten“** (25 Cr). Erst ein gepflegter Eingang signalisiert, dass hier jemand Schrott annimmt. Scrappys vorhandener Spruch „Wir sind jetzt offiziell ein Ort, an den Leute freiwillig kommen“ bekommt dadurch eine spielerische Folge.
2. Etwa 25 Sekunden Spielzeit nach dem Kauf hupt ein Lieferwagen am Tor. Auf der Palette „ABLADEN – keine Fragen“ liegen dann 2–4 gewöhnliche Schrottteile.
3. Eine Meldung nennt Absender und Zettel, z. B. *Frau Pohl hat am Tor Schrott abgeladen: „Aus dem Keller meines Mannes. Er hat alles aufgehoben. ALLES.“*
4. Der Notizzettel zeigt „Jemand hat Schrott am Tor abgeladen.“, solange Geliefertes dort liegt.
5. Ein wiederhergestellter Scrappy kommentiert die erste Lieferung einmalig, spätere gelegentlich (Regeln in `scrappy_lines.tres`).
6. Die Teile sind gewöhnliche Fundstücke: aufheben, ablegen, verkaufen. Verkaufte Lieferteile verschwinden aus Welt und Spielstand.

## 3. Taktung und Grenzen

| Regel | Wert | Begründung |
|---|---|---|
| Erste Lieferung | 25 s nach Freischaltung | Sofortige Rückmeldung auf den Kauf |
| Abstand | 150 s Spielzeit | Nebenbei-Einkommen, kein Ersatz fürs Erkunden |
| Rückstau | Neue Lieferung nur, wenn weniger als 2 Lieferteile herumliegen; sonst erneuter Versuch nach 20 s | Kein Anhäufen, keine endlose Farm (Weltfunde 4.3) |
| Inhalt | 7 handgeschriebene Einträge in fester Reihenfolge, danach Wiederholung | Nachvollziehbar und testbar, kein Zufall |
| Ertrag | ~11 Cr je Lieferung, rund 4,6 Cr pro Minute | Deutlich unter aktivem Sammeln |
| Offline | Keine Lieferungen, solange das Spiel geschlossen ist | Konzept: keine vollständige Offline-Produktion |

Alle Werte stehen in `data/deliveries/neighbor_deliveries.tres` und lassen sich ohne Codeänderung anpassen.

## 4. Absender

Drei wiederkehrende Nachbarn und ein Unbekannter, jeweils mit einer Eigenheit (vgl. [Bewohner, 3.2](characters-residents-relationships.md)):

- **Frau Pohl:** räumt die Keller ihres verstorbenen Mannes aus und entdeckt dabei immer neue Keller.
- **Benno von der Werkstatt:** trocken. Was bei ihm im Weg liegt, liegt jetzt bei dir im Weg.
- **Lotte (9):** bringt Dosen „für den Roboter“ und darf nicht mehr über den Zaun klettern.
- **Jemand:** „Nicht fragen.“

Es sind Hintergrundfiguren ohne Modell und ohne Beziehungssystem. Ihre Namen und Eigenheiten können später zu echten Bewohnern ausgebaut werden.

## 5. Technik

- `DeliveryTable` (Resource): Daten, Taktung, `validate(catalog)`.
- `ScrapDeliveries` (Szene `scenes/world/DropOffSpot.tscn`): erzeugt echte `ScrapItem`-Platzierungen an sechs Markern. Ihre IDs `delivery_<n>` sind über den Spielstand stabil. Der Dienst meldet sie dem Szenen-Controller, der das Objektregister besitzt, und gibt verkaufte Teile wieder frei. Er ist kein Autoload und hat keinen globalen Zustand.
- Spielstand **Version 4**: neuer Block `deliveries` mit Timer, nächstem Eintrag, Zähler und lebenden Teilen (ID, Gegenstand, Marker). Position und Zustand bewegter oder getragener Teile laufen wie bei allen Weltobjekten über `world_objects`. Version 3 wird explizit migriert (leerer Block), Version 1 bleibt abgelehnt.
- Ladereihenfolge: Lieferteile werden **vor** den Objektzuständen und dem Tragekorb wiederhergestellt.
- Klang: `van_horn` (synthetisiert, zweimal kurz und etwas außer Atem), danach das vorhandene `delivery`.

## 6. Tests

`tests/integration/test_deliveries.gd` mit 8 Tests:
- Datenprüfung inklusive Übersetzungen und Ertragsgrenze.
- Sperre vor dem Eingang.
- Erzeugen, Aufheben, Verkaufen und Verschwinden.
- Rückstau.
- Feste Reihenfolge.
- Speichern und Fortsetzen mit abgelegtem, getragenem und wartendem Teil.
- Scrappys Kommentar.
- v3-Migration und Ablehnung kaputter Daten.

Screenshots: `30_delivery_arrived`, `31_delivery_pickup`.

## 7. Offen

- Playtest: Ob 150 s und 11 Cr sich gut anfühlen, und ob die Meldung lang genug sichtbar ist.
- Ein sichtbarer Lieferwagen oder eine Figur am Tor (bisher nur Hupe und Staub).
- Diese Lieferungen sind die vorgesehene erste Aufgabe für den ersten Mitarbeiter in P3a: Lieferteile vom Tor zur Verkaufsstelle tragen.
