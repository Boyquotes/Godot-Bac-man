class_name Player
extends Actor


func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		queue_facing(Facing.UP)
	elif event.is_action_pressed("ui_right"):
		queue_facing(Facing.RIGHT)
	elif event.is_action_pressed("ui_down"):
		queue_facing(Facing.DOWN)
	elif event.is_action_pressed("ui_left"):
		queue_facing(Facing.LEFT)
