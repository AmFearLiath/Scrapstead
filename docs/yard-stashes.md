# Durchsuchbare Hof-Requisiten (Block 4)

Reifenstapel, Autowrack, Regal, Kisten, Fässer, Container, Paletten,
Motorblock und die Schrotthaufen im Hof lassen sich immer wieder durchsuchen.
Jede Suche verbraucht eine Ladung und bringt ein paar zufällige Teile aus der
Fundliste der Requisite. Die Ladungen kommen beim Spielen langsam zurück (nur
Spielzeit, nichts passiert, solange das Spiel zu ist). Wunsch des Nutzers:
„Alle füllen sich langsam wieder auf.“

## Aufbau

- `scripts/data/StashDefinition.gd`: eine Fundstelle (Hof-Objekt, Name, Aktion,
  Werkzeug, Suchdauer, Kapazität, Nachfüllzeit, Teile pro Suche, Fundliste mit
  Gewichten, Texte).
- `scripts/data/StashTable.gd`, Daten in `data/stashes/yard_stashes.tres`,
  erzeugt mit `python tools/make_stashes.py`.
- `scripts/world/YardStashes.gd` (Knoten `YardStashes` in `OldYardTest.tscn`):
  setzt beim Start auf jedes Hof-Objekt einen `YardStash`-Interaktionskörper
  (Kopie der Kollisionsboxen, Interaktionsschicht), zählt Ladungen und
  Nachfüllzeit, erzeugt die Funde als echte `ScrapItem`s (`stash_<n>`) und
  gibt sie nach dem Verkauf wieder frei.
- `scripts/world/YardStash.gd`: Prompt mit verbleibenden Ladungen oder
  Restzeit, Werkzeugprüfung. Der Interaktionspunkt liegt auf der Seite des
  Objekts, die dem Spieler am nächsten ist; dort landen auch die Funde.
- Der Körper hängt am Hof-Objekt: Verschiebt der Spieler es im Baumodus,
  wandert die Fundstelle mit. Wegfindung und Bauraster sehen ihn nicht
  (eigene Kollisionsschicht).
- Funde sind normale Teile: Spieler und Juri können sie aufheben, verkaufen,
  zerlegen.
- Spielstand: Schlüssel `stashes` (Ladungen, Nachfüllzeit, Zähler, liegende
  Funde mit Position). Ältere Spielstände ohne den Schlüssel starten mit vollen
  Fundstellen; eine neue Spielstandversion ist nicht nötig.

## Fundstellen

| ID | Hof-Objekt | Werkzeug | Ladungen | Nachfüllen je Ladung | Teile | Fundliste |
|---|---|---|---|---|---|---|
| `tyres` | Tyres | – | 2 | 5 min | 1–2 | scrap_wire_coil, scrap_rusted_bolt, scrap_empty_can |
| `car_wreck` | CarWreck | Brechstange | 2 | 8 min | 1–3 | device_broken_radio, mat_copper_wire, scrap_copper_pipe, scrap_rusted_bolt, find_brass_figurine |
| `shelf` | Shelf | – | 3 | 6 min | 1–2 | scrap_rusted_bolt, scrap_wire_coil, device_broken_toaster, mat_electronic_parts |
| `crates_open` | Crates1 | – | 2 | 6 min | 1–2 | scrap_wood_offcut, scrap_rusted_bolt, scrap_empty_can |
| `crates_nailed` | Crates2 | Brechstange | 2 | 7 min | 1–3 | mat_electronic_parts, scrap_wire_coil, scrap_wood_offcut, device_broken_radio |
| `barrels` | Barrels | – | 2 | 5 min | 1–2 | scrap_empty_can, scrap_copper_pipe, scrap_rusted_bolt |
| `scrap_pile` | SmallScrapPile | – | 2 | 4 min | 1–2 | scrap_rusted_bolt, scrap_empty_can, scrap_wire_coil |
| `scrap_heap_large` | LargeScrapHeap | – | 4 | 4 min | 2–3 | scrap_rusted_bolt, scrap_empty_can, scrap_copper_pipe, scrap_wire_coil, device_broken_toaster, find_brass_figurine |
| `scrap_heap_small` | SmallScrapHeap | – | 2 | 4 min | 1–2 | scrap_rusted_bolt, scrap_empty_can, scrap_wire_coil |
| `engine_block` | EngineBlock | Flaschenzug | 1 | 10 min | 2–3 | mat_copper_wire, scrap_copper_pipe, scrap_rusted_bolt |
| `container` | Container | Brechstange | 2 | 10 min | 2–3 | device_broken_toaster, device_broken_radio, mat_electronic_parts, scrap_wire_coil, find_brass_figurine |
| `pallets` | Pallets | – | 2 | 5 min | 1–2 | scrap_wood_offcut, scrap_rusted_bolt |

Seltene Funde: Die Messingfigur kann im Autowrack, im Container und im großen
Schrotthaufen auftauchen. Verschlossene Kisten sind bewusst nicht in den
Fundlisten (die gibt es nur bei Lieferungen).

## Tests

`tests/integration/test_yard_stashes.gd`: Tabelle gültig und übersetzt, jede
Fundstelle hat ihren Körper, Suche verbraucht Ladungen und füllt sich nach der
Zeit wieder auf (nie über die Kapazität), Werkzeuge (Brechstange,
Flaschenzug), Speichern und Laden mit getragenen und liegenden Funden,
Mitwandern beim Verschieben.

## Offen

- Juri durchsucht Fundstellen noch nicht selbst, er sammelt nur die Funde auf.
- Die Requisiten zeigen ihren Füllstand nur im Prompt, nicht am Modell.
