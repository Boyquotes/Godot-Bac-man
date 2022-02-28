extends Node


const scene_order = [
	"TitleScreen",
	"levels/level_test",
]

var player_lives = 3
var score = 0
var current_scene : Node = null
var current_scene_index = 0

onready var root = get_tree().get_root()


func _ready():
	init_current_scene()


func load_next_scene():
	current_scene_index += 1
	assert(
			current_scene_index < scene_order.size(),
			"Fell off the end of scene_order"
	)
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://%s.tscn" % scene_order[current_scene_index])
	call_deferred("init_current_scene")


func init_current_scene():
	current_scene = root.get_child(root.get_child_count() - 1)
	# warning-ignore: RETURN_VALUE_DISCARDED
	current_scene.connect("scene_clear", self, "load_next_scene")
