extends Control
# ------------------------------------------------------------------
# BlackbloomBattleAtmosphere
# The Blackbloom arena's battle-area effects. BattleAtmosphere creates one
# of these (and frees it with the rest of its children) for the
# the_blackbloom_area.jpg arena, then calls build(). Purely visual: never
# takes input, never touches game state. It sits under the fighters, and
# the painted battle UI panel at the bottom is left alone.
#
#   - the moon's halo breathes, a cold light fanning down from it
#   - violet mist drifts through the ruins, and low over the ground
#   - the glowing flowers pulse, each on its own rhythm, with violet motes
#     rising off them
#   - the spirit-lights among the ruins flicker, the gate's glow breathing
#   - the pool glints and ripples
#   - violet motes wander the edges of the arena and dark petals fall,
#     kept out of the middle so they never crowd the fight
#
# Positions of art features are given in pixels of the 1672x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const SHAFTS_SHADER := preload("res://shaders/light_shafts.gdshader")
const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted UI panel starts below this (image UV y).
const FLOOR_UV := 0.72

# The moon and the cold light fanning from it (rect in image UV, origin in
# that rect's own UV).
const MOON_PX := Vector2(1170.0, 98.0)
const MOON_DIAMETER := 330.0
const MOON_COLOR := Color(0.62, 0.7, 1.0)
const SHAFTS_RECT_UV := Rect2(0.45, 0.0, 0.5, 0.7)
const SHAFTS_ORIGIN := Vector2(0.45, 0.0)
const SHAFT_COLOR := Color(0.62, 0.68, 1.0)

# Mist (image UV): through the ruins, and low over the ground.
const MIST_RECT_UV := Rect2(0.0, 0.25, 1.0, 0.4)
const LOW_MIST_RECT_UV := Rect2(0.0, 0.5, 1.0, 0.24)
const MIST_COLOR := Color(0.55, 0.42, 0.92)

# The glowing flowers (source px) and the glow's diameter - only those
# above the painted panel.
const FLOWERS := [
	{"px": Vector2(190.0, 290.0), "d": 70.0},
	{"px": Vector2(40.0, 380.0), "d": 110.0},
	{"px": Vector2(160.0, 495.0), "d": 70.0},
	{"px": Vector2(598.0, 497.0), "d": 46.0},
	{"px": Vector2(965.0, 510.0), "d": 56.0},
	{"px": Vector2(1075.0, 497.0), "d": 56.0},
	{"px": Vector2(1305.0, 497.0), "d": 50.0},
	{"px": Vector2(1452.0, 468.0), "d": 60.0},
	{"px": Vector2(1522.0, 425.0), "d": 70.0},
	{"px": Vector2(1585.0, 545.0), "d": 70.0},
	{"px": Vector2(1500.0, 655.0), "d": 56.0},
	{"px": Vector2(130.0, 640.0), "d": 60.0},
]
const FLOWER_COLOR := Color(0.6, 0.3, 1.0)
const MOTE_COLOR := Color(0.8, 0.65, 1.0)

# Spirit-lights among the distant ruins (source px): the glowing gate and
# the flickering candles beside it.
const LIGHTS := [
	{"px": Vector2(945.0, 325.0), "d": 130.0, "base": 0.7},   # the gate's glow
	{"px": Vector2(880.0, 322.0), "d": 40.0, "base": 0.55},
	{"px": Vector2(740.0, 430.0), "d": 44.0, "base": 0.6},
	{"px": Vector2(1010.0, 430.0), "d": 40.0, "base": 0.55},
	{"px": Vector2(1260.0, 365.0), "d": 40.0, "base": 0.5},
	{"px": Vector2(560.0, 360.0), "d": 40.0, "base": 0.5},
	{"px": Vector2(1100.0, 400.0), "d": 36.0, "base": 0.5},
]
const LIGHT_COLOR := Color(0.65, 0.35, 1.0)

# The pool (source px rect) - glints on it.
const POOL_RECT_PX := Rect2(690.0, 440.0, 460.0, 70.0)
const POOL_GLINTS := 14
const POOL_COLOR := Color(0.8, 0.8, 1.0)

