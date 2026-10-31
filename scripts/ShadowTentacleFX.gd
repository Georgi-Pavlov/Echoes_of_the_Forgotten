class_name ShadowTentacleFX
extends Node2D

## Purely cosmetic: Nightshroud's Sleepless Curse - the halo of his normal
## attack hangs over the victim's head for as long as the curse lasts, and
## shadow tentacles lower from it, coil down around the body and hold it
## fast.
##
## It is a child of the victim's battle sprite, so it moves, flips and
## disappears with it. It watches the victim's own state: once
## enemy["sleepless_curse_turns_left"] runs out (or is broken by damage) or
## the victim dies, the tentacles unwind, the halo thins away and it removes
## itself.

const SHADOW := Color(0.02, 0.0, 0.05)
const SHEEN := Color(0.5, 0.3, 0.85)
const TENTACLES := 3
const SEGMENTS := 34
## Seconds to drop the halo and for the tentacles to coil down, and to let go.
const INTRO_TIME := 0.7
const OUTRO_TIME := 0.55
## Smoke puffs circling in the halo.
const PUFFS := 12

var _enemy: Dictionary
var _sprite: Control
var _soft: GradientTexture2D
var _age := 0.0
var _outro := -1.0
var _phases: Array[float] = []
var _puff_seeds: Array[float] = []


## Starts the curse visuals on `enemy`'s sprite (or revives them if the last
## ones are still unwinding).
static func attach(enemy: Dictionary, sprite: Control) -> void:
	if not is_instance_valid(sprite):
		return
	var existing: Variant = sprite.get_meta("sleepless_curse_fx", null)
	if is_instance_valid(existing):
		existing._outro = -1.0
		return
	var fx := ShadowTentacleFX.new()
	fx._enemy = enemy
	fx._sprite = sprite
	sprite.set_meta("sleepless_curse_fx", fx)
	sprite.add_child(fx)


func _ready() -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.4), Color(1, 1, 1, 0)])
	_soft = GradientTexture2D.new()
	_soft.gradient = g
	_soft.fill = GradientTexture2D.FILL_RADIAL
	_soft.fill_from = Vector2(0.5, 0.5)
	_soft.fill_to = Vector2(1.0, 0.5)
	_soft.width = 64
	_soft.height = 64
	for i in TENTACLES:
		_phases.append(TAU * float(i) / TENTACLES + randf() * 0.5)
	for i in PUFFS:
		_puff_seeds.append(randf() * TAU)
	z_index = 1


func _exit_tree() -> void:
	if is_instance_valid(_sprite) and _sprite.get_meta("sleepless_curse_fx", null) == self:
		_sprite.remove_meta("sleepless_curse_fx")


func _active() -> bool:
	return int(_enemy.get("sleepless_curse_turns_left", 0)) > 0 \
		and int(_enemy.get("current_hp", 1)) > 0


func _process(delta: float) -> void:
	if not is_instance_valid(_sprite):
		queue_free()
		return
	_age += delta
	if _active():
		_outro = -1.0
	elif _outro < 0.0:
		_outro = 0.0
	else:
		_outro += delta
		if _outro >= OUTRO_TIME:
			queue_free()
			return
	queue_redraw()


## 0..1 how far the curse has taken hold (halo dropped, tentacles coiled).
func _grip() -> float:
	var k := clampf(_age / INTRO_TIME, 0.0, 1.0)
	k = k * k * (3.0 - 2.0 * k)
	if _outro >= 0.0:
		k = minf(k, 1.0 - _outro / OUTRO_TIME)
	return k


func _puff(pos: Vector2, size: float, alpha: float) -> void:
	draw_texture_rect(_soft, Rect2(pos - Vector2.ONE * size * 0.5, Vector2.ONE * size), false, Color(SHADOW, alpha))


func _draw() -> void:
	if not is_instance_valid(_sprite):
		return
	var box := _sprite.size
	var t := Time.get_ticks_msec() / 1000.0
	var grip := _grip()
	var width := clampf(box.x * 0.45, 80.0, 170.0)
	# The halo drops in from above and settles over the head.
	var drop := (1.0 - minf(_age / (INTRO_TIME * 0.5), 1.0)) * width * 0.7
	var center := Vector2(box.x * 0.5, box.y * 0.02 - width * 0.12 - drop)
	var tilt := 0.32
	var halo_a := minf(_age / (INTRO_TIME * 0.5), 1.0) * (1.0 if _outro < 0.0 else 1.0 - _outro / OUTRO_TIME)

	# --- the halo: a soft base arc of darkness with smoke circling it ---
	draw_set_transform(center, 0.0, Vector2(1.0, tilt))
	draw_arc(Vector2.ZERO, width * 0.5, 0.0, TAU, 48, Color(SHEEN, 0.08 * halo_a), width * 0.3, true)
	draw_arc(Vector2.ZERO, width * 0.5, 0.0, TAU, 48, Color(SHADOW, 0.4 * halo_a), width * 0.3, true)
	draw_set_transform(Vector2.ZERO)
	for i in PUFFS:
		var seed_a: float = _puff_seeds[i]
		var ang: float = seed_a + t * (0.8 if i % 2 == 0 else -0.6)
		var flicker := 0.75 + 0.25 * sin(t * 8.0 + seed_a)
		var pos := center + Vector2(cos(ang) * width * 0.5, sin(ang) * width * 0.5 * tilt)
		_puff(pos, width * 0.4 * (0.9 + 0.2 * flicker), 0.6 * halo_a * flicker)

	# --- the tentacles: from the halo, coiling down around the body ---
	if grip <= 0.0:
		return
	var top_y := center.y + width * 0.05
	var bottom_y := box.y * 0.92
	var half_w := box.x * 0.36
	for i in TENTACLES:
		var phase: float = _phases[i]
		var turns := 1.8 + 0.3 * i
		var prev := Vector2.ZERO
		var prev_front := true
		for s in SEGMENTS + 1:
			var f := float(s) / SEGMENTS
			if f > grip:
				break
			# Starts on the halo's rim, then winds round the body.
			var wind := phase + f * turns * TAU + t * 0.7 + sin(t * 1.3 + i) * 0.3
			var spread := minf(f * 3.0, 1.0)
			var rim_x := cos(phase) * width * 0.5 * (1.0 - spread)
			var x := box.x * 0.5 + rim_x + sin(wind) * half_w * spread * (1.0 - 0.25 * f)
			var y := lerpf(top_y, bottom_y, f) + sin(t * 2.0 + f * 5.0 + i) * 2.0
			var pt := Vector2(x, y)
			var front := cos(wind) >= 0.0 or spread < 1.0
			if s > 0:
				var thick := lerpf(box.x * 0.022, box.x * 0.006, f)
				thick = clampf(thick, 1.2, 5.0)
				var a := 0.95 if front else 0.55
				a *= (1.0 if _outro < 0.0 else 1.0 - _outro / OUTRO_TIME)
				draw_line(prev, pt, Color(SHADOW, a), thick, true)
				if front and prev_front:
					draw_line(prev + Vector2(-thick * 0.2, 0.0), pt + Vector2(-thick * 0.2, 0.0), Color(SHEEN, 0.28 * a), maxf(thick * 0.25, 1.0), true)
				# A faint smoky haze round the thread, so it reads as shadow, not rope.
				if s % 3 == 0:
					_puff(pt, thick * 5.0, 0.18 * a)
			prev = pt
			prev_front = front
