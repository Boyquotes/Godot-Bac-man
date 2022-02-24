class_name Player
extends Actor


func _process(_delta):
	if age % 120 == 30:
		print("bac")
	elif age % 120 == 90:
		print("boc")


func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		facing = Facing.UP
	elif event.is_action_pressed("ui_right"):
		facing = Facing.RIGHT
	elif event.is_action_pressed("ui_down"):
		facing = Facing.DOWN
	elif event.is_action_pressed("ui_left"):
		facing = Facing.LEFT
