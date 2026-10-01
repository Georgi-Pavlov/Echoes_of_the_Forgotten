shader_type canvas_item;

// Sets a painted brook flowing: drawn over it, it re-reads the picture
// underneath and runs streaks of light and shade along the direction of
// flow, with the surface wobbling slightly along the current and foam
// glinting. Only water is touched - grey-blue pixels and white foam - so
// the rocks and grass in and around it stay put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Direction the water runs, in screen space (normalised in the shader).
uniform vec2 flow = vec2(1.0, 0.3);
uniform float speed = 2.5;
uniform float strength = 0.8;
uniform float wobble_px = 2.0;
uniform vec4 foam_color : source_color = vec4(1.0, 0.98, 0.92, 1.0);
uniform vec4 edge_fade = vec4(0.08, 0.1, 0.08, 0.1);

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
	vec2 dir = normalize(flow);
	vec2 across = vec2(-dir.y, dir.x);
	vec2 px = SCREEN_UV * size;
	// Coordinates along and across the current: long streaks along it.
	vec2 q = vec2(dot(px, dir) / 18.0, dot(px, across) / 3.0);

	float w = value_noise(q * vec2(0.6, 0.4) - vec2(TIME * speed * 0.6, 0.0)) - 0.5;
	vec2 offset = dir * w * wobble_px / size;
	vec3 col = textureLod(screen_tex, SCREEN_UV + offset, 0.0).rgb;
	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	float luma = dot(here, vec3(0.299, 0.587, 0.114));
	float sat = max(here.r, max(here.g, here.b)) - min(here.r, min(here.g, here.b));
	// Water in warm light is a neutral grey, barely bluer than it is red;
	// rocks and grass are clearly warmer than that.
	float blue = smoothstep(-0.1, -0.02, here.b - here.r) * smoothstep(0.12, 0.3, luma);
	float foam = smoothstep(0.45, 0.65, luma) * (1.0 - smoothstep(0.18, 0.32, sat));
	float water = max(blue, foam);

	float streak = value_noise(q - vec2(TIME * speed, 0.0)) * 0.6
			+ value_noise(q * vec2(1.9, 1.3) - vec2(TIME * speed * 1.5, 0.0)) * 0.4;
	col *= 1.0 + (streak - 0.5) * 0.7 * strength;
	float sparkle = smoothstep(0.78, 0.95, value_noise(q * vec2(2.5, 2.0) - vec2(TIME * speed * 1.2, TIME)));
	col += foam_color.rgb * sparkle * (0.3 + foam * 0.5) * strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask * water);
}
