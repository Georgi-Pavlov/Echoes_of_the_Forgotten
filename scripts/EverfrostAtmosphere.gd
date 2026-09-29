extends Control
# ------------------------------------------------------------------
# EverfrostAtmosphere
# The Everfrost's effects for the hero picker. ZoneAtmosphere creates
# one of these (and frees it again with the rest of its children) when
# Frost Daughter's background is shown, then calls build().
# Purely visual: never takes input, never touches game state. The
# painted stats frame is left untouched.
#
#   - her eyes and the sigil on her forehead glow faintly, constantly
#   - the ice crystals over her raised hand pulse, shedding frost motes
#   - the frost on her axe glimmers and drops small flakes of ice
#   - the campfire, hall windows and torches in the valley flicker
#   - mist drifts along the valley floor and the waterfalls' bases
#   - moonlight shimmers on the icy river
#   - every few seconds a gust of wind sweeps snow across the valley
#
# Positions are in the background image's own pixels, mapped onto the
# Background the same way its "keep aspect covered" stretch draws it.
# ------------------------------------------------------------------

const WATER_SHADER := preload("res://shaders/water_shimmer.gdshader")
const FOG_SHADER := preload("res://shaders/menu_fog.gdshader")

var _root: Control   # = self; effects are this node's children
var _img_size := Vector2.ONE
var _scale := 1.0
var _offset := Vector2.ZERO
var _time := 0.0
# fire glows: [TextureRect, base alpha, phase]
var _fires: Array = []
var _background: TextureRect
# Skarn: the exhale plume, blood drips (each {pos, y0, len, age, life, grow})
var _breath: CPUParticles2D
var _breath_phase := 0.0
var _drips: Array[Dictionary] = []
var _drip_layer: Node2D


## `hero` = "frost_daughter" or "skarn" - both share the valley on the
## right; each has its own effects on the left.
func build(_atm: Control, background: TextureRect, hero: String = "frost_daughter") -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_root = self
	_background = background
	_img_size = background.texture.get_size()
	_scale = max(background.size.x / _img_size.x, background.size.y / _img_size.y)
	_offset = (background.size - _img_size * _scale) * 0.5
	if hero == "skarn":
		_build_skarn()
	else:
		_build_frost_daughter()
	_build_valley()


func _process(delta: float) -> void:
	if _breath != null:
		_process_skarn(delta)
	if _fires.is_empty():
		return
	_time += delta
	for f in _fires:
		var glow: TextureRect = f[0]
		var p: float = f[2]
		# layered sines read as an irregular flame flicker
		var flick := 0.72 + 0.14 * sin(_time * 7.3 + p) + 0.09 * sin(_time * 13.1 + p * 2.7) + 0.05 * sin(_time * 23.0 + p * 1.3)
		glow.modulate.a = f[1] * flick


# --- helpers -----------------------------------------------------------

## Image pixel -> screen position.
func _px(p: Vector2) -> Vector2:
	return _offset + p * _scale


func _additive() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


func _radial(inner: Color, outer: Color, core: float = 0.0, size: int = 64) -> GradientTexture2D:
	var g := Gradient.new()
	if core > 0.0:
		g.offsets = PackedFloat32Array([0.0, core, 1.0])
		g.colors = PackedColorArray([inner, inner.lerp(outer, 0.5), outer])
	else:
		g.set_color(0, inner)
		g.set_color(1, outer)
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = size
	t.height = size
	return t


## Additive glow centred on an image point; `radius` in image pixels.
func _glow(centre: Vector2, radius: float, tex: Texture2D, alpha: float) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.material = _additive()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.size = Vector2.ONE * radius * 2.0 * _scale
	r.position = _px(centre) - r.size / 2.0
	r.modulate.a = alpha
	_root.add_child(r)
	return r


func _pulse(node: CanvasItem, low: float, high: float, period: float) -> void:
	node.modulate.a = low
	var tw := node.create_tween().set_loops()   # bound to the node: dies with it
	tw.tween_property(node, "modulate:a", high, period / 2.0).set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", low, period / 2.0).set_trans(Tween.TRANS_SINE)


func _particles_in(a: Vector2, b: Vector2) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.position = _px((a + b) / 2.0)
	p.emission_rect_extents = (b - a) * _scale / 2.0
	_root.add_child(p)
	return p


func _ramp(offsets: Array, colors: Array) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array(offsets)
	g.colors = PackedColorArray(colors)
	return g


