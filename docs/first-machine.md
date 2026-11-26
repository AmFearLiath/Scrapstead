# Scrapstead — Die erste Maschine: kleiner Magnetsammler (P3b)

**Status:** Umgesetzt (26.11.2026, autonome Entwicklungsphase)
**Bezug:** [MVP-Plan P3b](mvp-prototype-plan.md), [Progression, Abschnitt 5](progression-business-growth.md), [Kernmatrix 4.8](core-gameplay-matrix.md), [Startgelände, Abschnitt 7](starting-yard-blockout.md)

## 1. Zweck

P3b soll zeigen, dass eine Maschine eine erkennbare Wiederholungstätigkeit übernimmt. Eingabe und Ausgabe sollen verständlich sein, die Maschine darf nichts aus dem Nichts erzeugen und keine Bestände verdoppeln, und das Spiel darf nicht zum Leerlauf-Tycoon werden. Laut Progressionskonzept ist die erste Maschine der **kleine Magnetsammler**.

## 2. Was der Spieler erlebt

1. **Vorher:** Auf dem reservierten Stellplatz der freien Arbeitsfläche (östlich des Hauptwegs) steht ein Schild „RESERVIERT – für etwas mit Motor“. Daneben liegt Walts Nagelhaufen („nicht barfuß“).
2. **Kauf:** Im Katalog steht „Kleiner Magnetsammler“ (60 Cr). Die Karte nennt Herkunft, Aufstellort und Wirkung: „Alle 20 s eine Schraube oder Dose aus dem Nagelhaufen (45 Teile) in seine Kiste · hält an, wenn 6 drin liegen“. Nach dem Kauf steht er mit einer Staubwolke auf dem Stellplatz. Scrappy: „Ein Magnet! Schön. Ich halte Abstand. Ich hänge an meinen Schrauben.“
3. **Arbeit:** Der Ausleger schwenkt zum Haufen und senkt den Magneten ab. Er hebt ein Teil an, das sichtbar am Magneten hängt, schwenkt zur Drahtkiste und lässt es hineinfallen. Die Statuslampe leuchtet grün.
4. **Ausgabe:** Die Teile in der Kiste sind gewöhnliche Fundstücke. Du hebst sie auf und verkaufst sie an der Theke.
5. **Kiste voll:** Bei 6 Teilen hält die Maschine an. Die Lampe blinkt gelb, und der Notizzettel sagt „Die Kiste am Magnetsammler ist voll.“ Sobald ein Platz frei ist, arbeitet sie weiter.
6. **Nachschub:** Solange die Maschine steht, kippt Schrotthändler Kowalski alle 4 Minuten Spielzeit 12 Teile Kleinschrott auf den Nagelhaufen („Spart mir die Deponiegebühr.“), höchstens bis 45 Teile. Lose Schrauben und Dosen, die du selbst neben den Haufen legst, nimmt der Magnet zuerst.
7. **Haufen leer:** Ist der Haufen leer, meldet sie „nichts mehr zu holen“ (graue Lampe), bis die nächste Fuhre kommt. Der Haufen schrumpft und wächst sichtbar mit seinem Bestand.
8. **Bedienung:** Am Schaltkasten schaltest du ein und aus. Der Hinweis zeigt Status, Haufenbestand und Kistenfüllung, z. B. „arbeitet · Haufen 37 · Kiste 2/6“. Mit R siehst du die Regeln.
9. **Upgrade:** „Stärkerer Magnet“ (25 Cr, setzt die Maschine voraus) verkürzt den Takt von 20 auf 12 s. Beschreibung: „Bitte nicht mit Herzschrittmacher, Armbanduhr oder festen Überzeugungen zu nah ran.“

## 3. Regeln

