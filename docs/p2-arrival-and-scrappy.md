# Scrapstead — P2: Einstieg und Scrappy (Umsetzung)

**Version:** 0.1  
**Status:** Umgesetzt und automatisiert geprüft (Stand 26.11.2026); spielerische Bewertung offen  
**Grundlage:** `mvp-prototype-plan.md` (Abschnitt 6), `first-hour-experience.md`, `scrappy-companion.md`, `lore-walt-wren.md`, `starting-yard-layout-discovery.md`

---

## 1. Ziel

Der Old Yard wird als erzählerischer Ort erlebbar: ankommen, Walts Brief lesen, arbeiten, Geld verdienen, Scrappy entdecken und wiederherstellen, den Hof sichtbar verbessern. Die Kernschleife aus P1 bleibt unverändert und trägt weiterhin allein.

## 2. Festgelegte Detailentscheidungen

Die folgenden Punkte waren im Konzept offen und werden für den Prototyp so festgelegt:

| Frage | Entscheidung |
|---|---|
| Vorgeschichte vor dem ersten steuerbaren Moment | Keine Zwischensequenz. Nach „Neues Spiel“ blendet das Spiel ein, und Walts Brief liegt als Papierblatt über dem Hof. Ein Klick schließt ihn; danach ist sofort freies Spielen möglich. |
| Brief später erneut lesen | Über das Pausemenü („Walts Brief“). |
| Aufgabenhinweise ohne starre Kette | Kleiner Notizzettel unter der Credit-Anzeige mit höchstens zwei aktuellen Vorschlägen, abgeleitet aus Ereignis-Flags. Er schlägt vor, verlangt nichts und verschwindet, wenn nichts Sinnvolles anliegt. |
| Sichtbarkeit von Scrappys Fundort | Teilweise verschüttet am Rand des großen Schrotthaufens in Zone B; ein Auge schaut heraus. Kein Leuchten, kein Marker. |
| Freilegen des Kopfes | Halte-Aktion ohne Werkzeug, damit die Entdeckung nie hinter einem Kauf liegt. |
| Roter Werkzeugkasten | Neben der Werkbank in der Werkstattzone. Enthält garantiert die Kernkomponente und einen Zettel von Walt. |
| Story-Gegenstände | Kopf und Kernkomponente sind Schlüsselgegenstände außerhalb des Tragekorbs: keine Plätze, nicht verkaufbar, nicht ablegbar. Das HUD zeigt sie unter „Besonderes“. |
| Wiederherstellung | An der Werkbank, sobald beide Teile vorhanden sind (Halte-Aktion). Walt hat ein Notgestell vorbereitet: einen alten Farbeimer auf einem Rollbrett. Scrappy erwacht darauf. |
| Scrappys erste Ausstattung | Grundkörper (Farbeimer), Fortbewegung (Rollbrett mit vier Rollen), Werkzeugmodul (Greifzange), nützliches Modul (Taschenlampe), kosmetisches Accessoire (Fliege). Modulwechsel folgt in einer späteren Stufe. |
| Folgen und Warten | Interaktion mit Scrappy schaltet zwischen „Mitkommen“ und „Hier warten“. |
| Erste sichtbare Hofverbesserung | Neue Ware im Bestellkatalog: „Eingang herrichten“ (frisch gestrichenes Hofschild, Blumenkübel, Fußmatte). Vorher/Nachher ist am Tor sichtbar. Scrappy schlägt sie nach dem ersten Kauf vor. |
| Beziehung Walt ↔ Spieler | Bleibt bewusst offen (Konzept). Der Brief ist „an den neuen Besitzer“ adressiert. |

## 3. Ablauf (keine Pflichtreihenfolge außer Kopf + Kernteil → Wiederherstellung)

1. Einblenden, Walts Brief, Notizzettel: „Sieh dich auf dem Hof um.“
2. Erstes Aufheben → Notiz: „Bring Schrott zum Annahmetresen.“
3. Erster Verkauf → Notiz: „Im Büro liegt Walts Bestellkatalog.“
4. Kopf gefunden → Notiz: „Der Kopf braucht ein Kernteil. Walt hat bestimmt etwas aufbewahrt.“
5. Kernteil gefunden (ohne Kopf) → Notiz: „Wozu gehört dieses Kernteil? Irgendwo auf dem Hof …“
6. Beide vorhanden → Notiz: „Repariere Scrappy an der Werkbank.“
7. Wiederherstellung: kurzer Moment (Kamera rückt näher, Funken, Scrappy erwacht und spricht).
8. Danach Notizen zum Hof: „Mach den Eingang hübsch (Bestellkatalog).“

## 4. Scrappy im Prototyp

**Verhalten (Zustände):** ruht (nur Kopf, vor der Reparatur) · folgt · wartet · untersucht (kurzer Abstecher zu einem nahen, unberührten Fundstück, wenn der Spieler eine Weile stillsteht) · spricht.

**Bewegung:** Hält 1,8–2,6 m Abstand, bremst weich, weicht aus, wenn der Spieler auf ihn zuläuft, und blockiert keine Interaktionsziele. Ist er weiter als 16 m entfernt, rollt er schneller. Bleibt er hängen, setzt er sich hinter den Spieler zurück.

