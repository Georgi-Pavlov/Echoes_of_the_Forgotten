shader_type canvas_item;

// Sets a painted ship sailing the sky: drawn over it in a rect a little
// bigger than the ship, it re-reads the picture underneath rocked gently
// about a pivot (the hull), bobbing up and down and swaying slowly back and
// forth along its course. The rect's edges fade out over sky, so the ship
// itself always moves as one piece.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Pivot the ship rocks about, in 1280x720 screen pixels.
uniform vec2 pivot = vec2(640.0, 360.0);
uniform float rock_degrees = 1.2;
uniform float rock_period = 5.0;
uniform float bob_px = 2.5;
uniform float bob_period = 4.0;
// Slow back-and-forth along its course (+x), in screen pixels.
uniform float sway_px = 4.0;
uniform float sway_period = 18.0;
uniform float phase = 0.0;
// Soft fade width at the rect's edges (left, top, right, bottom), in rect UV.
uniform vec4 edge_fade = vec4(0.1, 0.08, 0.1, 0.08);
// Up to two areas inside the rect left alone (screen UV: x0, y0, x1, y1).
uniform vec4 exclude_a = vec4(0.0);
uniform vec4 exclude_b = vec4(0.0);

float outside(vec2 p, vec4 r) {
	vec2 inside = smoothstep(r.xy - 0.003, r.xy + 0.003, p) * (1.0 - smoothstep(r.zw - 0.003, r.zw + 0.003, p));
	return 1.0 - inside.x * inside.y;
}

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	float angle = radians(rock_degrees) * sin(TIME * TAU / rock_period + phase);
	vec2 offset = vec2(sin(TIME * TAU / sway_period + phase) * sway_px,
			sin(TIME * TAU / bob_period + phase * 1.7) * bob_px);

	// Where this pixel's colour comes from: undo the move, then the turn.
	vec2 p = SCREEN_UV * size - pivot - offset;
	float c = cos(-angle);
	float s = sin(-angle);
	vec2 src = vec2(p.x * c - p.y * s, p.x * s + p.y * c) + pivot;
	vec3 col = textureLod(screen_tex, src / size, 0.0).rgb;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	mask *= outside(SCREEN_UV, exclude_a) * outside(SCREEN_UV, exclude_b);
	COLOR = vec4(col, mask);
}
