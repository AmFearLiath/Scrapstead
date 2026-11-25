# Scrapstead — Zentrale Entwicklungswerkstatt und Admin-Tooling

**Version:** 0.1  
**Status:** Architektur- und Produktionsprinzip beschlossen; konkrete Werkzeuge werden schrittweise festgelegt  
**Engine:** Godot 4.7.2 Stable / GDScript  
**Geltungsbereich:** Entwicklung, Konfiguration, Content-Erstellung, Weltbearbeitung und interne Administration

---

## 1. Ziel und Leitentscheidung

Scrapstead erhält eine zentrale Entwicklungswerkstatt, über die das Spiel konfiguriert, gepflegt, erweitert und mit Inhalten versorgt werden kann.

Diese Werkstatt ist nicht zwingend ein eigenständiger, vollständig neu entwickelter Editor. Sie darf Godot-interne Ressourcen, den Godot-Editor, EditorPlugins, Inspector-Erweiterungen, Tool-Skripte und spezialisierte Werkzeuge verwenden.

**Leitentscheidung: Eine zentrale Anlaufstelle für alle Entwicklungs- und Verwaltungsaufgaben – mit spezialisierten Werkzeugen im Hintergrund.**

Die Werkstatt soll verhindern, dass relevante Einstellungen, Daten und Inhalte über unübersichtliche Dateien, verstreute Editorfenster und manuelle Codeänderungen gepflegt werden müssen.

Der zentrale Einstieg ist verbindlich. Nicht jede Funktion muss in einer einzigen Oberfläche neu implementiert werden.

## 2. Grundprinzipien

1. **Zentraler Zugang:** Entwickler finden die relevanten Werkzeuge und Verwaltungsbereiche an einer klaren Stelle.
2. **Spezialisierte Werkzeuge:** Werte, Texte, Quests, NPCs, Gebäude und Karten dürfen jeweils eigene Editoren verwenden.
3. **Godot-native Umsetzung bevorzugt:** Godot Resources, Szenen, EditorPlugins, Inspector-Erweiterungen und Tool-Skripte werden genutzt, sofern sie die Aufgabe sinnvoll abdecken.
4. **Daten statt Codeänderung:** Spielinhalte und Balancingwerte werden möglichst über Daten und Ressourcen konfiguriert, nicht durch Änderungen an Gameplay-Code.
5. **Eine Datenquelle:** Editor und Spiel verwenden dieselben verbindlichen Definitionen und Datenformate. Es gibt keine separate, manuell gepflegte Kopie der Spielwerte.
6. **Validierung:** Werkzeuge prüfen Pflichtfelder, Referenzen, Wertebereiche, IDs, Abhängigkeiten und strukturelle Fehler.
7. **Vorschau und Test:** Wo sinnvoll, können Inhalte direkt geprüft oder in einer Vorschau geöffnet werden.
8. **Versionierung:** Datenformate und Ressourcen erhalten nachvollziehbare Versionen und bei Bedarf Migrationen.
9. **Schrittweiser Ausbau:** Die Werkstatt wächst mit den tatsächlichen Spielsystemen. Es wird kein vollständiges universelles Redaktionssystem vor P0 gebaut.
10. **Entkopplung vom Release:** Die Entwicklungswerkstatt muss nicht Bestandteil des fertigen Spiels sein und darf aus dem Release-Build ausgeschlossen werden.

## 3. Verwaltungsbereiche

Die folgenden Bereiche bilden den langfristigen Funktionsrahmen. Ihre Umsetzung erfolgt nach Bedarf und Entwicklungsphase.

### 3.1 Projekt- und Systemübersicht

- Zentrale Startseite für die Entwicklungswerkstatt.
- Übersicht über verfügbare Werkzeuge und Datenbereiche.
- Status von Datenvalidierung und bekannten Fehlern.
- Verweise auf betroffene Ressourcen, Szenen und Dokumentation.
- Hinweise auf veraltete oder nicht kompatible Datenformate.
- Schneller Zugriff auf häufig verwendete Werkzeuge.

### 3.2 Werte, Balancing und Formeln

Konfigurierbar sein sollen alle spielrelevanten Werte, Preise und Formeln, soweit sie nicht aus technischen Gründen fest im Code liegen müssen.

