shader_type canvas_item;

// Sets painted lightning and glowing cracks crackling: drawn over them, it
// re-reads the picture underneath and makes the bright, hot pixels flicker
// - a restless shimmer running along them - and flare white-hot whenever
// `strike` is raised (the script pulses it for each lightning strike).
// Everything darker than the bolts is left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float strike = 0.0;
uniform float flicker = 0.45;
uniform vec4 strike_color : source_color = vec4(1.0, 0.75, 0.85, 1.0);
uniform vec4 edge_fade = vec4(0.08, 0.001, 0.08, 0.15);

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float l = dot(col, vec3(0.299, 0.587, 0.114));
	float bolt = smoothstep(0.5, 0.75, l) * smoothstep(0.08, 0.25, col.r - col.g);

	// A jittery shimmer running along the bolts, and a whole-bolt flutter.
	float run = value_noise(px / 14.0 + vec2(0.0, -TIME * 12.0));
	float flutter = value_noise(vec2(TIME * 9.0, 3.0));
	float f = (run * 0.6 + flutter * 0.4 - 0.4) * flicker;

	col += col * bolt * f;
	col += strike_color.rgb * bolt * strike * 1.2;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
