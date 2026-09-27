extends Control
# ------------------------------------------------------------------
# FrostspireAtmosphere
# Frostspire's effects for the hero picker. ZoneAtmosphere creates one
# of these (and frees it again with the rest of its children) when
# Nhal's or The Primordial Hunger's background is shown, then calls build(). Purely visual: never
# takes input, never touches game state.
#
#   - the huge vortex over the fortress turns and draws its clouds in
#     (frostspire_background.gdshader)
#   - the starry void inside Nhal's body twinkles: painted stars
#     flicker, extra stars glint, a faint nebula drifts (same shader)
#   - the beam of light through the fortress's spire shimmers, and
#     every few seconds the fortress charges up and lets loose a big
#     flash - the beam flares, the core and the vortex's eye blaze and
#     the sky lights up
#   - heavy snowfall in three layers, blown about by a gusting wind,
#     with gusts of blown snow sweeping across the scene
#   - frost creeping over the screen around Nhal, as if on cold glass
#     (frost_glass.gdshader)
#
# The Primordial Hunger's background is the same scene with the Hunger
# in Nhal's place - it shares the vortex, the fortress's flashes and the snow, and
# instead of Nhal's galaxy and frost:
#   - frost breath rolling out of its maw in slow exhales, a cold glow
#     deep in its throat swelling as it breathes out (and flaring with
#     the fortress's flashes)
#   - its body swelling as it breathes, its wings slowly flexing
#   - a glint of light sweeping up the crest of bone spines on its back
#   - its floating crystals bobbing and softly pulsing
#
# Positions of art features are fractions (0..1) of the background
# image, like ZoneAtmosphere's own.
# ------------------------------------------------------------------

const BG_SHADER := preload("res://shaders/frostspire_background.gdshader")
const FROST_SHADER := preload("res://shaders/frost_glass.gdshader")
const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted stats frame (UV x0, y0, x1, y1) - kept still.
const FRAME_CALM_RECT := Vector4(0.015, 0.635, 0.465, 0.99)

# The vortex: its eye, the half-axes of its ellipse, and the band (UV y)
# where its spin fades out above the spires.
const VORTEX_CENTER := Vector2(0.7883, 0.0935)
const VORTEX_RADII := Vector2(0.1495, 0.1222)
const VORTEX_FADE := Vector2(0.1, 0.15)

# The beam through the central spire: its x, the spire's tip, and the
# fortress's glowing core it rises from (UV).
const SPIRE_X := 0.7901
const SPIRE_TIP_Y := 0.0765
const CORE_UV := Vector2(0.7823, 0.405)
const BEAM_HALF := 0.0042
const SPIRE_HALF := 0.0108

# The same scene in the battle arena (frostspire_area.jpg, its own UV):
# the painted battle UI panel kept still, the vortex (mostly above the
# screen's top edge, behind a thicket of spires - so only its open sky
# swirls, see the shader's sky_only), the beam and the fortress's glowing
# gate, and where the snow settles (the platform's front edge).
const BATTLE_FRAME_CALM_RECT := Vector4(0.0, 0.685, 1.0, 1.0)
const BATTLE_VORTEX_CENTER := Vector2(0.7227, 0.039)
const BATTLE_VORTEX_RADII := Vector2(0.2148, 0.166)
const BATTLE_VORTEX_FADE := Vector2(0.14, 0.22)
const BATTLE_VORTEX_TURN := 0.25
const BATTLE_SPIRE_X := 0.7272
const BATTLE_SPIRE_TIP_Y := 0.1
const BATTLE_CORE_UV := Vector2(0.7161, 0.21)
const BATTLE_SPIRE_HALF := 0.039
const BATTLE_SNOW_FLOOR := 0.69
const LIGHT_COLOR := Color(0.62, 0.8, 1.0)

