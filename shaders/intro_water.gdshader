shader_type canvas_item;

// Still, dark water coming alive: drawn over the water in a painted scene,
// it re-reads the picture underneath with a slow horizontal ripple - gentle
// near the far shore, stronger towards the viewer - so the reflections
// waver, and lets bright reflections glint as the ripples catch them.
// Fades out at the rect's edges, and optionally over its lower-left corner
// (cut), so shoreline and foreground debris around the water stay put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float max_shift_px = 3.0;
uniform float speed = 1.4;
uniform vec4 glint_color : source_color = vec4(1.0, 0.72, 0.45, 1.0);
uniform float glint_strength = 0.6;
// Soft fade width at each edge (left, top, right, bottom), in rect UV.
uniform vec4 edge_fade = vec4(0.06, 0.18, 0.02, 0.1);
// Rect UV corner below-left of which there's no water (1, 0 = no cut).
uniform vec2 cut = vec2(0.0, 1.0);
// 1 = only touch blue-ish pixels - for clear water in a bright scene, so
// stone, plants and boats in or around it are left as painted.
uniform float blue_only = 0.0;
// 1 = leave very pale, washed-out pixels alone - blurred white flowers in
// front of the water, say.
uniform float skip_pale = 0.0;

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
	// Nearer water (lower in the rect) gets bigger, longer ripples.
	float near = UV.y;
	float t = TIME * speed;
	float n = value_noise(vec2(UV.x * 6.0, UV.y * 20.0) + vec2(TIME * 0.15, 0.0));
	float wave = sin(UV.y * mix(140.0, 60.0, near) - t + n * 5.0)
			* (0.6 + 0.4 * sin(UV.x * 9.0 + t * 0.4));
	float shift = wave * max_shift_px * mix(0.25, 1.0, near);
	vec2 offset = vec2(shift, shift * 0.15) * SCREEN_PIXEL_SIZE;
	vec3 col = textureLod(screen_tex, SCREEN_UV + offset, 0.0).rgb;
	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float blue = smoothstep(0.0, 0.1, here.b - here.r);

	// Glints only where the reflection is already bright.
	float a = value_noise(UV * vec2(30.0, 110.0) + vec2(TIME * 0.35, 0.0));
	float b = value_noise(UV * vec2(22.0, 80.0) - vec2(TIME * 0.28, 0.0));
	float glint = smoothstep(0.55, 0.85, a * b * 2.0);
	float bright = smoothstep(0.2, 0.6, dot(col, vec3(0.299, 0.587, 0.114)));
	col += glint_color.rgb * glint * bright * glint_strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	mask *= 1.0 - (1.0 - smoothstep(cut.x - 0.06, cut.x + 0.06, UV.x))
			* smoothstep(cut.y - 0.12, cut.y + 0.12, UV.y);

	mask *= mix(1.0, blue, blue_only);
	float here_luma = dot(here, vec3(0.299, 0.587, 0.114));
	float here_sat = max(here.r, max(here.g, here.b)) - min(here.r, min(here.g, here.b));
	float pale = smoothstep(0.62, 0.8, here_luma) * (1.0 - smoothstep(0.2, 0.35, here_sat));
	mask *= 1.0 - pale * skip_pale;

	COLOR = vec4(col, mask);
}