Beispiele:
- Gegenstandswerte und Verkaufspreise.
- Material- und Verarbeitungskosten.
- Maschinenleistung, Durchsatz und Verbrauch.
- Produktions- und Verarbeitungszeiten.
- Mitarbeiterkosten und Tätigkeitsleistung.
- Upgrade-Kosten und Effekte.
- Lager-, Transport- und Kapazitätswerte.
- Nachfrage-, Angebots- und Preisparameter.
- Belohnungen, Gebühren und sonstige Wirtschaftswerte.
- Bewegungs-, Interaktions- und sonstige Gameplay-Parameter, soweit sie als Designwerte gelten.

Formeln sollen, wo sinnvoll, als nachvollziehbare Konfiguration oder aus wiederverwendbaren Formelbausteinen zusammengesetzt werden können. Beliebige Codeausführung aus Daten ist nicht das Ziel. Die Lösung muss sicher, testbar, validierbar und für Entwickler verständlich bleiben.

### 3.3 Texte und Lokalisierung

- Dialoge und NPC-Texte.
- Beschreibungen, Tooltips und Objekttexte.
- Questtexte und Missionsziele.
- Benachrichtigungen und Systemmeldungen.
- Tutorial- und Hilfetexte.
- Lokalisierte Textvarianten.
- Prüfung auf fehlende Übersetzungen und ungültige Textreferenzen.

Texte sollen über stabile IDs referenziert werden, damit Änderungen an Formulierungen keine Gameplay-Referenzen beschädigen.

### 3.4 Quests, Missionen und Ereignisse

- Quests und Questketten erstellen und bearbeiten.
- Voraussetzungen, Auslöser und Ziele konfigurieren.
- Belohnungen und Konsequenzen festlegen.
- NPCs, Orte, Gegenstände und andere Referenzen zuweisen.
- Abhängigkeiten und mögliche unerreichbare Zustände validieren.
- Questabläufe und Verzweigungen soweit möglich visualisieren oder testen.

### 3.5 NPCs und Bewohner

- NPC-Definitionen und Identitäten verwalten.
- Namen, Aussehen-/Szenenreferenzen und Eigenschaften zuweisen.
- Dialoge und Beziehungen referenzieren.
- Rollen, Tätigkeiten und Verfügbarkeiten konfigurieren.
- Zugehörige Quests und Ereignisse verknüpfen.
- Fehlende oder ungültige Abhängigkeiten erkennen.

Das Tooling bearbeitet Definitionen und Verknüpfungen. Die eigentliche 3D-Modellierung und Animation darf weiterhin in Godot und geeigneten externen DCC-Werkzeugen stattfinden.

### 3.6 Gebäude, Objekte und Bauinhalte

- Gebäudedefinitionen und Fertiggebäude verwalten.
- Modulare Bauteile und Kompatibilitäten konfigurieren.
- Snap-Punkte, Anschlüsse und Platzierungsregeln pflegen.
- Funktionsbereiche und erforderliche Zugänge definieren.
- Objekt- und Maschinenressourcen zuordnen.
- Vorschau und Platzierungstests ermöglichen.

Die Werkstatt muss keine vollständige 3D-Modellierungssoftware ersetzen. Geometrie und Szenen können mit Godots vorhandenen Werkzeugen oder externen DCC-Programmen erstellt werden. Die zentrale Werkstatt verwaltet ihre Zuordnung, Metadaten, Regeln und Validierung.

### 3.7 Flächen, Karten und Weltaufbau

- Welt- und Kartenressourcen verwalten.
- Gebiete, Teilbereiche, Grundstücke und Zugänge definieren.
- Szenen und räumliche Inhalte zuordnen.
- Landmarken, Spawnpunkte, Sammelstellen und relevante Orte pflegen.
- Weltzustände und Freischaltbedingungen konfigurieren.
- Karten- und Levelressourcen öffnen, bearbeiten und testen.

Die eigentliche Levelgeometrie bleibt vorzugsweise in Godot-Szenen und Godot-kompatiblen Levelwerkzeugen. Die Werkstatt bietet einen zentralen Einstieg und zusätzliche projektbezogene Verwaltungsfunktionen.

