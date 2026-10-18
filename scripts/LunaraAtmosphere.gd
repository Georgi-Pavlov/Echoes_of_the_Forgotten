extends Control
# ------------------------------------------------------------------
# LunaraAtmosphere
# Lunara's (and Solara's) Blackbloom effects for the hero picker. ZoneAtmosphere creates
# one of these (and frees it again with the rest of its children) when
# the_blackbloom_lunara.jpg is shown, then calls build(). Purely visual:
# never takes input, never touches game state.
#
# Lunara (left half):
#   - she slowly breathes (a soft swell of her body)
#   - the crimson crescent behind her glows on a slow pulse
#   - blood-red petals drift down off her hair and the thorned vines
#
# The ruins (right half):
#   - the moon's halo breathes, a cold light fanning down from it
#   - violet mist drifts through the trees and ruins, and low over the path
#   - the glowing flowers pulse, each on its own rhythm, with violet motes
#     rising off them
#   - the spirit flames on the walls and pillars flicker unevenly
#   - the crescent halos behind the statues pulse in a slow wave, in step
#     with the crescent behind Lunara
#   - dark violet petals and pale motes fall slowly through the canopy
#
# Positions of art features are given in pixels of the 1672x941 source
# image, so they stay on target whatever the screen size.
# ------------------------------------------------------------------

const RIPPLE_SHADER := preload("res://shaders/underwater_ripple.gdshader")
const SHAFTS_SHADER := preload("res://shaders/light_shafts.gdshader")
const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")

# The painted stats frame (UV x0, y0, x1, y1) - kept still.
const FRAME_CALM_RECT := Vector4(0.01, 0.64, 0.466, 0.972)

# Breathing: centred on her torso.
const BREATHE_CENTER_UV := Vector2(0.21, 0.36)
const BREATHE_RADIUS := 0.28             # in units of image height
const BREATHE_AMOUNT := 0.02
const BREATHE_PERIOD := 5.0

# The crimson crescent behind her head.
const CRESCENT_PX := Vector2(645.0, 140.0)
const CRESCENT_DIAMETER := 330.0
const CRESCENT_COLOR := Color(0.9, 0.12, 0.18)

# The moon, and the cold light fanning down from it (a rect in image UV,
# and where in that rect's own UV the light comes from).
const MOON_PX := Vector2(1375.0, 105.0)
const MOON_DIAMETER := 360.0
const MOON_COLOR := Color(0.62, 0.7, 1.0)
const SHAFTS_RECT_UV := Rect2(0.5, 0.0, 0.5, 0.8)
const SHAFTS_ORIGIN := Vector2(0.53, 0.0)
const SHAFT_COLOR := Color(0.62, 0.68, 1.0)

# Mist (image UV): through the trees and ruins, and low over the path.
const MIST_RECT_UV := Rect2(0.48, 0.28, 0.52, 0.5)
const LOW_MIST_RECT_UV := Rect2(0.48, 0.6, 0.52, 0.4)
const MIST_COLOR := Color(0.55, 0.42, 0.92)

# The glowing flowers (source px) and the glow's diameter.
const FLOWERS := [
	{"px": Vector2(890.0, 712.0), "d": 80.0},
	{"px": Vector2(1000.0, 750.0), "d": 70.0},
	{"px": Vector2(1165.0, 745.0), "d": 70.0},
	{"px": Vector2(1275.0, 668.0), "d": 56.0},
	{"px": Vector2(1380.0, 690.0), "d": 56.0},
	{"px": Vector2(1475.0, 742.0), "d": 80.0},
	{"px": Vector2(1565.0, 775.0), "d": 90.0},
	{"px": Vector2(1648.0, 712.0), "d": 80.0},
	{"px": Vector2(1610.0, 650.0), "d": 56.0},
]
const FLOWER_COLOR := Color(0.6, 0.3, 1.0)
const MOTE_COLOR := Color(0.8, 0.65, 1.0)

# Spirit flames on the ruins (source px) and their glow diameter.
const FLAMES := [
	{"px": Vector2(870.0, 420.0), "d": 46.0},
	{"px": Vector2(965.0, 455.0), "d": 52.0},
	{"px": Vector2(1085.0, 470.0), "d": 40.0},
	{"px": Vector2(1190.0, 470.0), "d": 44.0},
	{"px": Vector2(1330.0, 430.0), "d": 46.0},
	{"px": Vector2(1408.0, 380.0), "d": 40.0},
	{"px": Vector2(1505.0, 305.0), "d": 52.0},
	{"px": Vector2(1585.0, 480.0), "d": 56.0},
	{"px": Vector2(1470.0, 620.0), "d": 50.0},
]
const FLAME_COLOR := Color(0.65, 0.35, 1.0)

