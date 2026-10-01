shader_type canvas_item;

// Sets painted storm clouds slowly swirling round a point - into a rift,
// say: drawn over them, it re-reads the picture underneath pushed along a
// whirlpool flow (round and inward), using the two-phase flow-map trick so
// the clouds keep moving for as long as the scene is up instead of
// stretching further and further. Only the dark cloud pixels move; bright
// lightning and glow stay put.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// The whirlpool's centre and its half-width/half-height, in screen pixels.
uniform vec2 center_px = vec2(913.0, 40.0);
uniform vec2 radii_px = vec2(260.0, 200.0);
// How far the clouds travel each cycle, and how long a cycle takes.
uniform float travel_px = 14.0;
uniform float cycle = 6.0;
// 1 = clockwise on screen, -1 = anticlockwise.
uniform float turn = -1.0;
uniform float inward = 0.35;

void fragment() {
	vec2 size = vec2(1280.0, 720.0);
	vec2 d = (SCREEN_UV * size - center_px) / radii_px;
	float r = length(d);
	vec2 tangent = turn * vec2(-d.y, d.x) / max(r, 0.001);
	vec2 flow = (tangent - normalize(d + 0.0001) * inward) * radii_px / max(radii_px.x, radii_px.y);
	// Faster near the middle, as a whirlpool would.
	flow *= mix(1.4, 0.5, clamp(r, 0.0, 1.0));

	float t = TIME / cycle;
	float p1 = fract(t);
	float p2 = fract(t + 0.5);
	vec2 o1 = flow * (p1 - 0.5) * travel_px / size;
	vec2 o2 = flow * (p2 - 0.5) * travel_px / size;
	vec3 a = textureLod(screen_tex, SCREEN_UV - o1, 0.0).rgb;
	vec3 b = textureLod(screen_tex, SCREEN_UV - o2, 0.0).rgb;
	vec3 col = mix(a, b, abs(p1 - 0.5) * 2.0);

	vec3 here = textureLod(screen_tex, SCREEN_UV, 0.0).rgb;
	float dark = 1.0 - smoothstep(0.3, 0.48, dot(here, vec3(0.299, 0.587, 0.114)));
	float disc = 1.0 - smoothstep(0.75, 1.0, r);
	COLOR = vec4(col, dark * disc);
}
