shader_type canvas_item;

// Garden shot of the hero-pick dream (scene 2): leaves and flowers sway in a
// breeze, the lantern flickers, soft rays fall from the bright opening, and
// `white` (0 -> 1) blows the whole picture out to white. All positions are
// texture UVs.

uniform vec2 lantern = vec2(0.358, 0.54);
uniform vec2 sun = vec2(0.96, 0.12);
uniform vec2 bloom_center = vec2(0.84, 0.3);
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

	// Only the greenery moves: the canopy and hanging wisteria along the
	// top, the white flowers bottom-left and the pink ones on the right.
	// The bench, pillars and path stay put.
	float canopy = smoothstep(0.3, 0.04, uv.y);
	float left_flowers = smoothstep(0.3, 0.1, uv.x) * smoothstep(0.76, 0.9, uv.y);
	float right_flowers = smoothstep(0.86, 0.95, uv.x) * smoothstep(0.62, 0.8, uv.y);
	float sway_mask = clamp(canopy + left_flowers + right_flowers, 0.0, 1.0);

	float gust = noise(vec2(uv.x * 2.0 + t * 0.2, uv.y * 2.0));
	vec2 off = vec2(
			sin(t * 0.5 + uv.y * 2.0 + uv.x * 1.5) * 0.0018 + (gust - 0.5) * 0.002,
			0.0);
	vec3 col = texture(TEXTURE, uv + off * sway_mask).rgb;

	// Lantern flame: quick flutter on a slow swell.
	vec2 l = (uv - lantern) * vec2(aspect, 1.0);
	float flick = 0.88 + 0.22 * noise(vec2(t * 6.0, 1.0)) + 0.06 * sin(t * 21.0);
	col += vec3(1.0, 0.6, 0.2) * exp(-dot(l, l) * 900.0) * 0.55 * flick;
	col += vec3(1.0, 0.5, 0.15) * exp(-dot(l, l) * 90.0) * 0.12 * flick;

	// Light rays from the opening, drifting slowly and breathing a little.
	vec2 r = (uv - sun) * vec2(aspect, 1.0);
	float ang = atan(r.y, r.x);
	float rays = noise(vec2(ang * 14.0 + t * 0.15, 0.0)) * 0.7
			+ noise(vec2(ang * 31.0 - t * 0.1, 4.0)) * 0.3;
	rays = smoothstep(0.35, 0.9, rays);
	float reach = exp(-length(r) * 1.6);
	float breathe = 0.85 + 0.15 * sin(t * 0.8);
	col += vec3(1.0, 0.82, 0.5) * rays * reach * 0.32 * breathe;

	// Blow out to white: the bright opening blooms first, then everything.
	vec2 b = (uv - bloom_center) * vec2(aspect, 1.0);
	float bloom = exp(-dot(b, b) * 2.2);
	col += vec3(1.0, 0.95, 0.85) * bloom * white * 2.2;
	col = mix(col, vec3(1.0), smoothstep(0.35, 1.0, white));

	COLOR = vec4(col, COLOR.a);
}
