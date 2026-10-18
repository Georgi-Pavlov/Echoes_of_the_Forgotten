class_name SfxSynth
extends RefCounted

## Procedural sound effects: every sound the game has by default is
## synthesized here from noise and sine sweeps - no audio files needed.
## AudioManager asks for them by event name (see EVENTS) and caches the
## result; a file dropped into res://assets/sounds/ named after an event
## replaces the generated one (see AudioManager.play_event()).

const RATE := 22050

## Every event this synthesizer knows, with the default volume (dB) its
## sound is played at.
const EVENTS := {
	"ui_click": -10.0,
	"button": -4.0,
	"typewriter_key": -8.0,
	"typewriter_back": -8.0,
	"hit": -6.0,
	"death": -4.0,
	"shotgun": -3.0,
	"double_trouble": 0.0,
	"explosion": -1.0,
	"blast_hopper_launch": -1.0,
	"land_thud": -6.0,
	"three_cheers_shot": -4.0,
	"creep_shoot": -6.0,
	"new_creep_shoot": -6.0,
	"bullet_impact": -8.0,
	"kiss": -4.0,
	"napalm_shot": -3.0,
	"napalm_impact": -2.0,
	"napalm_burn": -9.0,
	# Played from a file (assets/sounds/) - nothing is generated for these.
	"shop_transaction": -4.0,
	"chain": -3.0,
	"steps": -6.0,
	"Cinderbomb_explosion": -2.0,
	"vine_tentacle": -4.0,
	"fire_attack": -4.0,
	"raze_shoot": -2.0,
	"reload": -4.0,
	"kiss_the_wastes": -2.0,
	"melee_creep_roar": -2.0,
	"melee_creep_roar_2": -2.0,
	"bear_attack": -2.0,
	"bear_summon": -2.0,
}

static var _rng := RandomNumberGenerator.new()


## The generated sound for `event`, or null for an unknown name.
static func make(event: String) -> AudioStreamWAV:
	_rng.seed = hash(event)
	match event:
		"ui_click": return _ui_click()
		"typewriter_key": return _typewriter(1.0)
		"typewriter_back": return _typewriter(0.75)
		"hit": return _hit()
		"death": return _death()
		"shotgun": return _shotgun(0.5, 1.0)
		"double_trouble": return _double_trouble()
		"explosion": return _explosion(1.2, 1.0)
		"blast_hopper_launch": return _explosion(0.95, 0.85)
		"land_thud": return _land_thud()
		"three_cheers_shot": return _three_cheers_shot()
		"creep_shoot": return _rifle_shot()
		"bullet_impact": return _bullet_impact()
		"kiss": return _kiss()
		"napalm_shot": return _napalm_shot()
		"napalm_impact": return _explosion(1.0, 0.7, true)
		"napalm_burn": return _napalm_burn()
	return null


# --- building blocks ------------------------------------------------

static func _buffer(seconds: float) -> PackedFloat32Array:
	var buf := PackedFloat32Array()
	buf.resize(int(seconds * RATE))
	return buf


static func _noise() -> float:
	return _rng.randf() * 2.0 - 1.0


## Adds a sine sweep from `f0` to `f1` Hz over the whole of [start, start +
## length), shaped by an exponential decay `decay` (bigger = shorter).
static func _add_sweep(buf: PackedFloat32Array, start: float, length: float, f0: float, f1: float, decay: float, gain: float) -> void:
	var first := int(start * RATE)
	var count := int(length * RATE)
	var phase := 0.0
	for i in count:
		var idx := first + i
		if idx >= buf.size():
			break
		var t := float(i) / float(count)
		var f := lerpf(f0, f1, t)
		phase += TAU * f / float(RATE)
		buf[idx] += sin(phase) * exp(-decay * t * length) * gain


## Adds low-passed noise: `cutoff` is the one-pole coefficient (0..1, bigger
## = brighter); `cutoff_end` lets it darken (or brighten) over the burst.
static func _add_noise(buf: PackedFloat32Array, start: float, length: float, cutoff: float, cutoff_end: float, decay: float, gain: float, attack: float = 0.0) -> void:
	var first := int(start * RATE)
	var count := int(length * RATE)
	var state := 0.0
	for i in count:
		var idx := first + i
		if idx >= buf.size():
			break
		var t := float(i) / float(count)
		var a := lerpf(cutoff, cutoff_end, t)
		state += (_noise() - state) * a
		var env := exp(-decay * t * length)
		if attack > 0.0:
			env *= minf(1.0, float(i) / (attack * RATE))
		buf[idx] += state * env * gain


## Adds high-passed (crisp) noise - the leading "crack" of a gunshot.
static func _add_crack(buf: PackedFloat32Array, start: float, length: float, decay: float, gain: float) -> void:
	var first := int(start * RATE)
	var count := int(length * RATE)
	var low := 0.0
	for i in count:
		var idx := first + i
		if idx >= buf.size():
			break
		var n := _noise()
		low += (n - low) * 0.25
		buf[idx] += (n - low) * exp(-decay * float(i) / RATE) * gain


