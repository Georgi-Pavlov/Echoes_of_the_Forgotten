extends Control
# ------------------------------------------------------------------
# VerdantScarBattleAtmosphere
# The Verdant Scar arena's battle-area effects. BattleAtmosphere creates
# one of these (and frees it with the rest of its children) for any zone
# fighting in that arena, then calls build(). Purely visual: never takes
# input, never touches game state. It sits under the fighters, and the
# painted battle UI panel at the bottom is left alone.
#
#   - the green crystals on the pillars pulse, each on its own rhythm,
#     with sparks rising off them
#   - the green light in the distant tower breathes and flares, its beam
#     pulsing with it
#   - the waterfalls run and splash
#   - mist drifts through the ruins, and low over the ground
#   - fireflies wander and red petals drift down along the edges of the
#     arena, kept out of the middle so they never crowd the fight
#
# Positions of art features are given in pixels of the 1670x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted UI panel starts below this (image UV y).
const FLOOR_UV := 0.68

# The crystals on the pillars: where they sit (source px) and the glow's
# diameter.
const CRYSTALS := [
	{"px": Vector2(145.0, 347.0), "d": 90.0},
	{"px": Vector2(597.0, 369.0), "d": 80.0},
	{"px": Vector2(1151.0, 366.0), "d": 80.0},
	{"px": Vector2(1530.0, 340.0), "d": 90.0},
]
const CRYSTAL_COLOR := Color(0.5, 1.0, 0.45)
const SPARK_COLOR := Color(0.75, 1.0, 0.7)

# The green light in the distant tower, and its beam (top of the image
# down to where it fades).
const TOWER_PX := Vector2(924.0, 108.0)
const TOWER_CORE_DIAMETER := 90.0
const TOWER_HALO_DIAMETER := 260.0
const TOWER_COLOR := Color(0.42, 1.0, 0.58)
const TOWER_FLARE_EVERY := Vector2(4.0, 8.0)
const BEAM_TOP_Y := 0.0
const BEAM_BOTTOM_Y := 128.0
const BEAM_HALF_WIDTH := 7.0

# Mist (image UV): thin drift through the ruins, and low over the ground.
const MIST_RECT_UV := Rect2(0.0, 0.1, 1.0, 0.4)
const LOW_MIST_RECT_UV := Rect2(0.0, 0.4, 1.0, 0.2)
const MIST_COLOR := Color(0.88, 0.92, 0.88)

# Waterfalls: x is the centre, y0/y1 the top and foot, w the width.
const FALLS := [
	{"x": 1003.0, "y0": 292.0, "y1": 394.0, "w": 48.0},
	{"x": 1095.0, "y0": 205.0, "y1": 248.0, "w": 20.0},
	{"x": 840.0, "y0": 294.0, "y1": 340.0, "w": 30.0},
	{"x": 1410.0, "y0": 120.0, "y1": 175.0, "w": 66.0},
]
const STREAK_COUNT := 6
const WATER_COLOR := Color(0.85, 0.95, 1.0)

# Fireflies wander along both edges (image UV).
const FLY_REGIONS_UV := [Rect2(0.0, 0.18, 0.2, 0.45), Rect2(0.8, 0.18, 0.2, 0.45)]
const FLY_PER_REGION := 8
const FLY_COLORS := [Color(0.78, 1.0, 0.42), Color(0.78, 1.0, 0.42), Color(1.0, 0.86, 0.42)]

# Petals fall from the vines and flowers at the top corners, and fade out
# well above the painted panel.
const PETAL_SOURCES := [Rect2(0.0, 0.0, 0.22, 0.25), Rect2(0.78, 0.05, 0.2, 0.3)]
const PETAL_COUNT := 10
const PETAL_LIFE := Vector2(7.0, 12.0)
const PETAL_COLORS := [Color(0.75, 0.12, 0.2), Color(0.62, 0.08, 0.16), Color(0.85, 0.25, 0.3)]
const PETAL_FADE_START_UV := 0.52
const PETAL_FADE_END_UV := 0.64

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0                # image scale (screen px per source px)
var _origin := Vector2.ZERO  # where the source image's top-left lands
var _tex_size := Vector2.ONE

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _crystals: Array[Dictionary] = []

var _tower_core: TextureRect
var _tower_halo: TextureRect
var _tower_flare := 0.0
var _tower_next_flare := 0.0
var _beam_layer: Control

var _falls: Array[Dictionary] = []
var _water_layer: Control

