extends CanvasLayer


onready var pellet_count = get_tree().get_nodes_in_group("pellets").size()


func _input(event):
	if !event.is_action_pressed("ui_right"):
		get_tree().set_input_as_handled()


func _on_Pickup_collected(_pickup : Pickup, _type : String):
	pellet_count -= 1
	if pellet_count <= 0:
		yield(get_tree().create_timer(0.5), "timeout")
		Global.notify_event(Global.SCENE_CLEAR)
