class_name TiltParallax
extends Node

## A sense of depth from tilting the phone: the scene's art layers drift a
## little against the tilt while the UI stays put, as if looking through
## the screen into the world behind it - the further back a layer, the more
## it drifts (its `depth`, 1 = the art itself).
##
## On a phone it follows the gravity sensor, measured against however the
## phone is being held: the "level" position slowly re-centres to the
## current grip, so only fresh movement shows, never a permanent lean. With
## no sensor (a PC), the mouse plays the same part - moving it toward an
## edge looks that way. Every layer is enlarged about the screen's centre
## by the same small amount, so a drifting edge never comes into view and
## layers drawn to line up with each other (art and its effects) still do.
##
## Each frame it adds only its own change in offset to a layer's position,
## so it never fights anything else that moves a layer; stop() takes back
## exactly what it added (e.g. before a scene's own animation takes over).
##
## Use: TiltParallax.attach(self, [[$Background, 1.0], [$MenuAtmosphere, 0.8]])

const MAX_SHIFT := 12.0          # px a depth-1 layer drifts at full tilt
const TILT_FULL := 2.6           # m/s² change in gravity counted as full tilt (about 15 degrees)
const RECENTER_RATE := 0.35      # how fast "level" follows a new grip, per second
const SMOOTHING := 6.0           # how quickly the drift follows the tilt
# Flip these if, on a device, the layers drift the wrong way.
const INVERT_X := false
const INVERT_Y := false

var _layers: Array = []          # {node, depth, applied: Vector2, base_scale: Vector2}
var _overscan := 1.0
var _neutral := Vector3.ZERO
var _has_neutral := false
var _tilt := Vector2.ZERO


## Adds a parallax to `host` driving `layers` - each an [node, depth] pair.
static func attach(host: Node, layers: Array) -> TiltParallax:
	var parallax := TiltParallax.new()
	parallax.name = "TiltParallax"
	host.add_child(parallax)
	for layer in layers:
		parallax.add_layer(layer[0], float(layer[1]))
	return parallax


func _ready() -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size
	_overscan = 1.0 + 2.2 * MAX_SHIFT / maxf(minf(screen.x, screen.y), 1.0)


## Joins `node` (a Control directly under the screen-filling scene root)
## to the parallax at `depth`. `offset_included`: its position was copied
## from a layer that's already drifted, so the current drift is in it.
func add_layer(node: Variant, depth: float, offset_included: bool = false) -> void:
	if not (node is Control) or not is_instance_valid(node):
		return
	var control: Control = node
	var centre: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var base_scale: Vector2 = control.scale
	control.pivot_offset = centre - control.position
	control.scale = base_scale * _overscan
	var target := _offset_for(depth)
	var applied := target if offset_included else Vector2.ZERO
	control.position += target - applied
	_layers.append({"node": control, "depth": depth, "applied": target, "base_scale": base_scale})


## Eases every layer back to where (and how big) it was over `duration`
## seconds, then stop()s - for handing a layer to the scene's own animation
## without a jump. Await it.
func release(duration: float = 0.25) -> void:
	set_process(false)
	var from_tilt := _tilt
	var tween := create_tween()
	tween.tween_method(func(k: float) -> void:
		_tilt = from_tilt * (1.0 - k)
		for layer in _layers:
			var node: Control = layer["node"]
			if not is_instance_valid(node):
				continue
			var target := _offset_for(float(layer["depth"]))
			node.position += target - layer["applied"]
			layer["applied"] = target
			node.scale = layer["base_scale"] * lerpf(_overscan, 1.0, k)
	, 0.0, 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	stop()


## Takes back everything it added - offsets and enlargement - and frees
## itself.
func stop() -> void:
	for layer in _layers:
		var node: Control = layer["node"]
		if is_instance_valid(node):
			node.position -= layer["applied"]
			node.scale = layer["base_scale"]
	_layers.clear()
	set_process(false)
	queue_free()


func _process(delta: float) -> void:
	_tilt = _tilt.lerp(_read_tilt(delta), 1.0 - exp(-delta * SMOOTHING))
	for layer in _layers:
		var node: Control = layer["node"]
		if not is_instance_valid(node):
			continue
		var target := _offset_for(float(layer["depth"]))
		node.position += target - layer["applied"]
		layer["applied"] = target


func _offset_for(depth: float) -> Vector2:
	return -_tilt * MAX_SHIFT * depth


## The current tilt, -1..1 on each axis.
func _read_tilt(delta: float) -> Vector2:
	var g: Vector3 = Input.get_gravity()
	if g.length_squared() > 1.0:
		if not _has_neutral:
			_neutral = g
			_has_neutral = true
		_neutral = _neutral.lerp(g, 1.0 - exp(-delta * RECENTER_RATE))
		var d: Vector3 = g - _neutral
		var x: float = clampf(d.x / TILT_FULL, -1.0, 1.0)
		var y: float = clampf(-d.y / TILT_FULL, -1.0, 1.0)
		return Vector2(-x if INVERT_X else x, -y if INVERT_Y else y)
	# No sensor: on a PC the mouse stands in for the tilt.
	if OS.has_feature("mobile"):
		return Vector2.ZERO
	var viewport := get_viewport()
	var half: Vector2 = viewport.get_visible_rect().size * 0.5
	if half.x <= 0.0 or half.y <= 0.0:
		return Vector2.ZERO
	return ((viewport.get_mouse_position() - half) / half).clamp(-Vector2.ONE, Vector2.ONE)