var _flies: Array[Dictionary] = []
var _fly_layer: Control

var _petals: Array[Dictionary] = []
var _petal_accum := 0.0
var _petal_layer: Control
var _petal_fade_y := Vector2.ZERO


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
	_tex_size = _background.texture.get_size()

	_glow_tex = _atm._radial(128,
		PackedFloat32Array([0.0, 0.12, 0.35, 1.0]),
		PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.22), Color(1, 1, 1, 0.0)]))
	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# The tower's beam and light, far behind everything else.
	_beam_layer = _new_layer(true)
	_beam_layer.draw.connect(_draw_beam)
	_tower_halo = _glow(TOWER_PX, TOWER_HALO_DIAMETER, TOWER_COLOR)
	_tower_core = _glow(TOWER_PX, TOWER_CORE_DIAMETER, TOWER_COLOR)
	_tower_next_flare = _rng.randf_range(1.5, TOWER_FLARE_EVERY.x)

	# Waterfalls, then the mist over them.
	_falls.clear()
	for f in FALLS:
		var streaks: Array[Dictionary] = []
		for i in STREAK_COUNT:
			streaks.append({
				"off": _rng.randf(), "phase": _rng.randf(), "speed": _rng.randf_range(45.0, 80.0),
				"len": _rng.randf_range(8.0, 16.0), "alpha": _rng.randf_range(0.3, 0.55),
			})
		_falls.append({"fall": f, "streaks": streaks, "splash_phase": _rng.randf() * TAU})
	_water_layer = _new_layer(true)
	_water_layer.draw.connect(_draw_water)

	_add_fog(MIST_RECT_UV, {
		"density": 0.2, "speed": 0.012, "scale": 2.4,
		"band_center": 0.55, "band_height": 0.7,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.02, 0.35, 0.02, 0.35),
	})
	_add_fog(LOW_MIST_RECT_UV, {
		"density": 0.22, "speed": 0.024, "scale": 3.6,
		"band_center": 0.5, "band_height": 0.6,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.02, 0.45, 0.02, 0.5),
	})

	# The crystals, over the mist so they burn through it.
	_crystals.clear()
	for c in CRYSTALS:
		var halo := _glow(c["px"], c["d"], CRYSTAL_COLOR)
		var core := _glow(c["px"], c["d"] * 0.35, Color(0.85, 1.0, 0.8))
		_add_sparks(c["px"])
		_crystals.append({
			"halo": halo, "core": core,
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.7, 1.3),
		})

	# Fireflies and petals, over everything.
	_flies.clear()
	for region_i in FLY_REGIONS_UV.size():
		for i in FLY_PER_REGION:
			_flies.append({
				"region": region_i,
				"base": Vector2(_rng.randf_range(0.2, 0.8), _rng.randf_range(0.2, 0.8)),
				"amp": Vector2(_rng.randf_range(0.05, 0.11), _rng.randf_range(0.05, 0.11)),
				"freq": Vector2(_rng.randf_range(0.12, 0.34), _rng.randf_range(0.1, 0.3)),
				"phase": Vector4(_rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU, _rng.randf() * TAU),
				"blink": _rng.randf_range(1.0, 2.2), "blink_phase": _rng.randf() * TAU,
				"size": _rng.randf_range(26.0, 44.0),
				"tint": FLY_COLORS[_rng.randi() % FLY_COLORS.size()],
			})
	_fly_layer = _new_layer(true)
	_fly_layer.draw.connect(_draw_flies)

	_petal_fade_y = Vector2(
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_START_UV)).y,
		_atm._image_to_local(Vector2(0.0, PETAL_FADE_END_UV)).y)
	_petals.clear()
	_petal_layer = _new_layer(false)
	_petal_layer.draw.connect(_draw_petals)
	# Pre-warm so the battle doesn't open without petals.
	for i in 200:
		_update_petals(1.0 / 30.0)

	set_process(true)


# --- helpers --------------------------------------------------------

## Source-image pixels -> this node's local coordinates.
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


## A fog_drift.gdshader layer over `rect_uv` of the image.
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


