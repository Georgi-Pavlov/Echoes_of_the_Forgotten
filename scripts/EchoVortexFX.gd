class_name EchoVortexFX
extends Control

## The Echo vortex on the Map: once the player holds enough Echoes
## (GameManager.get_echoes_required()), a great crimson whirlpool tears open
## over the compass, between the Shop and World Status plaques. Its spiral
## arms coil into a black heart (echo_vortex.gdshader), a red glow breathes
## around it and sparks are dragged in along its arms. Hovering it makes it
## spin faster and burn brighter; clicking it emits `pressed`.
##
## Coordinates are designed for the 1280x720 viewport and scaled from there,
## same as CompassFX. Only the round vortex itself takes the mouse - the
## square around it lets clicks through (see _has_point()).

signal pressed

const DESIGN_SIZE := Vector2(1280, 720)
const CENTRE := Vector2(128, 175)        # the compass centre - see CompassFX.CENTRE
const RADIUS := 96.0                     # design px
const OPEN_TIME := 1.6
const SPARK_COUNT := 46
# How fast it turns - a slow, heavy churn - and how much faster while hovered.
const SPIN_SPEED := 0.3
const HOVER_SPIN_BOOST := 1.5

const VORTEX_SHADER := preload("res://shaders/echo_vortex.gdshader")
const GLOW_COLOR := Color(0.7, 0.04, 0.03)
const SPARK_COLORS := [Color(0.85, 0.25, 0.12), Color(0.95, 0.5, 0.25), Color(0.7, 0.06, 0.05)]

var _radius := RADIUS                    # screen px
var _time := 0.0
var _phase := 0.0                        # how far the vortex has turned (see echo_vortex.gdshader)
var _opening := 0.0
var _hover := 0.0                        # 0..1, eased
var _hovered := false
var _vortex: ColorRect
var _vortex_mat: ShaderMaterial
var _glow: TextureRect
var _sparks: Control
# Each spark: [angle, radius 0..1 of the vortex, angular speed, size, color index]
var _spark_state: Array = []


## Adds the vortex to `host` (the Map) and lets it tear open. `animate`
## false shows it fully open at once.
static func open(host: Control, animate: bool = true) -> EchoVortexFX:
	var fx := EchoVortexFX.new()
	fx._opening = 0.0 if animate else 1.0
	host.add_child(fx)
	return fx


func _ready() -> void:
	var screen := get_viewport_rect().size
	var k: float = screen.y / DESIGN_SIZE.y
	_radius = RADIUS * k
	var centre := CENTRE * Vector2(screen.x / DESIGN_SIZE.x, screen.y / DESIGN_SIZE.y)
	size = Vector2.ONE * _radius * 2.0
	position = centre - size * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func() -> void: _hovered = true)
	mouse_exited.connect(func() -> void: _hovered = false)

	# The red glow breathing around it, spilling well past its edge.
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(GLOW_COLOR, 0.4), Color(GLOW_COLOR, 0.15), Color(GLOW_COLOR, 0.0)])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	_glow = TextureRect.new()
	_glow.texture = tex
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glow.size = size * 1.9
	_glow.position = (size - _glow.size) * 0.5
	_glow.material = VoidReachFX._additive()
	add_child(_glow)

	_vortex_mat = ShaderMaterial.new()
	_vortex_mat.shader = VORTEX_SHADER
	_vortex = ColorRect.new()
	_vortex.material = _vortex_mat
	_vortex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vortex.size = size
	add_child(_vortex)

	_sparks = Control.new()
	_sparks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sparks.size = size
	_sparks.material = VoidReachFX._additive()
	_sparks.draw.connect(_draw_sparks)
	add_child(_sparks)
	for i in SPARK_COUNT:
		_spark_state.append(_new_spark(randf_range(0.15, 1.15)))

	_apply(0.0)


## Only the round vortex takes the mouse, not the corners of its square.
func _has_point(point: Vector2) -> bool:
	return point.distance_to(size * 0.5) <= _radius * _opening


func _gui_input(event: InputEvent) -> void:
	if _opening < 0.9:
		return
	var clicked: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed)
	if clicked:
		accept_event()
		pressed.emit()


func _process(delta: float) -> void:
	_hover = move_toward(_hover, 1.0 if _hovered else 0.0, delta * 3.0)
	_time += delta * (1.0 + _hover * 1.5)
	# Advanced here rather than scaling TIME in the shader, so hovering
	# speeds the turn up smoothly instead of jumping the arms ahead.
	_phase += delta * SPIN_SPEED * (1.0 + _hover * HOVER_SPIN_BOOST)
	if _opening < 1.0:
		_opening = minf(1.0, _opening + delta / OPEN_TIME)
	_apply(delta)


func _apply(delta: float) -> void:
	# Eased open: bursts out, then settles.
	var o := 1.0 - pow(1.0 - _opening, 3.0)
	_vortex_mat.set_shader_parameter("opening", o)
	_vortex_mat.set_shader_parameter("phase", _phase)
	_vortex_mat.set_shader_parameter("intensity", 1.0 + _hover * 0.45)
	var pulse := 0.5 + 0.5 * sin(_time * 1.6)
	_glow.modulate.a = o * (0.55 + 0.3 * pulse + 0.35 * _hover)
	_glow.scale = Vector2.ONE * (0.92 + 0.08 * pulse) * o
	_glow.pivot_offset = _glow.size * 0.5

	# Sparks spiral inward, faster the deeper they fall, and are reborn at
	# the rim once swallowed.
	for i in _spark_state.size():
		var s: Array = _spark_state[i]
		var depth: float = 1.0 - clampf(s[1], 0.0, 1.0)
		var drift: float = delta * SPIN_SPEED * (1.0 + _hover * HOVER_SPIN_BOOST)
		s[0] += drift * s[2] * (1.0 + depth * 3.0)
		s[1] -= drift * (0.18 + depth * 0.5)
		if s[1] <= 0.06:
			_spark_state[i] = _new_spark(randf_range(1.0, 1.2))
	_sparks.modulate.a = o
	_sparks.queue_redraw()


func _new_spark(r: float) -> Array:
	return [randf() * TAU, r, randf_range(1.2, 2.4), randf_range(1.2, 2.8), randi() % SPARK_COLORS.size()]


func _draw_sparks() -> void:
	var c := size * 0.5
	for s in _spark_state:
		var r: float = s[1] * _radius
		var p := c + Vector2.from_angle(s[0]) * r
		# A short streak trailing back along its path.
		var tail := c + Vector2.from_angle(s[0] - 0.22) * (r + 4.0)
		var fade: float = clampf(s[1] * 1.6, 0.0, 1.0) * clampf((1.2 - s[1]) * 4.0, 0.0, 1.0)
		var col: Color = SPARK_COLORS[s[4]]
		_sparks.draw_line(tail, p, Color(col, 0.7 * fade), s[3], true)
		_sparks.draw_circle(p, s[3] * 0.6, Color(col, fade))
