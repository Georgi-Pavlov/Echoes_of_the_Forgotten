shader_type canvas_item;

// Waking-up shot of the hero-pick dream (scene 4): the eyes open on a blurry,
// dark forest (`lids` 1 -> 0 opens them, `wake` 0 -> 1 clears and brightens
// the view), mist drifts between the trees, and the sunrise rays and the
// glow on the path breathe softly. All positions are texture UVs.

uniform vec2 sun = vec2(0.69, 0.12);
uniform vec2 path_glow = vec2(0.62, 0.42);
uniform float aspect = 1.7777;
uniform float wake : hint_range(0.0, 1.0) = 0.0;
uniform float lids : hint_range(0.0, 1.0) = 1.0;

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

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	// Blurry at first: a small ring of taps that tightens as the eyes focus.
	float r = (1.0 - wake) * 0.011;
	vec2 px = vec2(r / aspect, r);
	vec3 col = texture(TEXTURE, uv).rgb;
	col += texture(TEXTURE, uv + vec2(px.x, 0.0)).rgb;
	col += texture(TEXTURE, uv - vec2(px.x, 0.0)).rgb;
	col += texture(TEXTURE, uv + vec2(0.0, px.y)).rgb;
	col += texture(TEXTURE, uv - vec2(0.0, px.y)).rgb;
	col += texture(TEXTURE, uv + px).rgb;
	col += texture(TEXTURE, uv - px).rgb;
	col += texture(TEXTURE, uv + vec2(px.x, -px.y)).rgb;
	col += texture(TEXTURE, uv + vec2(-px.x, px.y)).rgb;
	col /= 9.0;

	// Mist: slow banks drifting through the forest, thickest far away.
	float mist = fbm(vec2(uv.x * 3.0 + t * 0.04, uv.y * 4.0 - t * 0.01));
	mist = smoothstep(0.35, 0.8, mist) * smoothstep(0.75, 0.2, uv.y);
	col = mix(col, vec3(0.78, 0.62, 0.62), mist * 0.2);

	// Sunrise rays between the trunks, and the path glowing as if it
	// breathed.
	vec2 s = (uv - sun) * vec2(aspect, 1.0);
	float ang = atan(s.y, s.x);
	float rays = noise(vec2(ang * 16.0 + t * 0.1, 0.0)) * 0.7
			+ noise(vec2(ang * 37.0 - t * 0.07, 3.0)) * 0.3;
	rays = smoothstep(0.4, 0.9, rays);
	float breathe = 0.85 + 0.15 * sin(t * 0.9);
	col += vec3(1.0, 0.7, 0.55) * rays * exp(-length(s) * 2.0) * 0.2 * breathe;

	vec2 g = (uv - path_glow) * vec2(aspect, 1.0);
	col += vec3(1.0, 0.72, 0.5) * exp(-dot(g, g) * 12.0) * 0.1 * breathe;

	// Still groggy: dark until the eyes have fully come round.
	col *= mix(0.3, 1.0, wake);

	// Eyelids: black bars from top and bottom, slightly curved.
	float open = 1.0 - lids;
	float h = open * 0.56;
	float dist = abs(uv.y - 0.5) + pow(uv.x - 0.5, 2.0) * 0.12;
	float vis = (1.0 - smoothstep(h - 0.07, h + 0.02, dist)) * smoothstep(0.0, 0.08, open);
	col *= vis;

	COLOR = vec4(col, COLOR.a);
}
