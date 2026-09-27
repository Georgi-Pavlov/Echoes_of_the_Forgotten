shader_type canvas_item;

// Frostspire's zone art (Nhal's background), brought to life in place:
//   - vortex: the huge vortex over the fortress turns, the inner rings
//     faster than the outer ones, and draws the clouds inward, with
//     streaks of light racing along its arms into the eye.
//     Two copies of the sky, each turned a little and reset in turn,
//     are blended so it seems to spin forever without the art ever
//     smearing. The fortress's spire and the light beam through the
//     eye stay still.
//   - galaxy: the starry void inside Nhal's body comes alive - the painted
//     stars flicker hard, stars in three depths drift and glint (the
//     big ones with cross-shaped glints), a nebula swirls and swells,
//     and now and then a shooting star streaks across.
//   - The Primordial Hunger (its own background, same scene): its body swells as
//     it breathes (`breath`, from GDScript), its wings flex - more at the
//     tips than the roots - its floating crystals bob, and a glint of
//     light sweeps up the crest of bone spines on its back
//     (`spine_sweep`, from GDScript). Every rect left at zero is off, so
//     each hero's background only turns on its own effects.
//   - flash: when the fortress flashes (`flash`, driven from GDScript)
//     the vortex's clouds light up around the eye and the whole scene
//     brightens a touch.
// A calm rect (UV x0/y0/x1/y1) keeps the stats frame still.

uniform float aspect = 1.0;  // image width / height
uniform vec4 calm_rect = vec4(0.0);

// Vortex: its eye (UV), the half-axes of its (perspective-flattened)
// ellipse (UV), and the band (UV y) over which the spin fades out
// before it reaches the fortress's spires.
uniform vec2 vortex_center = vec2(0.5);
uniform vec2 vortex_radii = vec2(0.15, 0.12);
uniform float vortex_fade_top = 0.1;
uniform float vortex_fade_bottom = 0.15;
uniform float vortex_period = 4.0;   // seconds per blended cycle
uniform float vortex_turn = 0.5;     // radians turned per cycle at the eye
uniform float vortex_pull = 0.1;     // how far the clouds sink in per cycle
// 1 = only the open sky swirls (and catches the streaks) - anything much
// darker, like spires standing in front of the vortex, is left alone.
uniform float sky_only = 0.0;
// Streaks of light racing along the arms into the eye: how many arms,
// how tightly they wind (matching the painted ones), how fast the
// streaks run, and how bright they are.
uniform float arm_count = 3.0;
uniform float arm_wind = 4.0;
uniform float streak_speed = 2.6;
uniform float streak_strength = 0.26;

// The central spire and the light beam through the eye (UV): the beam
// is kept still all the way up, the spire below its tip.
uniform float spire_x = 0.79;
uniform float beam_half = 0.005;
uniform float spire_half = 0.012;
uniform float spire_tip_y = 0.075;

// The starry void inside Nhal's body: up to three rects (UV), and the
// luma below which a pixel counts as void rather than icy limb.
uniform vec4 galaxy_rect_a = vec4(0.0);
uniform vec4 galaxy_rect_b = vec4(0.0);
uniform vec4 galaxy_rect_c = vec4(0.0);
uniform float void_luma = 0.24;

// The Primordial Hunger: its body (rect + the point it swells from), wings (rects;
// the left one flexes most at its left end, the right one at its right
// end), the spine crest (rect + the point its spines fan out from, and
// the angle the glint is at - off while it's far outside -PI..PI) and
// floating crystals (rects).
uniform vec4 body_rect = vec4(0.0);
uniform vec2 body_center = vec2(0.0);
uniform float breath = 0.0;
uniform vec4 wing_left = vec4(0.0);
uniform vec4 wing_right = vec4(0.0);
uniform vec4 spine_rect = vec4(0.0);
uniform vec2 spine_center = vec2(0.0);
uniform float spine_sweep = -10.0;
const int CRYSTAL_COUNT = 8;
uniform vec4 crystal_rects[CRYSTAL_COUNT];

uniform float flash = 0.0;
uniform vec4 flash_color : source_color = vec4(0.62, 0.8, 1.0, 1.0);

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

