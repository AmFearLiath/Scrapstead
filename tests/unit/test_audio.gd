extends TestSuite
## Audio data and settings: every referenced sound exists, buses and volumes work.

const USED_SOUNDS: PackedStringArray = ["step", "clink", "tin", "wire", "wood", "brass", "box", "basket", "thud",
	"nope", "bell", "kaching", "coins", "page", "paper", "phone", "delivery", "jingle", "switch", "pop", "click",
	"rummage", "hoist", "screw", "creak"]

var _library: SoundLibrary


func before_each() -> void:
	_library = load("res://data/audio/sound_library.tres")


func test_library_contains_all_used_sounds() -> void:
	for sound_name: String in USED_SOUNDS:
		check(_library.has_sound(sound_name), "sound '%s' exists" % sound_name)
		for stream: Variant in _library.get_variants(sound_name):
			check(stream is AudioStreamWAV and (stream as AudioStream).get_length() > 0.02,
				"'%s' variant is a playable WAV" % sound_name)
	for loop_name: String in ["rummage", "hoist", "screw"]:
		check(_library.loops.has(loop_name), "%s marked as loop" % loop_name)


func test_item_pickup_sounds_exist() -> void:
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	for definition: ItemDefinition in catalog.items:
		check(_library.has_sound(definition.pickup_sound), "%s pickup sound exists" % definition.id)


func test_music_streams_loop() -> void:
	for path: String in ["res://assets/audio/music/old_yard_shuffle.wav",
			"res://assets/audio/music/every_scrap_has_a_story.wav", "res://assets/audio/ambience/yard_ambience.wav"]:
		var stream: AudioStreamWAV = AudioLoop.looping(load(path))
		check_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s loops" % path.get_file())
		check(stream.get_length() > 30.0, "%s is a full piece" % path.get_file())


func test_buses_and_volume_settings() -> void:
	check(AudioServer.get_bus_index(&"Music") != -1, "Music bus")
	check(AudioServer.get_bus_index(&"SFX") != -1, "SFX bus")
	var session: Node = tree.root.get_node("GameSession")
	var before: Variant = session.get_setting(session.SETTING_MUSIC_VOLUME)
	check(session.set_setting(session.SETTING_MUSIC_VOLUME, 0.25), "music volume accepted")
	check_near(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), linear_to_db(0.25), 0.01,
		"bus volume applied")
	check(session.set_setting(session.SETTING_SFX_VOLUME, 0.0), "zero volume accepted")
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"SFX")), "zero mutes the bus")
	check(not session.set_setting(session.SETTING_MUSIC_VOLUME, 3.0), "out of range rejected")
	session.set_setting(session.SETTING_MUSIC_VOLUME, before)
	session.set_setting(session.SETTING_SFX_VOLUME, 0.8)
