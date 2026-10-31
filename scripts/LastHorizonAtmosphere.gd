extends Control
# ------------------------------------------------------------------
# LastHorizonAtmosphere
# Effects for Nightshroud's picker in The Last Horizon
# (the_last_horizon.jpg). ZoneAtmosphere creates one of these (and frees
# it again with the rest of its children) when that background is shown,
# then calls build(). Purely visual: never takes input, never touches
# game state.
#
#   - Nightshroud breathing: a slow swell of the whole body
#   - its two eyes glowing faintly, now and then flaring
#   - shadow wisps peeling off its body and drifting up into the dark
#   - the cloud bank crossing the sky, the moon's glow dimming and
#     brightening as thin cloud passes over it
#   - a low mist creeping over the road and ruins
#   - the wet road catching the moonlight in faint, shifting glints
#
# Positions of art features are fractions (0..1) of the background
# image, like ZoneAtmosphere's own.
# ------------------------------------------------------------------

const BREATHE_SHADER := preload("res://shaders/underwater_ripple.gdshader")

## The painted stats frame (UV x0, y0, x1, y1) - kept free of the swell.
const FRAME_CALM_RECT := Vector4(0.01, 0.6, 0.45, 0.95)
const BREATHE_CENTER_UV := Vector2(0.31, 0.24)
const BREATHE_RADIUS := 0.34              # in units of image height
const BREATHE_AMOUNT := 0.022
const BREATHE_PERIOD := 5.2

## The two eyes, and the glow around each (radius in source pixels).
const EYES_UV := [Vector2(0.381, 0.268), Vector2(0.423, 0.298)]
const EYE_RADIUS_PX := 16.0
const EYE_PULSE_TIME := 4.0
const EYE_FLARE_EVERY := Vector2(4.0, 9.0)
const EYE_FLARE_TIME := 0.9
const EYE_COLOR := Color(0.85, 0.9, 1.0)

## Shadow wisps: where they're born (image UV), how many a second, how long
## they live, how fast they rise (source px/s, x range, y range) and how big
## they grow (source px).
const WISP_SOURCE_UV := Rect2(0.04, 0.06, 0.42, 0.36)
const WISP_RATE := 3.4
const WISP_LIFE := Vector2(5.0, 9.0)
const WISP_VELOCITY := Rect2(-6.0, -26.0, 20.0, 14.0)
const WISP_SIZE := Vector2(120.0, 260.0)
const WISP_ALPHA := 0.5
## A cold grey-violet, pale enough to read against the near-black body.
const WISP_COLOR := Color(0.5, 0.48, 0.66)

## Sky: the cloud bank (image UV), and the moon.
const SKY_RECT_UV := Rect2(0.42, 0.0, 0.58, 0.42)
## A pale, moonlit bank drifting one way over a dark one drifting the other.
const CLOUD_LIGHT_COLOR := Color(0.38, 0.42, 0.58)
const CLOUD_DARK_COLOR := Color(0.015, 0.02, 0.035)
const MOON_UV := Vector2(0.861, 0.106)
const MOON_RADIUS_PX := 52.0
const MOON_COLOR := Color(0.75, 0.82, 1.0)

## Ground mist over the road and ruins (kept off the painted frame).
const MIST_RECT_UV := Rect2(0.42, 0.38, 0.58, 0.62)
const MIST_LOW_RECT_UV := Rect2(0.42, 0.62, 0.58, 0.38)
const MIST_COLOR := Color(0.62, 0.67, 0.8)

## Where the wet road catches the moon (image UV) - each glint has its
## own rhythm. Width is in source pixels.
const GLINTS_UV := [
	Vector2(0.675, 0.79), Vector2(0.71, 0.805), Vector2(0.735, 0.88),
	Vector2(0.775, 0.925), Vector2(0.85, 0.905), Vector2(0.885, 0.915),
	Vector2(0.78, 0.68), Vector2(0.81, 0.655), Vector2(0.9, 0.78),
	Vector2(0.945, 0.84), Vector2(0.64, 0.7),
]
const GLINT_COLOR := Color(0.7, 0.8, 1.0)
const GLINT_WIDTH_PX := 60.0

var _atmos: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0

var _soft_light: GradientTexture2D
var _soft_dark: GradientTexture2D
var _eye_glows: Array[TextureRect] = []
var _eye_flare_t := -1.0
var _next_eye_flare := 3.0
var _moon_glow: TextureRect
var _moon_cover: TextureRect
var _cloud_mat: ShaderMaterial
var _cloud_dark_mat: ShaderMaterial
var _mist_mat: ShaderMaterial
var _mist_low_mat: ShaderMaterial
var _wisp_layer: Control
var _glint_layer: Control
## Per wisp: {pos (local px), vel (local px/s), age, life, size}.
var _wisps: Array = []
var _wisp_debt := 0.0
## Per glint: {pos (local px), phase, period}.
var _glints: Array = []


