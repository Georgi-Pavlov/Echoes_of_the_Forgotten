shader_type canvas_item;

// A painted ritual circle pulsing with power: drawn over the floor, it
// re-reads the picture underneath and brightens the glowing lines etched
// into it in rings of light that spread outward from the circle's centre
// (seen in perspective, so the rings are flattened ellipses). Only the
// already-glowing gold lines light up - dark stone and kneeling figures
// stay as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The circle's centre in screen pixels, and how flattened it looks.
uniform vec2 center_px = vec2(900.0, 620.0);
uniform float squash = 3.2;
uniform float ring_px = 70.0;
uniform float speed = 1.4;
uniform float strength = 0.9;
uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.45, 1.0);
uniform vec4 edge_fade = vec4(0.12, 0.2, 0.12, 0.2);

void fragment() {
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	float l = dot(col, vec3(0.299, 0.587, 0.114));
	float lines = smoothstep(0.45, 0.75, l) * smoothstep(0.05, 0.2, col.r - col.b);

	vec2 d = px - center_px;
	float r = length(vec2(d.x, d.y * squash));
	float wave = 0.5 + 0.5 * sin(r / ring_px * 6.2832 - TIME * speed * 3.0);
	wave = pow(wave, 3.0);
	// The whole circle also breathes slowly.
	float breathe = 0.7 + 0.3 * sin(TIME * 0.8);

	col += (col * 0.6 + glow_color.rgb * 0.4) * lines * wave * breathe * strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
