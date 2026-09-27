shader_type canvas_item;

// Frost creeping over the screen, as if on cold glass: it grows in from
// the rect's edges as ice crystals - each grain of ice a fan of fine,
// straight needles (with side barbs, like frost ferns) growing roughly
// inward from the nearest edge, over a thin milky rime - slowly
// creeping further in and receding again, with glints twinkling in it.
// Drawn over the art in its own rect.

uniform float aspect = 1.0;          // rect width / height
uniform vec4 frost_color : source_color = vec4(0.86, 0.94, 1.0, 1.0);
uniform float strength = 0.8;
// How far the frost reaches in from the edges (rect height units), and
// how much that creeps in and out.
uniform float reach = 0.11;
uniform float creep = 0.06;
uniform float creep_speed = 0.35;
// Per edge (left, top, right, bottom): how far the frost reaches there,
// as a multiple of `reach` (0 keeps that edge clear).
uniform vec4 edge_reach = vec4(1.0, 1.0, 1.0, 0.7);
// Crystal grains per rect height.
uniform float grain_scale = 11.0;
// A 0..1 pulse from GDScript that flares the frost and its glints.
uniform float flare = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash2(vec2 p) {
	return vec2(hash(p), hash(p + vec2(19.3, 71.9)));
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
	for (int i = 0; i < 4; i++) {
		v += a * value_noise(p);
		p = p * 2.07 + vec2(3.1, 7.4);
		a *= 0.5;
	}
	return v;
}

// Voronoi: x = distance to the grain's edge, y = the grain's random id.
vec2 voronoi(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	float id = 0.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			float d = length(g + hash2(i + g) - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
				id = hash(i + g + 0.37);
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec2(d2 - d1, id);
}

// Fine ice filaments along `dir`: noise stretched out along it, kept
// only at its thin ridges, so they come out irregular - uneven lengths,
// spacing and brightness - like real frost needles.
float needle_set(vec2 q, vec2 dir, float density, float seed) {
	vec2 perp = vec2(-dir.y, dir.x);
	vec2 r = vec2(dot(q, dir), dot(q, perp));
	float n = value_noise(vec2(r.x * 1.2, r.y * density) + seed * 37.0) * 0.65
			+ value_noise(vec2(r.x * 2.6, r.y * density * 2.1) + seed * 11.0) * 0.35;
	return pow(1.0 - abs(2.0 * n - 1.0), 12.0);
}

void fragment() {
	vec2 uv = UV;
	vec2 p = uv * vec2(aspect, 1.0);

	// Distance to each edge, in rect-height units, scaled by that edge's
	// reach, then softly combined so corners round off and fill in.
	vec4 e = vec4(uv.x * aspect, uv.y, (1.0 - uv.x) * aspect, 1.0 - uv.y);
	vec4 de = e / max(edge_reach, vec4(0.0001));
	float k = 22.0;
	vec4 we = exp(-de * k);
	float d = -log(we.x + we.y + we.z + we.w) / k;

	// A jagged, slowly creeping front: fronds reach much further in
	// some places than others.
	float wob = sin(TIME * creep_speed) * 0.6 + sin(TIME * creep_speed * 0.43 + 1.3) * 0.4;
	float jag = fbm(p * 4.0) * 0.7 + fbm(p * 14.0) * 0.3;
	float front = (reach + creep * wob + flare * 0.02) * (0.35 + 1.3 * jag);
	float t = d / max(front, 0.0001);   // 0 at the edge, 1 at the front
	if (t >= 1.0) {
		COLOR = vec4(0.0);
	} else {
		float thick = 1.0 - smoothstep(0.0, 1.0, t);

		// Which way is "inward" here: away from the nearest edges.
		vec2 inward = vec2(we.x - we.z, we.y - we.w);
		inward = length(inward) > 0.0001 ? normalize(inward) : vec2(1.0, 0.0);

		vec2 q = p * grain_scale;
		vec2 v = voronoi(q);
		float ang = atan(inward.y, inward.x) + (v.y - 0.5) * 1.3;
		vec2 dir = vec2(cos(ang), sin(ang));
		// Side barbs branch off at about 60 degrees, one way or the other.
		float barb_ang = ang + (fract(v.y * 7.0) > 0.5 ? 1.05 : -1.05);
		vec2 barb = vec2(cos(barb_ang), sin(barb_ang));
		float needles = needle_set(q, dir, 12.0, v.y);
		float barbs = needle_set(q, barb, 18.0, v.y + 0.5) * 0.5;
		// Needles thin out toward the front, leaving only the longest.
		float ice = max(needles, barbs) * smoothstep(0.0, 0.25, thick + 0.1);
		float grain = (1.0 - smoothstep(0.0, 0.03, v.x)) * 0.5;
		float rime = fbm(p * 45.0);

		float a = thick * thick * (0.1 + 0.14 * rime) + (ice * 0.75 + grain * 0.35) * thick;

		// Glints twinkling in the ice.
		vec2 gp = p * 120.0;
		vec2 gc = floor(gp);
		float gh = hash(gc);
		float glint = 0.0;
		if (gh > 0.95) {
			float gd = length(fract(gp) - (hash2(gc) * 0.6 + 0.2));
			float tw = pow(0.5 + 0.5 * sin(TIME * (1.5 + gh * 6.0) + gh * 80.0), 10.0);
			glint = (1.0 - smoothstep(0.0, 0.3, gd)) * tw * thick * (1.0 + flare * 2.0);
		}

		vec3 c = mix(frost_color.rgb, vec3(1.0), clamp(ice + glint, 0.0, 1.0));
		COLOR = vec4(c, clamp(a * strength * (1.0 + flare * 0.5) + glint, 0.0, 1.0));
	}
}
