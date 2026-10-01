shader_type canvas_item;

// The intro's scene transition, drawn on the outgoing image (the incoming
// one sits right underneath it): the picture catches fire at `origin` and
// burns away outward along a ragged, noisy front. Just ahead of the hole
// the paper chars dark brown-black; right at the hole's rim it glows -
// white-hot at the very edge, cooling to orange - with stray embers
// smouldering in the charred band.
//   progress 0 = untouched, 1 = burned away completely.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 origin = vec2(0.5, 0.5);
uniform float aspect = 1.7778;
uniform float seed = 0.0;
uniform float edge_width = 0.012;
uniform float char_width = 0.05;
uniform vec4 ember_hot : source_color = vec4(1.0, 0.93, 0.62, 1.0);
uniform vec4 ember_color : source_color = vec4(1.0, 0.42, 0.06, 1.0);
uniform vec4 char_color : source_color = vec4(0.07, 0.035, 0.015, 1.0);

// Arithmetic hash rather than the usual fract(sin(...)) - sin loses
// precision on big inputs and turns the noise into visible blocks.
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

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * value_noise(p);
		p = p * 2.07 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 p = UV * vec2(aspect, 1.0);

	// Where along the burn this pixel sits: mostly distance from where the
	// fire started, broken up by noise so the front is ragged, not a circle.
	// v runs from exactly 0 at the origin to 1 at the corner farthest from
	// it, so the fire catches the moment progress leaves 0 and takes the
	// last pixel right as it reaches 1 - no dead time at either end. The
	// noise wobble is faded out near the origin to keep v = 0 there, and
	// the far corner is clamped so the wobble can't push it past 1.
	float n = fbm(p * 3.2 + seed) * 0.75 + fbm(p * 18.0 - seed) * 0.25;
	n = clamp((n - 0.2) / 0.6, 0.0, 1.0);
	vec2 o = origin * vec2(aspect, 1.0);
	float far_corner = length(max(o, vec2(aspect, 1.0) - o));
	float d = distance(p, o) / far_corner;
	float v = min(d + (n - 0.5) * 0.3 * min(d * 4.0, 1.0), 0.999);

	float front = mix(-(edge_width + char_width), 1.0, progress);
	float e = v - front;

	vec3 col = tex.rgb;
	float alpha = tex.a;

	if (e < 0.0) {
		alpha = 0.0;
	} else if (e < edge_width) {
		// The burning rim.
		float k = e / edge_width;
		float flicker = 0.85 + 0.15 * sin(TIME * 18.0 + n * 40.0);
		col = mix(ember_hot.rgb, ember_color.rgb, smoothstep(0.0, 1.0, k)) * flicker * 1.25;
		alpha *= smoothstep(0.0, 0.004, e);
	} else if (e < edge_width + char_width) {
		// Charring paper ahead of the flames, with embers glinting in it.
		float k = (e - edge_width) / char_width;
		vec3 charred = char_color.rgb;
		float spark = smoothstep(0.78, 0.95, fbm(p * 26.0 + seed + TIME * 0.6));
		charred += ember_color.rgb * spark * (1.0 - k) * 1.4;
		col = mix(charred, tex.rgb * 0.75, smoothstep(0.0, 1.0, k));
	}

	COLOR = vec4(col, alpha);
}
