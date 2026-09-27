shader_type canvas_item;
// Premultiplied, so the rim and the spilled glow can add light (colour
// with no alpha) while the void itself covers what's behind it.
render_mode blend_premul_alpha;

// The Hollow Cold's wound in the air: a tall, ragged tear in the world,
// gaping open onto the void before creation - a fragment of nebula
// swirling behind it, stars glinting through - rimmed with icy light
// that flickers along its torn edges and spills cold glow around it.
// Drawn over its own rect; `rip` (how long the tear runs, 0..1) and
// `gape` (how wide it's pulled open, 0..1) are driven from GDScript to
// tear it open and seal it shut again.

uniform float rip = 1.0;
uniform float gape = 1.0;
uniform float aspect = 0.5;          // rect width / height
uniform float seed = 0.0;
// Widest half-width at full gape, in rect-height units.
uniform float max_half_width = 0.11;
uniform vec4 rim_color : source_color = vec4(0.75, 0.9, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.45, 0.65, 1.0, 1.0);

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
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	// Centred coordinates in rect-height units: x across, y up/down
	// (-0.5..0.5).
	vec2 p = vec2((UV.x - 0.5) * aspect, UV.y - 0.5);
	float s = seed * 17.3;

	// The tear runs vertically from the middle out to `rip` of the
	// rect's height, along a slightly wandering line.
	float half_len = 0.47 * rip;
	float along = p.y / max(half_len, 0.001);            // -1..1 inside
	float cx = 0.035 * sin(p.y * 7.0 + s) + 0.02 * sin(p.y * 17.0 + s * 2.3);
	// Widest in the middle, pinched to points at both ends, with ragged,
	// torn edges that shift a little as it breathes.
	float profile = pow(max(1.0 - along * along, 0.0), 0.75);
	float ragged = (fbm(vec2(p.y * 22.0 + s, TIME * 0.3)) - 0.5) * 0.9
			+ (value_noise(vec2(p.y * 70.0 - s, TIME * 0.8)) - 0.5) * 0.35;
	float breathe = 0.94 + 0.06 * sin(TIME * 1.7 + s);
	float hw = max_half_width * gape * breathe * profile * (1.0 + ragged * 0.55);
	// Distance past the edge (negative inside), in rect-height units.
	float dx = abs(p.x - cx) - max(hw, 0.0);
	float inside = 1.0 - smoothstep(-0.004, 0.002, dx);
	inside *= step(abs(along), 1.0);

	vec3 rgb = vec3(0.0);   // premultiplied
	float alpha = 0.0;

	if (inside > 0.0) {
		// The void behind it: a nebula fragment, slowly swirling and
		// drifting, deep black between its clouds.
		vec2 q = p * 6.0 + vec2(s, -s * 0.5);
		vec2 warp = vec2(fbm(q + vec2(TIME * 0.12, 0.0)), fbm(q + vec2(5.2, TIME * 0.1)));
		float n = fbm(q * 1.4 + warp * 1.8 + vec2(-TIME * 0.05, TIME * 0.08));
		float n2 = fbm(q * 3.1 - warp + vec2(TIME * 0.09, 0.0));
		vec3 deep = vec3(0.01, 0.01, 0.04);
		vec3 violet = vec3(0.42, 0.12, 0.7);
		vec3 blue = vec3(0.1, 0.35, 0.95);
		vec3 cyan = vec3(0.55, 0.9, 1.0);
		vec3 neb = mix(deep, violet, smoothstep(0.35, 0.75, n));
		neb = mix(neb, blue, smoothstep(0.5, 0.85, n2) * 0.8);
		neb += cyan * pow(smoothstep(0.62, 0.95, n * n2 * 1.9), 2.0) * 0.8;

		// Stars glinting through, twinkling.
		for (int layer = 0; layer < 2; layer++) {
			float density = layer == 0 ? 55.0 : 24.0;
			vec2 sp = (p + vec2(0.0, TIME * 0.004 * float(layer + 1))) * density;
			vec2 cell = floor(sp);
			float h = hash(cell + seed + float(layer) * 31.0);
			if (h > 0.82) {
				vec2 f = fract(sp) - (vec2(hash(cell + 2.1), hash(cell + 6.3)) * 0.6 + 0.2);
				float core = 1.0 - smoothstep(0.0, layer == 0 ? 0.14 : 0.1, length(f));
				float tw = pow(0.5 + 0.5 * sin(TIME * (1.5 + h * 5.0) + h * 70.0), 4.0);
				float glint = layer == 1 ? max(exp(-abs(f.x) * 50.0), exp(-abs(f.y) * 50.0)) * (1.0 - smoothstep(0.0, 0.5, length(f))) * 0.6 : 0.0;
				neb += vec3(0.85, 0.9, 1.0) * (core + glint) * tw * 1.4;
			}
		}
		rgb = neb * inside;
		alpha = inside;
		// Cold light leaking in round the torn edge, just inside it.
		float inner = exp(-abs(dx) * 55.0) * inside;
		rgb += rim_color.rgb * inner * 0.55;
	}

	// Cold glow spilling out around the tear, strongest at its middle -
	// pure added light.
	float ends = 1.0 - smoothstep(0.7, 1.05, abs(along));
	float spill = exp(-max(dx, 0.0) * 22.0) * ends * rip * (0.5 + 0.5 * gape);
	spill *= 0.8 + 0.2 * sin(TIME * 5.0 + p.y * 30.0 + s);
	rgb += glow_color.rgb * spill * 0.6 * (1.0 - inside);

	// The torn rim: bright, icy, flickering along its length.
	float rim = exp(-abs(dx) * 110.0) * step(abs(along), 1.0);
	float flicker = 0.65 + 0.35 * value_noise(vec2(p.y * 40.0 + s, TIME * 6.0));
	rim *= flicker * rip;
	rgb += rim_color.rgb * rim * 1.5;
	alpha = max(alpha, clamp(rim, 0.0, 1.0) * 0.6);

	COLOR = vec4(rgb, alpha);
}
