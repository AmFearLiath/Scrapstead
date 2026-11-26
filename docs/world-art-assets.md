# Scrapstead — Art Direction: Walts Flickwerk-Diorama

**Version:** 0.2  
**Status:** Verbindliche Stilrichtung für den Art-Direction-Prototyp; wird mit jedem Asset-Pass überprüft  
**Grundlage:** Decision Log (Projektidentität, Humoridentität), `lore-walt-wren.md`, `ui-ux.md`

---

## 1. Leitidee

Scrapstead sieht aus wie ein **liebevoll gebautes Miniatur-Diorama eines Schrottplatzes, auf dem alles schon einmal repariert wurde**. Jedes Objekt trägt Walts Handschrift: Flicken, Klebeband, falsche Schrauben, zweckentfremdete Teile. So wird „Every Scrap Has a Story“ sichtbar, bevor ein Text gelesen wird.

Stichworte: warm · verschmitzt · handgemacht · leicht schief · gut lesbar · einladend, nie trostlos.

Der Stil muss aus der festen isometrischen Spielkamera (orthografisch, Pitch −35°, Zoom 9–19) funktionieren. Was dort nicht lesbar ist, wird nicht modelliert.

## 2. Die vier Stilregeln

### 2.1 Flickwerk (Erkennungsmerkmal)

- Jedes **alte** Hauptobjekt besitzt 1–3 sichtbare Reparaturen: aufgenietete Blechflicken, Klebebandstreifen, Draht, eine Schraube in falscher Farbe.
- Flicken stehen farblich im **Kontrast** zum Grundmaterial (Petrol auf Rost, Senf auf Petrol, Rost auf Holz).
- Flicken sind leicht erhaben (1–2 cm), haben 2–4 übergroße Nieten und sitzen nie perfekt gerade (3–8°).
- **Neue** Dinge aus dem Hinterhof-Versand sind sauber, gerade und ungeflickt. Fortschritt wird dadurch sichtbar: Je weiter der Betrieb wächst, desto ordentlicher wird der Hof.

### 2.2 Formsprache: dicklich, weich, leicht schief

- Alle Kanten sind abgerundet (Bevel 2–6 cm, 2–3 Segmente), keine messerscharfen Kanten.
- Alte Objekte sind um 1–4° verkippt, lange Kanten leicht unregelmäßig (Vertex-Jitter 1–2 cm).
- Details sind übergroß: Schrauben, Griffe und Räder ca. 1,5-fach realer Größe. Kleinstes lesbares Detail: ca. 8 cm.
- Silhouetten von oben lesbar halten: charakteristische Teile (Griffe, Antennen, Schilder) ragen über die Grundform hinaus.
- Polygonzahl ist Nebensache; Lesbarkeit und saubere Flächen zählen. Richtwert für Requisiten: 300–3 000 Dreiecke.

### 2.3 Farbe statt Textur

- Keine Bildtexturen. Farbe kommt aus der Palette (Vertex-Farben bzw. Materialparameter).
- Pro Objekt höchstens 3 Hauptfarben plus Akzent. Große Flächen in ruhigen Tönen, Akzente (Senf, Signalrot) sparsam.
- Abnutzung über leichte Farbvariation pro Teil (±4 % Helligkeit), nicht über Schmutztexturen.

### 2.4 Licht: goldener Nachmittag

- Sonne flach aus Südwest (hinter der Kamera links), warmes Licht.
- Schatten sind **pflaumenfarben getönt**, nie grau oder schwarz.
- Drei klare Helligkeitsstufen (Licht, Halbschatten, Schatten) mit weichen Übergängen.
- Ein warmer Lichtsaum an den Kanten trennt Objekte vom Boden.
- Dunkelbraune Umrisslinien (Tintenfarbe, nicht Schwarz) betonen Silhouetten.
- Ein dezenter Miniatur-Effekt (Tilt-Shift-Unschärfe am oberen und unteren Bildrand, leichte Vignette) verstärkt den Diorama-Charakter.

## 3. Palette

| Name | Hex | Einsatz |
|---|---|---|
| Rost | `#9A4A22` | Altes Metall, Fässer, Schrott |
| Rost hell | `#C8642D` | Markenfarbe, Flicken, Akzentflächen |
| Senf | `#E0A93B` | Klebeband, Warnteile, Hervorhebung, Münzen |
| Creme | `#F2E6CF` | Schilder, Papier, UI-Text |
| Moos | `#6F8A4A` | Pflanzen, Platinen, kleine Lebenszeichen |
| Petrol | `#3E8A86` | Lackierte Teile, Walts Lieblingsfarbe, Flicken |
| Stahlblau | `#5E7C8C` | Neues Metall, Werkzeug, Wellblech |
| Holz | `#8A6440` | Kisten, Tische, Zäune |
| Holz dunkel | `#4E3A28` | Pfosten, Griffe, Beine |
| Sand | `#B39A72` | Hofboden |
| Erde | `#8C7A5B` | Boden außerhalb, Diorama-Sockel |
| Tinte | `#2B211B` | Umrisse, UI-Hintergrund |
| Pflaume | `#5B4560` | Schattentönung |

