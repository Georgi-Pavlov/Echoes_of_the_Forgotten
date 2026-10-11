shader_type canvas_item;
// Added light: fire glows over whatever is behind it.
render_mode blend_add;

// A wall of tall flames, drawn over its own rect (ground along its bottom
// edge): ragged tongues of fire licking upward, each column flickering to
// its own height, white-yellow at the base through orange to a smoky red
// at the tips. `reveal` (0..1) spreads it out from the middle to the
// sides; `strength` (0..1) lets it roar up and die down. Used by
// SweepFlamesFX.

uniform float aspect = 4.0;        // rect width / height
uniform float reveal = 1.0;
uniform float strength = 1.0;
uniform float seed = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
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
	for (int i = 0; i < 5; i++) {
		v += a * value_noise(p);
		p = p * 2.02 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	float x = (UV.x - 0.5) * 2.0;          // -1..1, 0 under the caster
	float h = 1.0 - UV.y;                  // 0 at the ground, 1 at the top
	vec2 p = vec2(UV.x * aspect * 3.0 + seed, h * 3.0);
	// Rising, turbulent fire: noise scrolling up, warped sideways.
	float warp = fbm(p * 0.8 + vec2(0.0, -TIME * 1.6));
	float n = fbm(vec2(p.x + warp * 0.9, p.y - TIME * 3.2));
	// Each column flickers to its own height - tallest near the caster.
	float col_h = 0.45 + 0.55 * fbm(vec2(p.x * 0.6, TIME * 1.4));
	col_h *= mix(1.0, 0.65, abs(x));
	col_h *= strength;
	// Fire: strong at the base, thinning into tongues toward the top.
	float fire = n * 1.7 - h / max(col_h, 0.01) * 0.85;
	fire = smoothstep(0.0, 0.6, fire) * smoothstep(0.0, 0.25, strength);
	// Spread out from the middle, softly at its leading edges and the sides.
	float spread = 1.0 - smoothstep(reveal - 0.12, reveal, abs(x));
	float sides = 1.0 - smoothstep(0.88, 1.0, abs(x));
	fire *= spread * sides;
	vec3 c = mix(vec3(0.55, 0.08, 0.02), vec3(1.0, 0.45, 0.08), smoothstep(0.05, 0.4, fire));
	c = mix(c, vec3(1.0, 0.85, 0.45), smoothstep(0.45, 0.85, fire));
	c = mix(c, vec3(1.0, 0.97, 0.85), smoothstep(0.85, 1.0, fire) * (1.0 - smoothstep(0.0, 0.25, h)));
	COLOR = vec4(c, fire * 0.7);
}
