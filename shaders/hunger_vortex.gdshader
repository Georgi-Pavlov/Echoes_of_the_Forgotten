shader_type canvas_item;

// The Hunger Calls' vortex, on the ground round its frozen target: a
// flattened disc (its rect's own ellipse) of blood-red spiral arms
// turning inward round a dark, hungry core, a faint rim marking the
// curse's reach. Used by HungerCallsFX.

uniform float intensity = 1.0;
uniform vec4 arm_color : source_color = vec4(0.8, 0.1, 0.14, 1.0);
uniform vec4 core_color : source_color = vec4(0.07, 0.0, 0.03, 1.0);
uniform vec4 rim_color : source_color = vec4(1.0, 0.45, 0.4, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	if (r >= 1.0) {
		COLOR = vec4(0.0);
	} else {
		float ang = atan(p.y, p.x);
		// Arms winding inward, turning.
		float arms = 0.5 + 0.5 * sin(3.0 * ang + 7.0 * log(r + 0.04) + TIME * 3.4);
		float arms2 = 0.5 + 0.5 * sin(5.0 * ang + 11.0 * log(r + 0.04) + TIME * 5.0);
		float grain = value_noise(p * 9.0 + vec2(TIME * 0.4, 0.0));
		float arm = smoothstep(0.45, 0.95, arms) * (0.7 + 0.3 * grain) + smoothstep(0.7, 1.0, arms2) * 0.35;
		float edge = 1.0 - smoothstep(0.78, 1.0, r);
		float core = 1.0 - smoothstep(0.0, 0.4, r);
		float rim = exp(-pow((r - 0.93) * 18.0, 2.0)) * (0.6 + 0.4 * sin(ang * 6.0 - TIME * 2.0));
		vec3 c = mix(arm_color.rgb * (0.6 + 0.6 * arm), core_color.rgb, core);
		c += rim_color.rgb * rim * 0.6;
		float a = (arm * 0.6 + core * 0.75) * edge + rim * 0.5;
		COLOR = vec4(c, clamp(a, 0.0, 1.0) * intensity);
	}
}
