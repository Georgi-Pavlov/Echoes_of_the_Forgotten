class_name ShadowDripFX
extends Node2D

## Purely cosmetic: Nightshroud's Hollowing Presence - shadow seeping out
## of an afflicted enemy and oozing down it like living darkness, for as
## long as the debuff lasts.
##
## Fine threads of shadow: each one pays out of the body, a tiny teardrop
## swelling at its end, then lets go and falls, trailing a thin thread that
## thins away.
##
## It is a child of the enemy's battle sprite, so it moves, flips and
## disappears with it. It watches the enemy's own state: once
## enemy["hollowing_damage_reduction_pct"] is cleared (the skill ran out) or
## the enemy is dead, it stops making new strands, lets the last ones fade
## and removes itself.

const SHADOW := Color(0.02, 0.0, 0.05)
## New strands per second, and how long one lasts from welling up to gone.
const DRIP_RATE := 3.2
const DRIP_LIFE := 2.0
## Share of a drip's life spent paying out of the body before it lets go.
const HANG := 0.45
const MAX_DRIPS := 12

var _enemy: Dictionary
var _sprite: Control
var _soft: GradientTexture2D
var _drips: Array[Dictionary] = []
var _spawn_acc := 0.0
var _ending := false


## Starts the dripping on `enemy`'s sprite, unless it already has it.
static func attach(enemy: Dictionary, sprite: Control) -> void:
	if not is_instance_valid(sprite):
		return
	# Recast while the last strands are still fading: just pick it back up.
	var existing: Variant = sprite.get_meta("shadow_drip_fx", null)
	if is_instance_valid(existing):
		existing._ending = false
		return
	var fx := ShadowDripFX.new()
	fx._enemy = enemy
	fx._sprite = sprite
	sprite.set_meta("shadow_drip_fx", fx)
	sprite.add_child(fx)


func _ready() -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
	_soft = GradientTexture2D.new()
	_soft.gradient = g
	_soft.fill = GradientTexture2D.FILL_RADIAL
	_soft.fill_from = Vector2(0.5, 0.5)
	_soft.fill_to = Vector2(1.0, 0.5)
	_soft.width = 64
	_soft.height = 64
	z_index = 1


func _exit_tree() -> void:
	if is_instance_valid(_sprite) and _sprite.get_meta("shadow_drip_fx", null) == self:
		_sprite.remove_meta("shadow_drip_fx")


func _active() -> bool:
	return float(_enemy.get("hollowing_damage_reduction_pct", 0.0)) > 0.0 \
		and int(_enemy.get("current_hp", 1)) > 0


func _process(delta: float) -> void:
	if not is_instance_valid(_sprite):
		queue_free()
		return
	if not _active():
		_ending = true

	if not _ending and _drips.size() < MAX_DRIPS:
		_spawn_acc += delta * DRIP_RATE
		while _spawn_acc >= 1.0:
			_spawn_acc -= 1.0
			_drips.append({
				# Where it wells up: across the body, from shoulders to waist.
				"x": randf_range(0.2, 0.8),
				"y": randf_range(0.15, 0.55),
				"age": 0.0,
				"size": randf_range(0.8, 1.3),
				"phase": randf() * TAU,
			})

	for d in _drips:
		d["age"] += delta
	_drips = _drips.filter(func(d: Dictionary) -> bool: return d["age"] < DRIP_LIFE)
	if _ending and _drips.is_empty():
		queue_free()
		return
	queue_redraw()


func _puff(pos: Vector2, size: float, alpha: float) -> void:
	draw_texture_rect(_soft, Rect2(pos - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(SHADOW, alpha))


func _draw() -> void:
	if not is_instance_valid(_sprite):
		return
	var box := _sprite.size
	var unit := clampf(box.x * 0.028, 2.0, 5.0)
	var t := Time.get_ticks_msec() / 1000.0

	# A faint pall of shadow clinging to the body while the curse holds.
	if not _ending:
		for i in 3:
			var at := Vector2(box.x * (0.3 + 0.2 * i), box.y * (0.35 + 0.1 * sin(t * 0.9 + i)))
			_puff(at, box.x * 0.55, 0.12)

	for d in _drips:
		var life: float = d["age"] / DRIP_LIFE
		var anchor := Vector2(box.x * d["x"], box.y * d["y"])
		var r: float = unit * d["size"]
		var sway: float = sin(t * 2.0 + d["phase"]) * r * 0.5
		if life < HANG:
			# A thin thread paying out of the body, slowly lengthening, a
			# tiny teardrop swelling at its end.
			var k: float = life / HANG
			var length: float = box.y * 0.22 * k
			var bead := anchor + Vector2(sway * k, length)
			draw_line(anchor, bead, Color(SHADOW, 0.9), r * 0.55, true)
			_stringy_bead(bead, r * (0.5 + 0.4 * k), 1.6 + 1.2 * k, 0.95)
		else:
			# Let go: the bead falls, trailing a long fine thread that thins
			# and fades behind it.
			var k: float = (life - HANG) / (1.0 - HANG)
			var a: float = 1.0 - k * k
			var top: float = box.y * 0.22 + box.y * 0.5 * k * k
			var bead := anchor + Vector2(sway, top)
			var thread_start := anchor + Vector2(sway * 0.3, box.y * 0.22 * (1.0 - k) + top * k * 0.4)
			draw_line(thread_start, bead, Color(SHADOW, 0.75 * a), r * 0.4, true)
			_stringy_bead(bead, r * 0.9, 2.2 + 1.5 * k, 0.95 * a)
			# What it leaves hanging from the body shrinks back up.
			if k < 0.6:
				var stub := anchor + Vector2(0.0, box.y * 0.22 * (1.0 - k / 0.6) * 0.5)
				draw_line(anchor, stub, Color(SHADOW, 0.7 * (1.0 - k / 0.6)), r * 0.4, true)


## A narrow teardrop, `stretch` times taller than wide, point up.
func _stringy_bead(at: Vector2, radius: float, stretch: float, alpha: float) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, stretch))
	draw_circle(Vector2.ZERO, radius, Color(SHADOW, alpha))
	draw_set_transform(Vector2.ZERO)
