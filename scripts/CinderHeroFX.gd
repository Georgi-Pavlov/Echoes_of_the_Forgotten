extends Control
# ------------------------------------------------------------------
# CinderHeroFX
# Cinder's side of his Verdant Scar background (the_verdant_scar_cinder.jpg)
# in the hero picker. RootmotherAtmosphere creates one of these for
# Cinder's background (the valley half is the Rootmother's own, shared)
# and calls build(). Purely visual.
#
#   - heavy flames roaring up behind him: tongues of fire licking up the
#     left edge and along the ground behind the stats frame, the painted
#     fires flickering with heat glow
#   - smoke: dark smoke drifting over the burning land and curling up
#     off the flames
#   - embers rising through the whole panel, swirling in the heat
#   - firelight on him: the goggles catch the flames - an orange glow
#     flickering in each lens with a glint sliding across them - and
#     glints of firelight run along the flamethrower's barrel, its
#     muzzle glowing with a sputtering pilot flame
#
# Positions are pixels of the 1672x941 source image.
# ------------------------------------------------------------------

const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# Where the flames roar up from (source px rects): the left edge, the
# ground behind him (just above the stats frame), and the right edge.
const FLAME_SOURCES := [
	{"rect": Rect2(0.0, 150.0, 70.0, 430.0), "amount": 70, "height": 1.0},
	{"rect": Rect2(0.0, 560.0, 790.0, 30.0), "amount": 110, "height": 1.2},
	{"rect": Rect2(700.0, 380.0, 80.0, 200.0), "amount": 40, "height": 0.8},
]
# Painted fires that flicker with heat glow (source px, diameter).
const HOTSPOTS := [
	{"px": Vector2(25.0, 420.0), "d": 220.0}, {"px": Vector2(30.0, 180.0), "d": 160.0},
	{"px": Vector2(110.0, 560.0), "d": 240.0}, {"px": Vector2(420.0, 575.0), "d": 260.0},
	{"px": Vector2(720.0, 560.0), "d": 220.0}, {"px": Vector2(600.0, 470.0), "d": 140.0},
]
const PANEL_RECT_UV := Rect2(0.0, 0.0, 0.475, 0.63)
const GOGGLES := [Vector2(497.0, 180.0), Vector2(536.0, 185.0)]
const GOGGLE_D := 34.0
# The barrel's top edge, from the grip to the muzzle (source px), and
# the muzzle itself.
const BARREL := [Vector2(470.0, 345.0), Vector2(600.0, 385.0), Vector2(690.0, 418.0)]
const MUZZLE := Vector2(703.0, 442.0)

const FIRE := Color(1.0, 0.5, 0.12)
const HOT := Color(1.0, 0.82, 0.4)

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0
var _origin := Vector2.ZERO
var _glow_tex: Texture2D
var _hotspots: Array[Dictionary] = []
var _goggle_glows: Array[TextureRect] = []
var _muzzle_glow: TextureRect
var _shine: Control


func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)
	_glow_tex = _atm._radial(64,
		PackedFloat32Array([0.0, 0.2, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.0)]))

	# Smoke drifting over the burning land, behind everything else.
	_add_smoke(Rect2(0.0, 0.0, 0.475, 0.45), 0.42, 0.012, 2.0, 0.35)
	_add_smoke(Rect2(0.0, 0.3, 0.475, 0.33), 0.32, 0.02, 3.0, 0.6)

	# The painted fires breathing heat.
	_hotspots.clear()
	for h in HOTSPOTS:
		_hotspots.append({"node": _glow(h["px"], h["d"], FIRE), "f1": _rng.randf_range(5.0, 9.0), "f2": _rng.randf_range(11.0, 17.0), "phase": _rng.randf() * TAU})

	# Tongues of flame roaring up, then smoke curling off them.
	for src in FLAME_SOURCES:
		_add_flames(src["rect"], int(src["amount"]), float(src["height"]))
	_add_rising_smoke()

	# Firelight on him: the goggles, the barrel and the muzzle.
	_goggle_glows.clear()
	for px in GOGGLES:
		_goggle_glows.append(_glow(px, GOGGLE_D, HOT))
	_muzzle_glow = _glow(MUZZLE, 60.0, FIRE)
	_shine = Control.new()
	_shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shine.material = _atm._additive()
	_shine.draw.connect(_draw_shine)
	add_child(_shine)

	_add_pilot_flame()
	_add_embers()
	set_process(true)


