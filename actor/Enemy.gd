class_name Enemy
extends Actor


enum State {
	WAITING,
	ROAMING,
	FLEEING,
	EATEN,
}


signal request_path (self_, target_position)


var nav_path : PoolVector2Array = []
var player : Player
var state = State.ROAMING setget set_state

onready var speed_roam = speed

export var speed_fleeing = 40
export var speed_eaten = 100
export var home := Vector2(0, 0)


func _process(_delta):
	if nav_path.size() == 0:
		request_new_path()
		return

	var to_point_0 = nav_path[0] - position
	var facing_ = nearest_facing(to_point_0)

	if nav_path.size() <= 1:
		if to_point_0.length() < 16:
			request_new_path()
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


func request_new_path():
	var target := position
	match state:
		State.WAITING, State.ROAMING:
			target = player.position
		State.FLEEING:
			target = Vector2(50, 50)
		State.EATEN:
			target = home

	emit_signal("request_path", self, target)


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
	request_new_path()
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
		State.EATEN:
			speed = speed_eaten
			$EatenSound.play()
			$AnimatedSprite.play("eaten")


func _on_player_spawned(player_):
	player = player_


func _on_player_powered_up():
	set_state(State.FLEEING)


func _on_player_powered_down():
	set_state(State.ROAMING)
