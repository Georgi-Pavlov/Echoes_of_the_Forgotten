shader_type canvas_item;
render_mode blend_add;

// Soft beams of sunlight fanning out from a point (usually off-screen) in
// a chosen direction, slowly swaying and breathing in strength. Drawn
// additively over the whole picture.

uniform vec2 origin = vec2(-0.05, -0.15);     // in this rect's UV
// Direction the fan points: 0 = straight down, positive = towards the right.
uniform float direction = 0.9;
uniform vec4 ray_color : source_color = vec4(1.0, 0.88, 0.62, 1.0);
uniform float intensity = 0.2;
uniform float spread = 0.75;                  // half-angle of the fan, radians
uniform float reach = 2.0;                    // fades out by this distance
uniform float sway = 0.04;
uniform float aspect = 1.7778;                // rect width / height

void fragment() {
	vec2 d = (UV - origin) * vec2(aspect, 1.0);
	float r = length(d);
	float ang = atan(d.x, d.y) - direction + sin(TIME * 0.21) * sway;

	float a = 0.5 + 0.5 * sin(ang * 23.0 + TIME * 0.3);
	float b = 0.5 + 0.5 * sin(ang * 37.0 - TIME * 0.45 + 1.7);
	float c = 0.5 + 0.5 * sin(ang * 11.0 + TIME * 0.17 + 4.1);
	float rays = pow(0.55 * a * b + 0.45 * c, 2.0);

	float fan = 1.0 - smoothstep(spread * 0.4, spread, abs(ang));
	float fall = 1.0 - smoothstep(0.2, reach, r);
	float pulse = 0.8 + 0.2 * sin(TIME * 0.5);

	COLOR = vec4(ray_color.rgb, rays * fan * fall * pulse * intensity);
}
