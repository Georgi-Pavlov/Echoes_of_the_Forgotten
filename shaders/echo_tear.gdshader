shader_type canvas_item;
// Premultiplied, so the cracks, rays and spilled glow can add light
// (colour with no alpha) while the tear itself covers what's behind it.
render_mode blend_premul_alpha;

// A fallen rival hero's Echo: a small, ragged tear in reality, opening
// onto a glimpse of the past - warm, hazy, golden light slowly swirling
// behind it - rimmed with gold and held together by golden cracks that
// splinter out around it like broken glass, light rays streaming out
// between them. Drawn over its own rect; `rip` (how long the tear runs),
// `gape` (how wide it's pulled open) and `crack` (how far the cracks have
// spread) are driven from GDScript to open it, and `flare` to make it
// blaze up just before it breaks apart.

uniform float rip = 1.0;
uniform float gape = 1.0;
uniform float crack = 1.0;
uniform float flare = 0.0;
uniform float aspect = 1.0;          // rect width / height
uniform float seed = 0.0;
// Half the tear's length, and its widest half-width at full gape, both
// in rect-height units - the rest of the rect is room for the cracks
// and the glow.
uniform float tear_half_len = 0.21;
uniform float max_half_width = 0.05;
uniform vec4 gold : source_color = vec4(1.0, 0.76, 0.28, 1.0);
uniform vec4 bright : source_color = vec4(1.0, 0.95, 0.78, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash2(vec2 p) {
	return vec2(hash(p + seed), hash(p + vec2(17.3, 4.1) + seed));
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
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

// Distance to the nearest Voronoi cell border - the shattered-glass
// pattern the cracks are drawn from.
float crack_distance(vec2 x) {
	vec2 n = floor(x);
	vec2 f = fract(x);
	vec2 mg = vec2(0.0);
	vec2 mr = vec2(0.0);
	float md = 8.0;
	for (int j = -1; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			vec2 g = vec2(float(i), float(j));
			vec2 r = g + hash2(n + g) - f;
			float d = dot(r, r);
			if (d < md) {
				md = d;
				mr = r;
				mg = g;
			}
		}
	}
	float edge = 8.0;
	for (int j = -2; j <= 2; j++) {
		for (int i = -2; i <= 2; i++) {
			vec2 g = mg + vec2(float(i), float(j));
			vec2 r = g + hash2(n + g) - f;
			if (dot(mr - r, mr - r) > 0.00001) {
				edge = min(edge, dot(0.5 * (mr + r), normalize(r - mr)));
			}
		}
	}
	return edge;
}

void fragment() {
	// Centred coordinates in rect-height units: x across, y up/down
	// (-0.5..0.5).
	vec2 p = vec2((UV.x - 0.5) * aspect, UV.y - 0.5);
	float s = seed * 17.3;
	// Everything outside the tear fades out before the rect's edge, so
	// the glow never shows the rect's square outline.
	float edge = smoothstep(0.0, 0.14, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	float blaze = 1.0 + flare * 1.6;

	// The tear runs vertically from the middle out to `rip` of its
	// length, along a slightly wandering line, widest in the middle and
	// pinched to points at both ends, with ragged edges.
	float half_len = tear_half_len * rip;
	float along = p.y / max(half_len, 0.001);            // -1..1 inside
	float cx = 0.018 * sin(p.y * 9.0 + s) + 0.01 * sin(p.y * 23.0 + s * 2.3);
	float profile = pow(max(1.0 - along * along, 0.0), 0.8);
	float ragged = (fbm(vec2(p.y * 26.0 + s, TIME * 0.25)) - 0.5) * 0.9
			+ (value_noise(vec2(p.y * 80.0 - s, TIME * 0.6)) - 0.5) * 0.4;
	float breathe = 0.93 + 0.07 * sin(TIME * 1.9 + s);
	float hw = max_half_width * gape * breathe * profile * (1.0 + ragged * 0.6) * (1.0 + flare * 0.35);
	// Distance past the edge (negative inside), in rect-height units.
	float dx = abs(p.x - cx) - max(hw, 0.0);
	float inside = 1.0 - smoothstep(-0.004, 0.002, dx);
	inside *= step(abs(along), 1.0);

	// Distance from the tear as a whole, for everything around it.
	float dist = length(vec2(max(dx, 0.0), max(abs(p.y) - half_len, 0.0)));

	vec3 rgb = vec3(0.0);   // premultiplied
	float alpha = 0.0;

	if (inside > 0.0) {
		// The past behind it: hazy amber and gold drifting slowly, like
		// light through old dust, burning white toward its heart.
		vec2 q = p * 7.0 + vec2(s, -s * 0.5);
		vec2 warp = vec2(fbm(q + vec2(TIME * 0.08, 0.0)), fbm(q + vec2(5.2, -TIME * 0.07)));
		float n = fbm(q * 1.3 + warp * 1.6 + vec2(0.0, TIME * 0.1));
		vec3 amber = vec3(0.45, 0.22, 0.05);
		vec3 haze = mix(amber, gold.rgb, smoothstep(0.3, 0.75, n));
		float core = exp(-abs(p.x - cx) / max(hw, 0.001) * 1.6) * (1.0 - along * along);
		haze = mix(haze, bright.rgb, clamp(core * 0.85, 0.0, 1.0));
		// Motes of memory drifting up through it.
		vec2 sp = (p + vec2(0.0, -TIME * 0.03)) * 60.0;
		vec2 cell = floor(sp);
		float h = hash(cell + seed);
		if (h > 0.8) {
			vec2 f = fract(sp) - (hash2(cell) * 0.6 + 0.2);
			float tw = 0.5 + 0.5 * sin(TIME * (2.0 + h * 4.0) + h * 60.0);
			haze += bright.rgb * (1.0 - smoothstep(0.0, 0.15, length(f))) * tw;
		}
		rgb = haze * inside * blaze;
		alpha = inside;
	}

	// The golden cracks: shattered-glass lines splintering out around the
	// tear, densest and brightest right at it, reaching further as
	// `crack` grows (and further still as it flares).
	float ang = atan(p.y, p.x);
	float reach = (0.1 + 0.14 * value_noise(vec2(ang * 3.0 + s, 0.0))) * crack;
	float cmask = 1.0 - smoothstep(reach * 0.35, reach, dist);
	if (cmask > 0.0 && inside < 1.0) {
		float e = crack_distance(p * vec2(11.0, 8.0) + vec2(s));
		float width = mix(0.07, 0.025, clamp(dist / max(reach, 0.001), 0.0, 1.0));
		float seam = 1.0 - smoothstep(0.0, width, e);
		float flicker = 0.7 + 0.3 * value_noise(vec2(e * 30.0 + s, TIME * 4.0));
		float c = seam * cmask * flicker * (1.0 - inside) * edge;
		rgb += mix(gold.rgb, bright.rgb, seam * 0.5) * c * 1.6 * blaze;
		alpha = max(alpha, clamp(c, 0.0, 1.0) * 0.5);
	}

	// Light rays streaming out of it, slowly shifting.
	float ray = pow(value_noise(vec2(ang * 5.0 + s, TIME * 0.35)), 3.0);
	float ray_fall = exp(-dist * 8.0) * (1.0 - inside) * rip * edge;
	rgb += gold.rgb * ray * ray_fall * 0.9 * blaze;

	// Warm glow spilling out around the tear - pure added light.
	float ends = 1.0 - smoothstep(0.8, 1.15, abs(along));
	float spill = exp(-dist * 16.0) * rip * (0.5 + 0.5 * gape) * edge;
	spill *= 0.85 + 0.15 * sin(TIME * 4.0 + p.y * 25.0 + s);
	rgb += gold.rgb * spill * 0.55 * (1.0 - inside) * blaze;

	// The torn rim: bright white-gold, flickering along its length.
	float rim = exp(-abs(dx) * 120.0) * step(abs(along), 1.0) * ends;
	rim *= (0.7 + 0.3 * value_noise(vec2(p.y * 45.0 + s, TIME * 5.0))) * rip;
	rgb += bright.rgb * rim * 1.6 * blaze;
	alpha = max(alpha, clamp(rim, 0.0, 1.0) * 0.6);

	COLOR = vec4(rgb, alpha);
}
