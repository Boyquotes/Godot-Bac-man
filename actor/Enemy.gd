class_name Enemy
extends Actor


enum State {
	WAITING,
	ROAMING,
	FLEEING,
}


signal request_path (self_, target_position)


var nav_path : PoolVector2Array = []
var player : Player
var state = State.ROAMING setget set_state

onready var speed_roam = speed

export var speed_fleeing = 40


func _process(_delta):
	if nav_path.size() == 0:
		emit_signal("request_path", self, player.position)
		return

	var to_point_0 = nav_path[0] - position
	var facing_ = nearest_facing(to_point_0)

	if nav_path.size() <= 1:
		if to_point_0.length() < 16:
			emit_signal("request_path", self, player.position)
	else:
		if to_point_0.length() < 8:
			nav_path.remove(0)
		else:
			var to_point_1 = nav_path[1] - position
			var facing_1 = nearest_facing(to_point_1)
			if is_opposite_facing(facing_, facing_1):
				facing_ = facing_1
				nav_path.remove(0)

	queue_facing(facing_)


func reset():
	set_state(State.WAITING)
	.reset()


# Override so Enemies don't rotate like Player does
func turn_up():
	pass

func turn_down():
	pass


func set_state(state_):
	state = state_
	match state_:
		State.WAITING:
			speed = 0
			$AnimatedSprite.play("walk")
		State.ROAMING:
			speed = speed_roam
			$AnimatedSprite.play("walk")
		State.FLEEING:
			speed = speed_fleeing
			$AnimatedSprite.play("flee")


func _on_PathTimer_timeout():
	# TODO: We should request a path to where the player is about to go,
	# lest we get stuck when they're halfway between tiles
	emit_signal("request_path", self, player.position)


func _on_player_spawned(player_):
	player = player_


func _on_player_powered_up():
	set_state(State.FLEEING)


func _on_player_powered_down():
	set_state(State.ROAMING)