func _dot() -> GradientTexture2D:
	return _radial(Color.WHITE, Color(1, 1, 1, 0), 0.0, 16)


## Small four-pointed star for glints.
func _sparkle() -> ImageTexture:
	var n := 24
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c := (n - 1) / 2.0
	for y in n:
		for x in n:
			var dx := absf(x - c) / c
			var dy := absf(y - c) / c
			var ray := maxf(clampf(1.0 - dx - dy * 9.0, 0, 1), clampf(1.0 - dy - dx * 9.0, 0, 1))
			var core := clampf(1.0 - sqrt(dx * dx + dy * dy) * 3.0, 0, 1)
			img.set_pixel(x, y, Color(1, 1, 1, clampf(ray + core, 0, 1)))
	return ImageTexture.create_from_image(img)


func _twinkle_curve() -> Curve:
	var c := Curve.new()
	c.add_point(Vector2(0.0, 0.0))
	c.add_point(Vector2(0.4, 1.0))
	c.add_point(Vector2(1.0, 0.0))
	return c


func _noise_tex(freq: float) -> NoiseTexture2D:
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = freq
	n.fractal_octaves = 3
	var t := NoiseTexture2D.new()
	t.width = 256
	t.height = 256
	t.seamless = true
	t.noise = n
	return t


# --- Frost Daughter (the_everfrost_frost_daughter.jpg) ----------------

const FD_EYES := [Vector2(403, 124), Vector2(445, 117)]
const FD_SIGIL_RECT := Rect2(404, 80, 40, 48)         # matches the sigil mask
const FD_SIGIL_MASK := "res://assets/zones/fx/the_everfrost_frost_daughter_sigil.png"
const FD_HAND := Vector2(673, 170)                    # ice crystals over her raised hand
const FD_HAND_AREA := [Vector2(607, 59), Vector2(738, 274)]
const FD_AXE := Vector2(101, 457)
const FD_AXE_AREA := [Vector2(33, 415), Vector2(176, 522)]
const FD_ICICLES := [Vector2(59, 470), Vector2(163, 499)]
# warm lights in the valley: position, radius, strength
const FD_FIRES := [
	[Vector2(1015, 666), 46.0, 0.85],   # campfire by the fence
	[Vector2(1483, 562), 26.0, 0.7],    # great hall door
	[Vector2(1535, 506), 16.0, 0.55],   # great hall windows
	[Vector2(1594, 551), 16.0, 0.55],
	[Vector2(1648, 549), 14.0, 0.5],
	[Vector2(1230, 597), 18.0, 0.6],    # huts
	[Vector2(1163, 575), 14.0, 0.5],
	[Vector2(993, 568), 12.0, 0.45],
	[Vector2(1398, 712), 14.0, 0.65],   # torches along the river
	[Vector2(1479, 712), 14.0, 0.65],
	[Vector2(1528, 715), 14.0, 0.65],
	[Vector2(1652, 705), 14.0, 0.6],
	[Vector2(1489, 248), 14.0, 0.5],    # fortress on the cliff
	[Vector2(1633, 411), 12.0, 0.45],
]
const FD_MIST_AREA := Rect2(849, 290, 823, 340)       # valley floor + waterfall bases
const FD_WATER_AREA := Rect2(1071, 752, 601, 189)     # icy river
const FD_GUST_SOURCE := Rect2(1150, 290, 210, 60)     # far mountains, where the wind rolls down from
const FD_GUST_GAP := Vector2(6.0, 11.0)               # seconds between gusts (after one ends)
const FD_GUST_RISE := 1.6                             # a gust swells in...
const FD_GUST_HOLD := 1.4
const FD_GUST_FALL := 2.4                             # ...and dies away
const FD_MIST_DENSITY := 0.5
const FD_MIST_GUST_DENSITY := 0.78