**Schutzregeln:** Scrappy hebt nichts auf, verbraucht nichts und löst keine Aktionen aus. Er ist kein Interaktionsziel, solange er dem Spieler im Weg wäre (Interaktionspunkt hinter ihm).

**Ausdruck ohne Dialog:** Augenblenden blinzeln, der Kopf neigt sich beim Untersuchen, die Antenne wippt, ein Hüpfer bei Freude, Wackeln beim Anfahren.

**Dialog:** Sprechblase über Scrappy mit Schreibmaschineneffekt und leisem Piepsen. Ausgelöst durch Ereignisse, mit Varianten, Abklingzeiten und Zufallsanteil („nicht jede Aktion braucht einen Kommentar“). Mindestens eine geschützte Walt-Erinnerung (an der Werkbank).

**Persistenz:** Zustand (ruht/aktiv), Folgemodus, Position, gesagte Einmal-Zeilen.

## 5. Daten und Speicherstand

- Spielstandschema **Version 3**: `story` (`flags`, `key_items`, `spoken_once`) und `scrappy` (`state`, `follow`, `position`).
- **Migration v2 → v3** ist explizit implementiert (ergänzt leere Story- und Scrappy-Daten). Ältere Versionen werden weiterhin abgelehnt.
- Dialogzeilen sind Lokalisierungsschlüssel `scrappy.<anlass>.<n>`; Auswahlregeln liegen in `data/story/scrappy_lines.tres`.

## 6. Abnahmekriterien P2 (Prototyp)

- Neues Spiel zeigt Walts Brief; er ist später über das Pausemenü lesbar.
- Notizen schlagen passende nächste Schritte vor, ohne Reihenfolge zu erzwingen.
- Kopf und Kernkomponente sind garantiert auffindbar, nicht verkaufbar und überstehen Speichern/Laden.
- Die Wiederherstellung funktioniert genau einmal, ist erkennbar inszeniert und Scrappy spricht.
- Scrappy folgt, wartet auf Wunsch, blockiert keine Wege und nimmt nichts.
- Scrappy kommentiert ausgewählte Ereignisse, wiederholt sich nicht ständig und ist nie herablassend.
- Die erste Hofverbesserung ist sichtbar vorher/nachher.
- Alle P0/P1-Tests bleiben grün.

## 7. Umsetzung (Stand 26.11.2026)

| Baustein | Datei(en) |
|---|---|
| Story-Zustand (Flags, Schlüsselgegenstände, gesagte Einmal-Zeilen) | `scripts/story/StoryState.gd` |
| Regie: Notizen, Dialogregeln, Aufwachsequenz, Erinnerungen | `scripts/story/StoryDirector.gd`, `scripts/story/ScrappyLines.gd`, `data/story/scrappy_lines.tres` |
| Fundort Kopf, roter Werkzeugkasten, Werkbank mit Reparatur | `scripts/world/ScrappyHeadSite.gd`, `RedToolbox.gd`, `RepairBench.gd` und die Szenen in `scenes/interaction/` |
| Scrappy (Bewegung, Animation, Folgen/Warten) | `scenes/scrappy/Scrappy.tscn`, `scripts/scrappy/` |
| Brief, Notizzettel, Sprechblase | `ui/hud/LetterPanel.tscn`, `TaskNotes.tscn`, `SpeechBubble.tscn` |
| Eingang herrichten (Katalogware, Lieferung am Tor) | `data/upgrades/yard_entrance.tres`, `assets/models/entrance_improvement.glb` |
| Modelle (Blender-Skript) | `tools/blender/props_story.py` |
| Klänge `scrappy_chirp`, `scrappy_wake`, `spark` | `tools/audio/synth_audio.py` |

**Dialogregeln:** Jeder Anlass hat Varianten, eine Auslösewahrscheinlichkeit und eine Abklingzeit; zwischen zwei unaufgeforderten Zeilen liegen mindestens 8 s. Antworten auf direkte Spieleraktionen (Folgen/Warten, Kauf) und die Aufwachsequenz haben Vorrang und werden eingereiht. Die vier Erinnerungen (Werkbank, Container mit Frau Mauser, Walts Schubkarre „Bertha“, Tor) werden je einmal ausgelöst, wenn Scrappy und Spieler in der Nähe sind, und im Spielstand vermerkt. Ruhender Scrappy sagt nichts.

**Tests:** `tests/integration/test_p2_story.gd` (12 Fälle), Migration v2 → v3 in `tests/unit/test_save_service.gd`, Brief und Wiederherstellung über einen echten Neustart in `tests/e2e_restart.gd`.

**Auffindbarkeit (Nachtrag):** Ohne Leuchten und Marker: Der ruhende Kopf piept leise und stockend, wenn der Spieler näher als 11 m ist; nach dem ersten Verkauf fragt der Notizzettel „Hat der große Schrotthaufen eben gepiept?“.

**Offen:** Ob das als Hinweis reicht, muss der Playtest zeigen, Tonalität und Häufigkeit der Sprüche im echten Spiel, Modulwechsel für Scrappy (spätere Stufe).
