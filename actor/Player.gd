class_name Player
extends Actor


enum State {
	WAITING,
	ROAMING,
	DYING,
	POWERUP,
}


signal life_lost ()
signal powered_down ()
signal powered_up ()


var state = State.ROAMING setget set_state
var combo := 0

onready var speed_roaming = speed
onready var home = position

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
	combo = 0
	position = home
	.reset()


func set_state(state_):
	state = state_
	# TODO: match state first, then state_, to undo previous changes separately
	match state_:
		State.WAITING:
			eats_ghosts = false
			speed = 0
			$PowerupTimer.stop()
			$AnimatedSprite.play("walk")
		State.ROAMING:
			eats_ghosts = false
			speed = speed_roaming
			$PowerupTimer.stop()
			$AnimatedSprite.play("walk")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", false)
		State.DYING:
			eats_ghosts = false
			speed = 0
			$PowerupTimer.stop()
			$AnimatedSprite.play("death")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", true)
			$DeathSound.play()
			yield($AnimatedSprite, "animation_finished")

			emit_signal("life_lost")
		State.POWERUP:
			eats_ghosts = true
			speed = speed_powerup
			$PowerupTimer.start()
			$AnimatedSprite.play("powerup")
			$InteractionArea/CollisionShape2D.set_deferred("disabled", false)
			emit_signal("powered_up")


func _on_InteractionArea_area_entered(area : Area2D):
	if area is Pickup:
		if area.pickup_type == "big_pellet":
			set_state(State.POWERUP)
	elif area.owner is Actor:
		if area.owner.hurts_player:
			set_state(State.DYING)


func _on_PowerupTimer_timeout():
	set_state(State.ROAMING)
	combo = 0
	emit_signal("powered_down")
