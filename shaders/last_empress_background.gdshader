shader_type canvas_item;

// The Last Empress's zone art, brought to life where it's painted:
//   - "breathing": a slow swell around breathe_center that fades smoothly
//     to nothing at breathe_radius, so the painted figure seems to inhale
//     and exhale (same as underwater_ripple.gdshader's, with its calm
//     rect keeping the painted stats frame still);
//   - local "regions", each a soft disc of the picture that moves on its
//     own: kind 0 is a jellyfish (its bell contracts and swells as it
//     bobs), kind 1 a shark (it drifts and sways through the water).
// Regions are given as parallel float arrays (centre in image UV, radius in
// units of image height, kind, phase, amplitude, speed).

const int MAX_REGIONS = 10;

uniform vec4 calm_rect = vec4(0.0, 0.0, 0.0, 0.0);
uniform float calm_feather = 0.02;

uniform vec2 breathe_center = vec2(0.3, 0.4);
uniform float breathe_radius = 0.3;
uniform float breathe_amount = 0.0;
uniform float breathe_period = 5.0;
uniform float aspect = 1.0;     // image width / height

uniform int region_count = 0;
uniform float region_cx[MAX_REGIONS];
uniform float region_cy[MAX_REGIONS];
uniform float region_radius[MAX_REGIONS];
uniform float region_kind[MAX_REGIONS];
uniform float region_phase[MAX_REGIONS];
uniform float region_amp[MAX_REGIONS];
uniform float region_speed[MAX_REGIONS];

void fragment() {
	vec2 uv = UV;
	vec2 offset = vec2(0.0);

	// Breathing: sample slightly toward the centre (and from a touch lower)
	// on the inhale, which swells the figure and lifts it a hair.
	vec2 rel = uv - breathe_center;
	float d = length(rel * vec2(aspect, 1.0)) / breathe_radius;
	float falloff = d < 1.0 ? (1.0 - d * d) * (1.0 - d * d) : 0.0;
	float breath = 0.5 - 0.5 * cos(TIME * 6.2831853 / breathe_period);
	float swell = breathe_amount * breath * falloff;
	offset += -rel * swell + vec2(0.0, 0.3 * swell * breathe_radius);

	// The calm rect (the painted frame) is left undistorted by the breath.
	vec2 dc = max(calm_rect.xy - uv, uv - calm_rect.zw);
	float outside = max(dc.x, dc.y);
	offset *= smoothstep(0.0, calm_feather, outside);

	for (int i = 0; i < MAX_REGIONS; i++) {
		if (i >= region_count) {
			break;
		}
		vec2 c = vec2(region_cx[i], region_cy[i]);
		vec2 r = uv - c;
		float dist = length(r * vec2(aspect, 1.0)) / region_radius[i];
		float f = dist < 1.0 ? (1.0 - dist * dist) * (1.0 - dist * dist) : 0.0;
		float t = TIME * region_speed[i] + region_phase[i];
		if (region_kind[i] < 0.5) {
			// Jellyfish: the bell swells and contracts, the whole body bobs.
			float pulse = sin(t * 6.2831853);
			offset += -r * (region_amp[i] * pulse) * f;
			offset += vec2(sin(t * 3.1) * 0.0012, -0.004 * sin(t * 6.2831853 * 0.5) * region_amp[i] * 12.0) * f;
		} else {
			// Shark: a slow drift through the water, a little sway to it.
			offset += vec2(sin(t * 6.2831853) * region_amp[i], sin(t * 6.2831853 * 0.7 + 1.3) * region_amp[i] * 0.4) * f;
		}
	}

	COLOR = texture(TEXTURE, clamp(uv + offset, vec2(0.0), vec2(1.0)));
}
