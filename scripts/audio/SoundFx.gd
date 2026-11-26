extends Node
## Scene-local sound effect player (no autoload, see p0-implementation-readiness.md).
## Plays named sounds from a SoundLibrary on the SFX bus with a small player
## pool, random variants and slight pitch variation; loops for held actions.

## Emitted for every sound that starts (diagnostics and tests).
signal played(sound_name: String)

@export var library: SoundLibrary
@export_range(1, 32) var voices: int = 10

var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _last_variant: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	for index: int in voices:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_players.append(player)


## Plays a one-shot sound. Unknown names are ignored with a debug warning.
func play(sound_name: String, volume_db: float = 0.0, pitch_variation: float = 0.05) -> void:
	var stream: AudioStream = _pick(sound_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + _rng.randf_range(-pitch_variation, pitch_variation)
	player.play()
	played.emit(sound_name)


## Plays several one-shots with a small delay between them.
func play_burst(sound_name: String, count: int, interval: float, volume_db: float = 0.0) -> void:
	for index: int in count:
		get_tree().create_timer(interval * index).timeout.connect(play.bind(sound_name, volume_db))


## Starts a looping sound and returns its player (stop it with stop_loop).
func start_loop(sound_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	var stream: AudioStream = _pick(sound_name)
	if stream == null:
		return null
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	player.stream = AudioLoop.looping(stream)
	player.volume_db = volume_db
	add_child(player)
	player.play()
	played.emit(sound_name)
	return player


## Fades out and frees a loop player.
func stop_loop(player: AudioStreamPlayer) -> void:
	if not is_instance_valid(player):
		return
	var tween: Tween = player.create_tween()
	tween.tween_property(player, "volume_db", -40.0, 0.15)
	tween.tween_callback(player.queue_free)


func _pick(sound_name: String) -> AudioStream:
	if library == null or not library.has_sound(sound_name):
		if OS.is_debug_build():
			push_warning("SoundFx: unknown sound '%s'." % sound_name)
		return null
	var variants: Array = library.get_variants(sound_name)
	var index: int = _rng.randi_range(0, variants.size() - 1)
	if variants.size() > 1 and index == _last_variant.get(sound_name, -1):
		index = (index + 1) % variants.size()
	_last_variant[sound_name] = index
	return variants[index]
