extends TestSuite
## Locale-aware number formatting.


func test_decimal_uses_locale_mark() -> void:
	check_eq(NumberFormat.decimal(3.5, 1, "de"), "3,5", "German decimal comma")
	check_eq(NumberFormat.decimal(3.5, 1, "en"), "3.5", "English decimal point")
	check_eq(NumberFormat.decimal(4.0, 1, "de"), "4", "no trailing zero")
	check_eq(NumberFormat.decimal(2.26, 1, "de_DE"), "2,3", "rounded to one digit with region suffix")


func test_integer_groups_thousands() -> void:
	check_eq(NumberFormat.integer(1250, "de"), "1.250", "German grouping")
	check_eq(NumberFormat.integer(1250, "en"), "1,250", "English grouping")
	check_eq(NumberFormat.integer(-1234567, "en"), "-1,234,567", "negative and millions")
	check_eq(NumberFormat.integer(999, "de"), "999", "small numbers unchanged")
