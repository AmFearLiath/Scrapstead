extends AudioStreamPlayer
## Scene-local looping music or ambience with a gentle fade-in.

## Target volume after the fade-in.
@export var target_volume_db: float = -6.0
@export var fade_in_seconds: float = 2.0


func _ready() -> void:
	if stream == null:
		return
	stream = AudioLoop.looping(stream)
	volume_db = -40.0
	play()
	create_tween().tween_property(self, "volume_db", target_volume_db, fade_in_seconds)
