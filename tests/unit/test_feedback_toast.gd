extends TestSuite
## Feedback toast: short results stay brief, long notes stay readable.

const TOAST: GDScript = preload("res://scripts/ui/FeedbackToast.gd")


func test_display_time_grows_with_text_length_within_bounds() -> void:
	check_near(TOAST.display_seconds_for("Aufgehoben: Dose"), 2.6, 0.001, "short message keeps the base time")
	var note: String = "Frau Pohl hat am Tor Schrott abgeladen: „Aus dem Keller meines Mannes. Er hat alles aufgehoben. ALLES.“"
	var long_time: float = TOAST.display_seconds_for(note)
	check(long_time > 5.0 and long_time <= 7.0, "delivery note readable (%.1f s)" % long_time)
	check_near(TOAST.display_seconds_for("x".repeat(1000)), 7.0, 0.001, "never longer than the cap")
