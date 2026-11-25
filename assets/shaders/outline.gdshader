// Ink outline as second material pass (inverted hull). Constant world-space
// thickness suits the orthographic game camera.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec4 outline_color : source_color = vec4(0.17, 0.13, 0.106, 1.0);
uniform float thickness : hint_range(0.0, 0.1) = 0.035;

void vertex() {
	VERTEX += normalize(NORMAL) * thickness;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