| Regel | Wert | Begründung |
|---|---|---|
| Eingabe | Walts Nagelhaufen: bis zu 45 Teile in fester Reihenfolge (Schraube, Dose, Schraube, Schraube, Dose …). Lose Schrauben und Dosen im Umkreis von 3 m um den Haufen nimmt er zuerst. | Klar definierte Quelle; nichts entsteht aus dem Nichts |
| Nachschub | Kowalski: alle 240 s Spielzeit +12 Teile, nie über 45, auch bei ausgeschalteter Maschine | Beschaffungsweg Lieferant; hält die Maschine nach dem ersten Haufen nützlich (Rückmeldung aus dem ersten Spielen) |
| Magnetisch | Nur verrostete Schraube und leere Dose | Kupfer und Holz sind nicht magnetisch; Wertvolles bleibt beim Spieler |
| Takt | 20 s, mit Upgrade 12 s | ~7,8 bzw. 13 Cr/min, solange geleert wird |
| Ausgabe | Drahtkiste, 6 Plätze | Eindeutiger Ausgabepunkt; volle Kiste stoppt die Maschine (kein Leerlauf-Tycoon) |
| Wert | Erster Haufen ≈ 117 Cr bei 60 Cr Kaufpreis; danach ≈ 7,8 Cr/min aus Kowalskis Fuhren | Lohnt sich dauerhaft, bleibt aber Nebeneinkommen |
| Status | arbeitet · Kiste voll · nichts mehr zu holen · ausgeschaltet | Lampe, Hinweis am Schaltkasten, Notiz bei voller Kiste |
| Offline | Arbeitet nur, während gespielt wird | Konzept: keine vollständige Offline-Produktion |
| Hindernis | Erst nach dem Kauf fest (Kollision) | Vorher läuft man über den freien Stellplatz |

**Duplizieren ausgeschlossen:** Ein Takt wird erst entschieden, wenn der Timer abläuft. Dann wandert genau ein vorhandenes loses Teil in die Kiste (dasselbe Objekt, nur versetzt), oder der Haufenbestand sinkt um eins und ein neues Teil mit fortlaufender ID entsteht. Die Animation zeigt nur den Fortschritt.

## 4. Technik

- `MachineProfile` (Resource, `data/machines/magnet_collector.tres`): Freischaltung, Upgrade, Takte, Kistengröße, Arbeitsradius, magnetische Gegenstände, Haufenmuster und Haufengröße. `validate()` prüft, dass der Haufen nur magnetische Teile enthält.
- `MagnetCollector` (`scenes/machines/MagnetCollector.tscn`): Prozesslogik, Status und Spielstand. Erzeugte Kistenteile laufen wie die Anlieferungen über `item_spawned`/`item_removed` in das Objektregister des Szenen-Controllers.
- `MagnetAnimator`: Schwenk, Absenken, Anheben eines Platzhalters des nächsten Teils, Statuslampe und schrumpfender Haufen. Er liest nur den Zustand.
- `MagnetControls`: Schaltkasten (ein/aus, Hinweis, Regeln).
- `UpgradeDefinition.effect_key`: feste Wirkungszeile im Katalog für Maschinenwaren. Die Katalogliste scrollt jetzt.
- Modelle: `tools/blender/props_machines.py` → `magnet_collector.glb` (Gruppen Turret/Boom/Cable/Magnet) und `magnet_bin.glb`.
- Spielstand **Version 6**: Block `machines.magnet_collector` mit Schalter, Timer, entnommenen Haufenteilen, Zähler und Kistenteilen. Versetzte lose Teile laufen über `world_objects`. Version 5 wird explizit migriert.

## 5. Tests

`tests/integration/test_magnet.gd` mit 10 Tests:
- Profil, Übersetzungen und Wirtschaftlichkeit (Haufen > Preis, < 15 Cr/min).
- Nichts vor dem Kauf; das Upgrade setzt die Maschine voraus.
- Kiste füllt sich aus dem Haufen, Verkauf normal.
- Volle Kiste stoppt die Maschine, mit Notiz und ohne Überlappung.
- Lose Schraube wird als dasselbe Objekt übernommen, Kupfer bleibt liegen.
- Nie mehr als der Haufen.
- Ausschalter und stärkerer Magnet.
- Animation folgt dem Takt und erzeugt selbst nichts.
- Speichern und Fortsetzen.
- v5-Migration und Ablehnung kaputter Daten.

Screenshots `37_machine_pad_reserved` bis `42_machine_crate_full`.

## 6. Offen

- Playtest: ob 20 s und 6 Plätze sich gut anfühlen und ob das Leeren der Kiste Beschäftigung oder Pflicht ist.
- Juri leert die Kiste bewusst nicht (eine Aufgabe pro Mitarbeiter). Eine zweite Aufgabe wäre ein naheliegender nächster Delegationsschritt.
- Mit Kowalskis Takt (12 Teile / 4 min) bremst der Nachschub die schnellere Spule auf Dauer aus. Sie leert vor allem den Rückstand schneller. Ob das reicht, zeigt der Playtest.
- Versetzen der Maschine an andere Haufen (Platzierung) ist bewusst noch nicht umgesetzt.
- Der Magnet hat noch kein eigenes Brummgeräusch; er nutzt vorhandene Klänge.
