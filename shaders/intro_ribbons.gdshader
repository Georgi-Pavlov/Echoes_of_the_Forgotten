shader_type canvas_item;

// Sets painted ribbons of magic flowing: drawn over them, it re-reads the
// picture underneath and runs pulses of light along the glowing,
// blue-white streams - as if current were racing through them - with a
// soft shimmer between pulses. Only the bright, blue-white ribbon pixels
// are touched; the paler sky and the stone around them stay as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The column the ribbons spiral around, in screen pixels (x).
uniform float axis_px = 805.0;
uniform float speed = 1.6;
uniform float strength = 0.9;
uniform vec4 pulse_color : source_color = vec4(0.75, 0.9, 1.0, 1.0);
uniform vec4 edge_fade = vec4(0.08, 0.001, 0.08, 0.1);

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 px = SCREEN_UV * vec2(1280.0, 720.0);
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	float l = dot(col, vec3(0.299, 0.587, 0.114));
	float ribbon = smoothstep(0.72, 0.88, l) * smoothstep(0.08, 0.2, col.b - col.r);

	// The ribbons wind round the column: measure along them by how far out
	// from the axis a pixel is plus how far down - pulses then travel
	// outward and downward along the spirals.
	float along = abs(px.x - axis_px) * 0.9 + px.y * 0.6;
	float n = value_noise(px / 60.0 + TIME * 0.2);
	float pulse = 0.5 + 0.5 * sin(along / 38.0 - TIME * speed * 3.0 + n * 3.0);
	pulse = pow(pulse, 5.0);
	float shimmer = 0.5 + 0.5 * sin(TIME * 9.0 + px.x * 0.07 + px.y * 0.05);

	col += (pulse_color.rgb * 0.6 + col * 0.4) * ribbon * (pulse + shimmer * 0.15) * strength;

	float mask = smoothstep(0.0, edge_fade.x, UV.x) * smoothstep(0.0, edge_fade.y, UV.y)
			* (1.0 - smoothstep(1.0 - edge_fade.z, 1.0, UV.x))
			* (1.0 - smoothstep(1.0 - edge_fade.w, 1.0, UV.y));
	COLOR = vec4(col, mask);
}
