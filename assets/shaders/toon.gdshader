// Scrapstead toon shading (docs/world-art-assets.md, 2.4):
// three light steps with soft edges, ambient-tinted shadows, warm rim light.
shader_type spatial;
render_mode specular_disabled;

// Base colour; multiplied with vertex colour when use_vertex_color is on.
uniform vec4 albedo : source_color = vec4(1.0);
uniform bool use_vertex_color = false;
// Brightness of the half-lit step (0 = black, 1 = fully lit).
uniform float mid_step : hint_range(0.0, 1.0) = 0.68;
// Width of the soft transition between steps.
uniform float step_softness : hint_range(0.001, 0.3) = 0.05;
uniform vec4 rim_color : source_color = vec4(1.0, 0.82, 0.58, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.22;

void fragment() {
	vec3 base = albedo.rgb;
	if (use_vertex_color) {
		base *= COLOR.rgb;
	}
	ALBEDO = base;
	ROUGHNESS = 1.0;
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = pow(1.0 - facing, 3.0) * smoothstep(0.0, 0.4, NORMAL.y + 0.3);
	EMISSION = rim_color.rgb * base * rim * rim_strength;
}

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float lit = smoothstep(0.0, step_softness, ndl);
	float full = smoothstep(0.38 - step_softness, 0.38 + step_softness, ndl);
	float intensity = lit * mix(mid_step, 1.0, full) * ATTENUATION;
	DIFFUSE_LIGHT += LIGHT_COLOR * intensity / PI;
}
