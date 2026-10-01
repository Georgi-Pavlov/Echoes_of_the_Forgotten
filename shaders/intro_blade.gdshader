shader_type canvas_item;

// Sets a painted glowing blade alive: drawn over it, it re-reads the
// picture underneath and runs pulses of light along the blade from hilt to
// tip, with a restless flicker along its burning edge. Only the bright,
// fiery pixels close to the blade's line are touched. `flare` (0..1, from
// GDScript) makes the whole blade blaze.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The blade's base (just past the guard) and tip, in 1280x720 screen pixels.
uniform vec2 base_px;
uniform vec2 tip_px;
// How far either side of the blade's line it's lit, in screen pixels.
uniform float reach_px = 14.0;
uniform float speed = 1.6;
uniform float flare = 0.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.7, 0.35, 1.0);

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

	vec2 axis = tip_px - base_px;
	float len = length(axis);
	vec2 dir = axis / len;
	// 0 at the base, 1 at the tip; and how far off the blade's line.
	float along = dot(px - base_px, dir) / len;
	float off = abs(dot(px - base_px, vec2(-dir.y, dir.x)));
	float near = (1.0 - smoothstep(reach_px * 0.5, reach_px, off))
			* smoothstep(-0.05, 0.02, along) * (1.0 - smoothstep(1.0, 1.04, along));

	float l = dot(col, vec3(0.299, 0.587, 0.114));
	float hot = smoothstep(0.35, 0.7, l) * smoothstep(0.03, 0.2, col.r - col.b);

	// Pulses of light sliding out to the tip, and a quick flicker on top.
	float pulse = pow(0.5 + 0.5 * sin(along * 14.0 - TIME * speed * 4.0), 6.0);
	float flicker = value_noise(vec2(along * 30.0, TIME * 10.0));

	float amount = 0.15 + 0.7 * pulse + 0.25 * flicker + flare * 3.0;
	col += (col * 0.6 + glow_color.rgb * 0.4) * hot * near * amount;

	COLOR = vec4(col, near);
}
