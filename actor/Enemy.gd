class_name Enemy
extends Actor


enum State {
	WAITING,
	IDLING,
	ROAMING,
	FLEEING,
	EATEN,
}


signal request_path (self_, target_position)


var nav_path : PoolVector2Array = []
var player : Player
var state = State.ROAMING setget set_state

onready var speed_roaming = speed
onready var home = position

export var speed_idling = 40
export var speed_fleeing = 40
export var speed_eaten = 100


func _process(_delta):
	if is_following_path():
		follow_path()
	else:
		match state:
			State.WAITING:
				pass
			State.IDLING:
				idle_around()
			_:
				assert(false, "invalid state not following_path: %d" % state)


func is_following_path():
	return (
			state == State.ROAMING
			or state == State.FLEEING
			or state == State.EATEN
	)


func follow_path():
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


func idle_around():
	if facing == Facing.NONE:
		for f in [Facing.LEFT, Facing.DOWN, Facing.RIGHT, Facing.UP]:
			if can_move_in(f):
				queue_facing(f)
				return
	else:
		if can_move_in(facing):
			return
		elif can_move_in(get_left_facing(facing)):
			queue_facing(get_left_facing(facing))
		elif can_move_in(get_right_facing(facing)):
			queue_facing(get_right_facing(facing))
		else:
			queue_facing(get_left_facing(get_left_facing(facing)))


func request_new_path():
	if not is_following_path():
		return

	var target := position
	match state:
		State.ROAMING:
			target = player.position
		State.FLEEING:
			target = Vector2(50, 50)
		State.EATEN:
			target = home
		_:
			assert(false, "invalid state for request_new_path: %d" % state)

	emit_signal("request_path", self, target)


func reset():
	set_state(State.WAITING)
	position = home
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
		State.IDLING:
			speed = speed_idling
			$IdlingTimer.start()
			$AnimatedSprite.play("walk")
		State.ROAMING:
			speed = speed_roaming
			$AnimatedSprite.play("walk")
		State.FLEEING:
			speed = speed_fleeing
			$AnimatedSprite.play("flee")
		State.EATEN:
			speed = speed_eaten
			$EatenSound.play()
			$AnimatedSprite.play("eaten")
		_:
			assert(false, "unhandled state change to %d" % state_)


func _on_player_spawned(player_):
	player = player_


func _on_player_powered_up():
	if state != State.EATEN:
		set_state(State.FLEEING)


func _on_player_powered_down():
	set_state(State.ROAMING)


func _on_IdlingTimer_timeout():
	if state == State.IDLING:
		set_state(State.ROAMING)
