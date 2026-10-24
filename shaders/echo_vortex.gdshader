shader_type canvas_item;

// The Echo vortex on the Map (see EchoVortexFX.gd): a crimson whirlpool of
// spiral arms twisting into a black heart, burning hottest at its rim.
// Drawn on a square ColorRect; everything outside the inscribed circle is
// transparent.

uniform float phase = 0.0;           // how far the vortex has turned - advanced by EchoVortexFX, faster while hovered
uniform float intensity = 1.0;       // overall brightness - eased up while hovered
uniform float opening = 1.0;         // 0..1 - grows in from nothing when it first opens
uniform float arms = 4.0;
uniform float twist = 6.0;           // how tightly the arms coil toward the centre
uniform vec4 core_color : source_color = vec4(0.0, 0.0, 0.006, 1.0);
uniform vec4 deep_color : source_color = vec4(0.16, 0.0, 0.015, 1.0);
uniform vec4 hot_color : source_color = vec4(0.62, 0.05, 0.03, 1.0);
uniform vec4 rim_color : source_color = vec4(0.75, 0.22, 0.08, 1.0);
// Where the black heart gives way to the crimson arms (share of the radius).
uniform float heart_inner = 0.26;
uniform float heart_outer = 0.52;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;           // -1..1
	float r = length(p) / max(opening, 0.001);
	if (r > 1.0) {
		COLOR = vec4(0.0);
	} else {
		float a = atan(p.y, p.x);
		float t = phase;

		// Spiral arms: angle bent by log(radius), so they coil ever tighter
		// toward the centre, turning as a whole.
		float swirl = a * arms + twist * log(r + 0.04) * 1.6 - t * 2.4;
		float arm = 0.5 + 0.5 * sin(swirl);
		arm = pow(arm, 2.2);

		// Turbulence dragged round with the flow, so the arms tear and smoke.
		vec2 polar = vec2(a / 6.2832 * 6.0 - t * 0.35 + log(r + 0.04) * 1.2, r * 4.0 - t * 0.6);
		float n = noise(polar * 2.0) * 0.6 + noise(polar * 5.0) * 0.4;
		float flow = clamp(arm * 0.75 + n * 0.55 - 0.15, 0.0, 1.0);

		// Black heart -> deep crimson -> dark red arms -> smouldering rim.
		float heart = smoothstep(heart_inner, heart_outer, r);
		vec3 col = mix(core_color.rgb, deep_color.rgb, heart);
		col = mix(col, hot_color.rgb, flow * heart);
		float rim = smoothstep(0.66, 0.93, r) * (1.0 - smoothstep(0.93, 1.0, r));
		col += rim_color.rgb * rim * (0.45 + 0.55 * flow);
		// A slow pulse of light breathing outward through the arms.
		float pulse = 0.5 + 0.5 * sin(t * 2.0 - r * 7.0);
		col += hot_color.rgb * flow * pulse * 0.18 * heart;

		col *= intensity;

		// Stars in the black heart - a deep sky glimpsed through it, turning
		// slowly with the vortex (inner ones faster), twinkling, fading out
		// where the crimson takes over. Two layers: a few bright, many faint.
		float star_mask = 1.0 - smoothstep(heart_inner * 0.6, heart_outer * 0.95, r);
		float spin = t * 0.25 + 0.6 / (r + 0.25);
		vec2 sp = vec2(cos(a + spin), sin(a + spin)) * r;
		vec3 stars = vec3(0.0);
		for (int layer = 0; layer < 2; layer++) {
			float scale = layer == 0 ? 15.0 : 34.0;
			vec2 g = sp * scale;
			vec2 cell = floor(g);
			vec2 f = fract(g) - 0.5;
			float h = hash(cell + float(layer) * 17.0);
			float threshold = layer == 0 ? 0.8 : 0.74;
			if (h > threshold) {
				vec2 off = (vec2(hash(cell + 3.1), hash(cell + 7.7)) - 0.5) * 0.6;
				float d = length(f - off);
				float size = layer == 0 ? 0.17 : 0.1;
				float star = smoothstep(size, 0.0, d);
				// A soft cross glint on the brighter ones.
				if (layer == 0) {
					vec2 q = abs(f - off);
					star += smoothstep(0.03, 0.0, min(q.x, q.y)) * smoothstep(0.4, 0.0, d) * 0.5;
				}
				float twinkle = 0.55 + 0.45 * sin(TIME * (2.0 + h * 5.0) + h * 40.0);
				vec3 tint = mix(vec3(1.0, 0.9, 0.85), vec3(0.8, 0.85, 1.0), hash(cell + 11.0));
				stars += tint * star * twinkle * (layer == 0 ? 1.7 : 0.8);
			}
		}
		col += stars * star_mask;

		// Soft outer edge; the heart stays fully opaque.
		float alpha = 1.0 - smoothstep(0.86, 1.0, r);
		COLOR = vec4(col, alpha * clamp(opening * 1.5, 0.0, 1.0));
	}
}