# The starry void inside Nhal: hood, chest, and lower body (UV rects).
const GALAXY_RECTS := [
	Vector4(0.2165, 0.0531, 0.2542, 0.186),
	Vector4(0.2004, 0.2497, 0.2584, 0.4357),
	Vector4(0.1902, 0.4251, 0.2703, 0.5313),
]

# The hero panel the frost grows in from (UV rect), above the frame.
const FROST_RECT := Rect2(0.0, 0.0, 0.478, 0.643)

# The Primordial Hunger (UV): its body and the point it swells from, its wings,
# its maw, the crest of spines on its back and the point they fan out
# from, and its floating crystals (center, half-size).
const HUNGER_BODY_RECT := Vector4(0.09, 0.13, 0.39, 0.6)
const HUNGER_BODY_CENTER := Vector2(0.239, 0.361)
const HUNGER_WING_LEFT := Vector4(0.0, 0.2, 0.15, 0.53)
const HUNGER_WING_RIGHT := Vector4(0.359, 0.329, 0.473, 0.53)
const HUNGER_MAW := Vector2(0.1854, 0.2657)
const HUNGER_SPINE_RECT := Vector4(0.215, 0.02, 0.39, 0.47)
const HUNGER_SPINE_CENTER := Vector2(0.2273, 0.3507)
# The glint sweeps from the tallest spines round to the lowest (radians,
# around HUNGER_SPINE_CENTER), taking SPINE_SWEEP_TIME, every
# SPINE_SWEEP_EVERY seconds.
const SPINE_SWEEP_FROM := -1.7
const SPINE_SWEEP_TO := 0.6
const SPINE_SWEEP_TIME := 1.3
const SPINE_SWEEP_EVERY := 4.0
const HUNGER_CRYSTALS := [
	[Vector2(0.0359, 0.1275), Vector2(0.016, 0.06)],
	[Vector2(0.0897, 0.1169), Vector2(0.014, 0.043)],
	[Vector2(0.1866, 0.0691), Vector2(0.009, 0.032)],
	[Vector2(0.3935, 0.2604), Vector2(0.009, 0.032)],
	[Vector2(0.4288, 0.3188), Vector2(0.01, 0.043)],
	[Vector2(0.4498, 0.3613), Vector2(0.007, 0.024)],
]
# One breath: this long, the first BREATH_EXHALE of it breathing out.
const BREATH_PERIOD := 4.6
const BREATH_EXHALE := 0.4

# Flashes: the wait between them (s), how long the fortress charges
# before each, and the chance one comes as a double flash.
const FLASH_WAIT := Vector2(2.5, 6.0)
const CHARGE_TIME := 0.55
const DOUBLE_FLASH_CHANCE := 0.4

# Snow: per layer, how many flakes, their size, fall speed and sway (px
# at 1280-wide), and opacity. Far flakes are small and slow, near ones
# big, soft and fast.
const SNOW_LAYERS := [
	{"count": 520, "size": Vector2(3.5, 5.5), "speed": Vector2(50.0, 75.0), "sway": 8.0, "alpha": 0.7},
	{"count": 300, "size": Vector2(6.5, 9.5), "speed": Vector2(95.0, 140.0), "sway": 14.0, "alpha": 0.9},
	{"count": 90, "size": Vector2(15.0, 24.0), "speed": Vector2(190.0, 270.0), "sway": 24.0, "alpha": 0.6},
]
const WIND := 55.0          # px/s at 1280-wide, before gusts
const SNOW_COLOR := Color(0.9, 0.95, 1.0)

var _atm: Control
var _background: TextureRect
var _bg_mat: ShaderMaterial
var _frost_mat: ShaderMaterial
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0     # image scale
var _k := 1.0     # tuned-at-1280 scale

var _eye_glow: TextureRect
var _tip_glow: TextureRect
var _core_glow: TextureRect
var _sky_glow: TextureRect
var _beam: Control
var _snow_layer: Control
var _flake_tex: Texture2D
var _snow: Array[Dictionary] = []

