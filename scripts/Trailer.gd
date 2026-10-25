extends Node

## Trailer capture: plays the first two intro scenes, dream scenes 2-4 and the
## whole first choice back to back, then the closing screenshots (TrailerEnd),
## so the run can be recorded in one go:
##   Godot --path . --write-movie trailer.avi --fixed-fps 30 \
##       res://scenes/Trailer.tscn -- --dream-scene=2
## TrailerEnd quits the game when it ends, which stops the recording.

const INTRO_SCENES := 2
const DREAM_NEXT := "res://scenes/the_first_choice.tscn"
const CHOICE_NEXT := "res://scenes/TrailerEnd.tscn"


func _ready() -> void:
	# The Skip buttons have no place in a trailer.
	get_tree().node_added.connect(func(node: Node) -> void:
		if node is Button and (node as Button).text == "Skip":
			(node as Button).visible = false)

	load("res://scripts/the_first_choice.gd").set("_next_scene", CHOICE_NEXT)
	var intro_script: GDScript = load("res://scripts/Intro.gd")
	intro_script.set("trailer_last", INTRO_SCENES)
	intro_script.set("trailer_after", func() -> void:
		HeroPickDream.play(HeroPickDream.DEFAULT_FOLDER, DREAM_NEXT))
	# Built by hand so the test settings saved in Intro.tscn can be overridden.
	var intro: Control = load("res://scenes/Intro.tscn").instantiate()
	intro.start_scene = 1
	intro.loop_scene = false
	get_tree().root.add_child.call_deferred(intro)
	get_tree().set_deferred("current_scene", intro)
