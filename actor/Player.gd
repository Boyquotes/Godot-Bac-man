class_name Player
extends Actor


enum State {
	WAITING,
	ROAMING,
	DYING,
	POWERUP,
}


# warning-ignore: UNUSED_SIGNAL
signal pickup_collected (type)
signal life_lost
signal powerup_timedout
signal entered_enemy (enemy)


var state = State.ROAMING setget set_state

onready var speed_roaming = speed

export var speed_powerup = 80


func _unhandled_input(event):
	if state == State.WAITING:
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
	set_state(State.WAITING)
	.reset()


func set_state(state_):
	state = state_
	# TODO: match state first, then state_, to undo previous changes separately
	match state_:
		State.WAITING:
			speed = 0
			$PowerupTimer.stop()
			$AnimatedSprite.play("walk")
		State.ROAMING:
			speed = speed_roaming
			$PowerupTimer.stop()
			$AnimatedSprite.play("walk")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", false)
		State.DYING:
			speed = 0
			$PowerupTimer.stop()
			$AnimatedSprite.play("death")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", true)
			$DeathSound.play()
			yield($AnimatedSprite, "animation_finished")

			emit_signal("life_lost")
		State.POWERUP:
			speed = speed_powerup
			$PowerupTimer.start()
			$AnimatedSprite.play("powerup")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", false)


func _on_InteractionArea_area_entered(area : Area2D):
	if not area.owner.is_in_group("enemies"):
		return

	match state:
		State.WAITING, State.DYING:
			pass
		State.ROAMING:
			set_state(State.DYING)
		State.POWERUP:
			emit_signal("entered_enemy", area.owner)


func _on_PowerupTimer_timeout():
	set_state(State.ROAMING)
	emit_signal("powerup_timedout")
