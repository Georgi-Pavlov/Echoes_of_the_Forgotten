extends Control
# ------------------------------------------------------------------
# DrownedEmpireBattleAtmosphere
# The Drowned Empire arena's battle-area effects. BattleAtmosphere creates
# one of these (and frees it with the rest of its children) for any zone
# fighting in that arena, then calls build(). Purely visual: never takes
# input, never touches game state. It sits under the fighters, and the
# painted battle UI panel at the bottom is left alone.
#
#   - shafts of light slant down from the surface over the palace,
#     swaying slowly
#   - the painted kelp bends in a slow current (strongest at the tips),
#     the two tattered banners ripple, and the painted sharks drift (see
#     drowned_empire_battle_background.gdshader)
#   - rippling light drifts across the stone floor, like sun through waves
#   - schools of fish sweep across the upper water
#   - bubbles rise from the floor and the ruins, wobbling and popping
#   - a thin silt haze rolls slowly along the ground, and fine marine snow
#     drifts down over everything
#
# Positions of art features are given in pixels of the 1536x1024 source
# image, so they stay on target whatever the screen size. Everything on or
# above the stone floor stays clear of the painted panel.
# ------------------------------------------------------------------

const BG_SHADER := preload("res://shaders/drowned_empire_battle_background.gdshader")
const SHAFTS_SHADER := preload("res://shaders/light_shafts.gdshader")
const FOG_SHADER := preload("res://shaders/fog_drift.gdshader")
const CAUSTICS_SHADER := preload("res://shaders/floor_caustics.gdshader")

# The painted UI panel starts below this (image UV y); nothing drifts below it.
const FLOOR_UV := 0.7

# Painted kelp: x, base y and height (source px), half-width of the strip,
# and how far the tip sways (px).
const KELP := [
	{"x": 545.0, "base": 410.0, "h": 300.0, "hw": 18.0, "amp": 5.0},
	{"x": 507.0, "base": 345.0, "h": 150.0, "hw": 14.0, "amp": 4.0},
	{"x": 643.0, "base": 415.0, "h": 140.0, "hw": 14.0, "amp": 4.0},
	{"x": 75.0, "base": 400.0, "h": 150.0, "hw": 16.0, "amp": 4.0},
	{"x": 20.0, "base": 425.0, "h": 100.0, "hw": 12.0, "amp": 3.0},
	{"x": 1227.0, "base": 285.0, "h": 100.0, "hw": 14.0, "amp": 3.5},
	{"x": 1418.0, "base": 265.0, "h": 110.0, "hw": 14.0, "amp": 3.5},
	{"x": 1503.0, "base": 350.0, "h": 210.0, "hw": 18.0, "amp": 5.0},
	{"x": 1015.0, "base": 300.0, "h": 100.0, "hw": 12.0, "amp": 3.5},
]
# The tattered banners: x, the y of the bar they hang from, length, half
# width, sway (px).
const BANNERS := [
	{"x": 325.0, "top": 335.0, "h": 175.0, "hw": 46.0, "amp": 6.0},
	{"x": 1365.0, "top": 310.0, "h": 200.0, "hw": 46.0, "amp": 6.0},
]
# The painted sharks: x, y, radius (px), drift (px).
const SHARKS := [
	{"x": 448.0, "y": 152.0, "r": 60.0, "amp": 7.0},
	{"x": 418.0, "y": 230.0, "r": 36.0, "amp": 5.0},
	{"x": 1215.0, "y": 88.0, "r": 50.0, "amp": 7.0},
	{"x": 1250.0, "y": 28.0, "r": 30.0, "amp": 5.0},
]

# Light from the surface (a rect in image UV, and where in its own UV the
# light comes from).
const SHAFTS_RECT_UV := Rect2(0.2, 0.0, 0.65, 0.7)
const SHAFTS_ORIGIN := Vector2(0.483, -0.1)
const SHAFT_COLOR := Color(0.5, 0.85, 1.0)

# Rippling light across the stone floor (image UV): the strip of floor the
# fighters stand on, above the painted panel.
const CAUSTICS_RECT_UV := Rect2(0.0, 0.54, 1.0, 0.17)
const CAUSTICS_COLOR := Color(0.55, 0.95, 1.0)

# Silt rolling along the ground (image UV).
const SILT_RECT_UV := Rect2(0.0, 0.4, 1.0, 0.28)
const SILT_COLOR := Color(0.55, 0.8, 0.8)