var _next_flash := 0.0
var _charge := 0.0
var _charging := false
var _flash := 0.0
var _second_flash := -1.0

var _hero := "nhal"
# The scene's placements for this mode (the constants above).
var _frame_calm := FRAME_CALM_RECT
var _vortex_center := VORTEX_CENTER
var _vortex_radii := VORTEX_RADII
var _vortex_fade := VORTEX_FADE
var _spire_x := SPIRE_X
var _spire_tip_y := SPIRE_TIP_Y
var _core_uv := CORE_UV
var _spire_half := SPIRE_HALF
# Screen y where snow settles (it's gone past it) - the bottom of the view
# unless the mode has a floor.
var _snow_floor := INF
# How strongly the fortress's glows show - the arena draws its art larger
# and closer, so the same light would wash its sky out.
var _light_gain := 1.0
var _maw_glow: TextureRect
var _crystal_glows: Array[TextureRect] = []
var _breath_mist: CPUParticles2D


## `atm` is the owning ZoneAtmosphere - its image mapping helpers are
## reused so positions line up exactly with its own effects.
## `hero`: whose background this is - "nhal" or "the_primordial_hunger" (see the
## header) - which picks the hero-side effects on top of the shared scene;
## or "battle" for the battle arena (BattleAtmosphere): the shared scene
## alone, placed on the arena's own art.
func build(atm: Control, background: TextureRect, hero: String = "nhal") -> void:
	_atm = atm
	_hero = hero
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_k = _s / 0.7656
	var tex_size := _background.texture.get_size()
	if _hero == "battle":
		_frame_calm = BATTLE_FRAME_CALM_RECT
		_vortex_center = BATTLE_VORTEX_CENTER
		_vortex_radii = BATTLE_VORTEX_RADII
		_vortex_fade = BATTLE_VORTEX_FADE
		_spire_x = BATTLE_SPIRE_X
		_spire_tip_y = BATTLE_SPIRE_TIP_Y
		_core_uv = BATTLE_CORE_UV
		_spire_half = BATTLE_SPIRE_HALF
		_snow_floor = _atm._image_to_local(Vector2(0.0, BATTLE_SNOW_FLOOR)).y
		_light_gain = 0.45

	# Vortex, galaxy and the flash's light, on the art itself.
	_bg_mat = ShaderMaterial.new()
	_bg_mat.shader = BG_SHADER
	_bg_mat.set_shader_parameter("aspect", tex_size.x / tex_size.y)
	_bg_mat.set_shader_parameter("calm_rect", _frame_calm)
	_bg_mat.set_shader_parameter("vortex_center", _vortex_center)
	_bg_mat.set_shader_parameter("vortex_radii", _vortex_radii)
	_bg_mat.set_shader_parameter("vortex_fade_top", _vortex_fade.x)
	_bg_mat.set_shader_parameter("vortex_fade_bottom", _vortex_fade.y)
	_bg_mat.set_shader_parameter("spire_x", _spire_x)
	_bg_mat.set_shader_parameter("beam_half", BEAM_HALF)
	_bg_mat.set_shader_parameter("spire_half", _spire_half)
	_bg_mat.set_shader_parameter("spire_tip_y", _spire_tip_y)
	if _hero == "the_primordial_hunger":
		_bg_mat.set_shader_parameter("body_rect", HUNGER_BODY_RECT)
		_bg_mat.set_shader_parameter("body_center", HUNGER_BODY_CENTER)
		_bg_mat.set_shader_parameter("wing_left", HUNGER_WING_LEFT)
		_bg_mat.set_shader_parameter("wing_right", HUNGER_WING_RIGHT)
		_bg_mat.set_shader_parameter("spine_rect", HUNGER_SPINE_RECT)
		_bg_mat.set_shader_parameter("spine_center", HUNGER_SPINE_CENTER)
		var rects: Array[Vector4] = []
		for c in HUNGER_CRYSTALS:
			var center: Vector2 = c[0]
			var half: Vector2 = c[1]
			rects.append(Vector4(center.x - half.x, center.y - half.y, center.x + half.x, center.y + half.y))
		while rects.size() < 8:
			rects.append(Vector4.ZERO)
		_bg_mat.set_shader_parameter("crystal_rects", rects)
	elif _hero == "battle":
		# Only the open sky between the spires swirls, and gently.
		_bg_mat.set_shader_parameter("sky_only", 1.0)
		_bg_mat.set_shader_parameter("vortex_turn", BATTLE_VORTEX_TURN)
	else:
		_bg_mat.set_shader_parameter("galaxy_rect_a", GALAXY_RECTS[0])
		_bg_mat.set_shader_parameter("galaxy_rect_b", GALAXY_RECTS[1])
		_bg_mat.set_shader_parameter("galaxy_rect_c", GALAXY_RECTS[2])
	_bg_mat.set_shader_parameter("flash", 0.0)
	_background.material = _bg_mat

	# Glows: the sky flash under everything, then the core, the eye and
	# the spire's tip; the beam over them.
	var glow_tex: Texture2D = _atm._radial(64,
		PackedFloat32Array([0.0, 0.2, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.0)]))
	_sky_glow = _glow(glow_tex, _vortex_center + Vector2(0.0, 0.08), 950.0 * _s, LIGHT_COLOR)
	_sky_glow.modulate = Color(1, 1, 1, 0)
	_core_glow = _glow(glow_tex, _core_uv, 230.0 * _s, LIGHT_COLOR)
	_eye_glow = _glow(glow_tex, _vortex_center, 300.0 * _s, LIGHT_COLOR)
	_tip_glow = _glow(glow_tex, Vector2(_spire_x, _spire_tip_y), 110.0 * _s, Color(0.85, 0.93, 1.0))
	_beam = Control.new()
	_beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_beam.set_anchors_preset(Control.PRESET_FULL_RECT)
	_beam.material = _atm._additive()
	_beam.draw.connect(_draw_beam)
	add_child(_beam)

	if _hero == "the_primordial_hunger":
		_build_hunger(glow_tex)

	# Gusts of blown snow sweeping across the whole scene.
	var view := get_viewport_rect().size
	for gust in [{"speed": 0.09, "scale": 2.2, "density": 0.3}, {"speed": 0.16, "scale": 4.0, "density": 0.22}]:
		var mat := ShaderMaterial.new()
		mat.shader = FOG_SHADER
		mat.set_shader_parameter("fog_color", Color(0.82, 0.88, 0.96))
		mat.set_shader_parameter("aspect", view.x / maxf(view.y, 1.0))
		mat.set_shader_parameter("density", gust["density"])
		mat.set_shader_parameter("speed", gust["speed"])
		mat.set_shader_parameter("scale", gust["scale"])
		mat.set_shader_parameter("band_center", 0.5)
		mat.set_shader_parameter("band_height", 0.9)
		mat.set_shader_parameter("edge_fade", Vector4(0.02, 0.02, 0.02, 0.02))
		var haze := ColorRect.new()
		haze.material = mat
		haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
		haze.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(haze)

	# Snow.
	_flake_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.45, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.7), Color(1, 1, 1, 0.0)]))
	_snow.clear()
	for li in SNOW_LAYERS.size():
		var layer: Dictionary = SNOW_LAYERS[li]
		for i in int(layer["count"]):
			_snow.append({
				"layer": li,
				"pos": Vector2(_rng.randf() * view.x, _rng.randf() * minf(view.y, _snow_floor)),
				"size": _rng.randf_range(layer["size"].x, layer["size"].y),
				"speed": _rng.randf_range(layer["speed"].x, layer["speed"].y),
				"phase": _rng.randf() * TAU,
				"sway_speed": _rng.randf_range(0.6, 1.6),
			})
	_snow_layer = Control.new()
	_snow_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_snow_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_snow_layer.draw.connect(_draw_snow)
	add_child(_snow_layer)

	# Frost on the "glass" around Nhal, over everything - kept to the
	# part of the panel that's actually on screen, so it hugs the
	# screen's edge even when the art is cropped.
	if _hero == "nhal":
		_build_screen_frost()

	_next_flash = _rng.randf_range(1.5, 3.0)
	set_process(true)


