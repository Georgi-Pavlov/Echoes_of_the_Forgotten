shader_type canvas_item;

// A painted window torn into the air, showing a lost world, made to feel
// like a living memory: drawn over the window and its cracked frame, it
// re-reads the picture underneath and
//   - inside the window (the diamond given by its four corners), makes the
//     old world shimmer gently, as if seen through warm air, breathes its
//     light, sweeps a soft beam of sunlight across it and lets golden
//     motes twinkle in it;
//   - burns a bright seam along the window's edge;
//   - makes the glowing cracks around it surge with light, with thin arcs
//     of energy flickering over them;
//   - on an echo (`echo_t` is the seconds since the last one, set by
//     GDScript), flares the window and runs a ring of light out from it
//     along the cracks.
// Everything else in the rect is left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The window's corners, in 1280x720 screen pixels, going clockwise.
uniform vec2 top_px;
uniform vec2 right_px;
uniform vec2 bottom_px;
uniform vec2 left_px;
uniform float shimmer_px = 1.2;
uniform float echo_t = 100.0;
uniform float ring_speed = 160.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.82, 0.5, 1.0);
uniform vec4 arc_color : source_color = vec4(1.0, 0.9, 0.65, 1.0);
uniform vec4 edge_fade = vec4(0.12, 0.1, 0.12, 0.08);

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

// Distance from p to the line a->b, positive on the inside of a clockwise
// (on screen) outline.
float edge_dist(vec2 p, vec2 a, vec2 b) {
	vec2 e = b - a;
	vec2 d = p - a;
	return (e.x * d.y - e.y * d.x) / length(e);
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	vec2 px = SCREEN_UV * size;
	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float l = luma(here);

	// How far inside the window this pixel is (negative outside).
	float d = min(min(edge_dist(px, top_px, right_px), edge_dist(px, right_px, bottom_px)),
			min(edge_dist(px, bottom_px, left_px), edge_dist(px, left_px, top_px)));
	float inside = smoothstep(0.0, 8.0, d);
	vec2 center = (top_px + right_px + bottom_px + left_px) * 0.25;

	float echo = exp(-echo_t * 1.6);

	// Inside: the old world wavers as if seen through warm air - stronger
	// for a moment on an echo.
	float t = TIME * 0.35;
	vec2 q = px / 22.0;
	vec2 warp = vec2(fbm(q + vec2(t, -t * 0.6)), fbm(q + vec2(4.1 - t * 0.7, 2.3 + t))) - 0.5;
	vec3 col = textureLod(screen_tex, SCREEN_UV + warp * 2.0 * shimmer_px * (1.0 + echo * 2.0) / size, 0.0).rgb;
	col = mix(here, col, inside);

	// Its light breathes slowly, and a soft beam sweeps across it now and
	// then, top-right to bottom-left.
	float breathe = 0.5 + 0.5 * sin(TIME * 0.9);
	float sweep_pos = fract(TIME / 7.0) * 2.4 - 0.7;
	vec2 rel = (px - center) / vec2(110.0, 160.0);
	float beam = exp(-pow((dot(rel, normalize(vec2(-1.0, 0.6))) - sweep_pos) * 4.0, 2.0));
	col += col * inside * (0.06 * breathe + 0.22 * beam + 0.15 * echo);

	// Golden motes twinkling in it.
	vec2 cell = floor(px / 6.0);
	float h = hash(cell + 2.9);
	if (h < 0.03) {
		float sd = length(fract(px / 6.0) - (vec2(hash(cell + 1.3), hash(cell + 7.7)) * 0.6 + 0.2));
		float tw = pow(0.5 + 0.5 * sin(TIME * (0.8 + h * 50.0) + h * 300.0), 6.0);
		col += glow_color.rgb * (1.0 - smoothstep(0.0, 0.3, sd)) * tw * inside * 0.9;
	}

	// The seam: a bright line of light hugging the window's edge, glowing
	// in slow waves that run round it.
	float seam = exp(-pow(d / 4.0, 2.0));
	float seam_wave = 0.6 + 0.4 * sin(atan(px.y - center.y, px.x - center.x) * 3.0 - TIME * 1.4);
	col += glow_color.rgb * seam * seam_wave * (0.3 + 0.45 * echo);

	// The cracks around it: warm, bright pixels outside the window, surging
	// in waves that crawl outward, and lit by the echo's ring as it passes.
	float crack = smoothstep(0.45, 0.75, l) * smoothstep(0.0, 0.12, here.r - here.b) * (1.0 - inside);
	float near_crack = smoothstep(0.3, 0.55, l) * smoothstep(-0.05, 0.1, here.r - here.b) * (1.0 - inside);
	float r = distance(px, center);
	float surge = smoothstep(0.4, 0.75, fbm(vec2(r / 18.0 - TIME * 0.8, atan(px.y - center.y, px.x - center.x) * 2.0)));
	float ring = exp(-pow((r - echo_t * ring_speed) / 18.0, 2.0)) * exp(-echo_t * 0.8);
	col += col * crack * (surge * 0.55 + ring * 1.4);
	col += glow_color.rgb * near_crack * ring * 0.5;

	// Arcs: thin filaments flickering over the cracks.
	float n = fbm(px / 40.0 + vec2(TIME * 0.5, -TIME * 1.2));
	float ridge = pow(1.0 - abs(n * 2.0 - 1.0), 22.0);
	float flicker = step(0.5, value_noise(vec2(TIME * 7.0, px.y / 70.0)));
	col += arc_color.rgb * ridge * flicker * near_crack * 0.6;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
