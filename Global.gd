extends Node


var player_lives = 3
var current_scene : Node = null


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	# warning-ignore: RETURN_VALUE_DISCARDED
	current_scene.connect("leave_title", self, "load_next_scene")


func load_next_scene():
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://levels/level_test.tscn")