func _build_screen_frost() -> void:
	var a: Vector2 = _atm._image_to_local(FROST_RECT.position)
	var b: Vector2 = _atm._image_to_local(FROST_RECT.end)
	a = a.max(Vector2.ZERO)
	b = b.min(_background.size)
	_frost_mat = ShaderMaterial.new()
	_frost_mat.shader = FROST_SHADER
	_frost_mat.set_shader_parameter("aspect", (b.x - a.x) / maxf(b.y - a.y, 1.0))
	var frost := ColorRect.new()
	frost.material = _frost_mat
	frost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frost.position = a
	frost.size = b - a
	add_child(frost)


func _glow(tex: Texture2D, uv: Vector2, diameter: float, color: Color) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.size = Vector2.ONE * diameter
	r.position = _atm._image_to_local(uv) - r.size * 0.5
	r.pivot_offset = r.size * 0.5
	r.material = _atm._additive()
	r.self_modulate = color
	add_child(r)
	return r


# --- The Primordial Hunger ---------------------------------------------

## The Hunger's glows and frost breath (its body, wings, spine glint and
## crystals' bob are the background shader's - see build()).
func _build_hunger(glow_tex: Texture2D) -> void:
	_crystal_glows.clear()
	for c in HUNGER_CRYSTALS:
		var half: Vector2 = c[1]
		_crystal_glows.append(_glow(glow_tex, c[0], half.y * 2.6 * _background.texture.get_size().y * _s, Color(0.55, 0.75, 1.0)))
	_maw_glow = _glow(glow_tex, HUNGER_MAW, 150.0 * _s, Color(0.55, 0.78, 1.0))

	# Frost breath: soft mist rolling out of the maw and sinking, growing
	# as it spreads.
	var mist_tex: Texture2D = _atm._radial(32,
		PackedFloat32Array([0.0, 0.5, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))
	_breath_mist = CPUParticles2D.new()
	_breath_mist.texture = mist_tex
	_breath_mist.position = _atm._image_to_local(HUNGER_MAW + Vector2(0.0, 0.02))
	_breath_mist.amount = 60
	_breath_mist.lifetime = 2.6
	_breath_mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_breath_mist.emission_rect_extents = Vector2(30.0, 12.0) * _s
	_breath_mist.direction = Vector2(0.0, 1.0)
	_breath_mist.spread = 65.0
	_breath_mist.gravity = Vector2(0.0, 12.0 * _k)
	_breath_mist.initial_velocity_min = 10.0 * _k
	_breath_mist.initial_velocity_max = 26.0 * _k
	_breath_mist.damping_min = 4.0
	_breath_mist.damping_max = 9.0
	_breath_mist.angle_min = 0.0
	_breath_mist.angle_max = 360.0
	_breath_mist.scale_amount_min = 1.1 * _s
	_breath_mist.scale_amount_max = 2.3 * _s
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.35))
	grow.add_point(Vector2(1.0, 1.6))
	_breath_mist.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	ramp.colors = PackedColorArray([Color(0.85, 0.93, 1.0, 0.0), Color(0.88, 0.95, 1.0, 0.5), Color(0.75, 0.85, 1.0, 0.0)])
	_breath_mist.color_ramp = ramp
	_breath_mist.emitting = false
	add_child(_breath_mist)


