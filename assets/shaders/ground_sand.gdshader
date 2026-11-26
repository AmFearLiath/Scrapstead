// Scrapstead ground, art style 2 (docs/art-style-2.md): warm desert sand with
// large lighter/darker drifts, fine grain, soft wind ripples, compacted and
// dirtier patches and a few pebbles. World-space, so placed objects and the
// camera never show seams. Lit normally (no toon steps).
shader_type spatial;
render_mode cull_back;

uniform sampler2D large_noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D detail_noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 sand_light : source_color = vec4(0.88, 0.62, 0.44, 1.0);
uniform vec4 sand_dark : source_color = vec4(0.78, 0.52, 0.36, 1.0);
uniform vec4 compacted : source_color = vec4(0.88, 0.73, 0.56, 1.0);
uniform vec4 pebble : source_color = vec4(0.66, 0.46, 0.35, 1.0);
uniform float drift_scale = 0.018;
uniform float detail_scale = 0.35;
uniform float ripple_strength : hint_range(0.0, 1.0) = 0.35;
uniform float compacted_amount : hint_range(0.0, 1.0) = 0.45;
uniform float brightness : hint_range(0.5, 1.5) = 1.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_position.xz;
	float drift = texture(large_noise, p * drift_scale).r;
	float drift2 = texture(large_noise, p * drift_scale * 2.7 + vec2(0.31, 0.77)).r;
	float detail = texture(detail_noise, p * detail_scale).r;
	float grain = texture(detail_noise, p * 2.4 + vec2(0.5, 0.2)).r;
	// Wind ripples: stretched bands bent by the drift noise.
	float ripple = sin((p.x * 0.8 + p.y * 2.6) * 3.0 + drift2 * 9.0) * 0.5 + 0.5;
	ripple = smoothstep(0.55, 1.0, ripple) * ripple_strength * smoothstep(0.35, 0.7, drift);
	vec3 colour = mix(sand_dark.rgb, sand_light.rgb, smoothstep(0.25, 0.8, drift * 0.7 + drift2 * 0.3));
	colour *= 0.93 + 0.14 * detail;
	colour *= 0.96 + 0.08 * grain;
	colour = mix(colour, colour * 1.07, ripple);
	// Compacted, darker ground where vehicles and feet have pressed it.
	float pressed = smoothstep(0.62, 0.78, texture(large_noise, p * drift_scale * 1.6 + vec2(0.7, 0.1)).r) * compacted_amount;
	colour = mix(colour, compacted.rgb * (0.92 + 0.16 * detail), pressed);
	// Pebbles.
	float stones = smoothstep(0.78, 0.82, texture(detail_noise, p * 1.3 + vec2(0.13, 0.91)).r);
	colour = mix(colour, pebble.rgb, stones * 0.7);
	ALBEDO = colour * brightness;
	ROUGHNESS = 0.97;
	SPECULAR = 0.2;
	// Ripples and pebbles catch the low sun a little.
	vec3 bump = vec3((ripple - 0.5) * 0.15 + (stones - 0.5) * 0.1, 1.0, (detail - 0.5) * 0.12);
	NORMAL = normalize((VIEW_MATRIX * vec4(normalize(bump), 0.0)).xyz);
}
