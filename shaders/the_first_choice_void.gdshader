shader_type canvas_item;

// The torn-open void (first-choice dream, scene 2): the purple mass inside
// the portal churns and breathes, the golden cracks around it pulse and
// glitter, the two eyes glow and pulse, and `white` (0 -> 1) blows the whole
// picture out to white. Nothing is moved as a block - no camera shake. All
// positions are texture UVs.

uniform vec2 eye_top = vec2(0.478, 0.06);
uniform vec2 eye_low = vec2(0.526, 0.64);
uniform vec2 base = vec2(0.51, 0.84);
uniform float aspect = 1.7777;
uniform float white : hint_range(0.0, 1.0) = 0.0;

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

// Violet (the void) and gold (the cracks) found from the colour itself, so
// the masks follow the picture without needing separate art.
float violet(vec3 c) {
	return smoothstep(0.02, 0.16, c.b - c.g) * smoothstep(0.05, 0.2, c.r + c.b);
}

float gold(vec3 c) {
	float lum = dot(c, vec3(0.3, 0.55, 0.15));
	return smoothstep(0.35, 0.85, lum) * smoothstep(0.0, 0.25, c.r - c.b);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	// The void churns: a slow swirl of the purple only.
	vec3 raw = texture(TEXTURE, uv).rgb;
	float v = violet(raw);
	vec2 swirl = vec2(noise(uv * 7.0 + vec2(t * 0.12, -t * 0.09)) - 0.5,
			noise(uv * 7.0 + vec2(-t * 0.1, t * 0.13) + 9.0) - 0.5) * 0.012;
	vec3 col = texture(TEXTURE, uv + swirl * v).rgb;
	v = violet(col);

	// One slow breath for the whole thing - the void, the cracks and the eyes
	// all follow it.
	float breath = 0.5 + 0.5 * sin(t * 1.1);
	col *= 1.0 + v * (0.1 + 0.3 * breath);

	// The cracks pulse with the breath and glitter: a fine noise that
	// slides upward and flares where the gold is.
	float g = gold(col);
	col *= 1.0 + g * (0.08 + 0.18 * breath);
	float glitter = noise(uv * vec2(110.0 * aspect, 150.0) + vec2(t * 0.4, -t * 1.6));
	glitter = pow(glitter, 4.0) * 3.0 + 0.5 * noise(uv * vec2(40.0 * aspect, 60.0) + vec2(-t * 0.3, -t * 0.9));
	col += vec3(1.0, 0.78, 0.4) * g * glitter * 0.35;

	// The two eyes: a glow that swells and fades, and a slow blink that
	// dims it for a moment.
	float blink = 1.0 - 0.85 * smoothstep(0.93, 0.99, sin(t * 0.7)) ;
	vec2 a = (uv - eye_top) * vec2(aspect, 1.0);
	vec2 b = (uv - eye_low) * vec2(aspect, 1.0);
	float eyes = exp(-dot(a, a) * 520.0) + exp(-dot(b, b) * 520.0);
	float eye_pulse = 0.55 + 0.45 * sin(t * 1.1 + 1.0);
	col += vec3(0.85, 0.55, 1.0) * eyes * eye_pulse * blink * 0.5;

	// Light welling up from the base.
	vec2 s = (uv - base) * vec2(aspect, 1.0);
	col += vec3(1.0, 0.7, 0.35) * exp(-dot(s, s) * 14.0) * (0.06 + 0.06 * breath);

	// Blow out to white: the base blooms first, then everything.
	col += vec3(1.0, 0.92, 0.8) * exp(-dot(s, s) * 2.5) * white * 2.4;
	col = mix(col, vec3(1.0), smoothstep(0.35, 1.0, white));

	COLOR = vec4(col, COLOR.a);
}