## One breath at a time: the body swells as it breathes in; as it breathes
## out, the throat glows, frost mist rolls out and the body settles. The
## spine glint and the crystals' pulse run on their own clocks.
func _update_hunger() -> void:
	var phase := fmod(_time, BREATH_PERIOD) / BREATH_PERIOD
	var exhaling := phase < BREATH_EXHALE
	# -1 fully out .. 1 fully in: out during the exhale, easing back in after.
	var breath: float
	if exhaling:
		breath = cos(phase / BREATH_EXHALE * PI)
	else:
		breath = -cos((phase - BREATH_EXHALE) / (1.0 - BREATH_EXHALE) * PI)
	_bg_mat.set_shader_parameter("breath", breath)
	_breath_mist.emitting = exhaling

	var out := sin(phase / BREATH_EXHALE * PI) if exhaling else 0.0
	var maw := 0.25 + 0.55 * out + 0.9 * _flash
	_maw_glow.modulate = Color(maw, maw, maw, 1.0)
	_maw_glow.scale = Vector2.ONE * (0.9 + 0.25 * out + 0.3 * _flash)

	var sweep_t := fmod(_time, SPINE_SWEEP_EVERY)
	var sweep := lerpf(SPINE_SWEEP_FROM, SPINE_SWEEP_TO, sweep_t / SPINE_SWEEP_TIME) if sweep_t < SPINE_SWEEP_TIME else -10.0
	_bg_mat.set_shader_parameter("spine_sweep", sweep)

	for i in _crystal_glows.size():
		var g := 0.3 + 0.2 * sin(_time * 1.2 + float(i) * 1.7) + 0.5 * _flash
		_crystal_glows[i].modulate = Color(g, g, g, 1.0)


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_flash(delta)
	_update_lights()
	_update_snow(delta)
	if _hero == "the_primordial_hunger":
		_update_hunger()
	_beam.queue_redraw()
	_snow_layer.queue_redraw()


