extends IntroSceneFX

## Effects over the intro's sixth scene (the corruption taking hold): the
## storm clouds swirling into the rift, its red lightning crackling and
## striking, the eye glaring, narrowing and blinking, the red fleshy
## growths throbbing like a heartbeat, sickly mist creeping along the
## valley, waterfalls flowing, ash and embers drifting down, and the whole
## scene's light flashing with each strike. See IntroSceneFX.gd for how
## positions and areas are given.

const VORTEX_SHADER := preload("res://shaders/intro_vortex.gdshader")
const LIGHTNING_SHADER := preload("res://shaders/intro_lightning.gdshader")
const VEINS_SHADER := preload("res://shaders/intro_veins.gdshader")
const MIST_SHADER := preload("res://shaders/intro_mist.gdshader")
const WATERFALL_SHADER := preload("res://shaders/intro_waterfall.gdshader")

const EYE_POS := Vector2(0.7135, 0.0563)
const EYE_COLOR := Color(1.0, 0.25, 0.15)
const EYE_LID_COLOR := Color(0.1, 0.07, 0.07)
const BLINK_TIME := 0.45
const BLINK_GAP_MIN := 4.0
const BLINK_GAP_MAX := 8.0

## The storm swirling into the rift: centre and half-width/half-height.
const VORTEX_RADII := Vector2(0.21, 0.3)

## Where the lightning and glowing cracks are.
const LIGHTNING_AREA := Rect2(0.55, 0.0, 0.3, 0.45)
const STRIKE_GAP_MIN := 2.0
const STRIKE_GAP_MAX := 5.0
const STRIKE_LIGHT := Color(1.0, 0.7, 0.8)

## The land below the sky, where the growths are.
const VEINS_AREA := Rect2(0.0, 0.28, 1.0, 0.72)

## Banks of sickly mist: area, density, drift speed, edge fades.
const MISTS: Array[Dictionary] = [
	{"area": Rect2(0.38, 0.5, 0.62, 0.14), "density": 0.55, "speed": 0.025},
	{"area": Rect2(0.45, 0.62, 0.55, 0.16), "density": 0.6, "speed": 0.03},
	{"area": Rect2(0.0, 0.62, 0.45, 0.2), "density": 0.35, "speed": 0.02},
]
const MIST_COLOR := Color(0.72, 0.62, 0.78)

const WATERFALLS: Array[Rect2] = [
	Rect2(0.43, 0.53, 0.03, 0.07),
	Rect2(0.61, 0.575, 0.1, 0.03),
	Rect2(0.638, 0.625, 0.022, 0.07),
	Rect2(0.678, 0.62, 0.03, 0.08),
	Rect2(0.804, 0.675, 0.03, 0.06),
	Rect2(0.855, 0.685, 0.045, 0.075),
]

const ASH_COUNT := 60
const EMBER_COUNT := 25

var _eye_glow: TextureRect
var _eye_core: TextureRect
var _eye_lid: TextureRect
var _next_blink := 0.0
var _blink_t := -1.0
var _lightning: ShaderMaterial
var _strike := 0.0
var _next_strike := 0.0
var _light_add: ColorRect
var _light_dim: ColorRect
## Per flake: {pos, fall, sway, phase, size, ember}.
var _ash: Array = []
var _ash_layer: Control
var _ember_layer: Control
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func _ready() -> void:
	_rng.randomize()

	# The clouds swirl first; the lightning and growths then work on the
	# picture with them already moving.
	var vortex: ShaderMaterial = _add_shader_rect(
			Rect2(EYE_POS - VORTEX_RADII, VORTEX_RADII * 2.0), VORTEX_SHADER).material
	vortex.set_shader_parameter("center_px", EYE_POS * SIZE)
	vortex.set_shader_parameter("radii_px", VORTEX_RADII * SIZE)
	_recapture()
	_lightning = _add_shader_rect(LIGHTNING_AREA, LIGHTNING_SHADER).material
	var veins: ShaderMaterial = _add_shader_rect(VEINS_AREA, VEINS_SHADER).material
	veins.set_shader_parameter("source_px", EYE_POS * SIZE)
	for fall in WATERFALLS:
		_add_shader_rect(fall, WATERFALL_SHADER)
	for mist in MISTS:
		var rect := _add_shader_rect(mist["area"], MIST_SHADER)
		var mat: ShaderMaterial = rect.material
		mat.set_shader_parameter("fog_color", MIST_COLOR)
		mat.set_shader_parameter("density", mist["density"])
		mat.set_shader_parameter("speed", mist["speed"])
		mat.set_shader_parameter("aspect", rect.size.x / rect.size.y)
		mat.set_shader_parameter("band_center", 0.55)
		mat.set_shader_parameter("band_height", 0.55)
		mat.set_shader_parameter("edge_fade", Vector4(0.2, 0.3, 0.05, 0.3))

	_eye_glow = _add_glow(EYE_POS, 70.0, 0.6, EYE_COLOR)
	_eye_core = _add_glow(EYE_POS, 16.0, 0.8, Color(1.0, 0.8, 0.6))
	_eye_lid = _add_glow(EYE_POS, 30.0, 1.0, EYE_LID_COLOR, false)
	_next_blink = _rng.randf_range(2.0, BLINK_GAP_MAX)
	_next_strike = _rng.randf_range(0.8, STRIKE_GAP_MIN)

	for i in ASH_COUNT + EMBER_COUNT:
		_ash.append({
			"pos": Vector2(_rng.randf() * SIZE.x, _rng.randf() * SIZE.y),
			"fall": _rng.randf_range(12.0, 30.0),
			"sway": _rng.randf_range(8.0, 20.0),
			"phase": _rng.randf() * TAU,
			"size": _rng.randf_range(1.0, 2.4),
			"ember": i >= ASH_COUNT,
		})
	_ash_layer = _add_draw_layer(_draw_ash)
	_ember_layer = _add_draw_layer(_draw_embers, true)

	_light_dim = _add_full_rect(Color(1, 1, 1), CanvasItemMaterial.BLEND_MODE_MUL)
	_light_add = _add_full_rect(Color(STRIKE_LIGHT, 0.0), CanvasItemMaterial.BLEND_MODE_ADD)