## 4. Humor im Bild

Visueller Humor folgt den Säulen aus `lore-walt-wren.md` und wird sparsam eingesetzt:

- **Erfinderischer Unsinn:** Walts Apparate bestehen aus erkennbar zweckentfremdeten Teilen (Kaffeedose als Motor, Bratpfanne als Abdeckung, Gießkanne als Trichter).
- **Schilder und Etiketten** erzählen mit Symbolen statt mit eingebranntem Text (Lokalisierung): Ausrufezeichen, Pfeile, ein durchgestrichener Knopf.
- **Kleine Widersprüche:** eine Warnleuchte ohne erkennbaren Zweck, eine Kiste mit mehr Nägeln als Brettern, eine Klingel am Annahmetresen, die mit Klebeband repariert ist.
- Humor stört nie die Lesbarkeit von Interaktionsobjekten.

## 5. Technische Pipeline

- **Modelle** werden per Python-Skript in Blender erzeugt (`tools/blender/build_props.py` für Hauptobjekte, `tools/blender/props_world.py` für Welt, Fundstücke und Bewuchs), reproduzierbar und versioniert. Ausgabe: `.glb` nach `assets/models/`. Der Hof-Generator `tools/build_blockout.gd` platziert sie mit einfachen Kollisionsboxen.
- **Maßstab:** 1 Blender-Einheit = 1 m. Ursprung in der Bodenmitte des Objekts. Vorderseite zeigt in Blender nach −Y (wird in Godot +Z = Modellvorderseite).
- **Farben** als Vertex-Farben (Farbattribut `Col`) auf einem einzigen Material `Scrap`. Godot ersetzt es beim Import durch das gemeinsame Toon-Material.
- **Benannte Teilknoten** (z. B. `Closed`, `Open`, `Debris`, `Beam`) werden als leere Eltern-Objekte angelegt, damit Spielskripte Zustände umschalten können.
- **Shader:** `assets/shaders/toon.gdshader` (Stufenlicht, Schattentönung, Lichtsaum) und `outline.gdshader` (Umriss als zweiter Pass). Blockout-Geometrie nutzt denselben Shader mit Farbparameter.
- **Kollision** bleibt einfach und wird in den Godot-Szenen gepflegt, nicht im Modell.

Ablauf nach einer Modelländerung:

```bash
blender -b -P tools/blender/build_props.py -- --out assets/models --preview tests/_output/blender
godot --headless --path . --import
godot --headless --path . -s res://tools/configure_model_imports.gd   # einmalig je neuem Modell
godot --headless --path . --import
godot --headless --path . -s res://tools/build_blockout.gd            # wenn Gebäude/Deko im Hof betroffen sind
```

`--only <name>` baut ein einzelnes Modell. Die Vorschau-Renders verwenden die Winkel der Spielkamera.

## 6. Umgebung und Assetfamilien

Das erste Grundstück enthält Einfahrt, Büro/Werkstatt, Werkbank, Annahmetresen, mehrere unterscheidbare Schrotthaufen, Lagerzone, freie Arbeitsfläche und später Scrappys Fundort. Es soll unordentlich, aber einladend wirken – nie bedrohlich.

Wiederverwendbare Familien: Boden (Sand, verdichtete Erde, Beton), Schrott (Bleche, Rohre, Reifen, Fässer, Geräte, Fahrzeugteile), Gebäude (Büro, Schuppen, Lager), Maschinen, Requisiten (Paletten, Zäune, Schilder, Lampen, Container), Scrappy-Teile.

## 7. Visueller Fortschritt

Der Hof wird mit dem Betrieb sichtbar sauberer, geordneter, belebter und farbiger. Neue Assets kommunizieren Fortschritt auf einen Blick (siehe 2.1: neu = gerade und sauber).

## 8. Performance

Instanzen für wiederholte Requisiten, ein gemeinsames Material für alle Modelle, keine Texturen, einfache Kollisionen, zurückhaltende Animationen. Der Umrisspass verdoppelt die Draw Calls der Modelle; bei Bedarf wird er für Kleinteile abgeschaltet.

## 9. Umsetzungsstand (Art-Direction-Prototyp)

Vorher/Nachher: `docs/art/before_after.png`, Einzelbilder in `docs/art/before/` und `docs/art/after/`, Modellübersichten `docs/art/blender_props_contact_sheet.png` und `docs/art/blender_world_contact_sheet.png`.

