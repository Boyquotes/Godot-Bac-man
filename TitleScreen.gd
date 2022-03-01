extends CanvasLayer


onready var pellet_count = get_tree().get_nodes_in_group("pellets").size()


func _input(event):
	if !event.is_action_pressed("ui_right"):
		get_tree().set_input_as_handled()


func _on_Player_pickup_collected(_type):
	pellet_count -= 1
	if pellet_count <= 0:
		Global.load_next_scene()