func _pl(p: Vector2) -> Vector2:
	return _origin + p * _s


func _glow(px: Vector2, diameter: float, color: Color) -> TextureRect:
	var r := TextureRect.new()
	r.texture = _glow_tex
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.size = Vector2.ONE * diameter * _s
	r.position = _pl(px) - r.size * 0.5
	r.pivot_offset = r.size * 0.5
	r.material = _atm._additive()
	r.self_modulate = color
	add_child(r)
	return r


func _add_smoke(rect_uv: Rect2, density: float, speed: float, scale: float, band: float) -> void:
	var a: Vector2 = _atm._image_to_local(rect_uv.position)
	var b: Vector2 = _atm._image_to_local(rect_uv.end)
	var mat := ShaderMaterial.new()
	mat.shader = FOG_SHADER
	mat.set_shader_parameter("aspect", (b.x - a.x) / maxf(b.y - a.y, 1.0))
	mat.set_shader_parameter("fog_color", Color(0.16, 0.1, 0.08))
	mat.set_shader_parameter("density", density)
	mat.set_shader_parameter("speed", speed)
	mat.set_shader_parameter("scale", scale)
	mat.set_shader_parameter("band_center", band)
	mat.set_shader_parameter("band_height", 0.6)
	mat.set_shader_parameter("edge_fade", Vector4(0.02, 0.15, 0.15, 0.15))
	var fog := ColorRect.new()
	fog.material = mat
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.position = a
	fog.size = b - a
	add_child(fog)


## Tongues of fire licking up out of `rect` (source px): soft flame puffs
## shooting up, growing, flickering from white-yellow through orange to a
## smoky red as they climb.
func _add_flames(rect: Rect2, amount: int, height: float) -> void:
	var p := CPUParticles2D.new()
	p.position = _pl(rect.get_center())
	p.amount = amount
	p.lifetime = 0.9 * height
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = rect.size * 0.5 * _s
	p.direction = Vector2(0.0, -1.0)
	p.spread = 12.0
	p.gravity = Vector2(0.0, -90.0 * _s)
	p.initial_velocity_min = 60.0 * _s
	p.initial_velocity_max = 140.0 * _s
	p.tangential_accel_min = -30.0
	p.tangential_accel_max = 30.0
	p.scale_amount_min = 2.4 * _s
	p.scale_amount_max = 4.6 * _s
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 0.5))
	shrink.add_point(Vector2(0.25, 1.0))
	shrink.add_point(Vector2(1.0, 0.15))
	p.scale_amount_curve = shrink
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.12, 0.45, 0.8, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.9, 0.55, 0.85), Color(FIRE, 0.7), Color(0.75, 0.15, 0.04, 0.4), Color(0.2, 0.05, 0.02, 0.0)])
	p.color_ramp = ramp
	p.material = _atm._additive()
	add_child(p)
	p.emitting = true
	p.preprocess = p.lifetime


func _add_rising_smoke() -> void:
	var p := CPUParticles2D.new()
	p.position = _pl(Vector2(395.0, 520.0))
	p.amount = 26
	p.lifetime = 4.0
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(395.0, 60.0) * _s
	p.direction = Vector2(0.15, -1.0)
	p.spread = 15.0
	p.gravity = Vector2(6.0, -10.0) * _s
	p.initial_velocity_min = 15.0 * _s
	p.initial_velocity_max = 35.0 * _s
	p.scale_amount_min = 6.0 * _s
	p.scale_amount_max = 11.0 * _s
	var grow := Curve.new()
	grow.add_point(Vector2(0.0, 0.4))
	grow.add_point(Vector2(1.0, 1.6))
	p.scale_amount_curve = grow
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	ramp.colors = PackedColorArray([Color(0.15, 0.1, 0.08, 0.0), Color(0.12, 0.08, 0.07, 0.38), Color(0.08, 0.06, 0.06, 0.0)])
	p.color_ramp = ramp
	add_child(p)
	p.emitting = true
	p.preprocess = p.lifetime


## A small pilot flame sputtering at the flamethrower's muzzle.
func _add_pilot_flame() -> void:
	var p := CPUParticles2D.new()
	p.position = _pl(MUZZLE)
	p.amount = 24
	p.lifetime = 0.45
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 5.0 * _s
	p.direction = Vector2(0.4, -1.0)
	p.spread = 25.0
	p.gravity = Vector2(0.0, -80.0 * _s)
	p.initial_velocity_min = 15.0 * _s
	p.initial_velocity_max = 40.0 * _s
	p.scale_amount_min = 1.2 * _s
	p.scale_amount_max = 2.2 * _s
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.6, 1.0])
	ramp.colors = PackedColorArray([Color(0.6, 0.75, 1.0, 0.7), Color(1.0, 0.85, 0.45, 0.9), Color(FIRE, 0.6), Color(0.6, 0.12, 0.03, 0.0)])
	p.color_ramp = ramp
	p.material = _atm._additive()
	add_child(p)
	p.emitting = true