func build(atmos: Control, background: TextureRect) -> void:
	_atmos = atmos
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var s: float = _atmos._image_scale()
	_soft_light = _atmos._radial(64, PackedFloat32Array([0.0, 0.35, 1.0]),
			PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)]))
	_soft_dark = _atmos._radial(64, PackedFloat32Array([0.0, 0.5, 1.0]),
			PackedColorArray([Color(0, 0, 0, 1), Color(0, 0, 0, 0.45), Color(0, 0, 0, 0)]))

	# Nightshroud breathing, straight on the background texture.
	var breathe := ShaderMaterial.new()
	breathe.shader = BREATHE_SHADER
	breathe.set_shader_parameter("strength", 0.0)
	breathe.set_shader_parameter("calm_rect", FRAME_CALM_RECT)
	var tex_size := _background.texture.get_size()
	breathe.set_shader_parameter("aspect", tex_size.x / tex_size.y)
	breathe.set_shader_parameter("breathe_center", BREATHE_CENTER_UV)
	breathe.set_shader_parameter("breathe_radius", BREATHE_RADIUS)
	breathe.set_shader_parameter("breathe_amount", BREATHE_AMOUNT)
	breathe.set_shader_parameter("breathe_period", BREATHE_PERIOD)
	_background.material = breathe

	# The cloud banks: a pale one catching the moonlight and a dark one
	# behind it, drifting opposite ways across the sky.
	_cloud_mat = (_atmos._add_fog(SKY_RECT_UV, {
		"fog_color": CLOUD_LIGHT_COLOR, "density": 0.5, "speed": 0.05, "scale": 2.2,
		"band_center": 0.45, "band_height": 0.7,
		"edge_fade": Vector4(0.2, 0.001, 0.001, 0.3),
	}) as ColorRect).material
	_cloud_dark_mat = (_atmos._add_fog(SKY_RECT_UV, {
		"fog_color": CLOUD_DARK_COLOR, "density": 0.75, "speed": -0.04, "scale": 3.0,
		"band_center": 0.4, "band_height": 0.75,
		"edge_fade": Vector4(0.2, 0.001, 0.001, 0.3),
	}) as ColorRect).material

	# The moon's glow, and a dark cover that thin cloud pulls over it.
	var moon_center: Vector2 = _atmos._image_to_local(MOON_UV)
	var moon_size := Vector2.ONE * MOON_RADIUS_PX * 2.0 * s * 2.2
	_moon_glow = _atmos._centered_rect(_soft_light, moon_center, moon_size)
	_moon_glow.material = _atmos._additive()
	_moon_glow.modulate = Color(MOON_COLOR, 0.3)
	_moon_cover = _atmos._centered_rect(_soft_dark, moon_center, Vector2.ONE * MOON_RADIUS_PX * 2.0 * s * 1.15)
	_moon_cover.modulate = Color(1, 1, 1, 0.0)

	# Low mist creeping over the road and the ruins: a broad bank, and a
	# thicker, quicker one hugging the ground and rolling the other way.
	_mist_mat = (_atmos._add_fog(MIST_RECT_UV, {
		"fog_color": MIST_COLOR, "density": 0.85, "speed": 0.035, "scale": 2.6,
		"band_center": 0.5, "band_height": 0.55,
		"edge_fade": Vector4(0.25, 0.3, 0.001, 0.12),
	}) as ColorRect).material
	_mist_low_mat = (_atmos._add_fog(MIST_LOW_RECT_UV, {
		"fog_color": MIST_COLOR, "density": 1.0, "speed": -0.05, "scale": 3.2,
		"band_center": 0.45, "band_height": 0.55,
		"edge_fade": Vector4(0.25, 0.3, 0.001, 0.05),
	}) as ColorRect).material

	# Glints on the wet road.
	for uv in GLINTS_UV:
		_glints.append({
			"pos": _atmos._image_to_local(uv),
			"phase": _rng.randf() * TAU,
			"period": _rng.randf_range(2.6, 5.4),
		})
	_glint_layer = _add_draw_layer(_draw_glints, true)

	# Shadow wisps, over the creature.
	_wisp_layer = _add_draw_layer(_draw_wisps, false)

	# The eyes, last so nothing covers them.
	for uv in EYES_UV:
		var glow: TextureRect = _atmos._centered_rect(_soft_light, _atmos._image_to_local(uv), Vector2.ONE * EYE_RADIUS_PX * 2.0 * s)
		glow.material = _atmos._additive()
		glow.modulate = Color(EYE_COLOR, 0.0)
		_eye_glows.append(glow)

	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	_update_sky()
	_update_eyes(delta)
	_update_wisps(delta)
	_glint_layer.queue_redraw()
	_wisp_layer.queue_redraw()


