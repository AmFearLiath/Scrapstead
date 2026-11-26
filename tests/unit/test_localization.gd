extends TestSuite
## Localization table: placeholders like {value} must match between English
## and German (key parity and duplicates: test_economy::test_localization_parity).

const TABLE: String = "res://localization/scrapstead.csv"


func test_placeholders_match_between_languages() -> void:
	var file := FileAccess.open(TABLE, FileAccess.READ)
	if not check(file != null, "localization table readable"):
		return
	file.get_csv_line()
	var regex := RegEx.create_from_string(r"\{[a-z_]+\}")
	var mismatched: PackedStringArray = []
	var checked: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 3:
			continue
		checked += 1
		var english: Array = regex.search_all(row[1]).map(func(m: RegExMatch) -> String: return m.get_string())
		var german: Array = regex.search_all(row[2]).map(func(m: RegExMatch) -> String: return m.get_string())
		english.sort()
		german.sort()
		if english != german:
			mismatched.append(row[0])
	check(checked > 100, "rows checked")
	check(mismatched.is_empty(), "placeholder mismatch: %s" % ", ".join(mismatched))