## A thin stream of green sparks rising off a crystal.
func _add_sparks(px: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = _pl(px)
	p.material = _atm._additive()
	p.texture = _dot_tex
	p.amount = 6
	p.lifetime = 2.4
	p.preprocess = 2.4
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(8.0, 4.0) * _s
	p.direction = Vector2(0.0, -1.0)
	p.spread = 25.0
	p.gravity = Vector2(0.0, -6.0) * _s
	p.initial_velocity_min = 6.0 * _s
	p.initial_velocity_max = 16.0 * _s
	p.scale_amount_min = 0.2 * _s
	p.scale_amount_max = 0.45 * _s
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(SPARK_COLOR, 0.0), Color(SPARK_COLOR, 0.9), Color(CRYSTAL_COLOR, 0.5), Color(CRYSTAL_COLOR, 0.0)])
	p.color_ramp = ramp
	add_child(p)


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_crystals()
	_update_tower(delta)
	_update_petals(delta)
	_beam_layer.queue_redraw()
	_water_layer.queue_redraw()
	_fly_layer.queue_redraw()
	_petal_layer.queue_redraw()


func _update_crystals() -> void:
	for c in _crystals:
		var ph: float = c["phase"]
		var pulse: float = 0.7 + 0.2 * sin(_time * float(c["speed"]) + ph) + 0.06 * sin(_time * 7.0 + ph * 2.0)
		c["halo"].modulate = Color(pulse, pulse, pulse, 1.0)
		c["halo"].scale = Vector2.ONE * (0.92 + 0.14 * pulse)
		var core: float = 0.55 + 0.4 * pulse
		c["core"].modulate = Color(core, core, core, 1.0)


func _update_tower(delta: float) -> void:
	_tower_next_flare -= delta
	if _tower_next_flare <= 0.0:
		_tower_flare = 1.0
		_tower_next_flare = _rng.randf_range(TOWER_FLARE_EVERY.x, TOWER_FLARE_EVERY.y)
	_tower_flare = move_toward(_tower_flare, 0.0, delta / 1.6)
	var flare := smoothstep(0.0, 1.0, _tower_flare)
	var pulse: float = 0.62 + 0.14 * sin(_time * 0.8) + 0.05 * sin(_time * 2.3)
	var b: float = pulse + 0.38 * flare
	_tower_core.modulate = Color(b, b, b, 1.0)
	_tower_core.scale = Vector2.ONE * (0.95 + 0.1 * pulse + 0.18 * flare)
	var h: float = 0.25 + 0.15 * pulse + 0.5 * flare
	_tower_halo.modulate = Color(h, h, h, 1.0)
	_tower_halo.scale = Vector2.ONE * (0.95 + 0.1 * sin(_time * 0.6) + 0.12 * flare)


func _update_petals(delta: float) -> void:
	_petal_accum += delta * float(PETAL_COUNT) / ((PETAL_LIFE.x + PETAL_LIFE.y) * 0.5)
	while _petal_accum >= 1.0 and _petals.size() < PETAL_COUNT:
		_petal_accum -= 1.0
		var src: Rect2 = PETAL_SOURCES[_rng.randi() % PETAL_SOURCES.size()]
		var uv := src.position + Vector2(_rng.randf(), _rng.randf()) * src.size
		_petals.append({
			"pos": _atm._image_to_local(uv),
			"fall": _rng.randf_range(16.0, 30.0), "sway": _rng.randf_range(10.0, 22.0),
			"sway_freq": _rng.randf_range(0.7, 1.4), "sway_phase": _rng.randf() * TAU,
			"rot": _rng.randf() * TAU, "spin": _rng.randf_range(-1.6, 1.6),
			"flip": _rng.randf() * TAU, "flip_speed": _rng.randf_range(1.2, 2.6),
			"size": _rng.randf_range(5.0, 8.0), "age": 0.0, "life": _rng.randf_range(PETAL_LIFE.x, PETAL_LIFE.y),
			"color": PETAL_COLORS[_rng.randi() % PETAL_COLORS.size()],
		})
	_petal_accum = minf(_petal_accum, 1.0)
	for i in range(_petals.size() - 1, -1, -1):
		var p: Dictionary = _petals[i]
		p["age"] += delta
		p["pos"].y += float(p["fall"]) * _s * delta
		p["pos"].x += float(p["sway"]) * _s * cos(_time * float(p["sway_freq"]) + float(p["sway_phase"])) * delta
		p["rot"] += float(p["spin"]) * delta
		p["flip"] += float(p["flip_speed"]) * delta
		if p["age"] >= p["life"] or p["pos"].y >= _petal_fade_y.y:
			_petals.remove_at(i)


# --- drawing --------------------------------------------------------

