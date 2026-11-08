shader_type canvas_item;
// The blinded hero's view: a soft shadow over the whole battlefield with an
// elliptical window of clear sight around the hero. Drawn by BlindVisionFX.

uniform vec2 view_size = vec2(1280.0, 720.0);
// Window centre and semi-axes, in screen pixels.
uniform vec2 center = vec2(640.0, 400.0);
uniform vec2 radius = vec2(300.0, 200.0);
// Where the shadow starts to thicken and where it is fully dark, as
// multiples of the ellipse radius.
uniform float clear_until = 0.6;
uniform float dark_from = 1.2;
uniform vec4 shadow_color : source_color = vec4(0.07, 0.04, 0.02, 1.0);
uniform float darkness = 0.97;
uniform float time = 0.0;

void fragment() {
	vec2 p = UV * view_size;
	vec2 q = (p - center) / radius;
	// An uneven edge, like drifting sand: the ellipse breathes in and out.
	float angle = atan(q.y, q.x);
	float wobble = 0.05 * sin(angle * 3.0 + time * 0.9) + 0.03 * sin(angle * 7.0 - time * 1.4);
	float d = length(q) + wobble;
	float a = smoothstep(clear_until, dark_from, d);
	// Eased in, so the shadow creeps in gently at the window's edge and then
	// closes up, rather than a flat linear fade.
	a = a * a * (1.5 - 0.5 * a);
	COLOR = vec4(shadow_color.rgb, a * darkness);
}