func _build_frost_daughter() -> void:
	var ice := Color(0.62, 0.85, 1.0)

	# --- eyes and forehead sigil: constant, faint magic glow ---
	var eye_tex := _radial(Color(ice, 0.9), Color(ice, 0.0), 0.25)
	for e in FD_EYES:
		_glow(e, 10.0, eye_tex, 0.55)
	var sigil_tex: Texture2D = load(FD_SIGIL_MASK)
	for layer in [[1.0, 0.56], [1.7, 0.25]]:   # crisp lines + a soft halo
		var s := TextureRect.new()
		s.texture = sigil_tex
		s.material = _additive()
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s.self_modulate = Color(ice, layer[1])
		var size: Vector2 = FD_SIGIL_RECT.size * _scale * layer[0]
		s.size = size
		s.position = _px(FD_SIGIL_RECT.get_center()) - size / 2.0
		_root.add_child(s)

	# --- ice magic in her hand: pulsing glow + drifting frost motes ---
	_pulse(_glow(FD_HAND, 105.0, _radial(Color(0.7, 0.9, 1.0, 0.6), Color(0.5, 0.8, 1.0, 0.0), 0.2), 0.0), 0.3, 0.85, 2.6)
	var motes := _particles_in(FD_HAND_AREA[0], FD_HAND_AREA[1])
	motes.texture = _sparkle()
	motes.material = _additive()
	motes.amount = 14
	motes.lifetime = 2.2
	motes.preprocess = 2.2
	motes.lifetime_randomness = 0.4
	motes.direction = Vector2(0.2, -1)
	motes.spread = 40.0
	motes.gravity = Vector2(0, -6) * _scale
	motes.initial_velocity_min = 6.0 * _scale
	motes.initial_velocity_max = 18.0 * _scale
	motes.angle_min = 0.0
	motes.angle_max = 45.0
	motes.scale_amount_min = 0.3 * _scale
	motes.scale_amount_max = 0.7 * _scale
	motes.scale_amount_curve = _twinkle_curve()
	motes.color = Color(0.8, 0.93, 1.0, 0.9)

	# --- frost on the axe: faint glimmer, glints, falling ice flakes ---
	_pulse(_glow(FD_AXE, 80.0, _radial(Color(0.65, 0.88, 1.0, 0.45), Color(0.5, 0.8, 1.0, 0.0), 0.2), 0.0), 0.2, 0.55, 3.4)
	var glints := _particles_in(FD_AXE_AREA[0], FD_AXE_AREA[1])
	glints.texture = _sparkle()
	glints.material = _additive()
	glints.amount = 5
	glints.lifetime = 1.3
	glints.preprocess = 1.3
	glints.lifetime_randomness = 0.4
	glints.gravity = Vector2.ZERO
	glints.initial_velocity_min = 0.0
	glints.initial_velocity_max = 0.0
	glints.scale_amount_min = 0.4 * _scale
	glints.scale_amount_max = 0.9 * _scale
	glints.scale_amount_curve = _twinkle_curve()
	glints.color = Color(0.85, 0.95, 1.0, 0.95)
	var flakes := _particles_in(FD_ICICLES[0], FD_ICICLES[1])
	flakes.texture = _dot()
	flakes.amount = 7
	flakes.lifetime = 1.4
	flakes.preprocess = 1.4
	flakes.lifetime_randomness = 0.5
	flakes.direction = Vector2(0, 1)
	flakes.spread = 10.0
	flakes.gravity = Vector2(0, 70) * _scale
	flakes.initial_velocity_min = 0.0
	flakes.initial_velocity_max = 8.0 * _scale
	flakes.scale_amount_min = 0.12 * _scale
	flakes.scale_amount_max = 0.25 * _scale
	flakes.color_ramp = _ramp([0.0, 0.1, 0.7, 1.0], [
		Color(0.85, 0.95, 1.0, 0.0), Color(0.85, 0.95, 1.0, 0.95), Color(0.85, 0.95, 1.0, 0.7), Color(0.85, 0.95, 1.0, 0.0)])



# --- the valley (right side, the same in both heroes' art) --------------

