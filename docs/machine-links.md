# Maschinenverbindungen (Förderbänder)

**Status:** umgesetzt (26.11.2026) mit der zweiten Maschine, wie im Bausystem
vorgesehen. **Bezug:** [Bauen und Maschinenverbindungen](building-and-logistics.md)
Abschnitt 4–9, [Bausystem](building-system.md), [Schrottpresse](scrap-press.md).

## Bedienung

Baumodus → Werkzeug **Verbinden** (Taste L):
1. Maschine mit Ausgang anklicken (z. B. Magnetsammler).
2. Zielmaschine mit Eingang ansteuern: Die Vorschau zeigt die Route grün und
   die Länge, oder in einem Satz, warum es nicht geht.
3. Linksklick baut das Band (kostenlos). Rechtsklick bricht ab.

Entfernen: Werkzeug **Entfernen** auf ein Förderband zeigen und klicken.
Verbinden und Entfernen lassen sich rückgängig machen und wiederholen.

## Regeln

- Jeder Ausgang speist höchstens ein Band, jeder Eingang bekommt höchstens
  eines. Eine Maschine kann sich nicht selbst beliefern.
- Die Maschinen müssen zusammenpassen: Die Zielmaschine muss etwas annehmen,
  das die Quelle herstellt.
- Die Route wird automatisch auf dem 0,5-m-Raster gesucht (A*, ohne
  Diagonalen), vom Feld direkt neben dem Ausgang bis zum Feld direkt neben dem
  Eingang. Sie meidet alles, was im Hof steht oder gebaut ist, und andere
  Bänder.
- Bänder sind niedrig und **begehbar**: Sie blockieren weder Spieler noch Juri
  und dürfen Laufwege und Bedienflächen kreuzen (dort teurer, die Route
  weicht nach Möglichkeit aus). Auf Bändern kann man nichts bauen.
- Wird eine verbundene Maschine verschoben, sucht das Band eine neue Route.
  Die Maschine darf dabei auch über ihr eigenes altes Band gestellt werden.
  Findet sich kein Weg, bleibt die Verbindung bestehen, ist aber „blockiert“
  (Hinweis), und verbindet sich von selbst wieder, sobald Platz ist.
- Wird eine Maschine weggeräumt, verschwinden ihre Bänder.

## Transport

Alle 2 Sekunden schickt ein Band ein passendes Teil aus der Ausgabe der
Quelle los, wenn die Zielmaschine Platz hat. Der Platz im Trichter wird sofort
reserviert, das Teil kommt aber erst an, wenn es sichtbar in den Trichter
fällt (Fahrzeit über das Band plus kurzer Sprung). Erst dann wird es
verarbeitet. So kommt aus einer Maschine immer das Teil, das man hineinfallen
sah, auch bei langen Bändern. Beim Speichern gelten Teile auf dem Band als
angekommen, der Spielstand muss also keine Teile „unterwegs“ kennen.

## Technik

- `scripts/build/MachineLinks.gd` (Kind von `PlacedObjects`): Verbindungen,
  Routing, Bandmodelle (`conveyor_straight`, `conveyor_corner`), Transport,
  Speichern (`placed.links`: `[{"id", "from", "to"}]`; Routen werden beim
  Laden neu berechnet).
- Maschinen nehmen über Duck-Typing teil: Quellen `get_output_items()` und
  `get_output_item_ids()`, Ziele `accepts_item_type()`, `can_accept()`,
  `accept_item()`, beide `get_port_position()`. Anschlusspunkte stehen als
  `ports` im `PlaceableDefinition`.
- `PlacedObjects._refresh_validator` trägt Bandfelder als belegt ein
  (außer für die Maschinen des Bandes selbst).
- `BuildMode`: Werkzeug `connect`, Entfernen von Bändern, Rückgängig-Schritte
  `link`/`unlink`.

## Mehrere Ausgänge

Eine Maschine kann mehrere Ausgänge („Kanäle“) haben, z. B. die drei Kisten
der Sortiermaschine. Jeder Kanal speist ein eigenes Band. Beim Verbinden
zählt, wo der Spieler die Quellmaschine anklickt: Der nächste freie Ausgang
wird verbunden. Routen belegen nie das Feld vor einem fremden Anschluss und
meiden seine Nachbarfelder. Siehe [Verarbeitungskette](processing-chain.md).
