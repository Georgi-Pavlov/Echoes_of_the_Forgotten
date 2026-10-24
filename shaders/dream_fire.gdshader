shader_type canvas_item;

// Campfire shot of the hero-pick dream (scene 1): the flame licks and
// flickers, and a vignette closes in on it - `dim` 0 is a soft focus on the
// fire, 1 is staring straight into the flame with everything else gone dark.
// `focus` is the flame's base in texture UV space.

uniform vec2 focus = vec2(0.55, 0.69);
uniform float dim : hint_range(0.0, 1.0) = 0.3;
uniform float aspect = 1.7777;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	// Flame body: an ellipse sitting on the logs, a little above `focus`.
	vec2 body = (uv - (focus - vec2(0.0, 0.08))) * vec2(aspect, 1.0);
	float mask = 1.0 - smoothstep(0.0, 0.12, length(body * vec2(1.0, 0.65)));
	float height = clamp((focus.y - uv.y) / 0.2, 0.0, 1.0);

	// Tongues of flame: noise scrolling upward shoves the pixels sideways,
	// more so towards the tip.
	float n = noise(vec2(uv.x * 38.0, uv.y * 20.0 - t * 3.5));
	float n2 = noise(vec2(uv.x * 80.0 + 7.0, uv.y * 40.0 - t * 6.0));
	vec2 off = vec2((n - 0.5) * 0.016 + (n2 - 0.5) * 0.006, (n2 - 0.5) * 0.004);
	off *= mask * (0.35 + height);
	vec3 col = texture(TEXTURE, uv + off).rgb;

	// Slow breathing plus quick flutter of the light.
	float flick = 0.9 + 0.2 * noise(vec2(t * 5.0, 3.0)) + 0.06 * sin(t * 19.0);
	col *= 1.0 + mask * (flick - 0.9) * 1.6;

	vec2 f = (uv - focus + vec2(0.0, 0.07)) * vec2(aspect, 1.0);
	float glow = exp(-dot(f, f) * 22.0);
	col += vec3(1.0, 0.45, 0.12) * glow * 0.14 * flick;

	// Tunnel vision onto the flame.
	float d = length(f);
	float radius = mix(0.75, 0.07, dim);
	float soft = mix(0.5, 0.18, dim);
	float shade = smoothstep(radius, radius + soft, d);
	col *= 1.0 - shade * mix(0.5, 1.0, dim * dim);

	// The texture is opaque, so COLOR.a here is just the node's fade alpha.
	COLOR = vec4(col, COLOR.a);
}
