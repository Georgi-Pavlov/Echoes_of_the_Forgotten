shader_type canvas_item;

// Doorway shot of the hero-pick dream (scene 3): the wall lantern flickers,
// the leaf-shadows on the door and wall shimmer, and `white` (0 -> 1) lets
// the light from the doorway swallow the picture. The door itself is never
// moved. All positions are texture UVs.

uniform vec2 lantern = vec2(0.409, 0.31);
uniform vec2 doorway = vec2(0.705, 0.45);
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

void fragment() {
	vec2 uv = UV;
	float t = TIME;
	vec3 col = texture(TEXTURE, uv).rgb;

	// Dappled light: the foliage overhead moves in the breeze, so the
	// patches of sun on the door and wall slowly brighten and dim.
	float region = smoothstep(0.4, 0.5, uv.x) * (1.0 - smoothstep(0.7, 0.85, uv.y))
			* (1.0 - smoothstep(0.92, 1.0, uv.x)) * smoothstep(0.0, 0.1, uv.y);
	float dapple = noise(vec2(uv.x * 16.0 + t * 0.35, uv.y * 9.0 - t * 0.2))
			+ 0.5 * noise(vec2(uv.x * 34.0 - t * 0.5, uv.y * 20.0 + t * 0.3));
	col *= 1.0 + (dapple / 1.5 - 0.5) * 0.5 * region;

	// Lantern flame.
	vec2 l = (uv - lantern) * vec2(aspect, 1.0);
	float flick = 0.88 + 0.22 * noise(vec2(t * 6.0, 2.0)) + 0.06 * sin(t * 21.0);
	col += vec3(1.0, 0.6, 0.2) * exp(-dot(l, l) * 1100.0) * 0.55 * flick;
	col += vec3(1.0, 0.5, 0.15) * exp(-dot(l, l) * 110.0) * 0.14 * flick;

	// Light pouring out of the doorway, swelling until it fills the frame.
	vec2 d = (uv - doorway) * vec2(aspect, 1.0);
	float spill = exp(-dot(d * vec2(1.6, 1.0), d * vec2(1.6, 1.0)) * 5.0);
	col += vec3(1.0, 0.93, 0.78) * spill * white * 2.4;
	col = mix(col, vec3(1.0), smoothstep(0.35, 1.0, white));

	COLOR = vec4(col, COLOR.a);
}