# Schools of fish: the water each swims in (image UV), how many, the speed
# (px/s), the size (px) and which way.
const SCHOOLS := [
	{"rect": Rect2(0.05, 0.08, 0.5, 0.14), "count": 8, "speed": 24.0, "size": 10.0, "dir": 1.0},
	{"rect": Rect2(0.5, 0.07, 0.45, 0.14), "count": 8, "speed": 20.0, "size": 9.0, "dir": -1.0},
]
const FISH_COLORS := [Color(0.5, 0.72, 0.8), Color(0.42, 0.62, 0.72), Color(0.7, 0.62, 0.42)]

# Bubbles rise from the ground and the ruins (image UV).
const BUBBLE_SPAWN_UV := Rect2(0.03, 0.46, 0.94, 0.14)
const BUBBLE_TOP_UV := 0.1
const BUBBLE_COUNT := 36

const SNOW_COUNT := 80

var _atm: Control
var _background: TextureRect
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _s := 1.0                # image scale (screen px per source px)
var _origin := Vector2.ZERO  # where the source image's top-left lands
var _tex_size := Vector2.ONE

var _dot_tex: Texture2D

var _fish_layer: Control
var _schools: Array[Dictionary] = []

var _bubble_layer: Control
var _bubbles: Array[Dictionary] = []
var _bubble_accum := 0.0

var _snow_layer: Control
var _snow: Array[Dictionary] = []


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

	# Kelp, banners and sharks moving, straight on the background texture.
	var cx := PackedFloat32Array()
	var cy := PackedFloat32Array()
	var w := PackedFloat32Array()
	var h := PackedFloat32Array()
	var kind := PackedFloat32Array()
	var phase := PackedFloat32Array()
	var amp := PackedFloat32Array()
	var speed := PackedFloat32Array()
	for k in KELP:
		cx.append(float(k["x"]) / _tex_size.x)
		cy.append(float(k["base"]) / _tex_size.y)
		w.append(float(k["hw"]) / _tex_size.x)
		h.append(float(k["h"]) / _tex_size.y)
		kind.append(0.0)
		phase.append(_rng.randf())
		amp.append(float(k["amp"]) / _tex_size.x)
		speed.append(_rng.randf_range(0.13, 0.2))
	for b in BANNERS:
		cx.append(float(b["x"]) / _tex_size.x)
		cy.append(float(b["top"]) / _tex_size.y)
		w.append(float(b["hw"]) / _tex_size.x)
		h.append(float(b["h"]) / _tex_size.y)
		kind.append(1.0)
		phase.append(_rng.randf())
		amp.append(float(b["amp"]) / _tex_size.x)
		speed.append(_rng.randf_range(0.2, 0.28))
	for sh in SHARKS:
		cx.append(float(sh["x"]) / _tex_size.x)
		cy.append(float(sh["y"]) / _tex_size.y)
		w.append(float(sh["r"]) / _tex_size.y)
		h.append(1.0)
		kind.append(2.0)
		phase.append(_rng.randf())
		amp.append(float(sh["amp"]) / _tex_size.x)
		speed.append(_rng.randf_range(0.07, 0.1))
	var mat := ShaderMaterial.new()
	mat.shader = BG_SHADER
	mat.set_shader_parameter("aspect", _tex_size.x / _tex_size.y)
	mat.set_shader_parameter("region_count", cx.size())
	mat.set_shader_parameter("region_cx", _padded(cx))
	mat.set_shader_parameter("region_cy", _padded(cy))
	mat.set_shader_parameter("region_w", _padded(w))
	mat.set_shader_parameter("region_h", _padded(h))
	mat.set_shader_parameter("region_kind", _padded(kind))
	mat.set_shader_parameter("region_phase", _padded(phase))
	mat.set_shader_parameter("region_amp", _padded(amp))
	mat.set_shader_parameter("region_speed", _padded(speed))
	_background.material = mat

	_dot_tex = _atm._radial(32,
		PackedFloat32Array([0.0, 0.25, 1.0]),
		PackedColorArray([Color(1, 1, 1, 1.0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)]))

	# Light from the surface, behind everything else.
	var sa: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.position)
	var sb: Vector2 = _atm._image_to_local(SHAFTS_RECT_UV.end)
	var shafts_mat := ShaderMaterial.new()
	shafts_mat.shader = SHAFTS_SHADER
	shafts_mat.set_shader_parameter("origin", SHAFTS_ORIGIN)
	shafts_mat.set_shader_parameter("shaft_color", SHAFT_COLOR)
	shafts_mat.set_shader_parameter("intensity", 0.18)
	shafts_mat.set_shader_parameter("spread", 0.75)
	shafts_mat.set_shader_parameter("reach", 1.4)
	shafts_mat.set_shader_parameter("sway", 0.05)
	shafts_mat.set_shader_parameter("aspect", (sb.x - sa.x) / (sb.y - sa.y))
	var shafts := ColorRect.new()
	shafts.material = shafts_mat
	shafts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shafts.position = sa
	shafts.size = sb - sa
	add_child(shafts)

	# Light rippling across the floor, under the fighters.
	var ca: Vector2 = _atm._image_to_local(CAUSTICS_RECT_UV.position)
	var cb: Vector2 = _atm._image_to_local(CAUSTICS_RECT_UV.end)
	var caustics_mat := ShaderMaterial.new()
	caustics_mat.shader = CAUSTICS_SHADER
	caustics_mat.set_shader_parameter("caustic_color", CAUSTICS_COLOR)
	caustics_mat.set_shader_parameter("aspect", (cb.x - ca.x) / (cb.y - ca.y))
	caustics_mat.set_shader_parameter("intensity", 0.55)
	var caustics := ColorRect.new()
	caustics.material = caustics_mat
	caustics.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caustics.position = ca
	caustics.size = cb - ca
	add_child(caustics)

	# Fish sweep across the upper water.
	_schools.clear()
	for s in SCHOOLS:
		var fish: Array[Dictionary] = []
		for i in int(s["count"]):
			fish.append({
				"off": Vector2(_rng.randf(), _rng.randf()),
				"phase": _rng.randf() * TAU, "wag": _rng.randf_range(5.0, 9.0),
				"color": FISH_COLORS[_rng.randi() % FISH_COLORS.size()],
				"scale": _rng.randf_range(0.8, 1.2),
			})
		_schools.append({"def": s, "fish": fish, "pos": _rng.randf()})
	_fish_layer = _new_layer(false)
	_fish_layer.draw.connect(_draw_fish)

	# A thin silt haze along the ground.
	_add_fog(SILT_RECT_UV, {
		"density": 0.2, "speed": 0.02, "scale": 3.2,
		"band_center": 0.6, "band_height": 0.6,
		"fog_color": SILT_COLOR,
		"edge_fade": Vector4(0.02, 0.4, 0.02, 0.45),
	})

	# Bubbles and marine snow, over everything.
	_bubbles.clear()
	_bubble_layer = _new_layer(false)
	_bubble_layer.draw.connect(_draw_bubbles)
	for i in 240:
		_update_bubbles(1.0 / 30.0)
	_snow.clear()
	for i in SNOW_COUNT:
		_snow.append(_new_snow(true))
	_snow_layer = _new_layer(true)
	_snow_layer.draw.connect(_draw_snow)

	set_process(true)


