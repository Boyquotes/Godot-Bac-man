extends CanvasLayer


signal leave_title


var pellet_count = 0


func _ready():
	pellet_count = get_tree().get_nodes_in_group("pellets").size()


func _input(event):
	if !event.is_action_pressed("ui_right"):
		get_tree().set_input_as_handled()


func decrement_pellet_count():
	pellet_count -= 1
	if pellet_count <= 0:
		emit_signal("leave_title")