# Wandering motes along both edges (image UV), and falling petals from
# the canopy at the corners.
const MOTE_REGIONS_UV := [Rect2(0.0, 0.18, 0.22, 0.5), Rect2(0.78, 0.18, 0.22, 0.5)]
const MOTES_PER_REGION := 8
const PETAL_SOURCES_UV := [Rect2(0.0, 0.0, 0.25, 0.2), Rect2(0.75, 0.0, 0.25, 0.2)]
const PETAL_COUNT := 10
const PETAL_LIFE := Vector2(8.0, 13.0)
const PETAL_COLORS := [Color(0.45, 0.25, 0.75), Color(0.35, 0.2, 0.62), Color(0.6, 0.4, 0.9)]
const PETAL_FADE_UV := Vector2(0.5, 0.66)

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0
var _origin := Vector2.ZERO

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _moon: TextureRect
var _shafts_mat: ShaderMaterial
var _flowers: Array[Dictionary] = []
var _lights: Array[Dictionary] = []

var _glints: Array[Dictionary] = []
var _motes: Array[Dictionary] = []
var _petals: Array[Dictionary] = []
var _petal_accum := 0.0
var _layer: Control          # glints + motes (additive)
var _petal_layer: Control


## `atm` is the owning BattleAtmosphere - its image mapping helpers are
## reused so positions line up with the Background exactly.
func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# The moon's light fanning down, behind everything else.
	var sa: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.position)
	var sb: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.end)
	_shafts_mat = ShaderMaterial.new()
	_shafts_mat.shader = SHAFTS_SHADER
	_shafts_mat.set_shader_parameter("origin", SHAFTS_ORIGIN)
	_shafts_mat.set_shader_parameter("shaft_color", SHAFT_COLOR)
	_shafts_mat.set_shader_parameter("intensity", 0.1)
	_shafts_mat.set_shader_parameter("spread", 0.7)
	_shafts_mat.set_shader_parameter("reach", 1.4)
	_shafts_mat.set_shader_parameter("sway", 0.04)
	_shafts_mat.set_shader_parameter("aspect", (sb.x - sa.x) / (sb.y - sa.y))
	var shafts := ColorRect.new()
	shafts.material = _shafts_mat
	shafts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shafts.position = sa
	shafts.size = sb - sa
	add_child(shafts)
	_moon = _glow(MOON_PX, MOON_DIAMETER, MOON_COLOR)

	# The spirit-lights, then the mist over them.
	_lights.clear()
	for l in LIGHTS:
		_lights.append({
			"node": _glow(l["px"], l["d"], LIGHT_COLOR),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.9, 1.3),
			"base": l["base"], "gate": float(l["d"]) > 100.0,
		})
	_add_fog(MIST_RECT_UV, {
		"density": 0.22, "speed": 0.014, "scale": 2.4,
		"band_center": 0.55, "band_height": 0.6,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.02, 0.35, 0.02, 0.35),
	})
	_add_fog(LOW_MIST_RECT_UV, {
		"density": 0.26, "speed": 0.026, "scale": 3.6,
		"band_center": 0.5, "band_height": 0.55,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.02, 0.4, 0.02, 0.5),
	})

	# The flowers, over the mist so they burn through it.
	_flowers.clear()
	for f in FLOWERS:
		_flowers.append({
			"node": _glow(f["px"], f["d"], FLOWER_COLOR),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.5, 1.0),
		})
		_add_motes(f["px"], float(f["d"]))

	# Glints on the pool, wandering motes and falling petals, over everything.
	_glints.clear()
	for i in POOL_GLINTS:
		_glints.append({
			"pos": POOL_RECT_PX.position + Vector2(_rng.randf(), _rng.randf()) * POOL_RECT_PX.size,
			"speed": _rng.randf_range(0.7, 1.7), "phase": _rng.randf() * TAU,
		})
	_motes.clear()
	for region_i in MOTE_REGIONS_UV.size():
		for i in MOTES_PER_REGION:
			_motes.append({
				"region": region_i,
				"base": Vector2(_rng.randf_range(0.2, 0.8), _rng.randf_range(0.2, 0.8)),
				"amp": Vector2(_rng.randf_range(0.05, 0.11), _rng.randf_range(0.05, 0.11)),
				"freq": Vector2(_rng.randf_range(0.12, 0.34), _rng.randf_range(0.1, 0.3)),
				"phase": Vector4(_rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU),
				"blink": _rng.randf_range(0.8, 2.0), "blink_phase": _rng.randf() * TAU,
				"size": _rng.randf_range(22.0, 38.0),
			})
	_layer = _new_layer(true)
	_layer.draw.connect(_draw_glints_and_motes)

	_petals.clear()
	_petal_layer = _new_layer(false)
	_petal_layer.draw.connect(_draw_petals)
	for i in 240:
		_update_petals(1.0 / 30.0)

	set_process(true)


