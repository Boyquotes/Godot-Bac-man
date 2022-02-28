extends Node


var player_lives = 3
var current_scene : Node = null
onready var root = get_tree().get_root()


func _ready():
	init_current_scene()


func load_next_scene():
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://levels/level_test.tscn")
	init_current_scene()


func init_current_scene():
	current_scene = root.get_child(root.get_child_count() - 1)
	# warning-ignore: RETURN_VALUE_DISCARDED
	current_scene.connect("scene_clear", self, "load_next_scene")