# The crescent halos behind the statues (source px): centre and ring radius.
const HALOS := [
	{"px": Vector2(1068.0, 298.0), "r": 22.0},
	{"px": Vector2(1532.0, 395.0), "r": 24.0},
	{"px": Vector2(1560.0, 562.0), "r": 20.0},
]
const HALO_COLOR := Color(0.78, 0.7, 1.0)

# Petals. Violet ones fall through the canopy over the right half, fading
# before the foreground; red ones fall off her hair and the vines, fading
# out before the stats frame (all image UV).
const VIOLET_SOURCE_UV := Rect2(0.52, 0.0, 0.46, 0.3)
const VIOLET_COUNT := 14
const VIOLET_COLORS := [Color(0.45, 0.25, 0.75), Color(0.35, 0.2, 0.62), Color(0.6, 0.4, 0.9)]
const VIOLET_FADE_UV := Vector2(0.62, 0.78)
const RED_SOURCES_UV := [Rect2(0.03, 0.05, 0.3, 0.2), Rect2(0.05, 0.3, 0.38, 0.14)]
const RED_COUNT := 12
const RED_COLORS := [Color(0.78, 0.08, 0.16), Color(0.62, 0.05, 0.12), Color(0.9, 0.2, 0.25)]
const RED_FADE_UV := Vector2(0.5, 0.62)
const PETAL_LIFE := Vector2(8.0, 13.0)

# Solara's left half (her background, the_blackbloom_solara.jpg, shares the
# ruins on the right): she breathes, the golden sun behind her glows on the
# same slow wave as the statue halos, and autumn leaves - amber, rust and
# blood-red - drift down through the canopy around her.
const SOLARA_BREATHE_CENTER_UV := Vector2(0.2, 0.38)
const SOLARA_BREATHE_RADIUS := 0.3
const SOLARA_SUN_PX := Vector2(680.0, 118.0)
const SOLARA_SUN_DIAMETER := 330.0
const SOLARA_SUN_COLOR := Color(1.0, 0.72, 0.28)
const SOLARA_LEAF_SOURCES_UV := [Rect2(0.0, 0.0, 0.46, 0.18), Rect2(0.02, 0.2, 0.42, 0.2)]
const SOLARA_LEAF_COLORS := [Color(0.85, 0.35, 0.1), Color(0.7, 0.15, 0.1), Color(0.95, 0.6, 0.2), Color(0.6, 0.28, 0.1), Color(0.8, 0.2, 0.12)]

# Whose left half this is: "lunara" or "solara".
var _hero := "lunara"
var _breathe_center := BREATHE_CENTER_UV
var _breathe_radius := BREATHE_RADIUS
var _crescent_px := CRESCENT_PX
var _crescent_diameter := CRESCENT_DIAMETER
var _crescent_color := CRESCENT_COLOR
var _left_sources: Array = RED_SOURCES_UV
var _left_colors: Array = RED_COLORS
var _left_size := Vector2(7.0, 11.0)
var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0
var _origin := Vector2.ZERO
var _tex_size := Vector2.ONE

var _glow_tex: Texture2D
var _dot_tex: Texture2D

var _crescent: TextureRect
var _moon: TextureRect
var _shafts_mat: ShaderMaterial
var _flowers: Array[Dictionary] = []
var _flames: Array[Dictionary] = []
var _halo_layer: Control

var _violet: Array[Dictionary] = []
var _violet_accum := 0.0
var _red: Array[Dictionary] = []
var _red_accum := 0.0
var _petal_layer: Control


