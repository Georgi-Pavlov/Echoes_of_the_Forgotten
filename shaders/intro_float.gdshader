shader_type canvas_item;

// Sets a painted object hanging in the sky drifting gently up and down:
// drawn over it in a rect a little bigger than the object, it re-reads the
// picture underneath shifted by a few pixels. The rect's edges fade out
// over the bit of sky around the object, so only sky blends there - the
// object itself always moves as one piece.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// How far it drifts each way, in 1280x720 screen pixels.
uniform float amplitude = 3.0;
uniform float period = 6.0;
uniform float phase = 0.0;
// Soft fade width at the rect's edges (left, top, right, bottom), in rect
// UV. Use a tiny width on an edge that sits on the screen's edge.
uniform vec4 edge_fade = vec4(0.2, 0.12, 0.2, 0.12);
// Up to two areas inside the rect left alone (screen UV: x0, y0, x1, y1) -
// for a neighbouring object that drifts on its own.
uniform vec4 exclude_a = vec4(0.0);
uniform vec4 exclude_b = vec4(0.0);

float outside(vec2 p, vec4 r) {
	vec2 inside = smoothstep(r.xy - 0.003, r.xy + 0.003, p) * (1.0 - smoothstep(r.zw - 0.003, r.zw + 0.003, p));
	return 1.0 - inside.x * inside.y;
}

void fragment() {
	float t = TIME * TAU / period + phase;
	// Mostly up and down, with a slight sideways sway a quarter-cycle off,
	// so it bobs rather than slides.
	vec2 drift = vec2(sin(t * 0.5) * 0.3, sin(t)) * amplitude / vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV - drift, 0.0).rgb;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	mask *= outside(SCREEN_UV, exclude_a) * outside(SCREEN_UV, exclude_b);
	COLOR = vec4(col, mask);
}