| Bereich | Stand |
|---|---|
| Toon-Shader, Umrisse, Schattentönung, Lichtsaum | Umgesetzt, gilt für Modelle und Blockout |
| Miniatur-Effekt (Tilt-Shift, Vignette) | Umgesetzt (`ui/post/DioramaPost.tscn`) in Spiel und Menü |
| Blender-Modelle | 50 Modelle: alle Gebäude, Stationen, Suchquellen, Zäune (je 3 Varianten hoch/niedrig), Tor, Ziegelmauer, Träger, drei Schrotthaufen, Autowrack, Container mit Katze, Motorblock, Lagerzone (Kisten, Fässer, Regal mit Gummiente), Paletten, Reifen, Badewannen-Beet, Hofstrahler, Zerlegetisch, Lieferware, alle Fundstücke, Spielfigur, drei Grasbüschel-Varianten |
| Noch Blockout-Primitive | Boden, Wege, Maschinenfläche (bewusst flach), Zaun-Endpfosten |
| Spielfigur | Modell aus gelenkigen Gruppen (Beine, Torso, Kopf, Arme, Korb). Prozedurale Animation ohne Skelett (`scripts/player/PlayerAnimator.gd`): Laufzyklus mit Arm-/Beinschwung und Wippen, Atmen im Stand, kleines Stauchen beim Abbremsen, Arbeitshaltung beim Halten, Greifbewegung beim Aufheben, Korbfüllung nach belegten Plätzen |
| Effekte | `scripts/fx/WorldFx.gd`: aufgehobene Teile fliegen im Bogen in den Korb (Korb wippt), Staubwölkchen bei Schritten, Ablegen, Durchsuchen, Bergen und Lieferung, Münzregen beim Verkauf. Rein darstellend |

## 10. Abgrenzung zu menschlicher Kunstarbeit

Requisiten, Gebäude, Maschinen, Shader und Licht entstehen im Projekt per Skript. Figuren mit hohem Charakteranspruch (Spielfigur, Scrappy, NPCs), Rigging und Animation, Key Art und das finale Logo sollen später von einer Character- bzw. Illustrationsperson übernommen oder verfeinert werden. Bis dahin werden stilgerechte Platzhalter verwendet.

## 11. Klang und Musik

**Richtung:** warm, hölzern, ein wenig schief – wie der Hof selbst. Musik ist entspannt und verschmitzt, Geräusche sind kurz, weich und nie schrill. Humor entsteht auch akustisch aus Objekten (die geklebte Klingel am Tresen, das Wählscheibentelefon im Büro, ein seltenes „Klonk“ im Takt der Hofmusik).

| Bereich | Umsetzung |
|---|---|
| Hofmusik „Old Yard Shuffle“ | 96 BPM Swing in F-Dur, 32 Takte (80 s Loop): Marimba-Melodie, Ukulele-Offbeats, Kontrabass, Besen, Holzblock, alle 8 Takte ein Schrott-„Klonk“, Flächenklang im B-Teil |
| Menüthema „Every Scrap Has a Story“ | 72 BPM, 16 Takte (53 s Loop): dasselbe Motiv auf einer Spieluhr über Flächenklang und gezupftem Bass |
| Hof-Atmosphäre | 38-s-Loop aus leisem Wind, entfernten Vögeln und gelegentlichem Knarzen |
| Geräusche | 25 Klangarten mit bis zu 4 Varianten: Schritte, Aufnahmeklang je Fundstück (in den Itemdaten festgelegt), Korb, Ablegen, Ablehnung, Tresenklingel, Kasse, Münzen, Katalogseite, Papier, Wählscheibe, Lieferung, Kauf-Jingle, Schalter, Fund-„Plopp“, Klick, Halte-Loops (Wühlen, Flaschenzug, Schraubenzieher), Knarzen |

**Technik:**

- Alle Klänge entstehen per Klangsynthese aus `tools/audio/synth_audio.py` (numpy/scipy), reproduzierbar, ohne Samples und ohne Fremdlizenzen. Ausgabe: WAV 32 kHz mono unter `assets/audio/`, Bibliothek `data/audio/sound_library.tres`.
- Loops sind nahtlos (Nachklang wird zirkulär berechnet); Pegelprüfung: keine Übersteuerung, Spitzen −1 bis −10 dBFS je nach Rolle.
- Wiedergabe ohne Autoload, szenenlokal: `SoundFx` (Player-Pool, Varianten, leichte Tonhöhenvariation, Halte-Loops), `MusicPlayer` (Einblenden, Loop), `UiSounds` (Klick für jede Schaltfläche). Busse: Master, Music, SFX (mit dezentem Hall).
- Lautstärke für Musik und Geräusche ist in den Einstellungen regelbar und wird gespeichert.

**Grenzen:** Synthesizer-Klang erreicht kein Studio-Niveau echter Aufnahmen. Für eine Veröffentlichung sollten Musik und zentrale Geräusche von einer Sound-Designerin bzw. einem Sound-Designer überarbeitet oder ersetzt werden; die Bibliothek erlaubt den Austausch ohne Codeänderung.

