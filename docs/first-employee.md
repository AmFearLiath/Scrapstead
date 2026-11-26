# Scrapstead — Der erste Mitarbeiter (P3a)

**Status:** Umgesetzt (26.11.2026, autonome Entwicklungsphase)
**Bezug:** [MVP-Plan P3a](mvp-prototype-plan.md), [Kernmatrix 4.7](core-gameplay-matrix.md), [Wirtschaft, Abschnitt 7](gameplay-economy.md), [Anlieferungen](deliveries.md)

## 1. Zweck

P3a soll zeigen, dass Delegation eine echte Entscheidung ist und keine weitere Verwaltungsmaske. Ein Mitarbeiter übernimmt eine Tätigkeit, die der Spieler vorher selbst ausgeführt hat. Ergebnis, Arbeitsbereich und Kosten sind dabei sichtbar.

Die passende Wiederholungstätigkeit gibt es seit den [Anlieferungen](deliveries.md): Teile von der Abladepalette zur Theke tragen und verkaufen.

## 2. Figur

**Juri**, Bennos ehemaliger Lehrling. Er ist schlaksig, trägt eine Bommelmütze, einen zu großen Hoodie und Kopfhörer um den Hals, dazu eine Holzkiste auf einem Tragegestell. Benno nennt ihn „gut zu Fuß, weniger gut mit Werkzeug“. Für Juri liegt jede Strecke unter einem Kilometer „gleich da drüben“.

- Modell: `tools/blender/build_props.py` → `build_juri`, Ausgabe `assets/models/juri_model.glb`. Er hat dieselben Gelenkgruppen wie die Spielfigur und wird deshalb vom vorhandenen `PlayerAnimator` bewegt: Gehzyklus, Greifen und eine Kiste, die sich sichtbar füllt.
- Persönlichkeit zeigt er über kurze Sprüche in einer eigenen Sprechblase: beim Auftauchen, beim Einstellen, bei der ersten Runde, bei Pausen, beim Entlassen und gelegentlich beim Warten („Ich hab der Palette einen Namen gegeben. Sie heißt Paul.“).

## 3. Ablauf

1. **Kennenlernen:** Nach der zweiten Anlieferung steht Juri am Tor (Statusschild „sucht Arbeit“). Der Notizzettel zeigt „Am Tor sucht jemand Arbeit.“, bis er zum ersten Mal eingestellt wurde.
2. **Ansprechen:** Öffnet das Personalfenster mit Rolle, Beschreibung und Bedingungen.
3. **Einstellen:** einmalig 10 Cr Handgeld („für Handschuhe“). Ohne genug Credits passiert nichts, und die Meldung nennt den Grund.
4. **Arbeit:** Juri nimmt losen Schrott von der Palette, bis zu 2 Teile pro Runde, trägt ihn auf einer festen Route um die Theke herum und verkauft ihn dort. Danach geht er zurück oder wartet an seinem Platz neben der Palette.
5. **Ergebnis:** Nach jeder Runde erscheint eine Meldung, z. B. *„Juri hat 2 Teil(e) verkauft: 9 Cr, Lohn 2 Cr, +7 Cr für dich.“*, dazu Münzen und ein leises Kassengeräusch. Das Personalfenster zählt Runden, Teile, Umsatz, Lohn und was dem Hof bleibt.
6. **Eingreifen:** Im Personalfenster kann der Spieler jederzeit auf „Pause machen“/„Weiterarbeiten“ wechseln oder Juri entlassen. Entlassen braucht einen zweiten Klick („Wirklich entlassen?“). Getragene Teile legt Juri dann zurück auf die Palette und wartet wieder am Tor, „nicht auf komische Art“. Wer ihn erneut einstellt, zahlt das Handgeld noch einmal.

## 4. Regeln

