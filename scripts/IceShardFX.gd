class_name IceShardFX
extends Node2D

## Purely cosmetic: Nhal's normal attack ("attack_effect": "ice_shard").
##
## A shard of ice hangs in the air behind him, above his shoulder, from
## the start of the fight - slowly bobbing and turning, glinting,
## shedding the odd frost mote - as a child of his sprite (drawn behind
## it), so it follows him and mirrors when he turns. When he attacks, it
## launches from where it hangs, turns toward the target and flies at it
## along a slight arc, trailing frost, and bursts into ice on impact. A
## new shard then crystallises in its place: motes of frost drawn
## together, the shard growing out of them, a glint as it completes.
##
## Damage is the caller's; `on_hit` (fire()) fires when the shard lands.

const NODE_NAME := "IceShard"

const REFORM_DELAY := 0.25
const REFORM_TIME := 0.5
const SPEED := 950.0                  # px/s
const FLIGHT_TIME := Vector2(0.14, 0.38)

const LIGHT := Color(0.7, 0.88, 1.0, 1.0)
const DARK := Color(0.12, 0.3, 0.78, 1.0)
const RIM := Color(0.9, 0.97, 1.0)
const GLOW := Color(0.45, 0.7, 1.0)
const FROST := Color(0.8, 0.93, 1.0)

var _caster: TextureRect
var _origin := Vector2(0.66, -0.02)
var _time := 0.0
var _form := 0.0          # 0 = gone, 1 = whole
var _reform_wait := 0.0
var _glint := 0.0
var _glow: Node2D
var _body: Node2D
var _motes: CPUParticles2D
var _gather: CPUParticles2D


## Hangs a shard beside `caster` at `origin` (fractions of its art, for
## when it faces right - mirrored when it faces left), forming it from
## nothing. Returns the existing one if it already has a shard.
static func attach(caster: TextureRect, origin: Vector2) -> IceShardFX:
	var existing := of(caster)
	if existing != null:
		return existing
	var fx := IceShardFX.new()
	fx.name = NODE_NAME
	fx._caster = caster
	fx._origin = origin
	caster.add_child(fx)
	fx._start_reform(0.1)
	return fx


static func of(caster: Variant) -> IceShardFX:
	if not is_instance_valid(caster) or not (caster is Node):
		return null
	return caster.get_node_or_null(NODE_NAME) as IceShardFX


func _ready() -> void:
	# Hangs behind him, not in front of his art.
	show_behind_parent = true
	_glow = Node2D.new()
	_glow.material = VoidReachFX._additive()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_body = Node2D.new()
	_body.draw.connect(_draw_body)
	add_child(_body)

	# The odd frost mote drifting down off it.
	_motes = _particles(8, 1.3)
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_motes.emission_sphere_radius = 6.0
	_motes.gravity = Vector2(0.0, 22.0)
	_motes.initial_velocity_min = 2.0
	_motes.initial_velocity_max = 8.0
	_motes.spread = 180.0
	_motes.local_coords = false
	add_child(_motes)

	# Frost drawn together into a new shard.
	_gather = _particles(18, 0.4)
	_gather.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	_gather.emission_sphere_radius = 26.0
	_gather.radial_accel_min = -420.0
	_gather.radial_accel_max = -300.0
	_gather.local_coords = true
	add_child(_gather)
	# attach() starts the first one forming before this node is ready.
	_gather.emitting = _form < 1.0


func _process(delta: float) -> void:
	_time += delta
	if not is_instance_valid(_caster):
		return
	var facing := -1.0 if _caster.flip_h else 1.0
	var o := _origin
	if facing < 0.0:
		o.x = 1.0 - o.x
	position = _caster.size * o + Vector2(0.0, sin(_time * 2.1) * 3.0)
	# Tip angled a little toward the way he faces, swaying gently.
	rotation = -facing * 0.35 + sin(_time * 1.3) * 0.08

	if _form < 1.0:
		if _reform_wait > 0.0:
			_reform_wait -= delta
		else:
			var was := _form
			_form = minf(_form + delta / REFORM_TIME, 1.0)
			if was < 1.0 and _form >= 1.0:
				_glint = 1.0
				_gather.emitting = false
	_glint = move_toward(_glint, 0.0, delta * 2.5)
	_motes.emitting = _form >= 1.0
	_glow.queue_redraw()
	_body.queue_redraw()


## The shard's length in px - about a seventh of its caster's height.
func _length() -> float:
	return maxf(_caster.size.y * 0.15, 14.0) if is_instance_valid(_caster) else 26.0


## Launches the shard at `to` (a global position) - from wherever it's
## hanging right now - under `fx_layer`, and starts a new one forming.
## `on_hit` fires when it lands.
func fire(fx_layer: Node, to: Vector2, on_hit: Callable) -> void:
	var from := global_position
	var scale_now: float = global_scale.x
	IceShardProjectile.launch(fx_layer, from, global_rotation, to, _length() * scale_now, on_hit)
	_form = 0.0
	_start_reform(REFORM_DELAY)


func _start_reform(delay: float) -> void:
	_reform_wait = delay
	if is_instance_valid(_gather):
		_gather.restart()
		_gather.emitting = true


