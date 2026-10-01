shader_type canvas_item;

// Makes a painted, burning wound throb like a heart: drawn over it, it
// re-reads the picture underneath and pulses its crimson pixels brighter
// in a slow, heavy beat - a double thump, then a rest - that spreads out
// from the wound's core, so the veins at its edge beat a moment after the
// centre. Only true crimson is touched: orange-brown highlights around it
// (bark, firelit branches) are left as painted. `flare` (0..1, from
// GDScript) sets the whole wound blazing.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 core_px = vec2(880.0, 233.0);
uniform float spread_px_per_sec = 220.0;
uniform float beat_period = 2.4;
uniform float strength = 1.0;
uniform float flare = 0.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.12, 0.1, 1.0);
uniform vec4 edge_fade = vec4(0.15, 0.15, 0.15, 0.15);

void fragment() {
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	// Crimson: clearly red over both green and blue, and red rather than
	// orange - green not far above blue.
	float redness = col.r - max(col.g, col.b);
	float crimson = smoothstep(0.06, 0.2, redness) * (1.0 - smoothstep(0.08, 0.2, col.g - col.b));

	float t = TIME - distance(px, core_px) / spread_px_per_sec;
	float phase = fract(t / beat_period);
	float beat = exp(-pow((phase - 0.08) * 18.0, 2.0)) + 0.65 * exp(-pow((phase - 0.24) * 18.0, 2.0));

	float amount = (0.25 + beat) * strength + flare * 2.5;
	col += (col * 0.9 + glow_color.rgb * 0.3) * crimson * amount;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
