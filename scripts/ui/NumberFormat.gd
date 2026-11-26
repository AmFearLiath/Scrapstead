class_name NumberFormat
extends RefCounted
## Locale-aware number formatting for UI text (docs/localization.md).
## German uses a decimal comma and a dot as thousands separator.

const COMMA_DECIMAL_LOCALES: PackedStringArray = ["de", "fr", "es", "it", "nl", "pl", "pt", "cs"]


## Decimal number with up to `digits` decimals; trailing zeros are dropped
## ("3,5", "4", never "4,0").
static func decimal(value: float, digits: int = 1, locale: String = "") -> String:
	var text: String = String.num(snappedf(value, pow(10.0, -digits)), digits)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	var parts: PackedStringArray = text.split(".")
	var whole: String = group_thousands(parts[0], locale)
	if parts.size() == 1:
		return whole
	return whole + (_decimal_mark(locale)) + parts[1]


## Integer with thousands separators ("1.250" in German, "1,250" in English).
static func integer(value: int, locale: String = "") -> String:
	return group_thousands(str(value), locale)


static func group_thousands(digits: String, locale: String = "") -> String:
	var negative: bool = digits.begins_with("-")
	var plain: String = digits.trim_prefix("-")
	var separator: String = "." if _decimal_mark(locale) == "," else ","
	var result: String = ""
	while plain.length() > 3:
		result = separator + plain.right(3) + result
		plain = plain.left(plain.length() - 3)
	return ("-" if negative else "") + plain + result


static func _decimal_mark(locale: String) -> String:
	var language: String = (locale if not locale.is_empty() else TranslationServer.get_locale()).split("_")[0]
	return "," if COMMA_DECIMAL_LOCALES.has(language) else "."
