shader_type canvas_item;

// Sets a painted fire burning: drawn over the flames, it re-reads the
// picture underneath through a wavering upward-scrolling distortion, so
// the flames lick and dance, and flickers their brightness. Only the
// bright, fiery pixels are touched - the bowl and stone around them stay
// put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float waver_px = 2.5;
uniform float speed = 2.2;
uniform float flicker = 0.35;
uniform float seed = 0.0;
uniform vec4 edge_fade = vec4(0.15, 0.2, 0.15, 0.15);

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
	vec2 px = SCREEN_UV * size;
	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	// Tongues of flame rise: noise scrolling up, stretched vertically.
	vec2 q = px / vec2(7.0, 14.0) + vec2(seed, TIME * speed);
	vec2 waver = vec2(value_noise(q) - 0.5, value_noise(q + 17.0) - 0.5) * 2.0;
	// More waver towards the flame tips (top of the rect).
	waver *= waver_px * mix(1.0, 0.3, UV.y);
	vec3 col = textureLod(screen_tex, SCREEN_UV + waver / size, 0.0).rgb;

	float fire = smoothstep(0.4, 0.75, dot(here, vec3(0.299, 0.587, 0.114)))
			* smoothstep(0.05, 0.25, here.r - here.b);
	float f = value_noise(vec2(TIME * 7.0, seed)) * 0.6 + value_noise(vec2(TIME * 13.0, seed + 4.0)) * 0.4;
	col *= 1.0 + (f - 0.4) * flicker;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask * fire);
}
