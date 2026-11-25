// Miniature look: soft tilt-shift blur towards the top and bottom edge plus a
// warm vignette. Drawn below the HUD.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Half height of the sharp band around the screen centre (0..0.5).
uniform float focus_band : hint_range(0.0, 0.5) = 0.3;
uniform float max_blur_lod : hint_range(0.0, 5.0) = 1.6;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.32;
uniform vec4 vignette_color : source_color = vec4(0.17, 0.10, 0.10, 1.0);

void fragment() {
	float distance_from_band = max(abs(SCREEN_UV.y - 0.5) - focus_band, 0.0) / (0.5 - focus_band);
	float lod = smoothstep(0.0, 1.0, distance_from_band) * max_blur_lod;
	vec3 color = textureLod(screen_texture, SCREEN_UV, lod).rgb;
	vec2 centered = SCREEN_UV - 0.5;
	float vignette = smoothstep(0.35, 0.85, length(centered * vec2(1.2, 1.0)));
	color = mix(color, color * vignette_color.rgb * 2.0, vignette * vignette_strength);
	COLOR = vec4(color, 1.0);
}
