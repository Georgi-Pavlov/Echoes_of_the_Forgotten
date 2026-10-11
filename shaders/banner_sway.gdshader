shader_type canvas_item;

// Cloth swaying in the wind, straight on a background image: inside each
// rect (image UV x0, y0, x1, y1) the texture lookup is pushed sideways by
// a travelling wave, growing from nothing at the pole it hangs from to its
// full amount at the free end. "hang" rects hang from their top edge;
// "flag" is anchored on its left edge and flutters up and down instead.
// A rect of zero size is off.

uniform vec4 hang_a = vec4(0.0);
uniform vec4 hang_b = vec4(0.0);
uniform vec4 hang_c = vec4(0.0);
uniform vec4 flag_a = vec4(0.0);
uniform float amount = 0.006;
uniform float wind = 1.0;      // gust strength, driven from script (0..1+)

// Breathing: a slow swell around breathe_center (radius in image heights),
// fading to nothing at its edge and kept off the calm rect (the stats frame).
uniform vec2 breathe_center = vec2(0.5, 0.5);
uniform float breathe_radius = 0.3;
uniform float breathe_amount = 0.0;
uniform float breathe_period = 4.0;
uniform float aspect = 1.0;
uniform vec4 calm_rect = vec4(0.0);
uniform float calm_feather = 0.02;

vec2 hang(vec4 r, vec2 uv, float phase) {
	vec2 size = r.zw - r.xy;
	if (size.x <= 0.0 || size.y <= 0.0) {
		return vec2(0.0);
	}
	vec2 q = (uv - r.xy) / size;
	if (q.x < 0.0 || q.x > 1.0 || q.y < 0.0 || q.y > 1.0) {
		return vec2(0.0);
	}
	float side = smoothstep(0.0, 0.12, q.x) * (1.0 - smoothstep(0.88, 1.0, q.x));
	float free_end = q.y * q.y;
	float wave = sin(TIME * 1.7 + q.y * 5.0 + phase) + 0.45 * sin(TIME * 3.1 + q.y * 9.0 + phase * 2.0);
	return vec2(wave * free_end * side * amount * wind, 0.0);
}

vec2 flag(vec4 r, vec2 uv) {
	vec2 size = r.zw - r.xy;
	if (size.x <= 0.0 || size.y <= 0.0) {
		return vec2(0.0);
	}
	vec2 q = (uv - r.xy) / size;
	if (q.x < 0.0 || q.x > 1.0 || q.y < 0.0 || q.y > 1.0) {
		return vec2(0.0);
	}
	float edge = smoothstep(0.0, 0.15, q.y) * (1.0 - smoothstep(0.85, 1.0, q.y));
	float free_end = q.x * q.x;
	float wave = sin(TIME * 2.0 - q.x * 6.0) + 0.4 * sin(TIME * 3.7 - q.x * 11.0);
	return vec2(0.0, wave * free_end * edge * amount * 1.4 * wind);
}

void fragment() {
	vec2 offset = hang(hang_a, UV, 0.0) + hang(hang_b, UV, 1.7) + hang(hang_c, UV, 3.1) + flag(flag_a, UV);
	vec2 rel = UV - breathe_center;
	float d = length(rel * vec2(aspect, 1.0)) / breathe_radius;
	float falloff = d < 1.0 ? (1.0 - d * d) * (1.0 - d * d) : 0.0;
	float breath = 0.5 - 0.5 * cos(TIME * 6.2831853 / breathe_period);
	float swell = breathe_amount * breath * falloff;
	vec2 b_off = -rel * swell + vec2(0.0, 0.3 * swell * breathe_radius);
	vec2 dc = max(calm_rect.xy - UV, UV - calm_rect.zw);
	b_off *= smoothstep(0.0, calm_feather, max(dc.x, dc.y));
	offset += b_off;
	COLOR = texture(TEXTURE, clamp(UV + offset, vec2(0.0), vec2(1.0)));
}