## 4. Technisches Zielbild

Die Entwicklungswerkstatt wird bevorzugt als Erweiterung des Godot-Editors aufgebaut:

- Zentrales Dashboard bzw. Werkzeug-Übersicht als Einstieg.
- Eigene EditorPlugins oder Editor-Docks für spezielle Verwaltungsbereiche.
- Godot Resources als typisierte Datencontainer, wo sie sinnvoll sind.
- Godot-Szenen für räumliche und visuelle Inhalte.
- Strukturierte, versionierte Daten für Inhalte, die besser als Tabellen-/Datensatzsammlungen gepflegt werden.
- Inspector-Erweiterungen für häufige und kontextbezogene Bearbeitung.
- Tool-Skripte für Import, Export, Validierung und wiederholbare Aufgaben.
- Vorschau-Szenen für Inhalte, die im Editor isoliert getestet werden können.

Die konkrete technische Form darf je nach Bereich variieren. Entscheidend ist, dass alle Werkzeuge dieselben Datenverträge und Referenzen verwenden.

Ein separater externer Admin-Client ist nicht grundsätzlich ausgeschlossen, aber nicht die bevorzugte erste Lösung. Er würde nur eingeführt, wenn Godots Editorwerkzeuge für einen konkreten Arbeitsablauf nachweislich ungeeignet sind.

## 5. Datenhoheit und Konfiguration

- Es gibt eine eindeutige Quelle für jede Definition.
- Gameplay-Code konsumiert Definitionen und führt Regeln aus; er enthält nicht unnötig viele fest codierte Balancingwerte.
- Stabile IDs werden für Gegenstände, NPCs, Quests, Gebäude, Kartenbereiche und andere referenzierte Inhalte verwendet.
- Referenzen werden geprüft, bevor Daten im Spiel verwendet werden.
- Fehlende, doppelte oder ungültige IDs werden als Validierungsfehler gemeldet.
- Änderungen an Datenformaten werden versioniert und bei Bedarf migriert.
- Laufzeit-Spielstände bleiben von bearbeitbaren Inhaltsdefinitionen getrennt.
- Nicht jede technische Konstante muss im Admin-Bereich sichtbar sein. Sichtbar und konfigurierbar sind vor allem Design-, Balancing- und Content-Entscheidungen.

## 6. Aktualität und Synchronisierung

Die Entwicklungswerkstatt muss mit dem Spiel und seinen Systemen aktuell bleiben.

Dafür gelten folgende Regeln:

- Neue Gameplay-Systeme erhalten bei ihrer Einführung auch die notwendigen Konfigurations- und Verwaltungszugänge.
- Änderungen an Datenmodellen werden zusammen mit den zugehörigen Werkzeugen angepasst.
- Neue Felder und Referenztypen werden nicht nur im Spielcode ergänzt, sondern auch in den passenden Editoren und Validatoren berücksichtigt.
- Veraltete Daten werden erkannt und mit klaren Hinweisen gemeldet.
- Automatisierte Validierung prüft die Konsistenz zwischen Definitionen, Referenzen und unterstützten Datenversionen.
- Dokumentation beschreibt, welche Bereiche über welche Werkzeuge gepflegt werden.
- Kein Verwaltungsbereich darf dauerhaft eine zweite, abweichende Wahrheit über die Spieldaten führen.

**Aktualität ist eine Architektur- und Qualitätsanforderung, keine optionale spätere Komfortfunktion.**

## 7. Testen, Vorschau und Freigabe

Wo es einen echten Mehrwert bietet, soll die Werkstatt Folgendes ermöglichen:

- Einzelne Ressourcen in einer Vorschau öffnen.
- NPC- und Questabläufe in Testzuständen prüfen.
- Werte und Formeln mit Beispielwerten simulieren.
- Gebäude und Module auf Kompatibilität prüfen.
- Kartenbereiche und Szenen direkt öffnen.
- Referenzen und Abhängigkeiten anzeigen.
- Daten vor dem Einsatz validieren.
- Änderungen nachvollziehbar vergleichen.

Nicht jede Funktion benötigt einen eigenen Simulator. Vorschau und Test werden dort umgesetzt, wo sie Fehler vermeiden oder Iterationen deutlich beschleunigen.