## The tower's beam: a thin vertical shaft, brightest at the tower and
## fading upward, pulsing with its light.
func _draw_beam() -> void:
	var flare := smoothstep(0.0, 1.0, _tower_flare)
	var pulse: float = 0.5 + 0.12 * sin(_time * 0.8) + 0.3 * flare
	var top := _pl(Vector2(TOWER_PX.x, BEAM_TOP_Y))
	var bottom := _pl(Vector2(TOWER_PX.x, BEAM_BOTTOM_Y))
	var half := BEAM_HALF_WIDTH * _s * (1.0 + 0.5 * flare)
	var clear := Color(TOWER_COLOR, 0.0)
	var mid := Color(TOWER_COLOR, 0.5 * pulse)
	_beam_layer.draw_polygon(PackedVector2Array([top + Vector2(-half, 0.0), top + Vector2(half, 0.0), bottom + Vector2(half * 0.3, 0.0), bottom + Vector2(-half * 0.3, 0.0)]),
		PackedColorArray([clear, clear, mid, mid]))


func _draw_water() -> void:
	for entry in _falls:
		var f: Dictionary = entry["fall"]
		var span: float = f["y1"] - f["y0"]
		for st in entry["streaks"]:
			var frac := fposmod(float(st["phase"]) + _time * float(st["speed"]) / span, 1.0)
			var y: float = f["y0"] + frac * span
			var x: float = f["x"] - f["w"] * 0.5 + float(st["off"]) * f["w"]
			var a: float = sin(frac * PI) * float(st["alpha"])
			var top := _pl(Vector2(x, y))
			_water_layer.draw_line(top, top + Vector2(0.0, float(st["len"]) * _s), Color(WATER_COLOR, a), 1.3 * _s, true)
		# The splash where it lands, gently pulsing.
		var splash: float = 0.6 + 0.4 * sin(_time * 2.1 + float(entry["splash_phase"]))
		var size := Vector2(f["w"] * 2.6, f["w"] * 1.3) * _s
		_water_layer.draw_texture_rect(_glow_tex, Rect2(_pl(Vector2(f["x"], f["y1"])) - size * 0.5, size), false, Color(WATER_COLOR, 0.22 * splash))


func _draw_flies() -> void:
	for f in _flies:
		var b: float = 0.06 + pow(maxf(sin(_time * float(f["blink"]) + float(f["blink_phase"])), 0.0), 1.5)
		var ph: Vector4 = f["phase"]
		var fr: Vector2 = f["freq"]
		var wander := Vector2(
			sin(_time * fr.x + ph.x) + 0.5 * sin(_time * fr.y * 2.3 + ph.z),
			sin(_time * fr.y + ph.y) + 0.5 * sin(_time * fr.x * 1.9 + ph.w))
		var region: Rect2 = FLY_REGIONS_UV[f["region"]]
		var uv: Vector2 = region.position + (f["base"] + Vector2(f["amp"]) * wander) * region.size
		var p: Vector2 = _atm._image_to_local(uv)
		var halo := Vector2.ONE * float(f["size"]) * _s
		_fly_layer.draw_texture_rect(_glow_tex, Rect2(p - halo * 0.5, halo), false, Color(Color(f["tint"]), 0.85 * minf(b, 1.0)))
		var core := Vector2.ONE * float(f["size"]) * 0.3 * _s
		_fly_layer.draw_texture_rect(_dot_tex, Rect2(p - core * 0.5, core), false, Color(1.0, 1.0, 0.85, minf(b, 1.0)))


func _draw_petals() -> void:
	for p in _petals:
		var age: float = p["age"]
		var fade: float = smoothstep(0.0, 0.6, age) * (1.0 - smoothstep(float(p["life"]) - 1.5, float(p["life"]), age))
		fade *= 1.0 - smoothstep(_petal_fade_y.x, _petal_fade_y.y, p["pos"].y)
		if fade <= 0.01:
			continue
		var size: float = float(p["size"]) * _s
		var squash := 0.35 + 0.65 * absf(cos(float(p["flip"])))
		var rot: float = p["rot"]
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * i / 8.0
			# A teardrop: fuller at one end, drawn to a point at the other.
			var v := Vector2(cos(a) * size, sin(a) * size * 0.55 * squash * (1.0 - 0.35 * cos(a)))
			pts.append(Vector2(p["pos"]) + v.rotated(rot))
		_petal_layer.draw_colored_polygon(pts, Color(Color(p["color"]), 0.85 * fade))