## Normalizes to `peak`, fades the last few ms so nothing clicks, and
## packs into a 16-bit mono stream.
static func _finish(buf: PackedFloat32Array, peak: float = 0.9) -> AudioStreamWAV:
	var top := 0.0001
	for s in buf:
		top = maxf(top, absf(s))
	var fade := int(0.01 * RATE)
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		var s: float = buf[i] / top * peak
		var left := buf.size() - i
		if left < fade:
			s *= float(left) / float(fade)
		# Soft clip so stacked layers stay punchy rather than harsh.
		s = tanh(s * 1.2) / tanh(1.2)
		bytes.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	return wav


# --- the sounds -----------------------------------------------------

static func _ui_click() -> AudioStreamWAV:
	var buf := _buffer(0.08)
	_add_sweep(buf, 0.0, 0.05, 1100.0, 700.0, 60.0, 0.6)
	_add_crack(buf, 0.0, 0.02, 120.0, 0.3)
	return _finish(buf, 0.7)


## A typewriter key: the sharp strike of the typebar on the platen (a hard
## crack over a short metallic ring) and the dull thunk of the key bottoming
## out just behind it. `pitch` lowers it for the backspace.
static func _typewriter(pitch: float) -> AudioStreamWAV:
	var buf := _buffer(0.11)
	_add_crack(buf, 0.0, 0.025, 150.0, 0.9)
	_add_sweep(buf, 0.0, 0.05, 2300.0 * pitch, 1500.0 * pitch, 70.0, 0.35)
	_add_sweep(buf, 0.002, 0.07, 3400.0 * pitch, 3000.0 * pitch, 90.0, 0.12)
	_add_noise(buf, 0.012, 0.05, 0.2, 0.05, 55.0, 0.55)
	_add_sweep(buf, 0.012, 0.05, 190.0 * pitch, 110.0 * pitch, 50.0, 0.5)
	return _finish(buf, 0.8)


static func _hit() -> AudioStreamWAV:
	var buf := _buffer(0.28)
	_add_sweep(buf, 0.0, 0.2, 170.0, 55.0, 22.0, 1.0)
	_add_noise(buf, 0.0, 0.12, 0.45, 0.08, 30.0, 0.7)
	_add_crack(buf, 0.0, 0.02, 160.0, 0.35)
	return _finish(buf)


static func _death() -> AudioStreamWAV:
	var buf := _buffer(0.85)
	_add_sweep(buf, 0.0, 0.7, 320.0, 38.0, 4.0, 0.9)
	_add_noise(buf, 0.0, 0.8, 0.5, 0.03, 5.0, 0.8)
	_add_sweep(buf, 0.0, 0.1, 900.0, 200.0, 40.0, 0.4)
	return _finish(buf)


## One shotgun blast: a hard crack, a body of mid noise, a low thump and a
## short tail. `weight` thickens it.
static func _shotgun(seconds: float, weight: float) -> AudioStreamWAV:
	var buf := _buffer(seconds)
	_shot_into(buf, 0.0, weight)
	return _finish(buf)


static func _shot_into(buf: PackedFloat32Array, at: float, weight: float) -> void:
	_add_crack(buf, at, 0.12, 40.0, 1.0)
	_add_noise(buf, at, 0.3, 0.55, 0.06, 11.0, 0.9 * weight)
	_add_sweep(buf, at, 0.25, 130.0 * weight, 42.0, 13.0, 1.1 * weight)
	_add_noise(buf, at + 0.03, 0.35, 0.12, 0.02, 6.0, 0.35 * weight)


## Both barrels - bigger, with the second a hair behind the first, a deep
## boom and a rolling tail. Deliberately much heavier than "shotgun".
static func _double_trouble() -> AudioStreamWAV:
	var buf := _buffer(1.3)
	_shot_into(buf, 0.0, 1.5)
	_shot_into(buf, 0.022, 1.5)
	_add_sweep(buf, 0.0, 0.7, 90.0, 28.0, 4.5, 1.6)
	_add_noise(buf, 0.04, 1.1, 0.1, 0.01, 3.2, 0.7)
	# A slap of echo off the walls.
	_add_noise(buf, 0.22, 0.4, 0.25, 0.03, 8.0, 0.25)
	return _finish(buf)


## A big explosion: a rising crackle into a deep whump and a long rumble.
## `fiery` adds a roaring burn on the tail (napalm).
static func _explosion(seconds: float, weight: float, fiery: bool = false) -> AudioStreamWAV:
	var buf := _buffer(seconds)
	_add_crack(buf, 0.0, 0.06, 60.0, 0.9 * weight)
	_add_noise(buf, 0.0, seconds * 0.8, 0.3, 0.015, 4.0, 1.0 * weight, 0.01)
	_add_sweep(buf, 0.0, seconds * 0.7, 85.0 * weight, 25.0, 3.5, 1.5 * weight)
	if fiery:
		_add_noise(buf, 0.08, seconds * 0.85, 0.5, 0.18, 2.4, 0.5, 0.15)
	return _finish(buf)


