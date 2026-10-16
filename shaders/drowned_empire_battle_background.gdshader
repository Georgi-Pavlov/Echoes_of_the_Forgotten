shader_type canvas_item;

// The Drowned Empire's battle arena, moving where it's painted. Each "region"
// is a patch of the picture that sways on its own, and there are three kinds:
//   kind 0 - kelp: a thin vertical strip rooted at its base (cy) and rising
//            `h` above it; it bends more toward the tip than at the root,
//            like a stalk in a slow current;
//   kind 1 - banner: a strip hanging from its bar (cy) down `h`; it ripples
//            more toward its hem than where it's tied;
//   kind 2 - shark: a soft disc of the picture (radius w, in image heights)
//            that drifts slowly through the water.
// Regions are parallel float arrays (centre x, y, half width, height, kind,
// phase, amplitude, speed), all in image UV.

const int MAX_REGIONS = 24;

uniform float aspect = 1.5;          // image width / height
uniform int region_count = 0;
uniform float region_cx[MAX_REGIONS];
uniform float region_cy[MAX_REGIONS];
uniform float region_w[MAX_REGIONS];
uniform float region_h[MAX_REGIONS];
uniform float region_kind[MAX_REGIONS];
uniform float region_phase[MAX_REGIONS];
uniform float region_amp[MAX_REGIONS];
uniform float region_speed[MAX_REGIONS];

void fragment() {
	vec2 uv = UV;
	vec2 offset = vec2(0.0);

	for (int i = 0; i < MAX_REGIONS; i++) {
		if (i >= region_count) {
			break;
		}
		float t = TIME * region_speed[i] + region_phase[i];
		if (region_kind[i] < 1.5) {
			// A vertical strip: v runs 0..1 from where it's fixed (the kelp's
			// base, the banner's bar) to its free end.
			float v = region_kind[i] < 0.5 ? (region_cy[i] - uv.y) / region_h[i] : (uv.y - region_cy[i]) / region_h[i];
			float across = abs(uv.x - region_cx[i]) / region_w[i];
			float strip = (1.0 - smoothstep(0.55, 1.0, across)) * smoothstep(0.0, 0.06, v) * (1.0 - smoothstep(1.0, 1.08, v));
			float bend = pow(clamp(v, 0.0, 1.0), region_kind[i] < 0.5 ? 1.4 : 1.15);
			float freq = region_kind[i] < 0.5 ? 5.0 : 7.0;
			offset.x += region_amp[i] * (sin(t * 6.2831853 + v * freq) + 0.35 * sin(t * 6.2831853 * 1.7 + v * freq * 1.6)) * bend * strip;
		} else {
			// Shark: a slow drift through the water, a little sway to it.
			vec2 r = uv - vec2(region_cx[i], region_cy[i]);
			float dist = length(r * vec2(aspect, 1.0)) / region_w[i];
			float f = dist < 1.0 ? (1.0 - dist * dist) * (1.0 - dist * dist) : 0.0;
			offset += vec2(sin(t * 6.2831853) * region_amp[i], sin(t * 6.2831853 * 0.7 + 1.3) * region_amp[i] * 0.4) * f;
		}
	}

	COLOR = texture(TEXTURE, clamp(uv + offset, vec2(0.0), vec2(1.0)));
}