## 8. Trennung zwischen Entwicklungswerkstatt und Spiel

Die Werkstatt ist primär ein Entwicklungswerkzeug.

- Sie darf als Godot-Editor-Erweiterung existieren.
- Sie muss nicht im fertigen Spiel verfügbar sein.
- Editor-only-Funktionen und Entwicklungsdaten werden nicht unnötig in den Release-Build übernommen.
- Das Spiel muss mit den freigegebenen Daten auch ohne installierte Entwicklungswerkstatt lauffähig sein.
- Ein kleiner interner Debug- oder Admin-Modus im Spiel kann später sinnvoll sein, ist aber eine separate Entscheidung.
- Es wird keine Online-Administration, kein Web-Backend und kein Laufzeit-Adminserver vorausgesetzt.

Die Release-Version verwendet die benötigten Spieldaten und Gameplay-Systeme, nicht zwingend die Werkzeuge, mit denen diese Daten erstellt wurden.

## 9. Umfang und Umsetzungsstrategie

Die Werkstatt wird inkrementell aufgebaut und folgt der tatsächlichen Entwicklung.

### Frühe Grundlage
- Einheitliche Datenkonventionen und stabile IDs.
- Zentrale Werkzeug-Übersicht.
- Validierung und verständliche Fehlerausgabe.
- Zugriff auf die relevanten Godot-Ressourcen und Szenen.
- Konfiguration der ersten tatsächlich vorhandenen Gameplay-Werte.

### Mit den jeweiligen Spielsystemen
- Wirtschafts- und Balancingeditoren mit den Wirtschaftssystemen.
- Text- und Lokalisierungsverwaltung mit dem Content-Bedarf.
- Quest- und NPC-Verwaltung mit der Einführung dieser Systeme.
- Gebäude- und Modulverwaltung mit dem Bausystem.
- Karten- und Flächenwerkzeuge mit der Levelproduktion.

### Spätere Ausbaustufe
- Erweiterte Vorschau und Simulation.
- Änderungsvergleiche und Prüfberichte.
- Komfortfunktionen für größere Content-Mengen.
- Optionaler separater Admin-Client, falls ein konkreter Bedarf entsteht.

**Wichtig:** Die Entwicklungswerkstatt darf die Fertigstellung des spielbaren Kerns nicht blockieren. Sie wird parallel nur so weit ausgebaut, wie es für die jeweils aktiven Systeme notwendig ist.

## 10. Nicht-Ziele

- Kein vollständiger Ersatz für den Godot-Editor.
- Keine eigene 3D-Modellierungssoftware.
- Kein universelles CMS, das sämtliche Werkzeuge neu implementiert.
- Kein verpflichtendes Web-Backend oder Online-Adminsystem.
- Keine beliebige Ausführung von Code oder Skripten aus Content-Daten.
- Keine zweite manuell gepflegte Datenbank neben den eigentlichen Spieldaten.
- Kein vollständiger Editor für zukünftige Systeme, bevor diese überhaupt existieren.

## 11. Erfolgskriterien

Die Entwicklungswerkstatt erfüllt ihr Ziel, wenn:

1. Entwickler von einer zentralen Stelle aus die relevanten Verwaltungs- und Bearbeitungswerkzeuge erreichen.
2. Balancingwerte, Preise und geeignete Formeln ohne Änderungen am Gameplay-Code angepasst werden können.
3. Texte, Quests und NPC-Definitionen zentral gepflegt werden können.
4. Gebäude, Flächen und Karten mit geeigneten Godot-Werkzeugen erstellt und bearbeitet werden können.
5. Referenzen und Datenkonsistenz zuverlässig geprüft werden.
6. Neue Spielsysteme ihre erforderlichen Verwaltungswerkzeuge mitbringen.
7. Werkzeuge und Datenmodelle nicht auseinanderlaufen.
8. Das Spiel ohne die Entwicklungswerkstatt als Bestandteil des Release-Builds funktioniert.

---

**Leitgedanke:** Eine zentrale Werkstatt für das gesamte Projekt – nicht ein monolithischer Editor, sondern ein zusammenhängender Zugang zu den jeweils besten Werkzeugen.
