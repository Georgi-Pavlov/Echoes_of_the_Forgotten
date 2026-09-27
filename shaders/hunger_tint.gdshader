shader_type canvas_item;

// The Hunger Calls' mark on the enemies it drives at its victim: laid over
// a unit's sprite (as a copy of it), a reddish wash over the art - its
// own shading kept, just steeped in red - slowly throbbing. The sprite's
// alpha is the mask; the node's modulate (its fade) is honoured.

uniform vec4 hunger_color : source_color = vec4(0.95, 0.12, 0.1, 1.0);
uniform float strength = 0.55;

varying vec4 v_modulate;

void vertex() {
	v_modulate = COLOR;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float l = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float throb = 0.8 + 0.2 * sin(TIME * 4.0);
	vec3 c = hunger_color.rgb * (0.35 + 1.1 * l);
	COLOR = vec4(c, tex.a * strength * throb) * v_modulate;
}
