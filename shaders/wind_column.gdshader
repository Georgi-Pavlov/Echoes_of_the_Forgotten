shader_type canvas_item;
// Added light, so the wind glows against dark and bright backgrounds alike.
render_mode blend_add;

// A column of wind spiralling upward, drawn over its own tall rect: pale
// streaks of wind and frost swept up the column, curling from side to
// side as they rise, thickest round the middle and fading at its edges
// and toward the sky. Used by The Test of Time (TimeStillFX).

uniform float aspect = 0.25;     // rect width / height
uniform float intensity = 1.0;
uniform vec4 wind_color : source_color = vec4(0.82, 0.9, 1.0, 1.0);

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

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * value_noise(p);
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV;
	// Height in "column widths", so the streaks keep their shape however
	// tall the column is.
	float h = (1.0 - uv.y) / max(aspect, 0.01);
	// The wind curls from side to side as it rises.
	float curl = sin(h * 2.2 - TIME * 3.2) * 0.12 + sin(h * 0.9 + TIME * 1.3) * 0.06;
	float x = uv.x + curl;
	// Long streaks swept upward, and a softer haze.
	float streaks = smoothstep(0.42, 0.8, fbm(vec2(x * 9.0, h * 0.6 - TIME * 2.4)));
	float gusts = smoothstep(0.48, 0.85, fbm(vec2(x * 4.0 + 3.1, h * 0.35 - TIME * 1.5)));
	float haze = fbm(vec2(x * 3.0, h * 0.25 - TIME * 0.8));
	// Soft at the sides, fading toward the sky, strongest near the ground.
	float edges = smoothstep(0.0, 0.3, uv.x) * (1.0 - smoothstep(0.7, 1.0, uv.x));
	float ground = mix(0.45, 1.0, smoothstep(0.3, 1.0, uv.y));
	float sky = smoothstep(0.0, 0.2, uv.y);
	float a = (streaks * 0.9 + gusts * 0.6 + haze * 0.25) * edges * ground * sky * intensity;
	COLOR = vec4(wind_color.rgb, clamp(a, 0.0, 1.0) * wind_color.a);
}
