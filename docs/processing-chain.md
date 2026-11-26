# Verarbeitungskette: Sortieren, Pressen, Verkaufen

**Status:** umgesetzt (26.11.2026), Phase 4 „vollständiger eigener Betrieb“.
**Bezug:** [Schrottpresse](scrap-press.md), [Maschinenverbindungen](machine-links.md),
[Erster Mitarbeiter](first-employee.md), [Durchsuchbare Hof-Requisiten](yard-stashes.md).

## Idee (Wunsch des Nutzers)

Aus jedem Einzelteil den größtmöglichen Gewinn holen, in einer logischen
Kette: Lieferungen und Funde → zerlegen (Geräte) → sortieren → pressen →
Ballen verkaufen. Fehlt eine Maschine, geht der Schritt von Hand, oder Juri
erledigt ihn. Er macht alles nacheinander, darum dauert es spürbar länger, je
mehr anfällt. Jede vorhandene Maschine nimmt ihm einen Schritt ab.

## Materialgruppen

`data/materials/*.tres` (`MaterialGroup`), gemeinsam genutzt von Sortiermaschine
und Presse:

| Gruppe | Teile | Ballen | Teile pro Ballen | Ballenwert | lose (Ø) |
|---|---|---|---|---|---|
| Stahl | Schraube, Dose | Stahlballen | 6 | 22 Cr | ca. 15 Cr |
| Kupfer & Elektronik | Kupferrohr, Kabelknäuel, Kupferkabel, Elektronikteile | Kupferballen | 4 | 40 Cr | ca. 29 Cr |
| Holz | Holzrest | Holzbündel | 6 | 17 Cr | 12 Cr |

Geräte (Radio, Toaster) werden vorher am Zerlegetisch zerlegt; ihre Ausbeute
(Kupferkabel, Elektronikteile) geht in die Kette. Fundstücke wie die
Messingfigur, verschlossene Kisten und Träger werden direkt verkauft.

## Maschinen

- **Schrottpresse** (bis zu 3, je 140 Cr): nimmt alle drei Gruppen an und
  presst immer sortenrein; die Materialien warten im Trichter getrennt.
- **Sortiermaschine** (1, 180 Cr): ein Trichter (hinten), drei Kisten = drei
  Ausgänge: Stahl links, Kupfer & Elektronik vorne, Holz rechts. Jede Kiste
  kann per Förderband eine eigene Presse speisen. Beim Verbinden entscheidet
  die Klickstelle an der Sortiermaschine, welche Kiste verbunden wird.
- Ausbau-Beispiel: Magnetsammler → Band → Presse (Stahl); Sortiermaschine →
  drei Bänder → drei Pressen.

## Juri in der Kette

- Er zerlegt Geräte wie bisher (Schalter „Zerlegen“ im Mitarbeiterfenster).
- Was er trägt, bringt er zuerst zur Sortiermaschine, sofern mindestens eine
  ihrer Kisten per Band weiterführt (sonst würden sich die Kisten nur füllen).
  Gibt es keine solche Sortiermaschine, bringt er es zu einer Presse (die
  trennt Materialien selbst). Nur was keine Maschine nimmt, verkauft er.
- Fertige Ballen holt er von den Pressen-Ablagen und verkauft sie.
- Aus Sortierkisten ohne Band holt er die Teile und bringt sie zu einer Presse
  oder verkauft sie. Kisten mit Band rührt er nicht an. Sortierte Teile
  kommen nie zurück in eine Sortiermaschine, darum kann nichts im Kreis laufen.
- Der Magnetsammler fischt nicht in fremden Kisten oder Ablagen
  (`holds_output()` der Maschinen); früher holte er sortierte Schrauben aus
  einer nahen Sortiermaschine zurück in seine Kiste.
- Walts Nagelhaufen enthält nur Eisen, und der Magnet hebt nur Eisen: Über den
  Magnetsammler kommt immer nur Stahl. Gemischtes Material bringen Lieferungen
  und Fundstellen.
- Lohn: weiter pro verkauftem Stück. Ein Ballen ist ein Stück, also zahlt die
  Verarbeitung auch beim Lohn.

## Technik

- `scripts/data/MaterialGroup.gd`, `SorterProfile.gd`, `PressProfile.gd` (Gruppen statt Einzelteile).
- `scripts/world/SortingMachine.gd`, `SorterControls.gd`, `SortingAnimator.gd`,
  Szene `scenes/machines/SortingMachine.tscn`, Modell `sorter` in
  `tools/blender/props_press.py`.
- Ausgänge mit Kanälen: Ports mit `"channel"` im `PlaceableDefinition`;
  `MachineLinks` merkt sich den Kanal je Verbindung und speichert ihn.
- Routen belegen nie das Feld vor einem fremden Anschluss und meiden dessen
  Nachbarfelder, damit Bänder keine Ausgänge zumauern.
- Maschinen erzeugen Objekt-IDs mit ihrer Platzierungs-ID (`press_placed_3_1`),
  damit mehrere Pressen sich nicht in die Quere kommen.
- `YardWorker`: Aufgaben `TO_MACHINE`/`FEEDING`, `machines_provider`,
  Statistik `fed`.

## Tests

`tests/integration/test_processing_chain.gd` (Sortierdaten, Sortiermaschine mit
drei Pressen über drei Bänder inklusive Speichern/Laden, Juri füttert die Presse
und verkauft Ballen), `test_press_links.gd`.

## Offen

- Eine Verkaufspalette am Tresen, auf die Bänder Ballen legen (Juri holt sie
  derzeit direkt an den Pressen ab).
- Kein Spielertext erklärt die Kette bisher im Spiel (Scrappy-Hinweis oder
  Walts Liste wären passend).
