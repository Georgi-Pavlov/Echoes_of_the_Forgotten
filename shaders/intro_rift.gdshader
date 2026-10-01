shader_type canvas_item;

// A painted tear in the sky coming alive: drawn over the rift, it re-reads
// the picture underneath and
//   - churns the void inside it: the dark nebula slowly swirls (the picture
//     is re-read through a drifting warp) and new stars twinkle in it;
//   - makes its molten, burning rim crackle: the glow surges in waves that
//     run along it, and thin arcs of energy flicker over and around it.
// The void is the dark, violet-to-blue pixels; the rim the bright, warm
// ones - everything else in the rect is left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float swirl_px = 4.0;
uniform float swirl_speed = 0.12;
uniform float star_density = 0.035;
uniform float crackle_strength = 0.6;
uniform float arc_strength = 0.7;
uniform vec4 arc_color : source_color = vec4(1.0, 0.85, 0.6, 1.0);
uniform vec4 star_color : source_color = vec4(0.85, 0.8, 1.0, 1.0);
uniform vec4 edge_fade = vec4(0.1, 0.001, 0.1, 0.12);

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

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * value_noise(p);
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	vec2 px = SCREEN_UV * size;
	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float l = luma(here);

	float void_mask = (1.0 - smoothstep(0.25, 0.42, l)) * smoothstep(-0.06, 0.04, here.b - here.r * 0.85);
	float rim = smoothstep(0.5, 0.8, l) * smoothstep(0.0, 0.12, here.r - here.b);
	float near_rim = smoothstep(0.35, 0.6, l) * smoothstep(-0.05, 0.1, here.r - here.b);

	vec3 col = here;

	// The void: re-read through a slowly drifting swirl, so the nebula
	// churns - but only take colour from pixels that are void too, so
	// the rim never smears into it.
	float t = TIME * swirl_speed;
	vec2 q = px / 70.0;
	vec2 warp = vec2(fbm(q + vec2(t, -t * 0.7)), fbm(q + vec2(5.2 - t * 0.8, 1.3 + t))) - 0.5;
	vec3 swirled = textureLod(screen_tex, SCREEN_UV + warp * 2.0 * swirl_px / size, 0.0).rgb;
	float swirled_void = 1.0 - smoothstep(0.3, 0.45, luma(swirled));
	col = mix(col, swirled, void_mask * swirled_void);

	// Stars: a sparse field of points twinkling in and out.
	vec2 cell = floor(px / 5.0);
	float h = hash(cell + 3.7);
	if (h < star_density) {
		float d = length(fract(px / 5.0) - (vec2(hash(cell + 1.1), hash(cell + 8.3)) * 0.6 + 0.2));
		float tw = pow(0.5 + 0.5 * sin(TIME * (1.0 + h * 60.0) + h * 400.0), 4.0);
		col += star_color.rgb * (1.0 - smoothstep(0.0, 0.3, d)) * tw * void_mask * 1.2;
	}

	// The rim: surges of heat running along it.
	float surge = fbm(px / 40.0 + vec2(0.0, -TIME * 0.9)) ;
	surge = smoothstep(0.4, 0.75, surge);
	col += col * rim * surge * crackle_strength;

	// Arcs: thin bright filaments where ridged noise lines up, flickering.
	float n = fbm(px / 55.0 + vec2(TIME * 0.4, -TIME * 1.1));
	float ridge = 1.0 - abs(n * 2.0 - 1.0);
	ridge = pow(ridge, 24.0);
	float flicker = step(0.45, value_noise(vec2(TIME * 6.0, px.y / 90.0)));
	col += arc_color.rgb * ridge * flicker * near_rim * arc_strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
