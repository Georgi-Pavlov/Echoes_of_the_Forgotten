shader_type canvas_item;

// Sets a painted waterfall flowing: drawn over it in a rect that hugs the
// fall, it re-reads the picture underneath and runs thin vertical streaks
// of light and shade down through it. Only the pale water itself is
// touched - dark rock and cliff around it are left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Fall speed, in streak lengths per second.
uniform float speed = 3.0;
uniform float strength = 0.85;
uniform vec4 edge_fade = vec4(0.2, 0.12, 0.2, 0.3);

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

	// Streaks laid out in 1280x720 screen units, so they look the same at
	// any window size: narrow across, long down, scrolling downward.
	vec2 p = SCREEN_UV * vec2(1280.0, 720.0) / vec2(2.2, 16.0);
	float streak = value_noise(p - vec2(0.0, TIME * speed)) * 0.65
			+ value_noise(p * vec2(1.7, 0.6) - vec2(0.0, TIME * speed * 1.4)) * 0.35;

	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	float sat = max(col.r, max(col.g, col.b)) - min(col.r, min(col.g, col.b));
	float water = smoothstep(0.32, 0.6, luma) * (1.0 - smoothstep(0.12, 0.3, sat));

	col *= mix(1.0, 0.7 + 0.6 * streak, water * strength);

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