func _draw_body() -> void:
	var s := _grown()
	if s <= 0.01:
		return
	draw_crystal(_body, Vector2.ZERO, 0.0, _length() * s, 1.0)


func _draw_glow() -> void:
	var s := _grown()
	if s <= 0.01:
		return
	var l := _length() * s
	var pulse := 0.8 + 0.2 * sin(_time * 3.0)
	_glow.draw_circle(Vector2.ZERO, l * 0.7, Color(GLOW, 0.07 * pulse))
	_glow.draw_circle(Vector2.ZERO, l * 0.35, Color(GLOW, 0.08 * pulse))
	# A glint running up it now and then, and a flash when a new one
	# completes.
	var run := fmod(_time * 0.45, 1.0)
	if run < 0.25:
		var y := lerpf(l, -l, run / 0.25)
		_glow.draw_circle(Vector2(0.0, y), l * 0.12, Color(RIM, 0.7))
	if _glint > 0.0:
		_glow.draw_circle(Vector2.ZERO, l * (0.3 + 0.6 * (1.0 - _glint)), Color(RIM, 0.35 * _glint))


## How grown the shard is (eased, with a slight overshoot as it snaps
## together).
func _grown() -> float:
	var t := _form
	if t <= 0.0:
		return 0.0
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)


## Draws one ice crystal on `canvas`: a long, irregular, faceted shard
## centred at `at`, turned `angle` (its tip along +y before turning),
## `length` from tip to tip. Translucent, shaded rather than outlined:
## each face is brightest along the central ridge and fades toward its
## edges, the lit face pale, the shadowed face deep blue, both thinning
## out at the tips, with a couple of faint inner facets and a streak of
## sheen catching the light.
static func draw_crystal(canvas: CanvasItem, at: Vector2, angle: float, length: float, alpha: float) -> void:
	var l := length * 0.5
	var w := l * 0.3
	var ridge := [Vector2(0.0, -l), Vector2(w * 0.05, -l * 0.4), Vector2(w * 0.1, l * 0.05),
			Vector2(w * 0.05, l * 0.5), Vector2(w * 0.08, l)]
	var lit := [Vector2(0.0, -l), Vector2(-w * 0.5, -l * 0.55), Vector2(-w, -l * 0.08),
			Vector2(-w * 0.72, l * 0.5), Vector2(w * 0.08, l)]
	var shade := [Vector2(0.0, -l), Vector2(w * 0.58, -l * 0.5), Vector2(w * 0.94, l * 0.02),
			Vector2(w * 0.66, l * 0.56), Vector2(w * 0.08, l)]
	var to := func(v: Vector2) -> Vector2: return at + v.rotated(angle)
	# Thinner, more see-through toward both tips.
	var tip_fade := [0.6, 0.95, 1.0, 0.95, 0.6]
	var faces := [
		[lit, Color(0.86, 0.95, 1.0, 0.97), Color(0.32, 0.58, 0.95, 0.85)],
		[shade, Color(0.3, 0.52, 0.95, 0.97), Color(0.05, 0.16, 0.5, 0.88)],
	]
	for face in faces:
		var outline: Array = face[0]
		var ridge_col: Color = face[1]
		var edge_col: Color = face[2]
		for i in 4:
			var pts := PackedVector2Array([to.call(ridge[i]), to.call(ridge[i + 1]), to.call(outline[i + 1]), to.call(outline[i])])
			var cols := PackedColorArray([
				Color(ridge_col, ridge_col.a * tip_fade[i] * alpha), Color(ridge_col, ridge_col.a * tip_fade[i + 1] * alpha),
				Color(edge_col, edge_col.a * tip_fade[i + 1] * alpha), Color(edge_col, edge_col.a * tip_fade[i] * alpha),
			])
			canvas.draw_polygon(pts, cols)
		# Soften the polygon's hard edge with a matching, faint, anti-
		# aliased edge (the face's own colour - not a border line).
		var soft := PackedVector2Array()
		for v in outline:
			soft.append(to.call(v))
		canvas.draw_polyline(soft, Color(edge_col, edge_col.a * 0.5 * alpha), 1.0, true)
	# Faint inner facets, and a streak of sheen on the lit face.
	canvas.draw_line(to.call(lit[2]), to.call(ridge[2]), Color(1, 1, 1, 0.18 * alpha), 1.0, true)
	canvas.draw_line(to.call(shade[3]), to.call(ridge[3]), Color(0.7, 0.85, 1.0, 0.15 * alpha), 1.0, true)
	canvas.draw_line(to.call(Vector2(-w * 0.3, -l * 0.6)), to.call(Vector2(-w * 0.45, -l * 0.05)), Color(1, 1, 1, 0.45 * alpha), maxf(length * 0.03, 1.0), true)


func _particles(amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.texture = VoidReachFX._dot()
	p.scale_amount_min = 0.35
	p.scale_amount_max = 0.7
	p.gravity = Vector2.ZERO
	p.material = VoidReachFX._additive()
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	ramp.colors = PackedColorArray([Color(FROST, 0.0), FROST, Color(GLOW, 0.0)])
	p.color_ramp = ramp
	return p
