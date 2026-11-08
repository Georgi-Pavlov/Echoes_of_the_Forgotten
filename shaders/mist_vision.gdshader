shader_type canvas_item;
// What a hero sees through the Kingdom of Morvain's mist wall (see
// TERRAIN_DESIGN.md). Drawn by MistVisionFX over the fighters. Columns are
// described as x ranges in screen pixels:
//   clear_range - seen sharply
//   fog_a/fog_b - seen through fog: blurred, washed out and tinted
//   anything else - lost in shadow (same shadow as the blind effect)
// region_shadow = 1: that outside-the-wall layout (shadow beyond the fog).
// ellipse_on = 1: the inside-the-wall layout - the blind effect's elliptical
// window around the hero, with the adjacent columns fogged instead of clear.

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform vec2 view_size = vec2(1280.0, 720.0);
uniform vec2 clear_range = vec2(-5000.0, -4000.0);
uniform vec2 fog_a = vec2(-5000.0, -4000.0);
uniform vec2 fog_b = vec2(-5000.0, -4000.0);
uniform float feather = 36.0;
uniform float region_shadow = 1.0;
uniform float ellipse_on = 0.0;
uniform vec2 center = vec2(640.0, 400.0);
uniform vec2 radius = vec2(300.0, 200.0);
uniform float clear_until = 0.6;
uniform float dark_from = 1.2;
uniform vec4 shadow_color : source_color = vec4(0.07, 0.04, 0.02, 1.0);
uniform vec4 fog_color : source_color = vec4(0.82, 0.86, 0.9, 1.0);
uniform float darkness = 0.97;
uniform float fog_strength = 0.55;
uniform float fog_blur = 2.6;
uniform float time = 0.0;

float soft_box(float x, vec2 r) {
	return smoothstep(r.x - feather, r.x + feather, x) * (1.0 - smoothstep(r.y - feather, r.y + feather, x));
}

void fragment() {
	vec2 p = UV * view_size;
	float clear_amt = soft_box(p.x, clear_range);
	float fog_amt = max(soft_box(p.x, fog_a), soft_box(p.x, fog_b));

	// Shadow: everything not seen at all, plus (inside the wall) whatever lies
	// outside the elliptical window.
	float region_dark = region_shadow * (1.0 - max(clear_amt, fog_amt));
	vec2 q = (p - center) / radius;
	float angle = atan(q.y, q.x);
	float wobble = 0.05 * sin(angle * 3.0 + time * 0.9) + 0.03 * sin(angle * 7.0 - time * 1.4);
	float e = smoothstep(clear_until, dark_from, length(q) + wobble);
	e = e * e * (1.5 - 0.5 * e);
	float shadow = clamp(max(region_dark, ellipse_on * e), 0.0, 1.0) * darkness;

	// Fog: the scene behind it, blurred and washed toward grey-white, with
	// slow drifting patches of thicker and thinner mist.
	float patches = 0.8 + 0.2 * sin(p.x * 0.013 + time * 0.5) * sin(p.y * 0.019 - time * 0.35);
	float fog_a_val = fog_amt * (1.0 - clear_amt) * clamp(fog_strength * patches + 0.3, 0.0, 1.0);
	vec3 blurred = textureLod(screen_tex, SCREEN_UV, fog_blur).rgb;
	vec3 fogged = mix(blurred, fog_color.rgb, 0.45);

	float a = shadow + fog_a_val * (1.0 - shadow);
	vec3 rgb = vec3(0.0);
	if (a > 0.001) {
		rgb = (shadow_color.rgb * shadow + fogged * fog_a_val * (1.0 - shadow)) / a;
	}
	COLOR = vec4(rgb, a);
}