## Waits, charges up, flashes (sometimes twice), and lets it die away.
func _update_flash(delta: float) -> void:
	if _charging:
		_charge = minf(_charge + delta / CHARGE_TIME, 1.0)
		if _charge >= 1.0:
			_charging = false
			_fire_flash(1.0)
			if _rng.randf() < DOUBLE_FLASH_CHANCE:
				_second_flash = _rng.randf_range(0.12, 0.22)
	else:
		_charge = move_toward(_charge, 0.0, delta * 1.5)
		_next_flash -= delta
		if _next_flash <= 0.0:
			_charging = true
			_next_flash = _rng.randf_range(FLASH_WAIT.x, FLASH_WAIT.y)
	if _second_flash >= 0.0:
		_second_flash -= delta
		if _second_flash < 0.0:
			_fire_flash(0.8)
	_flash *= exp(-delta * 4.0)
	_bg_mat.set_shader_parameter("flash", _flash * _light_gain)
	if _frost_mat != null:
		_frost_mat.set_shader_parameter("flare", _flash * 0.7)


func _fire_flash(strength: float) -> void:
	_flash = maxf(_flash, strength)


## How bright the fortress's light is right now: an idle shimmer, rising
## as it charges, blazing on a flash.
func _light_level() -> float:
	var idle := 0.6 + 0.1 * sin(_time * 2.3) + 0.06 * sin(_time * 7.3)
	return idle + 0.55 * _charge * _charge + 1.6 * _flash


func _update_lights() -> void:
	var lvl := _light_level()
	var core := 0.55 * lvl * _light_gain
	_core_glow.modulate = Color(core, core, core, 1.0)
	_core_glow.scale = Vector2.ONE * (0.9 + 0.2 * _charge + 0.5 * _flash)
	var eye := (0.3 * lvl + 0.2 * sin(_time * 0.8)) * _light_gain
	_eye_glow.modulate = Color(eye, eye, eye, 1.0)
	_eye_glow.scale = Vector2.ONE * (0.95 + 0.4 * _flash)
	var tip := 0.7 * lvl * _light_gain
	_tip_glow.modulate = Color(tip, tip, tip, 1.0)
	_tip_glow.scale = Vector2.ONE * (0.85 + 0.3 * _charge + 0.9 * _flash)
	_sky_glow.modulate = Color(1, 1, 1, clampf(_flash * 0.5 * _light_gain, 0.0, 1.0))