# --- helpers --------------------------------------------------------

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


func _new_layer(additive: bool) -> Control:
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	if additive:
		layer.material = _atm._additive()
	add_child(layer)
	return layer


func _add_fog(rect_uv: Rect2, params: Dictionary) -> void:
	var a: Vector2 = _atm._image_to_local(rect_uv.position)
	var b: Vector2 = _atm._image_to_local(rect_uv.end)
	var mat := ShaderMaterial.new()
	mat.shader = FOG_SHADER
	mat.set_shader_parameter("aspect", (b.x - a.x) / (b.y - a.y))
	for key in params:
		mat.set_shader_parameter(key, params[key])
	var fog := ColorRect.new()
	fog.material = mat
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.position = a
	fog.size = b - a
	add_child(fog)


## A thin stream of violet motes rising off a flower.
func _add_motes(px: Vector2, diameter: float) -> void:
	var p := CPUParticles2D.new()
	p.position = _pl(px)
	p.material = _atm._additive()
	p.texture = _dot_tex
	p.amount = 4
	p.lifetime = 3.0
	p.preprocess = 3.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(diameter * 0.2, 4.0) * _s
	p.direction = Vector2(0.0, -1.0)
	p.spread = 25.0
	p.gravity = Vector2(0.0, -4.0) * _s
	p.initial_velocity_min = 6.0 * _s
	p.initial_velocity_max = 18.0 * _s
	p.scale_amount_min = 0.2 * _s
	p.scale_amount_max = 0.5 * _s
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(MOTE_COLOR, 0.0), Color(MOTE_COLOR, 0.9), Color(FLOWER_COLOR, 0.5), Color(FLOWER_COLOR, 0.0)])
	p.color_ramp = ramp
	add_child(p)


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_glows()
	_update_petals(delta)
	_layer.queue_redraw()
	_petal_layer.queue_redraw()


func _update_glows() -> void:
	var moon_b: float = 0.6 + 0.12 * sin(_time * 0.55) + 0.04 * sin(_time * 1.7)
	_moon.modulate = Color(moon_b, moon_b, moon_b, 1.0)
	_moon.scale = Vector2.ONE * (0.96 + 0.08 * sin(_time * 0.45))
	_shafts_mat.set_shader_parameter("intensity", 0.08 + 0.03 * sin(_time * 0.55))

	for f in _flowers:
		var pulse: float = 0.45 + 0.4 * (0.5 + 0.5 * sin(_time * float(f["speed"]) + float(f["phase"])))
		f["node"].modulate = Color(pulse, pulse, pulse, 1.0)
		f["node"].scale = Vector2.ONE * (0.9 + 0.2 * pulse)
	for l in _lights:
		var ph: float = l["phase"]
		var sp: float = l["speed"]
		var b: float
		if l["gate"]:
			# The gate breathes slowly instead of flickering.
			b = float(l["base"]) + 0.15 * sin(_time * 0.7 + ph)
		else:
			b = float(l["base"]) + 0.15 * sin(_time * 7.0 * sp + ph) + 0.1 * sin(_time * 13.0 * sp + ph * 2.3)
		l["node"].modulate = Color(b, b, b, 1.0)
		l["node"].scale = Vector2.ONE * (0.92 + 0.16 * b)


