shader_type canvas_item;

// Fills the gaps of the Trickster Forge logo with deep green fire. The
// texture is a mask (alpha = the enclosed white spaces of the logo). The
// fire spreads outward from the middle as "progress" goes 0..1, with a
// ragged, flickering front, then keeps licking and pulsing.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
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
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(7.3, 3.1);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	float mask = texture(TEXTURE, UV).a;
	vec2 c = UV - vec2(0.5);
	// Flames rise: scroll the noise upward over time.
	float n = fbm(UV * 9.0 + vec2(0.0, TIME * 1.6));
	float n2 = fbm(UV * 18.0 + vec2(TIME * 0.7, TIME * 2.4));

	// Burn front: distance from the centre, roughened by noise.
	float d = length(c) * 1.9 + (n - 0.5) * 0.35;
	float lit = 1.0 - smoothstep(progress * 1.3 - 0.3, progress * 1.3, d);

	// Hotter right at the front, cooling to deep green behind it.
	float front = smoothstep(0.0, 0.25, lit) * (1.0 - smoothstep(0.25, 1.0, lit));
	float flick = 0.75 + 0.25 * n2 + 0.08 * sin(TIME * 17.0 + n * 6.0);
	vec3 col = mix(deep_color.rgb * (0.55 + 0.7 * n), hot_color.rgb, front * 0.85 + n2 * 0.18 * lit);
	col *= flick * intensity;

	COLOR = vec4(col, mask * lit);
}