# --- helpers --------------------------------------------------------

func _padded(values: PackedFloat32Array) -> PackedFloat32Array:
	var out := values.duplicate()
	while out.size() < 24:
		out.append(0.0)
	return out


## Source-image pixels -> this node's local coordinates.
func _pl(p: Vector2) -> Vector2:
	return _origin + p * _s


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


# --- per frame ------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	_update_schools(delta)
	_update_bubbles(delta)
	_update_snow(delta)
	_fish_layer.queue_redraw()
	_bubble_layer.queue_redraw()
	_snow_layer.queue_redraw()


func _update_schools(delta: float) -> void:
	for sc in _schools:
		var def: Dictionary = sc["def"]
		var rect: Rect2 = def["rect"]
		var width: float = rect.size.x * _tex_size.x
		sc["pos"] = fposmod(float(sc["pos"]) + float(def["dir"]) * float(def["speed"]) * delta / width, 1.0)


func _new_snow(anywhere: bool) -> Dictionary:
	return {
		"uv": Vector2(_rng.randf(), (_rng.randf() * FLOOR_UV) if anywhere else -0.02),
		"fall": _rng.randf_range(5.0, 14.0), "sway": _rng.randf_range(4.0, 12.0),
		"sway_freq": _rng.randf_range(0.2, 0.6), "phase": _rng.randf() * TAU,
		"size": _rng.randf_range(0.8, 2.0), "alpha": _rng.randf_range(0.18, 0.4),
	}


func _update_snow(delta: float) -> void:
	for i in _snow.size():
		var p: Dictionary = _snow[i]
		var uv: Vector2 = p["uv"]
		uv.y += float(p["fall"]) * delta / _tex_size.y
		uv.x += sin(_time * float(p["sway_freq"]) + float(p["phase"])) * float(p["sway"]) * delta / _tex_size.x
		p["uv"] = uv
		if uv.y > FLOOR_UV:
			_snow[i] = _new_snow(false)