func _update_petals(delta: float) -> void:
	_petal_accum += delta * float(PETAL_COUNT) / ((PETAL_LIFE.x + PETAL_LIFE.y) * 0.5)
	while _petal_accum >= 1.0 and _petals.size() < PETAL_COUNT:
		_petal_accum -= 1.0
		var src: Rect2 = PETAL_SOURCES_UV[_rng.randi() % PETAL_SOURCES_UV.size()]
		var uv := src.position + Vector2(_rng.randf(), _rng.randf()) * src.size
		_petals.append({
			"pos": _atm._image_to_local(uv),
			"fall": _rng.randf_range(14.0, 26.0), "sway": _rng.randf_range(10.0, 22.0),
			"sway_freq": _rng.randf_range(0.6, 1.3), "sway_phase": _rng.randf() * TAU,
			"rot": _rng.randf() * TAU, "spin": _rng.randf_range(-1.4, 1.4),
			"flip": _rng.randf() * TAU, "flip_speed": _rng.randf_range(1.1, 2.4),
			"size": _rng.randf_range(6.0, 10.0), "age": 0.0,
			"life": _rng.randf_range(PETAL_LIFE.x, PETAL_LIFE.y),
			"color": PETAL_COLORS[_rng.randi() % PETAL_COLORS.size()],
		})
	_petal_accum = minf(_petal_accum, 1.0)
	var end_y: float = _atm._image_to_local(Vector2(0.0, PETAL_FADE_UV.y)).y
	for i in range(_petals.size() - 1, -1, -1):
		var p: Dictionary = _petals[i]
		p["age"] += delta
		p["pos"].y += float(p["fall"]) * _s * delta
		p["pos"].x += float(p["sway"]) * _s * cos(_time * float(p["sway_freq"]) + float(p["sway_phase"])) * delta
		p["rot"] += float(p["spin"]) * delta
		p["flip"] += float(p["flip_speed"]) * delta
		if p["age"] >= p["life"] or p["pos"].y >= end_y:
			_petals.remove_at(i)


# --- drawing --------------------------------------------------------

func _draw_glints_and_motes() -> void:
	# Glints and slow ripples on the pool.
	for g in _glints:
		var b: float = pow(maxf(sin(_time * float(g["speed"]) + float(g["phase"])), 0.0), 8.0)
		if b < 0.05:
			continue
		var p := _pl(g["pos"])
		var d := Vector2.ONE * 8.0 * _s
		_layer.draw_texture_rect(_dot_tex, Rect2(p - d * 0.5, d), false, Color(POOL_COLOR, 0.8 * b))
		var arm := 6.0 * _s * b
		_layer.draw_line(p - Vector2(arm, 0.0), p + Vector2(arm, 0.0), Color(POOL_COLOR, 0.45 * b), 1.0, true)
	# Motes drifting about the edges, each blinking on its own rhythm.
	for m in _motes:
		var b: float = 0.08 + pow(maxf(sin(_time * float(m["blink"]) + float(m["blink_phase"])), 0.0), 1.5)
		var ph: Vector4 = m["phase"]
		var fr: Vector2 = m["freq"]
		var wander := Vector2(
			sin(_time * fr.x + ph.x) + 0.5 * sin(_time * fr.y * 2.3 + ph.z),
			sin(_time * fr.y + ph.y) + 0.5 * sin(_time * fr.x * 1.9 + ph.w))
		var region: Rect2 = MOTE_REGIONS_UV[m["region"]]
		var uv: Vector2 = region.position + (m["base"] + Vector2(m["amp"]) * wander) * region.size
		var p: Vector2 = _atm._image_to_local(uv)
		var halo := Vector2.ONE * float(m["size"]) * _s
		_layer.draw_texture_rect(_glow_tex, Rect2(p - halo * 0.5, halo), false, Color(MOTE_COLOR, 0.8 * minf(b, 1.0)))
		var core := Vector2.ONE * float(m["size"]) * 0.28 * _s
		_layer.draw_texture_rect(_dot_tex, Rect2(p - core * 0.5, core), false, Color(0.95, 0.9, 1.0, minf(b, 1.0)))


func _draw_petals() -> void:
	var fy := Vector2(
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_UV.x)).y,
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_UV.y)).y)
	for p in _petals:
		var age: float = p["age"]
		var fade: float = smoothstep(0.0, 0.6, age) * (1.0 - smoothstep(float(p["life"]) - 1.5, float(p["life"]), age))
		fade *= 1.0 - smoothstep(fy.x, fy.y, p["pos"].y)
		if fade <= 0.01:
			continue
		var size: float = float(p["size"]) * _s
		var squash := 0.35 + 0.65 * absf(cos(float(p["flip"])))
		var rot: float = p["rot"]
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * i / 8.0
			var v := Vector2(cos(a) * size, sin(a) * size * 0.55 * squash * (1.0 - 0.35 * cos(a)))
			pts.append(Vector2(p["pos"]) + v.rotated(rot))
		_petal_layer.draw_colored_polygon(pts, Color(Color(p["color"]), 0.8 * fade))
