extends Node


const scene_order = [
	"TitleScreen",
	"levels/level_test",
	"GameOver",
]

var player_lives = 3
var score = 0
var current_scene_index = 0

onready var root = get_tree().get_root()


func load_next_scene():
	current_scene_index += 1
	assert(
			current_scene_index < scene_order.size(),
			"Fell off the end of scene_order"
	)
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://%s.tscn" % scene_order[current_scene_index])


func end_game():
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://GameOver.tscn")
	call_deferred("init_current_scene")


func reset_game():
	current_scene_index = -1
	load_next_scene()