## The beam: a thin bright shaft from the top of the sky down to the
## spire's tip, and a wider, softer column of light behind the spires
## down to the core. Both widen and blaze on a flash.
func _draw_beam() -> void:
	var lvl := _light_level() * lerpf(1.0, 0.7, 1.0 - _light_gain)
	var top: Vector2 = _atm._image_to_local(Vector2(_spire_x, 0.0)) - Vector2(0.0, 20.0)
	var tip: Vector2 = _atm._image_to_local(Vector2(_spire_x, _spire_tip_y))
	var core: Vector2 = _atm._image_to_local(Vector2(_spire_x, _core_uv.y))
	var w := (3.0 + 3.0 * _charge + 16.0 * _flash) * _s
	_shaft(top, tip, w, Color(LIGHT_COLOR, clampf(0.32 * lvl, 0.0, 1.0)), Color(0.95, 0.98, 1.0, clampf(0.5 * lvl, 0.0, 1.0)))
	_shaft(tip, core, w * 2.4, Color(LIGHT_COLOR, clampf(0.1 * lvl, 0.0, 1.0)), Color(0.85, 0.93, 1.0, clampf(0.16 * lvl, 0.0, 1.0)))


## A vertical shaft from `a` down to `b`: `edge` along its sides fading
## to clear, `mid` down its middle.
func _shaft(a: Vector2, b: Vector2, half_width: float, edge: Color, mid: Color) -> void:
	var o := Vector2(half_width, 0.0)
	var clear := Color(edge, 0.0)
	_beam.draw_polygon(PackedVector2Array([a - o * 2.0, a, b, b - o * 2.0]), PackedColorArray([clear, edge, edge, clear]))
	_beam.draw_polygon(PackedVector2Array([a, a + o * 2.0, b + o * 2.0, b]), PackedColorArray([edge, clear, clear, edge]))
	var c := o * 0.35
	_beam.draw_polygon(PackedVector2Array([a - c, a + c, b + c, b - c]), PackedColorArray([mid, mid, mid, mid]))


func _update_snow(delta: float) -> void:
	var view := get_viewport_rect().size
	# Gusting wind: it swells and slackens, now and then hard.
	var wind := WIND * (1.0 + 0.7 * sin(_time * 0.31) + 0.4 * sin(_time * 0.83 + 1.1) + 0.25 * sin(_time * 2.1)) * _k
	for f in _snow:
		var layer: Dictionary = SNOW_LAYERS[f["layer"]]
		# Near flakes are swept along harder than far ones.
		var depth: float = f["speed"] / 100.0
		var sway: float = float(layer["sway"]) * f["sway_speed"] * cos(_time * f["sway_speed"] + f["phase"])
		var pos: Vector2 = f["pos"] + Vector2(wind * depth + sway * _k, f["speed"] * _k) * delta
		# Gone past the ground (or the bottom of the view): falls again from the top.
		if pos.y > minf(view.y + 12.0, _snow_floor):
			pos = Vector2(_rng.randf() * view.x, -12.0 - _rng.randf() * 40.0)
		if pos.x > view.x + 12.0:
			pos.x -= view.x + 24.0
		elif pos.x < -12.0:
			pos.x += view.x + 24.0
		f["pos"] = pos


func _draw_snow() -> void:
	# The flash lights the snow up too.
	var lit := 1.0 + 0.6 * _flash
	for f in _snow:
		var layer: Dictionary = SNOW_LAYERS[f["layer"]]
		var sz: float = f["size"] * _k
		var col := Color(SNOW_COLOR * lit, clampf(float(layer["alpha"]) * lit, 0.0, 1.0))
		_snow_layer.draw_texture_rect(_flake_tex, Rect2(f["pos"] - Vector2(sz, sz) * 0.5, Vector2(sz, sz)), false, col)
