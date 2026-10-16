shader_type canvas_item;
render_mode blend_add;

// Light rippling across a sunken stone floor: the bright net of lines
// sunlight makes through moving water, drifting slowly. Two layers of the
// classic tileable water-caustic pattern at different scales and speeds, so
// the net never looks regular, squashed vertically to sit on the floor in
// perspective. Pure added light, faded out toward the edges of its rect so
// it never shows a boundary.

uniform vec4 caustic_color : source_color = vec4(0.55, 0.95, 1.0, 1.0);
uniform float intensity = 0.3;
uniform float scale = 1.5;
uniform float speed = 0.35;
uniform float aspect = 1.0;                       // rect width / height
uniform vec2 stretch = vec2(1.0, 2.2);            // y > 1 flattens the cells
// Fade distance at the left, top, right and bottom edges (fractions of the rect).
uniform vec4 edge_fade = vec4(0.04, 0.25, 0.04, 0.35);

float caustic(vec2 uv, float t) {
	vec2 p = mod(uv * 6.28318530718, 6.28318530718) - 250.0;
	vec2 i = p;
	float c = 1.0;
	float inten = 0.005;
	for (int n = 0; n < 4; n++) {
		float tt = t * (1.0 - (3.5 / float(n + 1)));
		i = p + vec2(cos(tt - i.x) + sin(tt + i.y), sin(tt - i.y) + cos(tt + i.x));
		c += 1.0 / length(vec2(p.x / (sin(i.x + tt) / inten), p.y / (cos(i.y + tt) / inten)));
	}
	c /= 4.0;
	c = 1.17 - pow(c, 1.4);
	return pow(abs(c), 8.0);
}

void fragment() {
	vec2 uv = UV * vec2(aspect, 1.0) * scale * stretch;
	float t = TIME * speed;
	float c = clamp(caustic(uv, t) + 0.6 * caustic(uv * 1.7 + vec2(0.31, 0.77), t * 0.8 + 2.0), 0.0, 1.5);
	float fade = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.z, 1.0 - UV.x)
			* smoothstep(0.0, edge_fade.y, UV.y) * smoothstep(0.0, edge_fade.w, 1.0 - UV.y);
	COLOR = vec4(caustic_color.rgb * c * intensity * fade, 1.0);
}