func build(atm: Control, background: TextureRect, hero: String = "lunara") -> void:
	_hero = hero
	if hero == "solara":
		_breathe_center = SOLARA_BREATHE_CENTER_UV
		_breathe_radius = SOLARA_BREATHE_RADIUS
		_crescent_px = SOLARA_SUN_PX
		_crescent_diameter = SOLARA_SUN_DIAMETER
		_crescent_color = SOLARA_SUN_COLOR
		_left_sources = SOLARA_LEAF_SOURCES_UV
		_left_colors = SOLARA_LEAF_COLORS
		_left_size = Vector2(9.0, 14.0)
	_atm = atm
	_background = background
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_s = _atm._image_scale()
	_origin = _atm._image_to_local(Vector2.ZERO)
	_tex_size = _background.texture.get_size()

	# Breathing, straight on the background texture (the ripple itself is
	# switched off - strength 0 - so only the swell is left).
	var mat := ShaderMaterial.new()
	mat.shader = RIPPLE_SHADER
	mat.set_shader_parameter("strength", 0.0)
	mat.set_shader_parameter("calm_rect", FRAME_CALM_RECT)
	mat.set_shader_parameter("aspect", _tex_size.x / _tex_size.y)
	mat.set_shader_parameter("breathe_center", _breathe_center)
	mat.set_shader_parameter("breathe_radius", _breathe_radius)
	mat.set_shader_parameter("breathe_amount", BREATHE_AMOUNT)
	mat.set_shader_parameter("breathe_period", BREATHE_PERIOD)
	_background.material = mat

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
	_shafts_mat.set_shader_parameter("spread", 0.8)
	_shafts_mat.set_shader_parameter("reach", 1.3)
	_shafts_mat.set_shader_parameter("sway", 0.04)
	_shafts_mat.set_shader_parameter("aspect", (sb.x - sa.x) / (sb.y - sa.y))
	var shafts := ColorRect.new()
	shafts.material = _shafts_mat
	shafts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shafts.position = sa
	shafts.size = sb - sa
	add_child(shafts)

	_moon = _glow(MOON_PX, MOON_DIAMETER, MOON_COLOR)
	_crescent = _glow(_crescent_px, _crescent_diameter, _crescent_color)

	# The mist over the glows.
	_add_fog(MIST_RECT_UV, {
		"density": 0.26, "speed": 0.016, "scale": 2.4,
		"band_center": 0.55, "band_height": 0.5,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.12, 0.25, 0.02, 0.3),
	})
	_add_fog(LOW_MIST_RECT_UV, {
		"density": 0.3, "speed": 0.03, "scale": 3.6,
		"band_center": 0.65, "band_height": 0.55,
		"fog_color": MIST_COLOR,
		"edge_fade": Vector4(0.12, 0.4, 0.02, 0.02),
	})

	# The flames, then the flowers (with motes rising off them), over the mist.
	_flames.clear()
	for f in FLAMES:
		_flames.append({
			"node": _glow(f["px"], f["d"], FLAME_COLOR),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.9, 1.3),
			"base": _rng.randf_range(0.55, 0.85),
		})
	_flowers.clear()
	for f in FLOWERS:
		_flowers.append({
			"node": _glow(f["px"], f["d"], FLOWER_COLOR),
			"phase": _rng.randf() * TAU, "speed": _rng.randf_range(0.5, 1.0),
		})
		_add_motes(f["px"], float(f["d"]))

	# The statue halos, and the petals over everything.
	_halo_layer = _new_layer(true)
	_halo_layer.draw.connect(_draw_halos)

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
	_halo_layer.queue_redraw()
	_petal_layer.queue_redraw()


## The slow wave the crescent behind Lunara and the statue halos share.
func _wave(offset: float = 0.0) -> float:
	return 0.5 + 0.5 * sin(_time * 1.1 - offset)


func _update_glows() -> void:
	var moon_b: float = 0.6 + 0.12 * sin(_time * 0.55) + 0.04 * sin(_time * 1.7)
	_moon.modulate = Color(moon_b, moon_b, moon_b, 1.0)
	_moon.scale = Vector2.ONE * (0.96 + 0.08 * sin(_time * 0.45))
	_shafts_mat.set_shader_parameter("intensity", 0.08 + 0.03 * sin(_time * 0.55))

	var c: float = 0.3 + 0.5 * _wave()
	_crescent.modulate = Color(c, c, c, 1.0)
	_crescent.scale = Vector2.ONE * (0.95 + 0.1 * _wave())

	for f in _flowers:
		var pulse: float = 0.45 + 0.4 * (0.5 + 0.5 * sin(_time * float(f["speed"]) + float(f["phase"])))
		f["node"].modulate = Color(pulse, pulse, pulse, 1.0)
		f["node"].scale = Vector2.ONE * (0.9 + 0.2 * pulse)
	for f in _flames:
		var ph: float = f["phase"]
		var sp: float = f["speed"]
		# A quick, uneven flicker around each flame's own brightness.
		var flick: float = float(f["base"]) + 0.15 * sin(_time * 7.0 * sp + ph) + 0.1 * sin(_time * 13.0 * sp + ph * 2.3)
		f["node"].modulate = Color(flick, flick, flick, 1.0)
		f["node"].scale = Vector2.ONE * (0.9 + 0.2 * flick)


