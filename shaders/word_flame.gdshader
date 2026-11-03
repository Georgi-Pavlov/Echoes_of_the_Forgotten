shader_type canvas_item;

// A word of black glyphs (alpha = the letters) that catches fire in deep
// green. The rect is bigger than the texture by "pad" on each side, so
// the flames have room to rise above the letters. "reveal" sweeps the
// fire in from left to right; once lit it keeps flickering.

uniform vec2 pad = vec2(0.0, 0.3);   // extra rect margin, fraction of the texture size per side
uniform float reveal : hint_range(0.0, 1.0) = 0.0;
uniform float flame_height = 0.2;    // how far flames rise, fraction of texture height
uniform vec4 deep_color : source_color = vec4(0.01, 0.38, 0.10, 1.0);
uniform vec4 hot_color : source_color = vec4(0.30, 1.0, 0.42, 1.0);
uniform float intensity = 1.0;

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
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		v += a * noise(p);
		p = p * 2.07 + vec2(5.1, 1.7);
		a *= 0.5;
	}
	return v;
}

float glyph(sampler2D tex, vec2 t) {
	if (t.x < 0.0 || t.x > 1.0 || t.y < 0.0 || t.y > 1.0) {
		return 0.0;
	}
	return texture(tex, t).a;
}

void fragment() {
	vec2 t = (UV - 0.5) * (1.0 + 2.0 * pad) + 0.5;
	float body = glyph(TEXTURE, t);

	// Tongues of flame: look at the letters below this pixel, pushed
	// sideways by drifting noise, fading out with height.
	float rise = fbm(vec2(t.x * 14.0, t.y * 4.0 + TIME * 2.2));
	float heat = 0.0;
	float total = 0.0;
	for (int i = 1; i <= 10; i++) {
		float k = float(i) / 10.0;
		float w = (1.0 - k) * (1.0 - k);
		float sway = (fbm(vec2(t.x * 9.0 + k * 2.0, TIME * 1.3 - k * 3.0)) - 0.5) * 0.07 * k;
		heat += glyph(TEXTURE, t + vec2(sway, k * flame_height)) * w;
		total += w;
	}
	heat /= total;
	float tongue = smoothstep(0.12, 0.55, heat * (0.55 + 1.1 * rise));

	// Sweep the fire in from the left with a ragged edge.
	float edge = fbm(vec2(t.y * 6.0, TIME * 0.8)) - 0.5;
	float gate = smoothstep(0.0, 0.14, reveal * 1.25 - t.x + edge * 0.18);

	float n = fbm(t * vec2(26.0, 8.0) + vec2(0.0, TIME * 1.9));
	float flick = 0.8 + 0.2 * sin(TIME * 15.0 + t.x * 40.0) * n;
	vec3 body_col = mix(deep_color.rgb * 0.8, hot_color.rgb, n * 0.65 + heat * 0.5);
	vec3 flame_col = mix(deep_color.rgb, hot_color.rgb, clamp(tongue * 1.2 + n * 0.25, 0.0, 1.0));
	vec3 col = mix(flame_col, body_col, body) * flick * intensity;

	float a = max(body, tongue * 0.9) * gate;
	COLOR = vec4(col, a);
}
