shader_type canvas_item;

// The floating city under the torn sky (first-choice dream, scene 3): the
// waterfalls run and mist rolls through the canyon, the eye in the sky
// glows, blinks and churns its swirl, the sunset light shimmers and the
// marble glints, and now and then lightning runs along the golden cracks.
// `wipe` (0 -> 1) closes the scene: the left bleeds out to a white haze while
// black shadow tendrils creep in from the right. The picture itself never moves -
// no camera, no shake. All positions are texture UVs.

uniform vec2 eye = vec2(0.616, 0.096);
uniform vec2 sun = vec2(0.09, 0.25);
uniform float aspect = 1.7777;
uniform float wipe : hint_range(0.0, 1.0) = 0.0;

// The four big waterfalls: x0, y0, x1, y1.
const vec4 FALLS[4] = vec4[4](
	vec4(0.303, 0.665, 0.332, 0.81),
	vec4(0.382, 0.665, 0.432, 0.83),
	vec4(0.521, 0.52, 0.549, 0.645),
	vec4(0.665, 0.79, 0.696, 0.94)
);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	return noise(p) * 0.6 + noise(p * 2.1 + 5.0) * 0.4;
}

// Violet (the void) and gold (the cracks), found from the colour itself.
float violet(vec3 c) {
	return smoothstep(0.02, 0.16, c.b - c.g) * smoothstep(0.05, 0.2, c.r + c.b);
}

float gold(vec3 c) {
	float lum = dot(c, vec3(0.3, 0.55, 0.15));
	return smoothstep(0.35, 0.85, lum) * smoothstep(0.0, 0.25, c.r - c.b);
}