func _update_petals(delta: float) -> void:
	_violet_accum += delta * float(VIOLET_COUNT) / ((PETAL_LIFE.x + PETAL_LIFE.y) * 0.5)
	while _violet_accum >= 1.0 and _violet.size() < VIOLET_COUNT:
		_violet_accum -= 1.0
		var uv := VIOLET_SOURCE_UV.position + Vector2(_rng.randf(), _rng.randf()) * VIOLET_SOURCE_UV.size
		_violet.append(_new_petal(uv, VIOLET_COLORS, 6.0, 12.0, 12.0, 24.0))
	_violet_accum = minf(_violet_accum, 1.0)
	_step_petals(_violet, delta, VIOLET_FADE_UV.y)

	_red_accum += delta * float(RED_COUNT) / ((PETAL_LIFE.x + PETAL_LIFE.y) * 0.5)
	while _red_accum >= 1.0 and _red.size() < RED_COUNT:
		_red_accum -= 1.0
		var src: Rect2 = _left_sources[_rng.randi() % _left_sources.size()]
		var uv := src.position + Vector2(_rng.randf(), _rng.randf()) * src.size
		_red.append(_new_petal(uv, _left_colors, _left_size.x, _left_size.y, 14.0, 26.0))
	_red_accum = minf(_red_accum, 1.0)
	_step_petals(_red, delta, RED_FADE_UV.y)


func _new_petal(uv: Vector2, colors: Array, size_min: float, size_max: float, fall_min: float, fall_max: float) -> Dictionary:
	return {
		"pos": _atm._image_to_local(uv),
		"fall": _rng.randf_range(fall_min, fall_max), "sway": _rng.randf_range(10.0, 22.0),
		"sway_freq": _rng.randf_range(0.6, 1.3), "sway_phase": _rng.randf() * TAU,
		"rot": _rng.randf() * TAU, "spin": _rng.randf_range(-1.4, 1.4),
		"flip": _rng.randf() * TAU, "flip_speed": _rng.randf_range(1.1, 2.4),
		"size": _rng.randf_range(size_min, size_max), "age": 0.0,
		"life": _rng.randf_range(PETAL_LIFE.x, PETAL_LIFE.y),
		"color": colors[_rng.randi() % colors.size()],
	}


func _step_petals(list: Array[Dictionary], delta: float, fade_end_uv: float) -> void:
	var end_y: float = _atm._image_to_local(Vector2(0.0, fade_end_uv)).y
	for i in range(list.size() - 1, -1, -1):
		var p: Dictionary = list[i]
		p["age"] += delta
		p["pos"].y += float(p["fall"]) * _s * delta
		p["pos"].x += float(p["sway"]) * _s * cos(_time * float(p["sway_freq"]) + float(p["sway_phase"])) * delta
		p["rot"] += float(p["spin"]) * delta
		p["flip"] += float(p["flip_speed"]) * delta
		if p["age"] >= p["life"] or p["pos"].y >= end_y:
			list.remove_at(i)


# --- drawing --------------------------------------------------------

## The crescent rings behind the statues: a soft glow and a thin bright
## arc, brightening in a slow wave that runs from one statue to the next.
func _draw_halos() -> void:
	for i in HALOS.size():
		var h: Dictionary = HALOS[i]
		var w := _wave(float(i) * 0.9)
		var p := _pl(h["px"])
		var r: float = float(h["r"]) * _s
		var glow := Vector2.ONE * r * 4.0
		_halo_layer.draw_texture_rect(_glow_tex, Rect2(p - glow * 0.5, glow), false, Color(HALO_COLOR, 0.12 + 0.3 * w))
		# A crescent: an arc open at the top.
		_halo_layer.draw_arc(p, r, deg_to_rad(-60.0 + 180.0), deg_to_rad(240.0 + 180.0), 24, Color(HALO_COLOR, 0.25 + 0.6 * w), 2.0 + 2.0 * w, true)


func _draw_petals() -> void:
	_draw_petal_list(_violet, VIOLET_FADE_UV, 0.8)
	_draw_petal_list(_red, RED_FADE_UV, 0.85)


func _draw_petal_list(list: Array[Dictionary], fade_uv: Vector2, alpha: float) -> void:
	var fy := Vector2(
		_atm._image_to_local(Vector2(0.0, fade_uv.x)).y,
		_atm._image_to_local(Vector2(0.0, fade_uv.y)).y)
	for p in list:
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
			# A teardrop: fuller at one end, drawn to a point at the other.
			var v := Vector2(cos(a) * size, sin(a) * size * 0.55 * squash * (1.0 - 0.35 * cos(a)))
			pts.append(Vector2(p["pos"]) + v.rotated(rot))
		_petal_layer.draw_colored_polygon(pts, Color(Color(p["color"]), alpha * fade))
