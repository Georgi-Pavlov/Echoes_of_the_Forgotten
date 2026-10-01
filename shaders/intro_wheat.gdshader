shader_type canvas_item;

// Wind rolling across a painted field of ripe grain: drawn over the field,
// it re-reads the picture underneath and sweeps broad bands of light and
// shade across it, the way gusts bend tall stalks and show their pale
// undersides. Only golden pixels are touched - sheep, people, fences and
// green grass in or around the field stay as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Direction the wind blows, in screen space (normalised in the shader).
uniform vec2 wind = vec2(1.0, 0.15);
uniform float speed = 0.9;
uniform float strength = 0.18;
uniform vec4 edge_fade = vec4(0.08, 0.15, 0.08, 0.15);

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
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec2 dir = normalize(wind);
	float along = dot(px, dir);

	// Gust fronts sweeping downwind, their edges broken up by noise.
	float n = value_noise(px / vec2(90.0, 30.0) + vec2(0.0, TIME * 0.1));
	float gust = sin(along / 55.0 - TIME * speed * 3.0 + n * 3.0);
	gust = gust * 0.6 + 0.4 * sin(along / 23.0 - TIME * speed * 4.3 + n * 5.0);

	float golden = smoothstep(0.45, 0.65, col.r) * smoothstep(0.2, 0.35, col.r - col.b)
			* smoothstep(0.0, 0.08, col.r - col.g);
	// Bright where stalks bend and catch the light, a little deeper in the
	// troughs between gusts.
	col *= 1.0 + gust * strength;
	col += vec3(0.08, 0.06, 0.0) * max(gust, 0.0) * strength * 2.0;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask * golden);
}
