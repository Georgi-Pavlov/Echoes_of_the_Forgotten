shader_type canvas_item;

// Water on the lens (first-choice dream, scene 1): a few fat drops sliding
// down the glass, each leaving a thin wet trail, and a scatter of tiny
// still droplets. Every drop shows the picture behind it magnified and
// upside down, with a bright glint and a dark rim. Draw it as a full-screen
// ColorRect over the picture; `amount` fades the whole effect in and out.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float aspect = 1.7777;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

float h11(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

float h21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Drops sliding down a set of vertical lanes. Returns (uv offset, glint, rim).
vec4 sliding(vec2 uv, float lanes, float seed, float t) {
	float lane = floor(uv.x * lanes);
	if (h11(lane * 7.13 + seed) < 0.4) {
		return vec4(0.0);
	}
	float speed = 0.04 + 0.09 * h11(lane * 3.7 + seed);
	float phase = h11(lane * 5.1 + seed);
	// Stop-and-go: it hangs a moment, then runs.
	float y = fract(phase + t * speed + 0.05 * sin(t * 1.3 + lane));
	float x = (lane + 0.2 + 0.6 * h11(lane * 9.9 + seed)) / lanes;

	float ry = 0.024 + 0.014 * h11(lane * 1.9 + seed);
	float rx = ry * 0.78;
	vec2 d = vec2((uv.x - x) * aspect, uv.y - y);
	vec2 local = d / vec2(rx, ry);
	float e = length(local);
	float mask = smoothstep(1.0, 0.82, e);

	// The wet streak it leaves above itself, fading with distance.
	float above = y - uv.y;
	float trail_len = 0.28;
	float trail = step(0.0, above) * step(above, trail_len)
			* smoothstep(rx * 0.32, 0.0, abs(d.x)) * (1.0 - above / trail_len) * 0.45;

	vec2 off = -vec2(d.x / aspect, d.y) * 0.9 * mask;
	off += -vec2(d.x / aspect, 0.0) * trail * 0.6;
	float glint = mask * smoothstep(0.55, 0.0, length(local - vec2(-0.35, -0.45)));
	float rim = mask * smoothstep(0.55, 1.0, e) + trail * 0.25;
	return vec4(off, glint, rim);
}

// Tiny droplets that stay put, jittered in a fine grid.
vec4 still(vec2 uv) {
	vec2 grid = vec2(70.0 * aspect, 70.0);
	vec2 cell = floor(uv * grid);
	float r = h21(cell);
	if (r < 0.78) {
		return vec4(0.0);
	}
	vec2 centre = cell + 0.5 + (vec2(h21(cell + 3.1), h21(cell + 8.7)) - 0.5) * 0.5;
	vec2 d = uv * grid - centre;
	float e = length(d) / (0.16 + 0.18 * h21(cell + 5.5));
	float mask = smoothstep(1.0, 0.8, e);
	vec2 off = -vec2(d.x / (grid.x), d.y / grid.y) * 0.7 * mask;
	float glint = mask * smoothstep(0.6, 0.0, length(d / 0.3 - vec2(-0.3, -0.4)));
	return vec4(off, glint, mask * smoothstep(0.6, 1.0, e));
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 a = sliding(uv, 13.0, 1.0, TIME);
	vec4 b = sliding(uv, 21.0, 7.0, TIME * 1.15);
	vec4 c = still(uv);

	vec2 off = (a.xy + b.xy + c.xy) * amount;
	vec3 col = texture(screen_tex, uv + off).rgb;
	float glint = a.z + b.z + c.z;
	float rim = a.w + b.w + c.w;
	col = col * (1.0 - rim * 0.35 * amount) + vec3(1.0, 0.95, 0.9) * glint * 0.5 * amount;
	COLOR = vec4(col, 1.0);
}
