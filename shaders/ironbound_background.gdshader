shader_type canvas_item;

// The Ironbound Isles' zone art, brought to life in place:
//   - sea: the water rolls (a gentle moving warp) and its foam glints
//   - face: the tentacles hanging from Kaelen Varr's face writhe - waves
//     travel down them so the tips sway more than the roots - and every
//     so often (`twitch`, driven from GDScript) they jerk and curl
//   - deep: tentacles like his rise out of the dark behind him, sway,
//     and sink back out of sight. They're drawn only where the dark
//     navy backdrop shows, never over the hero himself (he's painted
//     into the same image), so they read as being behind him
// A calm rect (UV x0/y0/x1/y1) keeps the stats frame still.

uniform float aspect = 1.0;  // image width / height
uniform vec4 calm_rect = vec4(0.0);

// Sea: up to two rects (UV) the water fills.
uniform vec4 sea_rect_a = vec4(0.0);
uniform vec4 sea_rect_b = vec4(0.0);
uniform float sea_warp = 0.0022;

// Face tentacles: the rect they hang in, where they're rooted (UV y),
// and a 0..1 twitch pulse from GDScript.
uniform vec4 face_rect = vec4(0.0);
uniform float face_root_y = 0.15;
uniform float face_sway = 0.006;
uniform float twitch = 0.0;

// Deep tentacles: the region they live in (UV), the line they rise from
// (UV y), and each one's base x (UV) and how high it reaches (UV).
const int DEEP_COUNT = 6;
uniform vec4 deep_rect = vec4(0.0);
uniform float deep_floor = 0.64;
uniform float deep_x[DEEP_COUNT];
uniform float deep_reach[DEEP_COUNT];
uniform float deep_period = 14.0;
uniform vec4 flesh_color : source_color = vec4(0.38, 0.19, 0.19, 1.0);
uniform vec4 rim_color : source_color = vec4(0.45, 0.62, 0.7, 1.0);

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

