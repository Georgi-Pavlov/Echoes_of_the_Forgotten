extends Node

func _ready() -> void:
	var s: Script = load("res://scripts/TiltParallax.gd")
	print("COMPILE TiltParallax: ", "OK" if s != null and s.can_instantiate() else "FAILED")
	get_tree().quit()
