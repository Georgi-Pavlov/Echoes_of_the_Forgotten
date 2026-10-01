shader_type canvas_item;

// Makes painted red, fleshy growths throb like living tissue: drawn over
// them, it re-reads the picture underneath and pulses the crimson pixels
// brighter and more saturated in a slow heartbeat - a double thump, then a
// rest - that ripples outward across the land from a point, so nearer
// growths beat a moment before farther ones. Everything not crimson is
// left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Where the beat spreads from, in screen pixels, and how fast it spreads.
uniform vec2 source_px = vec2(913.0, 40.0);
uniform float spread_px_per_sec = 250.0;
uniform float beat_period = 3.2;
uniform float strength = 0.9;
uniform vec4 glow_color : source_color = vec4(1.0, 0.15, 0.2, 1.0);
uniform vec4 edge_fade = vec4(0.001, 0.08, 0.001, 0.001);

void fragment() {
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float l = dot(col, vec3(0.299, 0.587, 0.114));
	float flesh = smoothstep(0.1, 0.25, col.r - max(col.g, col.b)) * (1.0 - smoothstep(0.45, 0.6, l));

	float t = TIME - distance(px, source_px) / spread_px_per_sec;
	float phase = fract(t / beat_period);
	// Lub-dub: two quick thumps, the second softer, then quiet.
	float beat = exp(-pow((phase - 0.08) * 22.0, 2.0)) + 0.6 * exp(-pow((phase - 0.26) * 22.0, 2.0));

	col += (col * 0.9 + glow_color.rgb * 0.25) * flesh * beat * strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