func _update_bubbles(delta: float) -> void:
	_bubble_accum += delta * 2.6
	while _bubble_accum >= 1.0 and _bubbles.size() < BUBBLE_COUNT:
		_bubble_accum -= 1.0
		var uv := BUBBLE_SPAWN_UV.position + Vector2(_rng.randf(), _rng.randf()) * BUBBLE_SPAWN_UV.size
		_bubbles.append({
			"px": uv * _tex_size, "rise": _rng.randf_range(24.0, 52.0),
			"size": _rng.randf_range(2.0, 6.0), "phase": _rng.randf() * TAU,
			"wobble": _rng.randf_range(4.0, 12.0), "age": 0.0,
			"top": _rng.randf_range(BUBBLE_TOP_UV, 0.35) * _tex_size.y, "pop": -1.0,
		})
	_bubble_accum = minf(_bubble_accum, 1.0)
	for i in range(_bubbles.size() - 1, -1, -1):
		var b: Dictionary = _bubbles[i]
		b["age"] += delta
		if float(b["pop"]) >= 0.0:
			b["pop"] += delta
			if b["pop"] > 0.18:
				_bubbles.remove_at(i)
			continue
		var p: Vector2 = b["px"]
		p.y -= float(b["rise"]) * delta
		b["px"] = p
		if p.y <= float(b["top"]):
			b["pop"] = 0.0


# --- drawing --------------------------------------------------------

func _draw_fish() -> void:
	for sc in _schools:
		var def: Dictionary = sc["def"]
		var rect: Rect2 = def["rect"]
		var dir: float = def["dir"]
		var size: float = float(def["size"])
		for f in sc["fish"]:
			var off: Vector2 = f["off"]
			# Spread along the school's own length, trailing the leader.
			var u := fposmod(float(sc["pos"]) + off.x * 0.3 * -dir, 1.0)
			var x := (rect.position.x + u * rect.size.x) * _tex_size.x
			var y := (rect.position.y + off.y * rect.size.y) * _tex_size.y + sin(_time * 1.3 + float(f["phase"])) * 6.0
			# Fade in and out at the region's edges.
			var edge := smoothstep(0.0, 0.1, u) * (1.0 - smoothstep(0.9, 1.0, u))
			var c: Color = f["color"]
			var length := size * _s * float(f["scale"])
			var p := _pl(Vector2(x, y))
			var wag := sin(_time * float(f["wag"]) + float(f["phase"])) * 0.25 * length
			var head := p + Vector2(dir * length * 0.5, 0.0)
			var tail := p - Vector2(dir * length * 0.5, 0.0)
			# A slim body and a forked tail.
			_fish_layer.draw_colored_polygon(PackedVector2Array([
				head, p + Vector2(0.0, -length * 0.2), tail + Vector2(0.0, wag * 0.3),
				p + Vector2(0.0, length * 0.2)]), Color(c, 0.55 * edge))
			_fish_layer.draw_colored_polygon(PackedVector2Array([
				tail, tail - Vector2(dir * length * 0.35, -length * 0.25 + wag), tail - Vector2(dir * length * 0.35, length * 0.25 + wag)]), Color(c, 0.5 * edge))


func _draw_bubbles() -> void:
	for b in _bubbles:
		var p: Vector2 = b["px"]
		var pos := _pl(Vector2(p.x + sin(_time * 1.6 + float(b["phase"])) * float(b["wobble"]), p.y))
		var r: float = float(b["size"]) * _s
		var a := minf(float(b["age"]) / 0.5, 1.0)
		if float(b["pop"]) >= 0.0:
			var f := float(b["pop"]) / 0.18
			r *= 1.0 + 0.7 * f
			a *= 1.0 - f
		_bubble_layer.draw_arc(pos, r, 0.0, TAU, 14, Color(0.7, 0.9, 1.0, 0.5 * a), 1.2, true)
		_bubble_layer.draw_circle(pos + Vector2(-r * 0.35, -r * 0.35), maxf(r * 0.22, 0.6), Color(1, 1, 1, 0.7 * a))


func _draw_snow() -> void:
	for p in _snow:
		var uv: Vector2 = p["uv"]
		var pos := _pl(uv * _tex_size)
		var d := Vector2.ONE * float(p["size"]) * 3.0 * _s
		_snow_layer.draw_texture_rect(_dot_tex, Rect2(pos - d * 0.5, d), false, Color(0.75, 0.9, 1.0, float(p["alpha"])))