func _add_embers() -> void:
	var a: Vector2 = _atm._image_to_local(PANEL_RECT_UV.position)
	var b: Vector2 = _atm._image_to_local(PANEL_RECT_UV.end)
	var p := CPUParticles2D.new()
	p.position = Vector2((a.x + b.x) * 0.5, b.y)
	p.amount = 70
	p.lifetime = 5.0
	p.texture = VoidReachFX._dot()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2((b.x - a.x) * 0.5, 20.0)
	p.direction = Vector2(0.0, -1.0)
	p.spread = 25.0
	p.gravity = Vector2(0.0, -8.0)
	p.initial_velocity_min = 40.0 * _s
	p.initial_velocity_max = 110.0 * _s
	p.tangential_accel_min = -25.0
	p.tangential_accel_max = 25.0
	p.scale_amount_min = 0.35
	p.scale_amount_max = 0.8
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.1, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(HOT, 0.0), Color(1.0, 0.75, 0.3, 1.0), Color(FIRE, 0.8), Color(0.6, 0.12, 0.03, 0.0)])
	p.color_ramp = ramp
	p.material = _atm._additive()
	add_child(p)
	p.emitting = true
	p.preprocess = p.lifetime


func _process(delta: float) -> void:
	_time += delta
	# Fire flicker: a fast ragged base, now and then a big surge.
	var surge := pow(maxf(sin(_time * 0.9) * sin(_time * 1.7 + 1.0), 0.0), 2.0)
	for h in _hotspots:
		var f: float = 0.55 + 0.18 * sin(_time * float(h["f1"]) + float(h["phase"])) + 0.1 * sin(_time * float(h["f2"]) + float(h["phase"]) * 1.7) + 0.3 * surge
		h["node"].modulate = Color(f, f, f, 1.0)
		h["node"].scale = Vector2.ONE * (0.92 + 0.12 * f)
	# The lenses: firelight flickering in them.
	for i in _goggle_glows.size():
		var g: float = 0.45 + 0.25 * sin(_time * (8.0 + i * 1.3) + i) + 0.12 * sin(_time * 19.0 + i * 2.0) + 0.3 * surge
		_goggle_glows[i].modulate = Color(g, g, g, 1.0)
	var m: float = 0.5 + 0.3 * sin(_time * 13.0) + 0.15 * sin(_time * 29.0) + 0.2 * surge
	_muzzle_glow.modulate = Color(m, m, m, 1.0)
	_shine.queue_redraw()


## Glints of firelight: one sliding across each goggle lens, and two
## running along the barrel's top edge toward the muzzle.
func _draw_shine() -> void:
	for i in GOGGLES.size():
		var t := fmod(_time * 0.55 + i * 0.37, 1.6)
		if t < 1.0:
			var c: Vector2 = GOGGLES[i]
			var p := _pl(c + Vector2(lerpf(-10.0, 10.0, t), lerpf(-8.0, 6.0, t)))
			var a := sin(t * PI)
			_shine.draw_circle(p, 3.5 * _s, Color(1.0, 0.95, 0.8, 0.85 * a))
			_shine.draw_circle(p, 8.0 * _s, Color(HOT, 0.3 * a))
	for k in 2:
		var t := fmod(_time * 0.35 + k * 0.5, 1.0)
		var p := _along_barrel(t)
		var a := sin(t * PI) * 0.8
		var dir := (_pl(BARREL[2]) - _pl(BARREL[0])).normalized()
		_shine.draw_line(p - dir * 14.0 * _s, p + dir * 14.0 * _s, Color(HOT, 0.6 * a), 3.0 * _s, true)
		_shine.draw_circle(p, 5.0 * _s, Color(1.0, 0.9, 0.7, 0.5 * a))


func _along_barrel(t: float) -> Vector2:
	var seg_t := t * (BARREL.size() - 1)
	var i := mini(int(seg_t), BARREL.size() - 2)
	return _pl((BARREL[i] as Vector2).lerp(BARREL[i + 1], seg_t - i))