func _process(delta: float) -> void:
	_time += delta
	_update_eye(delta)

	# Lightning: every few seconds a strike - a sharp flash that flickers
	# once more before dying away.
	if _time >= _next_strike:
		_strike = 1.0
		_next_strike = _time + _rng.randf_range(STRIKE_GAP_MIN, STRIKE_GAP_MAX)
	_strike = maxf(_strike - delta * 2.2, 0.0)
	var flash := _strike * (0.6 + 0.4 * absf(sin(_strike * 18.0)))
	_lightning.set_shader_parameter("strike", flash)

	# The scene's light: lit up by each strike, and between strikes a
	# brooding, slowly breathing gloom.
	var gloom := 0.92 + 0.04 * sin(_time * 0.7)
	var dim := minf(gloom + flash * 0.2, 1.0)
	_light_dim.color = Color(dim, dim, dim)
	_light_add.color = Color(STRIKE_LIGHT, 0.12 * flash)

	for flake in _ash:
		var sway: float = sin(_time * 0.9 + flake["phase"]) * flake["sway"]
		var p: Vector2 = flake["pos"] + Vector2(sway - 6.0, flake["fall"]) * delta
		# Embers float more than they fall.
		if flake["ember"]:
			p.y -= flake["fall"] * 0.6 * delta
		flake["pos"] = Vector2(fposmod(p.x, SIZE.x), fposmod(p.y, SIZE.y))

	_ash_layer.queue_redraw()
	_ember_layer.queue_redraw()


## The eye glares, its slit slowly narrowing and widening, and now and
## then it blinks shut.
func _update_eye(delta: float) -> void:
	var closed := 0.0
	if _blink_t >= 0.0:
		_blink_t += delta
		var t := _blink_t / BLINK_TIME
		if t >= 1.0:
			_blink_t = -1.0
			_next_blink = _time + _rng.randf_range(BLINK_GAP_MIN, BLINK_GAP_MAX)
		else:
			closed = sin(t * PI)
	elif _time >= _next_blink:
		_blink_t = 0.0

	var narrow := 0.5 + 0.5 * sin(_time * 0.6)
	var glare := 0.7 + 0.3 * sin(_time * 1.4)
	_eye_glow.modulate.a = glare * (1.0 - closed)
	_eye_glow.scale = Vector2(0.7 + 0.3 * narrow, 1.0)
	_eye_core.modulate.a = (0.6 + 0.4 * narrow) * (1.0 - closed)
	_eye_core.scale = Vector2(0.5 + 0.5 * narrow, 1.0)
	_eye_lid.modulate.a = maxf(closed, (1.0 - narrow) * 0.35)
	_eye_lid.scale = Vector2(1.0, 0.4 + 0.6 * closed)


func _draw_ash(layer: Control) -> void:
	for flake in _ash:
		if flake["ember"]:
			continue
		var size: float = flake["size"]
		var tilt := sin(_time * 1.5 + flake["phase"]) * 0.8
		var v := Vector2(size * 1.4, 0).rotated(tilt)
		layer.draw_line(flake["pos"] - v, flake["pos"] + v, Color(0.25, 0.22, 0.22, 0.75), size * 0.9)


func _draw_embers(layer: Control) -> void:
	for flake in _ash:
		if not flake["ember"]:
			continue
		var glow := 0.5 + 0.5 * sin(_time * 3.0 + flake["phase"])
		layer.draw_circle(flake["pos"], flake["size"] * 2.5, Color(1.0, 0.25, 0.1, 0.12 * glow))
		layer.draw_circle(flake["pos"], flake["size"] * 0.8, Color(1.0, 0.45, 0.2, 0.8 * glow))


func _add_full_rect(color: Color, blend: CanvasItemMaterial.BlendMode) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(PRESET_FULL_RECT)
	rect.color = color
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = blend
	rect.material = mat
	add_child(rect)
	return rect
