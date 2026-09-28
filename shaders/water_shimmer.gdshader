shader_type canvas_item;
render_mode blend_add;

// Moonlit shimmer on icy water: two layers of noise drifting against
// each other; only where both line up bright does a glint appear, so
// the highlights ripple and wander. Fades out towards the rect's edges.

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform vec4 tint : source_color = vec4(0.75, 0.88, 1.0, 1.0);
uniform float intensity = 0.55;
uniform vec2 scale = vec2(3.0, 9.0);   // horizontal ripples: squashed vertically
uniform float edge = 0.18;              // soft fade at the rect's edges

void fragment() {
	vec2 uv = UV * scale;
	float a = texture(noise_tex, uv + vec2(TIME * 0.02, TIME * 0.004)).r;
	float b = texture(noise_tex, uv * 1.3 + vec2(-TIME * 0.017, 0.31)).r;
	float glint = smoothstep(0.62, 0.95, a * b * 1.9);
	float twinkle = 0.75 + 0.25 * sin(TIME * 2.3 + a * 12.0);
	vec2 d = min(UV, 1.0 - UV);
	float fade = smoothstep(0.0, edge, d.x) * smoothstep(0.0, edge, d.y);
	COLOR = vec4(tint.rgb, glint * twinkle * fade * intensity);
}
