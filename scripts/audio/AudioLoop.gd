class_name AudioLoop
extends RefCounted
## Helper to make imported WAV streams loop seamlessly over their full length.


## Returns a looping copy of a WAV stream (other stream types are returned as is).
static func looping(stream: AudioStream) -> AudioStream:
	var wav := stream as AudioStreamWAV
	if wav == null:
		return stream
	var copy: AudioStreamWAV = wav.duplicate()
	copy.loop_mode = AudioStreamWAV.LOOP_FORWARD
	copy.loop_begin = 0
	copy.loop_end = int(wav.get_length() * wav.mix_rate)
	return copy