float rect_mask(vec2 uv, vec4 r, float feather) {
	if (r.z <= r.x) {
		return 0.0;
	}
	vec2 d = min(uv - r.xy, r.zw - uv);
	return smoothstep(0.0, feather, min(d.x, d.y));
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

// Where the sky at `uv` is sampled from at cycle phase `p` (0..1): turned
// about the eye and pulled outward (so the clouds drift in), in the
// ellipse's own round space. The phase is centred so p = 0.5 is the art
// untouched.
vec2 swirl_src(vec2 uv, float p) {
	vec2 d = (uv - vortex_center) / vortex_radii;
	float r = length(d);
	float k = p - 0.5;
	// Inner rings turn faster than the outer ones.
	float a = -k * vortex_turn * mix(1.8, 0.5, clamp(r, 0.0, 1.0));
	float c = cos(a);
	float s = sin(a);
	d = vec2(d.x * c - d.y * s, d.x * s + d.y * c);
	d *= 1.0 + k * vortex_pull;
	vec2 src = vortex_center + d * vortex_radii;
	// Never drag the bright beam round into the clouds.
	float bx = src.x - spire_x;
	if (abs(bx) < beam_half * 2.5) {
		src.x = spire_x + (bx < 0.0 ? -1.0 : 1.0) * beam_half * 2.5;
	}
	return src;
}

void fragment() {
	vec2 uv = UV;
	float calm_d = max(max(calm_rect.x - uv.x, uv.x - calm_rect.z), max(calm_rect.y - uv.y, uv.y - calm_rect.w));
	float calm = calm_rect.z > calm_rect.x ? smoothstep(0.0, 0.015, calm_d) : 1.0;

	// --- The Primordial Hunger's body, wings and crystals, warped in place.
	vec2 src = uv;
	float body = rect_mask(uv, body_rect, 0.04);
	if (body > 0.0) {
		src = body_center + (src - body_center) * (1.0 - 0.006 * breath * body);
	}
	float wl = rect_mask(uv, wing_left, 0.03);
	if (wl > 0.0) {
		float k = clamp((wing_left.z - uv.x) / (wing_left.z - wing_left.x), 0.0, 1.0);
		src.y += sin(TIME * 1.3) * 0.007 * k * k * wl;
	}
	float wr = rect_mask(uv, wing_right, 0.03);
	if (wr > 0.0) {
		float k = clamp((uv.x - wing_right.x) / (wing_right.z - wing_right.x), 0.0, 1.0);
		src.y += sin(TIME * 1.3 + 0.6) * 0.007 * k * k * wr;
	}
	for (int i = 0; i < CRYSTAL_COUNT; i++) {
		float cm = rect_mask(uv, crystal_rects[i], 0.01);
		if (cm > 0.0) {
			src.y += sin(TIME * 1.2 + float(i) * 1.7) * 0.004 * cm;
		}
	}
	vec4 col = texture(TEXTURE, clamp(mix(uv, src, calm), vec2(0.0), vec2(1.0)));

	// A glint sweeping up the spine crest, catching only the pale bone.
	float spine = rect_mask(uv, spine_rect, 0.02);
	if (spine > 0.0 && spine_sweep > -5.0) {
		vec2 sd = (uv - spine_center) * vec2(aspect, 1.0);
		float band = exp(-pow((atan(sd.y, sd.x) - spine_sweep) * 6.0, 2.0));
		float bone = smoothstep(0.45, 0.8, luma(col.rgb));
		col.rgb += vec3(0.75, 0.88, 1.0) * band * bone * spine * 0.75;
	}

	// --- Vortex.
	vec2 vd = (uv - vortex_center) / vortex_radii;
	float vr = length(vd);
	float spin = 1.0 - smoothstep(0.7, 1.0, vr);
	spin *= 1.0 - smoothstep(vortex_fade_top, vortex_fade_bottom, uv.y);
	float col_x = abs(uv.x - spire_x);
	spin *= smoothstep(beam_half, beam_half * 2.5, col_x);
	spin *= mix(1.0, smoothstep(spire_half, spire_half * 1.8, col_x), smoothstep(spire_tip_y - 0.01, spire_tip_y, uv.y));
	spin *= calm;
	if (sky_only > 0.0) {
		spin *= mix(1.0, smoothstep(0.2, 0.3, luma(col.rgb)), sky_only);
	}
	if (spin > 0.0) {
		float t = TIME / vortex_period;
		float p1 = fract(t);
		float p2 = fract(t + 0.5);
		float w1 = 1.0 - abs(2.0 * p1 - 1.0);
		vec4 s1 = texture(TEXTURE, clamp(swirl_src(uv, p1), vec2(0.0), vec2(1.0)));
		vec4 s2 = texture(TEXTURE, clamp(swirl_src(uv, p2), vec2(0.0), vec2(1.0)));
		col = mix(col, mix(s2, s1, w1), spin);

		// Light streaks spiralling in: bright along the arms (which wind
		// inward clockwise, like the painted ones), in pulses that run
		// clockwise along them into the eye. Pure pattern, so it can
		// move fast without smearing the art.
		float ang = atan(vd.y, vd.x);
		float lr = log(max(vr, 0.02));
		float arms = 0.5 + 0.5 * sin(arm_count * ang + arm_wind * lr);
		float pulse = 0.5 + 0.5 * sin((arm_count + 2.0) * ang - arm_wind * 1.5 * lr - TIME * streak_speed);
		float streak = arms * arms * pulse * pulse * pulse;
		float mid = smoothstep(0.06, 0.3, vr);
		col.rgb += vec3(0.6, 0.76, 1.0) * streak * streak_strength * mid * spin * (0.35 + luma(col.rgb));
		// And the gaps between the arms darken a touch as the pulses pass.
		col.rgb *= 1.0 - 0.1 * (1.0 - arms) * pulse * mid * spin;
	}

	// --- Galaxy inside Nhal's body.
	float gal = max(rect_mask(uv, galaxy_rect_a, 0.012), max(rect_mask(uv, galaxy_rect_b, 0.012), rect_mask(uv, galaxy_rect_c, 0.012)));
	if (gal > 0.0) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float l = luma(col.rgb);
		float void_ = (1.0 - smoothstep(void_luma * 0.7, void_luma, l)) * gal;

		// Painted stars: a lone bright speck with only dark around it.
		float n1 = luma(texture(TEXTURE, uv + vec2(px.x * 2.5, 0.0)).rgb);
		float n2 = luma(texture(TEXTURE, uv - vec2(px.x * 2.5, 0.0)).rgb);
		float n3 = luma(texture(TEXTURE, uv + vec2(0.0, px.y * 2.5)).rgb);
		float n4 = luma(texture(TEXTURE, uv - vec2(0.0, px.y * 2.5)).rgb);
		float nmax = max(max(n1, n2), max(n3, n4));
		float navg = (n1 + n2 + n3 + n4) * 0.25;
		float speck = smoothstep(0.08, 0.2, l - nmax) * (1.0 - smoothstep(void_luma * 0.8, void_luma * 1.2, nmax)) * gal;
		if (speck > 0.0) {
			vec2 cell = floor(uv / px / 4.0);
			float h = hash(cell);
			float tw = 0.5 + 0.5 * sin(TIME * (1.8 + h * 5.0) + h * 40.0);
			tw = tw * tw;
			// Dips out, then flares well past its painted brightness.
			float gain = 0.05 + 2.6 * tw;
			col.rgb = mix(col.rgb, vec3(navg) + (col.rgb - vec3(navg)) * gain, speck);
			col.rgb += vec3(0.7, 0.75, 1.0) * speck * tw * 0.25;
		}

		if (void_ > 0.0) {
			vec2 q = uv * vec2(aspect, 1.0);

			// A nebula swirling through the dark: warped clouds of violet
			// and blue that drift, curl, and slowly swell and fade.
			vec2 warp = vec2(value_noise(q * 25.0 + TIME * 0.12), value_noise(q * 25.0 - TIME * 0.1 + 5.3)) - 0.5;
			vec2 nq = q + warp * 0.035;
			float neb = value_noise(nq * 40.0 + vec2(TIME * 0.12, -TIME * 0.18)) * 0.6
					+ value_noise(nq * 95.0 - vec2(TIME * 0.2, TIME * 0.08)) * 0.4;
			vec3 neb_col = mix(vec3(0.45, 0.14, 0.75), vec3(0.14, 0.34, 0.85), value_noise(nq * 18.0 + TIME * 0.07));
			float swell = 0.75 + 0.25 * sin(TIME * 0.9 + q.y * 40.0);
			col.rgb += neb_col * smoothstep(0.38, 0.85, neb) * 0.55 * swell * void_;

			// Stars in three depths, drifting slowly upward (the far ones
			// slowest) and glinting in and out.
			for (int layer = 0; layer < 3; layer++) {
				float fl = float(layer);
				float density = layer == 0 ? 190.0 : (layer == 1 ? 110.0 : 60.0);
				vec2 sp = (q + vec2(0.0, TIME * (0.0015 + 0.002 * fl))) * density;
				vec2 cell = floor(sp);
				float h = hash(cell + fl * 17.0);
				if (h > (layer == 0 ? 0.68 : (layer == 1 ? 0.78 : 0.86))) {
					vec2 f = fract(sp) - (vec2(hash(cell + 3.1), hash(cell + 7.7)) * 0.6 + 0.2);
					float d = length(f);
					float size = layer == 0 ? 0.17 : (layer == 1 ? 0.13 : 0.1);
					float core = 1.0 - smoothstep(0.0, size, d);
					float tw = 0.5 + 0.5 * sin(TIME * (1.2 + fract(h * 13.0) * 4.5) + h * 91.0);
					tw = pow(tw, 4.0);
					vec3 star = mix(vec3(0.75, 0.82, 1.0), vec3(0.92, 0.7, 1.0), fract(h * 7.0));
					float glow = 0.0;
					if (layer == 2) {
						// The big ones get a halo and, at their peak, a cross-
						// shaped glint.
						glow = (1.0 - smoothstep(0.0, 0.45, d)) * 0.35;
						float cross_ = max(exp(-abs(f.y) * 60.0) * (1.0 - smoothstep(0.0, 0.5, abs(f.x))),
								exp(-abs(f.x) * 60.0) * (1.0 - smoothstep(0.0, 0.5, abs(f.y))));
						glow += cross_ * smoothstep(0.5, 1.0, tw) * 0.9;
					}
					col.rgb += star * (core + glow) * tw * 2.0 * void_;
				}
			}

			// Now and then a shooting star streaks across one of the rects.
			float st_period = 2.2;
			float st_seed = floor(TIME / st_period);
			float st_t = fract(TIME / st_period) / 0.3;   // streaks in the first 30%
			if (st_t < 1.0) {
				float pick = hash(vec2(st_seed, 4.2));
				vec4 r = pick < 0.34 ? galaxy_rect_a : (pick < 0.67 ? galaxy_rect_b : galaxy_rect_c);
				vec2 start = mix(r.xy, r.zw, vec2(hash(vec2(st_seed, 1.3)), hash(vec2(st_seed, 8.1))));
				float sa = hash(vec2(st_seed, 2.9)) * 6.2832;
				vec2 dir = vec2(cos(sa), sin(sa));
				vec2 head = start * vec2(aspect, 1.0) + dir * 0.06 * st_t;
				vec2 rel = q - head;
				float along = dot(rel, -dir);          // distance back along the tail
				float across = abs(dot(rel, vec2(-dir.y, dir.x)));
				float tail_len = 0.03 * min(st_t * 3.0, 1.0);
				float st = (1.0 - smoothstep(0.0, 0.0012, across))
						* step(0.0, along) * (1.0 - smoothstep(0.0, tail_len, along));
				st += (1.0 - smoothstep(0.0, 0.0025, length(rel))) * 1.5;
				col.rgb += vec3(0.85, 0.9, 1.0) * st * sin(st_t * 3.1416) * 1.6 * void_;
			}
		}
	}

	// --- The fortress's flash lighting the sky.
	if (flash > 0.0) {
		vec2 fd = (uv - vortex_center) / (vortex_radii * vec2(1.6, 2.4));
		float glow = exp(-dot(fd, fd) * 1.4);
		float lit = 0.35 + luma(col.rgb);
		col.rgb += flash_color.rgb * flash * (glow * 0.55 * lit + (uv.x > 0.48 ? 0.05 : 0.02)) * calm;
	}

	COLOR = col;
}