func _build_valley() -> void:
	# --- drifting valley mist ---
	# soft on every side: fades in from the top/bottom and the left/right
	var band := Image.create(64, 64, false, Image.FORMAT_L8)
	for y in 64:
		var vy := sin(float(y) / 63.0 * PI)
		for x in 64:
			var vx := clampf(minf(x, 63 - x) / 14.0, 0.0, 1.0)
			var v := vy * vx * vx * (3.0 - 2.0 * vx)
			band.set_pixel(x, y, Color(v, v, v))
	var mist_mat := ShaderMaterial.new()
	mist_mat.shader = FOG_SHADER
	mist_mat.set_shader_parameter("noise_tex", _noise_tex(0.012))
	mist_mat.set_shader_parameter("clear_mask", ImageTexture.create_from_image(band))
	mist_mat.set_shader_parameter("density", FD_MIST_DENSITY)
	mist_mat.set_shader_parameter("mask_top", -1.0)
	mist_mat.set_shader_parameter("mask_full", 0.0)
	mist_mat.set_shader_parameter("fog_color", Color(0.82, 0.86, 0.95))
	mist_mat.set_shader_parameter("speed_a", Vector2(0.012, 0.0))
	mist_mat.set_shader_parameter("speed_b", Vector2(-0.007, 0.002))
	var mist := ColorRect.new()
	mist.material = mist_mat
	mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mist.position = _px(FD_MIST_AREA.position)
	mist.size = FD_MIST_AREA.size * _scale
	_root.add_child(mist)

	# --- shimmer on the icy river ---
	var water_mat := ShaderMaterial.new()
	water_mat.shader = WATER_SHADER
	water_mat.set_shader_parameter("noise_tex", _noise_tex(0.02))
	var water := ColorRect.new()
	water.material = water_mat
	water.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water.position = _px(FD_WATER_AREA.position)
	water.size = FD_WATER_AREA.size * _scale
	_root.add_child(water)

	# --- flickering fires, torches and windows ---
	for f in FD_FIRES:
		var tex := _radial(Color(1.0, 0.72, 0.35, 0.8), Color(1.0, 0.45, 0.1, 0.0), 0.15)
		_fires.append([_glow(f[0], f[1], tex, f[2]), f[2], randf() * TAU])

	# --- wind gusts rolling down from the mountains towards the viewer ---
	# Snow is thrown out of the far mountains: small and slow up there,
	# growing and speeding up as it comes towards the screen. Each gust
	# swells in and dies away (the layer fades in and out while it
	# emits, so it never pops on or off), a soft cloud of snow rolls
	# out with it and the valley mist thickens, so it blends with the fog.
	var snow := _particles_in(FD_GUST_SOURCE.position, FD_GUST_SOURCE.end)
	snow.texture = _dot()
	snow.amount = 150
	snow.lifetime = 3.2
	snow.lifetime_randomness = 0.35
	snow.direction = Vector2(0.05, 1)
	snow.spread = 75.0
	snow.gravity = Vector2(0, 14) * _scale
	snow.initial_velocity_min = 40.0 * _scale
	snow.initial_velocity_max = 110.0 * _scale
	snow.linear_accel_min = 30.0 * _scale     # speeds up as it nears the viewer
	snow.linear_accel_max = 70.0 * _scale
	snow.scale_amount_min = 0.9 * _scale
	snow.scale_amount_max = 1.6 * _scale
	var approach := Curve.new()                # tiny far away, larger up close
	approach.add_point(Vector2(0.0, 0.08))
	approach.add_point(Vector2(1.0, 1.0), 1.4, 0.0)
	snow.scale_amount_curve = approach
	snow.color_ramp = _ramp([0.0, 0.25, 0.8, 1.0], [
		Color(0.93, 0.96, 1.0, 0.0), Color(0.93, 0.96, 1.0, 0.75), Color(0.93, 0.96, 1.0, 0.6), Color(0.93, 0.96, 1.0, 0.0)])
	snow.emitting = false
	snow.modulate.a = 0.0

	var cloud := _glow(FD_GUST_SOURCE.get_center(), 170.0,
		_radial(Color(0.9, 0.93, 1.0, 0.5), Color(0.9, 0.93, 1.0, 0.0), 0.1, 128), 0.0)
	cloud.pivot_offset = cloud.size / 2.0

	var timer := Timer.new()   # our child: stops when the hero changes
	timer.one_shot = true
	_root.add_child(timer)
	var fire_gust := func():
		var total := FD_GUST_RISE + FD_GUST_HOLD + FD_GUST_FALL
		snow.emitting = true
		var tw := snow.create_tween()
		tw.tween_property(snow, "modulate:a", 1.0, FD_GUST_RISE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(FD_GUST_HOLD)
		tw.tween_callback(func(): snow.emitting = false)
		tw.tween_property(snow, "modulate:a", 0.0, FD_GUST_FALL).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var set_density := func(d: float): mist_mat.set_shader_parameter("density", d)
		var fog := mist.create_tween()
		fog.tween_method(set_density, FD_MIST_DENSITY, FD_MIST_GUST_DENSITY, FD_GUST_RISE + FD_GUST_HOLD * 0.5).set_trans(Tween.TRANS_SINE)
		fog.tween_method(set_density, FD_MIST_GUST_DENSITY, FD_MIST_DENSITY, FD_GUST_FALL + FD_GUST_HOLD * 0.5 + 1.0).set_trans(Tween.TRANS_SINE)
		cloud.scale = Vector2.ONE * 0.5
		var billow := cloud.create_tween().set_parallel()
		billow.tween_property(cloud, "scale", Vector2(2.4, 1.9), total + 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		billow.tween_property(cloud, "position:y", cloud.position.y + 60.0 * _scale, total + 0.8).set_trans(Tween.TRANS_SINE)
		billow.tween_property(cloud, "modulate:a", 0.55, FD_GUST_RISE + FD_GUST_HOLD * 0.5).set_trans(Tween.TRANS_SINE)
		billow.chain().tween_property(cloud, "modulate:a", 0.0, FD_GUST_FALL + 0.8).set_trans(Tween.TRANS_SINE)
		var home_y := cloud.position.y
		billow.chain().tween_callback(func(): cloud.position.y = home_y)
		timer.start(total + randf_range(FD_GUST_GAP.x, FD_GUST_GAP.y))
	timer.timeout.connect(fire_gust)
	timer.start(randf_range(1.5, 3.0))


# --- Skarn (the_everfrost_skarn.jpg) --------------------------------------

const SK_MOUTH := Vector2(484, 262)        # the gaping maw, in image px
const SK_BREATH_TIME := 1.4                # each exhale lasts this long
# His body heaving: a slow swell of the art around his chest (the same
# background shader Veyrik's screen uses, wobble off), the stats frame
# kept still. He breathes out as the swell falls.
const SK_BREATHE_CENTER_UV := Vector2(0.269, 0.345)
const SK_BREATHE_RADIUS := 0.28            # in units of image height
const SK_BREATHE_AMOUNT := 0.03
const SK_BREATHE_PERIOD := 3.6
const SK_FRAME_CALM_RECT := Vector4(0.0, 0.575, 0.49, 1.0)
const BREATHE_SHADER := preload("res://shaders/underwater_ripple.gdshader")
# Where the blood running down his horns gathers and drips from.
const SK_BLOOD := [Vector2(342, 272), Vector2(268, 155), Vector2(647, 238),
	Vector2(672, 244), Vector2(719, 226), Vector2(600, 210)]
const SK_DRIP_EVERY := Vector2(0.6, 1.6)   # seconds between drops (any source)
# The ice crystals on his shoulders and behind his head.
const SK_CRYSTALS := [Rect2(37, 300, 125, 100), Rect2(719, 187, 93, 75), Rect2(737, 337, 69, 63), Rect2(250, 144, 44, 43)]
const BLOOD := Color(0.62, 0.03, 0.04)
const BLOOD_HI := Color(0.95, 0.35, 0.3)

var _next_drip := 0.5


func _build_skarn() -> void:
	# --- his body heaving with each breath ---
	var mat := ShaderMaterial.new()
	mat.shader = BREATHE_SHADER
	mat.set_shader_parameter("strength", 0.0)
	mat.set_shader_parameter("breathe_center", SK_BREATHE_CENTER_UV)
	mat.set_shader_parameter("breathe_radius", SK_BREATHE_RADIUS)
	mat.set_shader_parameter("breathe_amount", SK_BREATHE_AMOUNT)
	mat.set_shader_parameter("breathe_period", SK_BREATHE_PERIOD)
	mat.set_shader_parameter("aspect", _img_size.x / _img_size.y)
	mat.set_shader_parameter("calm_rect", SK_FRAME_CALM_RECT)
	_background.material = mat

	# --- his breath steaming out of the open maw as the swell falls ---
	_breath = CPUParticles2D.new()
	_breath.position = _px(SK_MOUTH)
	_breath.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_breath.emission_rect_extents = Vector2(18.0, 10.0) * _scale
	_breath.texture = _radial(Color.WHITE, Color(1, 1, 1, 0), 0.0, 64)
	_breath.amount = 70
	_breath.lifetime = 2.0
	_breath.lifetime_randomness = 0.3
	_breath.direction = Vector2(0.15, 1)
	_breath.spread = 35.0
	_breath.gravity = Vector2(0, -8) * _scale          # vapour slows and lifts as it cools
	_breath.initial_velocity_min = 40.0 * _scale
	_breath.initial_velocity_max = 75.0 * _scale
	_breath.damping_min = 30.0 * _scale
	_breath.damping_max = 45.0 * _scale
	_breath.scale_amount_min = 0.7 * _scale
	_breath.scale_amount_max = 1.1 * _scale
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.35))
	grow.add_point(Vector2(1.0, 2.4))
	_breath.scale_amount_curve = grow
	_breath.color_ramp = _ramp([0.0, 0.15, 0.6, 1.0], [
		Color(0.92, 0.96, 1.0, 0.0), Color(0.92, 0.96, 1.0, 0.6), Color(0.88, 0.94, 1.0, 0.34), Color(0.88, 0.94, 1.0, 0.0)])
	_breath.emitting = false
	_root.add_child(_breath)
	_breath_phase = _shader_phase()

	# --- the ice crystals on his shoulders catching the light ---
	for r in SK_CRYSTALS:
		var rect: Rect2 = r
		var glints := _particles_in(rect.position, rect.end)
		glints.texture = _sparkle()
		glints.material = _additive()
		glints.amount = maxi(3, int(rect.get_area() / 1800.0))
		glints.lifetime = 1.2
		glints.preprocess = 1.2
		glints.lifetime_randomness = 0.5
		glints.gravity = Vector2.ZERO
		glints.initial_velocity_min = 0.0
		glints.initial_velocity_max = 0.0
		glints.angle_min = 0.0
		glints.angle_max = 45.0
		glints.scale_amount_min = 0.4 * _scale
		glints.scale_amount_max = 0.9 * _scale
		glints.scale_amount_curve = _twinkle_curve()
		glints.color = Color(0.82, 0.94, 1.0, 0.95)

	# --- blood gathering and dripping off his horns ---
	_drip_layer = Node2D.new()
	_drip_layer.draw.connect(_draw_drips)
	_root.add_child(_drip_layer)


