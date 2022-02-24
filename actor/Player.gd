class_name Player
extends Actor


func _process(_delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		set_facing(Facing.UP)
	elif event.is_action_pressed("ui_right"):
		set_facing(Facing.RIGHT)
	elif event.is_action_pressed("ui_down"):
		set_facing(Facing.DOWN)
	elif event.is_action_pressed("ui_left"):
		set_facing(Facing.LEFT)