void fragment() {
	vec2 uv = UV;
	vec2 src = uv;

	// --- Sea: rolling swell and sideways drift.
	float sea = max(rect_mask(uv, sea_rect_a, 0.02), rect_mask(uv, sea_rect_b, 0.02));
	if (sea > 0.0) {
		float w1 = sin(uv.x * 90.0 + uv.y * 40.0 - TIME * 1.6);
		float w2 = sin(uv.x * 37.0 - uv.y * 70.0 + TIME * 1.1);
		src += vec2(w1 * 0.6 + w2 * 0.4, w2 * 0.5 + w1 * 0.3) * sea_warp * sea;
	}

	// --- Face tentacles: waves running down them.
	float face = rect_mask(uv, face_rect, 0.015);
	if (face > 0.0) {
		float len = max(face_rect.w - face_root_y, 0.01);
		float s = clamp((uv.y - face_root_y) / len, 0.0, 1.0);
		float wave = sin(uv.y * 70.0 - TIME * 2.2 + uv.x * 25.0) * 0.7
				+ sin(uv.y * 31.0 - TIME * 1.3 - uv.x * 40.0) * 0.5;
		// A twitch: a sharp jerk and curl, strongest at the tips.
		float jerk = twitch * sin(uv.y * 45.0 - TIME * 9.0) * 1.8;
		src.x += (wave + jerk) * face_sway * s * s * face;
		src.y -= twitch * 0.006 * s * s * face;
	}

	float calm_d = max(max(calm_rect.x - uv.x, uv.x - calm_rect.z), max(calm_rect.y - uv.y, uv.y - calm_rect.w));
	float calm = calm_rect.z > calm_rect.x ? smoothstep(0.0, 0.015, calm_d) : 1.0;
	src = mix(uv, src, calm);
	vec4 col = texture(TEXTURE, clamp(src, vec2(0.0), vec2(1.0)));

	// Foam glinting: the brightest crests catch moving light.
	if (sea > 0.0) {
		float luma = dot(col.rgb, vec3(0.299, 0.587, 0.114));
		float glint = value_noise(vec2(uv.x * 60.0 * aspect - TIME * 0.7, uv.y * 90.0 + TIME * 0.4));
		col.rgb += vec3(0.75, 0.85, 0.95) * smoothstep(0.55, 0.85, luma) * smoothstep(0.55, 0.9, glint) * 0.22 * sea * calm;
	}

	// --- Deep tentacles, behind the hero.
	float region = rect_mask(uv, deep_rect, 0.03);
	if (region > 0.0) {
		// Only where the dark navy backdrop shows: bluer than it is red,
		// and dark. Anything else (the hero, the spray) stays in front.
		float blue = col.b - col.r;
		float luma = dot(col.rgb, vec3(0.299, 0.587, 0.114));
		float backdrop = smoothstep(0.05, 0.11, blue) * (1.0 - smoothstep(0.2, 0.3, luma));
		float body = 0.0;
		float shade = 0.0;
		float rim = 0.0;
		float sucker = 0.0;
		float depth = 0.0;
		float pit = 0.0;
		float edge_dark = 0.0;
		float spec = 0.0;
		for (int i = 0; i < DEEP_COUNT; i++) {
			if (deep_reach[i] <= 0.0) {
				continue;
			}
			float fi = float(i);
			// Each rises, lingers, and sinks back, on a staggered cycle.
			float p = fract(TIME / deep_period + fi * 0.37);
			float up = smoothstep(0.0, 0.35, p) * (1.0 - smoothstep(0.62, 1.0, p));
			float height = deep_reach[i] * up;
			if (height <= 0.005) {
				continue;
			}
			float s = (deep_floor - uv.y) / height;   // 0 at the floor, 1 at the tip
			if (s < -0.05 || s > 1.05) {
				continue;
			}
			float sc = clamp(s, 0.0, 1.0);
			// Sways, bending more toward the tip, and curls over at the top.
			float bend = sin(sc * 4.0 - TIME * (0.8 + 0.15 * fi) + fi * 1.7) * 0.03 * sc
					+ sin(TIME * 0.5 + fi) * 0.02 * sc * sc;
			float curl = (sc > 0.8) ? (sc - 0.8) * 0.12 * sin(fi * 2.0 + 1.0) : 0.0;
			float cx = deep_x[i] + bend + curl;
			// Half-width in image-height units: thick at the base, tapering
			// to a fine point.
			float w = mix(0.048, 0.004, pow(sc, 0.65));
			float dx = (uv.x - cx) * aspect;
			float across = dx / w;                  // -1..1 across the body
			float inside = 1.0 - smoothstep(0.8, 1.0, abs(across));
			// Rounded tip.
			inside *= 1.0 - smoothstep(0.96, 1.02, s);
			if (inside <= body) {
				continue;
			}
			body = inside;
			// Round, not flat: lit on one side, falling into shadow on the other.
			float round_ = sqrt(max(0.0, 1.0 - across * across));
			shade = round_ * (0.55 + 0.45 * smoothstep(-0.9, 0.7, across));
			rim = smoothstep(0.45, 0.9, across) * (1.0 - smoothstep(0.9, 1.0, across));
			// A row of suckers down the shadowed underside: pale rings with
			// dark centers, shrinking toward the tip.
			vec2 sq = vec2((fract(sc * 16.0) - 0.5) * 1.2, (across + 0.5) * 1.4);
			float sd = length(sq);
			float ring = (1.0 - smoothstep(0.26, 0.34, sd)) * smoothstep(0.12, 0.2, sd);
			sucker = ring * (1.0 - smoothstep(0.65, 0.95, sc));
			pit = (1.0 - smoothstep(0.1, 0.16, sd)) * (1.0 - smoothstep(0.65, 0.95, sc));
			edge_dark = smoothstep(0.7, 0.97, abs(across));
			spec = exp(-pow((across - 0.3) * 3.5, 2.0)) * round_;
			depth = sc;
		}
		float a = body * backdrop * region * calm;
		if (a > 0.0) {
			// Mottled skin, shaded round, with a wet highlight along the lit
			// side, a dark outline like the painted ones, and the suckers.
			vec3 flesh = flesh_color.rgb * (0.6 + 0.4 * value_noise(uv * vec2(300.0, 170.0)));
			flesh *= 0.3 + 0.9 * shade;
			flesh += vec3(0.55, 0.4, 0.36) * spec * 0.45;
			flesh = mix(flesh, vec3(0.62, 0.46, 0.42) * (0.55 + 0.45 * shade), sucker * 0.8);
			flesh = mix(flesh, vec3(0.08, 0.03, 0.04), pit * 0.7);
			flesh *= 1.0 - 0.7 * edge_dark;
			flesh += rim_color.rgb * rim * 0.18;
			// Deep in the dark: it's murkiest where it comes up out of the
			// gloom and clearest toward the tip, never fully opaque.
			float murk = mix(0.6, 0.92, smoothstep(0.0, 0.5, depth));
			col.rgb = mix(col.rgb, flesh, a * murk);
		}
	}

	COLOR = col;
}