## 0..1 through the background shader's breathing cycle - the shader
## runs on the engine clock, so the exhale can be timed to the swell.
func _shader_phase() -> float:
	return fposmod(Time.get_ticks_msec() / 1000.0, SK_BREATHE_PERIOD) / SK_BREATHE_PERIOD


func _process_skarn(delta: float) -> void:
	# Breathe out as the chest starts to fall (the swell peaks at half-way).
	var phase := _shader_phase()
	if _breath_phase < 0.5 and phase >= 0.5:
		_breath.emitting = true
		var stop := _breath.create_tween()
		stop.tween_interval(SK_BREATH_TIME)
		stop.tween_callback(func(): _breath.emitting = false)
	_breath_phase = phase

	_next_drip -= delta
	if _next_drip <= 0.0:
		_next_drip = randf_range(SK_DRIP_EVERY.x, SK_DRIP_EVERY.y)
		var src: Vector2 = SK_BLOOD[randi() % SK_BLOOD.size()]
		_drips.append({"pos": _px(src), "vel": 0.0, "age": 0.0, "grow": randf_range(0.6, 1.1),
			"fall": randf_range(40.0, 95.0) * _scale, "y0": _px(src).y, "size": randf_range(2.6, 3.8) * _scale * 1.3})
	for d in _drips:
		d.age += delta
		if d.age > d.grow:   # swollen enough: it lets go and falls
			d.vel += 260.0 * _scale * delta
			d.pos.y += d.vel * delta
	_drips = _drips.filter(func(d): return d.pos.y - d.y0 < d.fall)
	_drip_layer.queue_redraw()


func _draw_drips() -> void:
	for d in _drips:
		var p: Vector2 = d.pos
		var r: float = d.size
		if d.age <= d.grow:
			# swelling at the tip of the streak
			r *= lerpf(0.4, 1.0, d.age / d.grow)
			_drip_layer.draw_circle(p + Vector2(0, r * 0.6), r, BLOOD)
		else:
			# a falling drop, stretched by its speed, fading near the end
			var fade := 1.0 - smoothstep(0.7, 1.0, (p.y - d.y0) / d.fall)
			var tail: float = clampf(d.vel * 0.03, 0.0, r * 3.0)
			_drip_layer.draw_line(p - Vector2(0, tail), p, Color(BLOOD, fade), r * 1.2, true)
			_drip_layer.draw_circle(p, r, Color(BLOOD, fade))
			_drip_layer.draw_circle(p - Vector2(r * 0.3, r * 0.3), r * 0.35, Color(BLOOD_HI, 0.7 * fade))