float box(vec2 uv, vec4 r) {
	vec2 soft = vec2(0.004, 0.012);
	return smoothstep(r.x - soft.x, r.x + soft.x, uv.x) * smoothstep(r.z + soft.x, r.z - soft.x, uv.x)
			* smoothstep(r.y - soft.y, r.y + soft.y, uv.y) * smoothstep(r.w + soft.y, r.w - soft.y, uv.y);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	// The eye's swirl turns: a slow churn of the dark violet only.
	vec3 raw = texture(TEXTURE, uv).rgb;
	float v = violet(raw);
	vec2 swirl = vec2(noise(uv * 9.0 + vec2(t * 0.12, -t * 0.09)) - 0.5,
			noise(uv * 9.0 + vec2(-t * 0.1, t * 0.13) + 9.0) - 0.5) * 0.01;
	vec3 col = texture(TEXTURE, uv + swirl * v).rgb;

	// Waterfalls: streaks of light sliding down.
	float falls = 0.0;
	for (int i = 0; i < 4; i++) {
		falls = max(falls, box(uv, FALLS[i]));
	}
	float streak = noise(vec2(uv.x * 260.0, uv.y * 26.0 - t * 2.6))
			+ 0.6 * noise(vec2(uv.x * 130.0 + 3.0, uv.y * 14.0 - t * 1.7));
	col += vec3(0.9, 0.93, 1.0) * (streak / 1.6 - 0.45) * 0.5 * falls;

	// Mist rolling through the canyon between the bridges.
	float mist = fbm(vec2(uv.x * 3.5 + t * 0.03, uv.y * 5.0 - t * 0.012));
	mist = smoothstep(0.4, 0.85, mist) * smoothstep(0.5, 0.68, uv.y) * smoothstep(0.1, 0.35, uv.x);
	col = mix(col, vec3(0.95, 0.82, 0.72), mist * 0.18);

	// One slow breath for the void: the cracks pulse and glitter, the eye
	// swells and fades, with a slow blink.
	float breath = 0.5 + 0.5 * sin(t * 1.1);
	float v2 = violet(col);
	col *= 1.0 + v2 * (0.08 + 0.2 * breath);
	float upper = smoothstep(0.5, 0.2, uv.y) * smoothstep(0.3, 0.45, uv.x);
	float g = gold(col) * upper;
	col *= 1.0 + g * (0.08 + 0.2 * breath);
	float glitter = pow(noise(uv * vec2(120.0 * aspect, 150.0) + vec2(t * 0.4, -t * 1.5)), 4.0) * 3.0;
	col += vec3(1.0, 0.78, 0.4) * g * glitter * 0.3;

	vec2 e = (uv - eye) * vec2(aspect, 1.0);
	float blink = 1.0 - 0.85 * smoothstep(0.93, 0.99, sin(t * 0.7));
	col += vec3(0.85, 0.55, 1.0) * exp(-dot(e, e) * 700.0) * (0.55 + 0.45 * sin(t * 1.1 + 1.0)) * blink * 0.5;

	// Sunset light: rays fanning from the left, breathing a little, and a
	// glint on the bright marble.
	vec2 s = (uv - sun) * vec2(aspect, 1.0);
	float ang = atan(s.y, s.x);
	float rays = noise(vec2(ang * 12.0 + t * 0.12, 0.0)) * 0.7 + noise(vec2(ang * 29.0 - t * 0.08, 4.0)) * 0.3;
	rays = smoothstep(0.4, 0.9, rays);
	col += vec3(1.0, 0.78, 0.5) * rays * exp(-length(s) * 1.5) * 0.2 * (0.85 + 0.15 * sin(t * 0.8));
	float lum = dot(col, vec3(0.3, 0.55, 0.15));
	float marble = smoothstep(0.5, 0.8, lum) * smoothstep(0.65, 0.2, uv.x);
	col += vec3(1.0, 0.92, 0.75) * pow(noise(uv * vec2(150.0 * aspect, 210.0) + vec2(t * 0.5, t * 0.3)), 7.0) * 4.0 * marble * 0.5;

	// Lightning: every few seconds a bolt of light along the cracks and a
	// flicker over the sky.
	float slot = floor(t / 3.2);
	float within = fract(t / 3.2) * 3.2;
	float fires = step(0.35, hash(vec2(slot, 7.0)));
	float flash = fires * exp(-within * 14.0) * (0.6 + 0.4 * sin(within * 70.0));
	col += vec3(0.95, 0.85, 1.0) * flash * (g * 1.6 + v2 * 0.5 + upper * 0.12);

	// The closing: the left side bleeds out into a bright haze that thickens
	// toward the edge, while tendrils of black shadow creep in from the
	// right, each finger reaching a different distance and writhing a
	// little. Neither is solid - the picture shows through, ragged, until
	// the next scene takes over.
	float haze_edge = uv.x + (fbm(vec2(uv.y * 4.0 + t * 0.05, uv.x * 3.0 - t * 0.04)) - 0.5) * 0.18;
	float haze = wipe * smoothstep(0.8, 0.0, haze_edge);
	col = mix(col, vec3(1.0, 0.97, 0.92), haze * 0.9);

	float depth = 1.0 - uv.x;
	// The fingers bend as they reach: the lane each pixel belongs to is
	// pushed sideways by a slow flowing noise that grows with distance, so
	// the tendrils curl instead of running ruler-straight.
	float curl = (fbm(vec2(depth * 3.5 - t * 0.15, uv.y * 2.5 + t * 0.05)) - 0.5) * 0.22 * depth;
	float lane = uv.y + curl;
	// Each lane reaches a different distance: many thin tendrils, a few
	// long ones, plus a ragged shadow along the whole right edge.
	float reach = pow(noise(vec2(lane * 26.0, 3.0)), 2.4) * 0.8
			+ pow(noise(vec2(lane * 11.0, 8.0)), 2.0) * 0.45
			+ 0.1;
	float wobble = (fbm(vec2(lane * 30.0 - t * 0.3, depth * 6.0)) - 0.5) * 0.06;
	float front = wipe * (reach * 1.15) + wobble * wipe;
	float shadow = smoothstep(front, front - 0.035, depth) * step(0.0001, wipe);
	// Thin and fade toward the tips so the tendrils taper to a point.
	shadow *= smoothstep(0.0, 0.6, (front - depth) / max(front, 0.001) + 0.15);
	col = mix(col, vec3(0.01, 0.0, 0.02), clamp(shadow, 0.0, 0.95));


	COLOR = vec4(col, COLOR.a);
}
