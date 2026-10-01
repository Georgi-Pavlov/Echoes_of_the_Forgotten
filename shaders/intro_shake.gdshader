shader_type canvas_item;

// Shakes the whole picture: drawn over the full screen, it re-reads it
// shifted by `offset_px` (set every frame from GDScript). At zero offset it
// leaves the picture exactly as it is.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 offset_px = vec2(0.0);

void fragment() {
	COLOR = vec4(textureLod(screen_tex, SCREEN_UV - offset_px / vec2(1280.0, 720.0), 0.0).rgb, 1.0);
}
