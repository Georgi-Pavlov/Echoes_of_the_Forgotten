shader_type canvas_item;

// Makes a painted giant breathe: drawn over it, it re-reads the picture
// underneath slightly stretched about a point at its feet - taller and a
// touch narrower on the in-breath, settling back on the out-breath - and
// sways its upper reaches (a crown of branches, say) gently from side to
// side, more the higher up they are. The rect's edges fade out, so what's
// around it stays put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Where the stretch is anchored, in 1280x720 screen pixels.
uniform vec2 pivot_px = vec2(900.0, 520.0);
// How much taller it gets at the top of a breath (0.01 = 1%).
uniform float breath_amount = 0.008;
uniform float breath_period = 4.5;
// How far the top of the rect sways each way, in screen pixels.
uniform float sway_px = 3.0;
uniform float sway_period = 7.0;
uniform vec4 edge_fade = vec4(0.15, 0.001, 0.1, 0.15);

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	vec2 px = SCREEN_UV * size;

	// Slow in, slow out: a sine eased towards the top of the breath.
	float breath = 0.5 - 0.5 * cos(TIME * TAU / breath_period);
	breath = breath * breath * (3.0 - 2.0 * breath);
	vec2 stretch = vec2(1.0 - breath * breath_amount * 0.5, 1.0 + breath * breath_amount);
	vec2 src = pivot_px + (px - pivot_px) / stretch;

	float height = 1.0 - UV.y;
	src.x -= sin(TIME * TAU / sway_period) * sway_px * height * height;

	vec3 col = textureLod(screen_tex, src / size, 0.0).rgb;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