| Regel | Wert | Begründung |
|---|---|---|
| Arbeitsbereich | Alles im Umkreis von 1,7 m um die Abladepalette | Ein klar sichtbarer Bereich. Der Spieler kann eigene Teile dort ablegen und gibt sie damit frei. |
| Erlaubte Teile | Nur Kategorie „loser Schrott“ | Wertvolles (Messingfigur, Radio) lässt Juri liegen und sagt das auch. |
| Kapazität | 2 Teile pro Runde | Weniger als der Spieler mit Korb; Juri ist bequem, nicht schnell. |
| Tempo | 2,4 m/s, 0,6 s Aufheben, 0,9 s Verkaufen | Sichtbar langsamer als der Spieler |
| Handgeld | 10 Cr einmalig | Eine kleine, bewusste Entscheidung |
| Lohn | 1 Cr pro verkauftem Teil, direkt vom Erlös | Kann nie mehr kosten, als er einbringt: kein stiller Geldverlust und kein Softlock (Kernmatrix: Betriebskosten) |
| Status | arbeitet · wartet auf Schrott · kommt nicht durch · macht Pause | Als Schild über dem Kopf, im Prompt und im Personalfenster |
| Blockieren | Juri hat keine Kollisionsebene. Bleibt er hängen, zeigt er nach 0,9 s „kommt nicht durch“ und schiebt sich nach 2,4 s zum nächsten Wegpunkt durch. | Abnahmekriterium: blockiert keine wichtigen Bereiche dauerhaft |
| Offline | Arbeitet nur, während gespielt wird | Wie die Anlieferungen |

**Entscheidung für den Spieler:** Juri behält etwa 29 % des Lieferertrags (1 Cr bei durchschnittlich ~3,5 Cr pro Teil). Dafür muss der Spieler nicht mehr zum Tor laufen und kann sammeln, zerlegen oder erkunden. Wer bastelt (Kupferrohr aufheben statt verkaufen), pausiert ihn oder nimmt die Teile selbst. Was auf der Palette liegt, gehört zu Juris Aufgabe. Damit ist die Palette ein einfacher, sichtbarer Arbeitsbereich.

## 5. Technik

- `EmployeeProfile` (Resource, `data/employees/juri.tres`): Name, Rolle, Kosten, Kapazität, Tempo, Arbeitsradius und Erscheinen.
- `YardWorker` (`scenes/staff/YardWorker.tscn`): Zustände abwesend/verfügbar/eingestellt und die Aufgabenschleife Aufheben → Theke → Verkaufen. Er bucht über das `Wallet`: Verkauf als Gutschrift, Lohn als eigene Abbuchung, beide im Kassenbuch sichtbar. Er setzt den Zustand der Teile; Animation bucht nichts.
- `YardWorkerTalk` öffnet das Panel `staff`; `StaffPanel` (`ui/interaction/StaffPanel.tscn`) zeigt die Ergebnisse von Einstellen, Pause und Entlassen nur an.
- Die Route besteht aus `Staff/Route` mit Markern um die Theke herum, `CounterSpot` vor der Theke, `WaitSpot` am Tor und `RestSpot` neben der Palette. Das ist bewusst kein Navigationsnetz.
- Spielstand **Version 5**: Block `employee` mit Präsenz, Pause, gesehenen Lieferungen, Position, Blickrichtung, getragenen Teilen und Statistik. Getragene Teile stehen in `world_objects` als „carried“. Juri beansprucht sie beim Laden, bevor der Korb des Spielers geprüft wird. Version 4 wird explizit migriert (leerer Block).
- Kein Autoload, kein globaler Zustand; der Szenen-Controller verdrahtet alles.

## 6. Tests

`tests/integration/test_staff.gd` mit 10 Tests:
- Profil und alle Übersetzungen.
- Auftauchen nach zwei Lieferungen.
- Einstellen mit und ohne Geld.
- Vollständige Arbeit an einer Lieferung mit exakter Lohnbuchung und ohne Durchschieben auf der Route.
- Pause und Fortsetzen.
- Wertvolles bleibt liegen; vom Spieler abgelegter Schrott wird verkauft.
- Entlassen mit Rückgabe der Teile.
- Speichern und Fortsetzen mitten in einer Runde.
- v4-Migration und Ablehnung kaputter Daten.
- Bedienung des Personalfensters inklusive Rückfrage.

Screenshots `32_staff_at_gate` bis `36_staff_at_counter`.

## 7. Offen

- Playtest: Ob sich Handgeld und Lohn wie eine Entscheidung anfühlen oder wie eine Selbstverständlichkeit, und ob Juris Tempo nervt oder beruhigt.
- Scrappy beobachtet Juri noch nicht bei der Arbeit (Konzept: Scrappy besucht Mitarbeiter). Das ist ein guter nächster Schritt für die Figurenbeziehungen.
- Keine Erfahrung oder Entwicklung; das feste Rollenprofil genügt laut Kernmatrix für die Kernversion.
