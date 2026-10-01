shader_type canvas_item;

// A painted cracked, molten sun throbbing with heat: drawn over the sun in
// a rect the disc fits inside (as an ellipse), it re-reads the picture
// underneath and brightens its glowing cracks in slow waves that roll out
// from the centre, so different cracks flare at different moments. Dark
// crust between the cracks is left as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float strength = 1.6;
uniform float speed = 1.6;
uniform vec4 heat_color : source_color = vec4(1.0, 0.55, 0.2, 1.0);

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
	vec3 col = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;

	// Hot = bright and orange; the crust and grey clouds aren't.
	float hot = smoothstep(0.08, 0.35, col.r - col.b) * smoothstep(0.3, 0.8, col.r);

	float r = length((UV - 0.5) * 2.0);
	float n = value_noise(UV * 7.0 + TIME * 0.2);
	float pulse = 0.5 + 0.5 * sin(TIME * speed - r * 7.0 + n * 4.0);
	pulse = pulse * pulse;

	col += (col * 0.8 + heat_color.rgb * 0.5) * hot * pulse * strength;
	// Between flares the cracks never go fully dull - a low steady burn.
	col += heat_color.rgb * hot * 0.12 * strength;

	float mask = 1.0 - smoothstep(0.8, 1.0, r);
	COLOR = vec4(col, mask);
}
