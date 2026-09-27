shader_type canvas_item;

// Return to the Void's unmaking of the world, drawn over the battle
// background (behind the fighters) on a full-screen rect:
//   - dim: the whole battlefield darkens and drains toward grey
//   - crack: hairline cracks of cold light spread out from the target
//     across the dome it's about to erase, along the seams of the shards
//     it will break into
//   - erase: the world inside the dome breaks into those shards - the
//     real background, read from the screen - which shrink, turn and
//     drift inward, falling away into nothing, center first. Behind
//     them: the void before creation, nebula and stars, its torn edge
//     rimmed in icy light
//   - heal: the shards knit back, outermost first, sealing the wound
//   - frost: a ring of rime left on the world where the dome's edge was
// All positions are in this rect's pixels.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 rect_size = vec2(1280.0, 720.0);
uniform vec2 center_px = vec2(640.0, 360.0);
uniform vec2 radii_px = vec2(200.0, 120.0);
uniform float cell_px = 26.0;
uniform float dim = 0.0;
uniform float crack = 0.0;
uniform float erase = 0.0;
uniform float heal = 0.0;
uniform float frost = 0.0;
uniform float seed = 0.0;
uniform vec4 rim_color : source_color = vec4(0.75, 0.9, 1.0, 1.0);

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
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

// Voronoi over the shard grid (in cell units): xy = the nearest shard's
// center, z = distance to that shard's edge, w = the shard's random id.
vec4 shards(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	vec2 best = vec2(0.0);
	float id = 0.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = hash2(i + g + seed) * 0.8 + 0.1;
			float d = length(g + o - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
				best = i + g + o;
				id = hash(i + g + seed + 0.37);
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec4(best, (d2 - d1) * 0.5, id);
}

// How far out (0 = center, 1 = the dome's ragged edge) a point is.
float dome_dist(vec2 px) {
	vec2 p = (px - center_px) / radii_px;
	float ang = atan(p.y, p.x);
	float edge = 1.0 + (value_noise(vec2(ang * 2.5 + seed, seed)) - 0.5) * 0.22;
	return length(p) / edge;
}

vec3 dimmed(vec3 c) {
	vec3 grey = vec3(luma(c)) * vec3(0.82, 0.88, 1.0);
	return mix(c, grey * 0.5, dim);
}

// The void before creation.
vec3 void_color(vec2 px) {
	vec2 q = px / 90.0 + seed;
	vec2 warp = vec2(fbm(q + TIME * 0.15), fbm(q + 4.3 - TIME * 0.12));
	float n = fbm(q * 1.2 + warp * 1.7);
	vec3 c = mix(vec3(0.01, 0.01, 0.035), vec3(0.4, 0.12, 0.68), smoothstep(0.42, 0.8, n));
	c = mix(c, vec3(0.1, 0.32, 0.95), smoothstep(0.55, 0.9, fbm(q * 2.6 - warp)) * 0.7);
	vec2 sp = px / 9.0;
	vec2 cell = floor(sp);
	float h = hash(cell + seed);
	if (h > 0.9) {
		float d = length(fract(sp) - (hash2(cell + 3.3) * 0.6 + 0.2));
		float tw = pow(0.5 + 0.5 * sin(TIME * (1.5 + h * 5.0) + h * 70.0), 3.0);
		c += vec3(0.88, 0.92, 1.0) * (1.0 - smoothstep(0.0, 0.16, d)) * tw * 1.6;
	}
	return c;
}

void fragment() {
	vec2 px = UV * rect_size;
	vec3 bg = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	vec3 col = dimmed(bg);
	float d = dome_dist(px);

	if (d < 1.3) {
		vec4 v = shards(px / cell_px);
		vec2 c_px = v.xy * cell_px;
		float dc = dome_dist(c_px);
		float id = v.w;
		if (dc < 1.0) {
			// When this shard breaks away (center first) and when it
			// comes back (outermost first).
			float t_break = dc * 0.65 + id * 0.25;
			float s = clamp((erase * 1.2 - t_break) / 0.3, 0.0, 1.0);
			float t_heal = (1.0 - dc) * 0.65 + id * 0.25;
			float h = clamp((heal * 1.2 - t_heal) / 0.3, 0.0, 1.0);
			s *= 1.0 - h;

			// Before it breaks: a crack of cold light along its seam, once
			// the cracks have spread this far.
			// Only some seams split - a jagged fracture pattern, not a net.
			float seam = 1.0 - smoothstep(0.0, 0.8 / cell_px, v.z);
			float fracture = smoothstep(0.4, 0.62, value_noise(px / 38.0 + seed));
			float cracked = step(dc, crack * 1.05) * (1.0 - step(0.999, s)) * (1.0 - smoothstep(0.95, 1.0, d));
			col += rim_color.rgb * seam * fracture * cracked * (0.6 + 0.4 * sin(TIME * 20.0 + id * 30.0)) * 0.75;

			if (s > 0.0) {
				// The shard shrinks, turns and drifts inward; look up where
				// this pixel falls on it.
				float k = 1.0 - s;
				vec2 inward = normalize(center_px - c_px + vec2(0.001));
				vec2 q = px - c_px - inward * s * cell_px * 0.4;
				float a = (id - 0.5) * s * 1.4;
				q = vec2(q.x * cos(a) + q.y * sin(a), -q.x * sin(a) + q.y * cos(a));
				vec2 src = c_px + q / max(k, 0.001);
				vec4 sv = shards(src / cell_px);
				bool on_shard = k > 0.03 && distance(sv.xy, v.xy) < 0.001;
				if (on_shard) {
					vec3 shard = dimmed(textureLod(screen_tex, SCREEN_UV + (src - px) * SCREEN_PIXEL_SIZE, 0.0).rgb);
					// Darkening as it falls away, its broken edges glinting.
					shard *= 1.0 - 0.55 * s;
					float edge_glint = 1.0 - smoothstep(0.0, 2.0 / cell_px, sv.z);
					shard += rim_color.rgb * edge_glint * 0.8 * s;
					col = shard;
				} else {
					col = void_color(px);
					// The torn edge of the hole in the world, lit up.
					col += rim_color.rgb * exp(-abs(d - 1.0) * 22.0) * 0.6 * (1.0 - h);
				}
			}
		}

		// Rime left on the world where the dome's edge was.
		if (frost > 0.0) {
			float ring = exp(-pow((d - 0.95) * 7.0, 2.0));
			float rime = fbm(px / 7.0 + seed) * 0.7 + fbm(px / 2.5) * 0.3;
			col = mix(col, vec3(0.88, 0.95, 1.0), clamp(ring * smoothstep(0.35, 0.8, rime) * frost, 0.0, 1.0) * 0.85);
		}
	}

	COLOR = vec4(col, 1.0);
}
