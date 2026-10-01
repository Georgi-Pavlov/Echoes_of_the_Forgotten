shader_type canvas_item;

// Turns a painted wheel (a mill wheel, say) seen at an angle: the wheel is
// an upright ellipse on screen, so the picture inside it is stretched out
// to a circle, turned, and squashed back - the spokes sweep round the way
// they would on the real, tilted wheel. Only the spokes inside the rim
// turn - the rim and whatever's around it stay as painted.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The wheel's centre and its half-width/half-height, in screen pixels.
uniform vec2 center_px = vec2(640.0, 360.0);
uniform vec2 radii_px = vec2(12.0, 18.0);
// Radians per second; positive turns clockwise on screen.
uniform float speed = 0.6;

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	vec2 q = (SCREEN_UV * size - center_px) / radii_px;
	float r = length(q);
	float a = -TIME * speed;
	vec2 src = vec2(q.x * cos(a) - q.y * sin(a), q.x * sin(a) + q.y * cos(a));
	vec3 col = textureLod(screen_tex, (src * radii_px + center_px) / size, 0.0).rgb;
	COLOR = vec4(col, 1.0 - smoothstep(0.62, 0.78, r));
}
