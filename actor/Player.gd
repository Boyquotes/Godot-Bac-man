class_name Player
extends Actor


enum State {
	ROAM,
	DEATH,
}


# warning-ignore: UNUSED_SIGNAL
signal pickup_collected (type)
signal life_lost


var state = State.ROAM setget set_state


func _unhandled_input(event):
	if state != State.ROAM:
		return

	if event.is_action_pressed("ui_up"):
		queue_facing(Facing.UP)
	elif event.is_action_pressed("ui_right"):
		queue_facing(Facing.RIGHT)
	elif event.is_action_pressed("ui_down"):
		queue_facing(Facing.DOWN)
	elif event.is_action_pressed("ui_left"):
		queue_facing(Facing.LEFT)


func reset():
	set_state(State.ROAM)
	.reset()


func set_state(state_):
	state = state_
	match state_:
		State.ROAM:
			set_physics_process(true)
			$AnimatedSprite.play("walk")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", false)
		State.DEATH:
			set_physics_process(false)
			$AnimatedSprite.play("death")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", true)
			$DeathSound.play()
			yield($AnimatedSprite, "animation_finished")

			emit_signal("life_lost")


func _on_InteractionArea_area_entered(area : Area2D):
	if area.owner.is_in_group("enemies"):
		set_state(State.DEATH)
