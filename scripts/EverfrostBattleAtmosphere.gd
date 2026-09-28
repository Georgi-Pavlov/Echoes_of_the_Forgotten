extends Control
# ------------------------------------------------------------------
# EverfrostBattleAtmosphere
# The Everfrost's battle-area effects. BattleAtmosphere creates one of
# these (and frees it with the rest of its children) for the_everfrost,
# then calls build(). Purely visual: never takes input, never touches
# game state. The painted battle UI panel at the bottom is left alone.
#
#   - the braziers, torches, hut windows and watchtower lamps flicker,
#     each on its own rhythm; embers rise off the two big braziers
#   - wind blows across the arena in gusts: driven snow and faint
#     streaks of blown snow, thicker when a gust comes through
#
# Positions are background-image UV (0..1), mapped through
# BattleAtmosphere's own helpers.
# ------------------------------------------------------------------

# uv, glow radius (px at the 1536-wide image), strength
const FIRES := [
	[Vector2(0.055, 0.45), 70.0, 0.95],    # big braziers
	[Vector2(0.95, 0.457), 70.0, 0.95],
	[Vector2(0.246, 0.4), 34.0, 0.7],      # braziers along the fence
	[Vector2(0.388, 0.422), 30.0, 0.7],
	[Vector2(0.617, 0.422), 30.0, 0.7],
	[Vector2(0.758, 0.4), 34.0, 0.7],
	[Vector2(0.25, 0.372), 22.0, 0.5],     # hut windows / doors
	[Vector2(0.707, 0.375), 22.0, 0.5],
	[Vector2(0.738, 0.27), 16.0, 0.45],
	[Vector2(0.205, 0.235), 16.0, 0.5],    # watchtower lamps
	[Vector2(0.81, 0.24), 16.0, 0.5],
	[Vector2(0.32, 0.08), 12.0, 0.4],      # the fortress on the cliff
]
const EMBER_SOURCES := [Vector2(0.055, 0.44), Vector2(0.95, 0.447)]
const FLOOR_UV := 0.68          # the painted UI panel starts below this
const FLAKES := 140
const STREAKS := 22

var _atm: Control
var _background: TextureRect
var _time := 0.0
var _s := 1.0                   # image -> screen scale
var _fires: Array = []          # [TextureRect, strength, phase]
var _flakes: Array[Dictionary] = []
var _streaks: Array[Dictionary] = []
var _top := 0.0
var _floor := 0.0
var _width := 0.0


func build(atm: Control, background: TextureRect) -> void:
	_atm = atm
	_background = background
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = atm._image_scale()
	var a: Vector2 = atm._image_to_local(Vector2.ZERO)
	var b: Vector2 = atm._image_to_local(Vector2(1.0, FLOOR_UV))
	_top = a.y
	_floor = b.y
	_width = b.x - a.x

	var tex: GradientTexture2D = atm._radial(64, PackedFloat32Array([0.0, 0.2, 1.0]),
		PackedColorArray([Color(1.0, 0.78, 0.4, 0.85), Color(1.0, 0.5, 0.15, 0.45), Color(1.0, 0.35, 0.05, 0.0)]))
	for f in FIRES:
		var glow := TextureRect.new()
		glow.texture = tex
		glow.material = atm._additive()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var r: float = f[1] * _s * 2.0
		glow.size = Vector2(r, r)
		glow.position = atm._image_to_local(f[0]) - glow.size * 0.5
		add_child(glow)
		_fires.append([glow, f[2], randf() * TAU])

	for uv in EMBER_SOURCES:
		_add_embers(atm._image_to_local(uv))

	for i in FLAKES:
		_flakes.append(_new_flake(true))
	for i in STREAKS:
		_streaks.append(_new_streak(true))
	set_process(true)


func _add_embers(at: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = at
	p.material = _atm._additive()
	p.amount = 18
	p.lifetime = 1.8
	p.preprocess = 1.8
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(22.0, 6.0) * _s
	p.direction = Vector2(0.3, -1)
	p.spread = 25.0
	p.gravity = Vector2(18, -30) * _s
	p.initial_velocity_min = 20.0 * _s
	p.initial_velocity_max = 50.0 * _s
	p.scale_amount_min = 1.2 * _s
	p.scale_amount_max = 2.6 * _s
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color(1, 0.8, 0.4, 0), Color(1, 0.7, 0.3, 1), Color(1, 0.35, 0.08, 0.6), Color(0.6, 0.1, 0.02, 0)])
	p.color_ramp = ramp
	add_child(p)


# --- wind -----------------------------------------------------------------

## 0..1: how hard the wind is gusting right now.
func _gust() -> float:
	return clampf((0.5 + 0.5 * sin(_time * 0.41)) * (0.5 + 0.5 * sin(_time * 0.27 + 1.1)) * 1.6, 0.0, 1.0)


func _new_flake(anywhere: bool) -> Dictionary:
	var depth := randf()   # 0 = far (small, slow), 1 = near
	return {
		"x": randf() * _width if anywhere else -randf() * 60.0,
		"y": randf_range(_top, _floor),
		"depth": depth,
		"size": lerpf(1.0, 3.2, depth) * _s * 1.4,
		"phase": randf() * TAU,
	}


func _new_streak(anywhere: bool) -> Dictionary:
	return {
		"x": randf() * _width if anywhere else -randf() * 300.0,
		"y": randf_range(_top + (_floor - _top) * 0.15, _floor),
		"len": randf_range(60.0, 160.0) * _s * 1.4,
		"alpha": randf_range(0.08, 0.2),
	}


func _process(delta: float) -> void:
	_time += delta
	for f in _fires:
		var glow: TextureRect = f[0]
		var p: float = f[2]
		var flick := 0.72 + 0.14 * sin(_time * 7.3 + p) + 0.09 * sin(_time * 13.1 + p * 2.7) + 0.05 * sin(_time * 23.0 + p * 1.3)
		glow.modulate.a = f[1] * flick
	var g := _gust()
	var wind := (60.0 + 260.0 * g) * _s * 1.4
	for i in _flakes.size():
		var f: Dictionary = _flakes[i]
		f.x += wind * lerpf(0.45, 1.0, f.depth) * delta
		f.y += (18.0 + sin(_time * 2.0 + f.phase) * 22.0) * _s * delta
		if f.x > _width + 20.0 or f.y > _floor:
			_flakes[i] = _new_flake(false)
	for i in _streaks.size():
		var s: Dictionary = _streaks[i]
		s.x += wind * 1.6 * delta
		if s.x - s.len > _width:
			_streaks[i] = _new_streak(false)
	queue_redraw()


func _draw() -> void:
	var g := _gust()
	for s in _streaks:
		var a: float = s.alpha * (0.35 + 0.65 * g)
		var y: float = s.y + sin(_time * 1.5 + s.x * 0.01) * 6.0
		draw_line(Vector2(s.x - s.len, y), Vector2(s.x, y - s.len * 0.04), Color(0.9, 0.95, 1.0, a), 2.0 * _s * 1.4, true)
	for f in _flakes:
		var fade: float = clampf((_floor - f.y) / 30.0, 0.0, 1.0)
		draw_circle(Vector2(f.x, f.y), f.size, Color(0.95, 0.97, 1.0, lerpf(0.35, 0.85, f.depth) * fade))
