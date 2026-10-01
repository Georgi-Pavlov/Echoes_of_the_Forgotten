shader_type canvas_item;

// Leaves rustling in a breeze: drawn over a painted tree canopy, it
// re-reads the picture underneath nudged a pixel or two by drifting noise,
// so clumps of leaves shiver and sway, harder when a gust comes through.
// The rect's edges fade out, so trunk and sky around it stay put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float amplitude_px = 1.8;
uniform float speed = 0.8;
// Size of the leaf clumps that move together, in screen pixels.
uniform float clump_px = 26.0;
uniform vec4 edge_fade = vec4(0.25, 0.001, 0.1, 0.25);

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
	vec2 size = vec2(1280.0, 720.0);
	vec2 p = SCREEN_UV * size / clump_px;
	float t = TIME * speed;
	// Gusts: the whole canopy stirs harder every few seconds.
	float gust = 0.55 + 0.45 * sin(TIME * 0.7) * sin(TIME * 0.31 + 1.0);
	vec2 shove = vec2(value_noise(p + vec2(t, 0.0)) - 0.5,
			value_noise(p + vec2(7.3, t * 1.3)) - 0.5) * 2.0;
	// Plus a slow lean the same way, as the breeze pushes.
	shove.x += sin(TIME * 0.5) * 0.4;
	vec2 offset = shove * amplitude_px * gust / size;
	vec3 col = textureLod(screen_tex, SCREEN_UV + offset, 0.0).rgb;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