static func _land_thud() -> AudioStreamWAV:
	var buf := _buffer(0.35)
	_add_sweep(buf, 0.0, 0.25, 110.0, 40.0, 14.0, 1.2)
	_add_noise(buf, 0.0, 0.2, 0.2, 0.03, 16.0, 0.8)
	return _finish(buf)


## One sharp, fast rifle crack with a whip of a zip through the air.
static func _three_cheers_shot() -> AudioStreamWAV:
	var buf := _buffer(0.4)
	_add_crack(buf, 0.0, 0.08, 70.0, 1.2)
	_add_noise(buf, 0.0, 0.15, 0.6, 0.15, 24.0, 0.6)
	_add_sweep(buf, 0.0, 0.12, 2400.0, 380.0, 16.0, 0.35)
	_add_sweep(buf, 0.0, 0.16, 140.0, 60.0, 18.0, 0.7)
	return _finish(buf)


static func _bullet_impact() -> AudioStreamWAV:
	var buf := _buffer(0.22)
	_add_crack(buf, 0.0, 0.05, 90.0, 0.8)
	_add_sweep(buf, 0.0, 0.14, 210.0, 80.0, 24.0, 0.7)
	_add_noise(buf, 0.0, 0.1, 0.5, 0.1, 30.0, 0.5)
	return _finish(buf)


## The blown kiss: a soft breathy "mwah" then a handful of rising glassy
## chimes, each with a little vibrato.
static func _kiss() -> AudioStreamWAV:
	var buf := _buffer(1.1)
	_add_noise(buf, 0.0, 0.18, 0.35, 0.12, 14.0, 0.5, 0.03)
	_add_sweep(buf, 0.02, 0.12, 700.0, 420.0, 18.0, 0.35)
	var notes := [1318.5, 1568.0, 1760.0, 1975.5, 2349.3, 2637.0]
	for n in notes.size():
		var start: float = 0.16 + float(n) * 0.11
		var length := 0.5
		var first := int(start * RATE)
		var count := int(length * RATE)
		var phase := 0.0
		for i in count:
			var idx := first + i
			if idx >= buf.size():
				break
			var t := float(i) / float(RATE)
			phase += TAU * (float(notes[n]) + 6.0 * sin(t * 28.0)) / float(RATE)
			var env := exp(-7.0 * t) * minf(1.0, t / 0.004)
			buf[idx] += (sin(phase) + 0.25 * sin(phase * 2.0)) * env * 0.35
	return _finish(buf, 0.8)


## The incendiary shell leaving the gun: a thump and a rising whoosh.
static func _napalm_shot() -> AudioStreamWAV:
	var buf := _buffer(0.7)
	_add_crack(buf, 0.0, 0.06, 80.0, 0.8)
	_add_sweep(buf, 0.0, 0.2, 140.0, 50.0, 14.0, 1.1)
	# The whoosh: noise brightening as the shell flies away.
	_add_noise(buf, 0.05, 0.55, 0.05, 0.4, 3.2, 0.7, 0.12)
	return _finish(buf)


## Burning jelly: a bed of soft roar with random pops and crackles.
static func _napalm_burn() -> AudioStreamWAV:
	var seconds := 3.0
	var buf := _buffer(seconds)
	var state := 0.0
	for i in buf.size():
		var t := float(i) / float(RATE)
		var env := smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(seconds - 1.2, seconds, t))
		state += (_noise() - state) * 0.04
		buf[i] += state * 1.4 * env
	# Pops and crackles.
	var pops := 90
	for p in pops:
		var at := _rng.randf() * (seconds - 0.2)
		var env2 := smoothstep(0.0, 0.3, at) * (1.0 - smoothstep(seconds - 1.2, seconds, at))
		_add_crack(buf, at, 0.012 + _rng.randf() * 0.02, 160.0, (0.15 + _rng.randf() * 0.5) * env2)
	return _finish(buf, 0.7)


## A lone rifle shot: a flat hard crack with a short tail and a whip-zip.
static func _rifle_shot() -> AudioStreamWAV:
	var buf := _buffer(0.5)
	_add_crack(buf, 0.0, 0.1, 55.0, 1.2)
	_add_noise(buf, 0.0, 0.2, 0.4, 0.08, 14.0, 0.6)
	_add_sweep(buf, 0.0, 0.1, 1900.0, 520.0, 16.0, 0.3)
	_add_sweep(buf, 0.0, 0.2, 100.0, 45.0, 14.0, 0.5)
	# The flat echo of a shot across open ground.
	_add_noise(buf, 0.17, 0.3, 0.25, 0.04, 10.0, 0.18)
	return _finish(buf)


## Sounds that are an attack landing on something. A death sound waits for
## the latest of these to finish (see AudioManager.play_event_after_attacks()).
const ATTACK_EVENTS := [
	"shotgun", "double_trouble", "raze_shoot", "reload", "three_cheers_shot", "bullet_impact",
	"explosion", "kiss_the_wastes", "napalm_shot", "napalm_impact", "creep_shoot",
	"fire_attack", "chain", "vine_tentacle", "bear_attack", "Cinderbomb_explosion",
]
