shader_type canvas_item;

// Touch of the First Cold's "hollowed out" moment: laid over a unit's
// sprite (as a copy of it), this fills its silhouette with the void
// before creation - black, a nebula drifting through it, stars glinting
// - rimmed with icy light along its outline. The sprite's own alpha is
// the mask, so the shape is exactly the unit's.

uniform float seed = 0.0;
uniform vec4 rim_color : source_color = vec4(0.75, 0.9, 1.0, 1.0);

// The node's modulate arrives as the vertex colour - kept here and
// applied at the end, so fading the node (modulate:a) fades this too.
varying vec4 v_modulate;

void vertex() {
	v_modulate = COLOR;
}

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
	float a = texture(TEXTURE, UV).a;
	if (a <= 0.01) {
		COLOR = vec4(0.0);
	} else {
		// The outline: where the alpha falls away nearby.
		vec2 px = TEXTURE_PIXEL_SIZE * 6.0;
		float amin = min(min(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
				min(texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a));
		float edge = clamp((a - amin) * 1.5, 0.0, 1.0);

		vec2 q = UV * vec2(4.0, 5.0) + seed;
		vec2 warp = vec2(fbm(q + TIME * 0.2), fbm(q + 3.7 - TIME * 0.15));
		float n = fbm(q * 1.3 + warp * 1.6);
		vec3 c = mix(vec3(0.01, 0.01, 0.04), vec3(0.4, 0.12, 0.68), smoothstep(0.4, 0.8, n));
		c = mix(c, vec3(0.12, 0.35, 0.95), smoothstep(0.55, 0.9, fbm(q * 2.7 - warp)) * 0.7);

		vec2 sp = UV * 70.0;
		vec2 cell = floor(sp);
		float h = hash(cell + seed);
		if (h > 0.8) {
			float d = length(fract(sp) - (vec2(hash(cell + 2.1), hash(cell + 6.3)) * 0.6 + 0.2));
			float tw = pow(0.5 + 0.5 * sin(TIME * (2.0 + h * 6.0) + h * 60.0), 3.0);
			c += vec3(0.85, 0.9, 1.0) * (1.0 - smoothstep(0.0, 0.16, d)) * tw * 1.5;
		}

		c += rim_color.rgb * edge * 1.4;
		COLOR = vec4(c, a) * v_modulate;
	}
}