## Cloud cover over the moon: two slow waves that sometimes line up, so
## it's often clear, now and then half-hidden, and rarely almost gone.
func _update_sky() -> void:
	var cover := clampf(0.5 + 0.5 * sin(_time * 0.23) * (0.6 + 0.4 * sin(_time * 0.071 + 1.3)), 0.0, 1.0)
	_moon_cover.modulate.a = 0.55 * cover
	_moon_glow.modulate.a = 0.34 * (1.0 - 0.8 * cover) * (0.92 + 0.08 * sin(_time * 1.1))
	# The bank itself thickens and thins on its own slow cycle.
	_cloud_mat.set_shader_parameter("density", 0.5 + 0.12 * sin(_time * TAU / 19.0))
	_cloud_dark_mat.set_shader_parameter("density", 0.75 + 0.12 * sin(_time * TAU / 23.0 + 2.0))
	_mist_mat.set_shader_parameter("density", 0.85 + 0.12 * sin(_time * TAU / 13.0 + 1.0))
	_mist_low_mat.set_shader_parameter("density", 1.0 + 0.1 * sin(_time * TAU / 9.0))


## A faint pulse in both eyes, and every few seconds a flare that swells
## them and lights them up.
func _update_eyes(delta: float) -> void:
	if _eye_flare_t < 0.0 and _time >= _next_eye_flare:
		_eye_flare_t = 0.0
	var flare := 0.0
	if _eye_flare_t >= 0.0:
		_eye_flare_t += delta
		if _eye_flare_t >= EYE_FLARE_TIME:
			_eye_flare_t = -1.0
			_next_eye_flare = _time + _rng.randf_range(EYE_FLARE_EVERY.x, EYE_FLARE_EVERY.y)
		else:
			flare = sin(PI * _eye_flare_t / EYE_FLARE_TIME)
	var pulse := 0.5 + 0.5 * sin(_time * TAU / EYE_PULSE_TIME)
	for i in _eye_glows.size():
		var glow := _eye_glows[i]
		var p := 0.5 + 0.5 * sin(_time * TAU / EYE_PULSE_TIME + i * 0.9)
		glow.modulate.a = clampf(0.16 + 0.14 * (p if i > 0 else pulse) + 0.7 * flare, 0.0, 1.0)
		glow.scale = Vector2.ONE * (1.0 + 0.8 * flare)


func _update_wisps(delta: float) -> void:
	var s: float = _atmos._image_scale()
	_wisp_debt += delta * WISP_RATE
	while _wisp_debt >= 1.0:
		_wisp_debt -= 1.0
		var uv := WISP_SOURCE_UV.position + Vector2(_rng.randf(), _rng.randf()) * WISP_SOURCE_UV.size
		_wisps.append({
			"pos": _atmos._image_to_local(uv),
			"vel": Vector2(
					_rng.randf_range(WISP_VELOCITY.position.x, WISP_VELOCITY.end.x),
					_rng.randf_range(WISP_VELOCITY.position.y, WISP_VELOCITY.end.y)) * s,
			"age": 0.0,
			"life": _rng.randf_range(WISP_LIFE.x, WISP_LIFE.y),
			"size": _rng.randf_range(WISP_SIZE.x, WISP_SIZE.y) * s,
		})
	for wisp in _wisps:
		wisp["age"] += delta
		wisp["pos"] += wisp["vel"] * delta
	_wisps = _wisps.filter(func(w): return w["age"] < w["life"])


func _draw_wisps(layer: Control) -> void:
	for wisp in _wisps:
		var k: float = wisp["age"] / wisp["life"]
		# Fades in, then out; swells as it spreads.
		var alpha: float = WISP_ALPHA * sin(PI * k)
		var size: float = wisp["size"] * (0.6 + 0.8 * k)
		layer.draw_texture_rect(_soft_light, Rect2(wisp["pos"] - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(WISP_COLOR, alpha))


func _draw_glints(layer: Control) -> void:
	var s: float = _atmos._image_scale()
	for glint in _glints:
		# Mostly a faint sheen, with a brighter catch of the light as the
		# wave passes.
		var wave := 0.5 + 0.5 * sin(_time * TAU / glint["period"] + glint["phase"])
		var catch_light := pow(wave, 6.0)
		var alpha := 0.07 + 0.3 * catch_light
		var w: float = GLINT_WIDTH_PX * s * (0.8 + 0.5 * catch_light)
		layer.draw_set_transform(glint["pos"], 0.0, Vector2(1.0, 0.22))
		layer.draw_texture_rect(_soft_light, Rect2(Vector2.ONE * -w * 0.5, Vector2.ONE * w), false, Color(GLINT_COLOR, alpha))
	layer.draw_set_transform(Vector2.ZERO)


func _add_draw_layer(draw_fn: Callable, additive: bool) -> Control:
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if additive:
		layer.material = _atmos._additive()
	layer.draw.connect(draw_fn.bind(layer))
	add_child(layer)
	return layer
