shader_type canvas_item;

// The intro's mist: slow rolling fog, layered noise drifting sideways,
// thickest along a horizontal band and fading out at the rect's edges.
// Drawn over a scene image in its own rect. Same look as fog_drift.gdshader,
// with a hash that stays smooth over the long time the intro runs.

uniform vec4 fog_color : source_color = vec4(0.78, 0.8, 0.84, 1.0);
uniform float density = 0.35;
uniform float speed = 0.02;
uniform float scale = 3.0;
uniform float aspect = 1.0;          // rect width / height
// Where (rect UV y) the fog is thickest, and how far it spreads from there.
uniform float band_center = 0.55;
uniform float band_height = 0.35;
// Soft fade-in width at each edge (left, top, right, bottom), in rect UV.
uniform vec4 edge_fade = vec4(0.25, 0.1, 0.05, 0.1);

// Arithmetic hash - fog_drift.gdshader's fract(sin(...)) one loses
// precision as the drifting coordinates grow and the fog turns blocky.
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
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
	vec2 p = UV * vec2(aspect, 1.0) * scale;
	float t = TIME * speed;
	// Two layers drifting at different speeds, one warping the other,
	// so the fog curls instead of just sliding.
	float warp = fbm(p * 0.7 + vec2(t * 3.0, t * 0.7));
	float f = fbm(p + vec2(-t * 5.0, t * 1.3) + warp * 1.4);
	float fog = smoothstep(0.35, 0.85, f);

	float band = 1.0 - smoothstep(0.0, band_height, abs(UV.y - band_center));
	float edges = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	float breathe = 0.85 + 0.15 * sin(TIME * 0.4);

	COLOR = vec4(fog_color.rgb, fog * band * edges * density * breathe);
}
