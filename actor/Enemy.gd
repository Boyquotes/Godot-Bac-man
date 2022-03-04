class_name Enemy
extends Actor


enum State {
	WAITING,
	IDLING,
	ROAMING,
	FLEEING,
	EATEN,
}


signal request_path (self_, target_position, avoid_player)


var nav_path : PoolVector2Array = []
var player : Player
var home_area : Area2D
var maze_bounds : Rect2
var state = State.ROAMING setget set_state

onready var speed_roaming = speed
onready var home = position # TODO: home_area.position?
onready var AI = roam_ai.new()

export var speed_idling = 40
export var speed_fleeing = 40
export var speed_eaten = 100
export var roam_ai : Script


func _process(_delta):
	match state:
		State.WAITING:
			pass
		State.IDLING:
			idle_around()
		State.ROAMING:
			follow_path()
		State.FLEEING:
			follow_path()
		State.EATEN:
			follow_path()
		_:
			assert(false, "unhandled state in _process: %d" % state)


func is_at_home():
	return $InteractionArea.overlaps_area(home_area)


# Breaking up the level into a 3x3 grid, checks if the given position
# lies within the * sections:
# *0*
# 000
# *0*
func is_in_corner(pos : Vector2) -> bool:
	var corner = nearest_corner(pos)
	return (
			abs(pos.x - corner.x) <= maze_bounds.size.x / 3
			and abs(pos.y - corner.y) <= maze_bounds.size.y / 3
	)


func nearest_corner(pos : Vector2) -> Vector2:
	var ret = Vector2(maze_bounds.position)

	if abs(pos.x - maze_bounds.end.x) <= abs(pos.x - maze_bounds.position.x):
		ret.x = maze_bounds.end.x

	if abs(pos.y - maze_bounds.end.y) <= abs(pos.y - maze_bounds.position.y):
		ret.y = maze_bounds.end.y

	return ret


func opposite_corner(pos : Vector2) -> Vector2:
	return nearest_corner(maze_bounds.end + maze_bounds.position - pos)


func follow_path():
	if nav_path.size() == 0:
		request_new_path()
		idle_around()
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
	var target := position
	var avoid_player := false
	match state:
		State.WAITING, State.IDLING:
			return
		State.ROAMING:
			target = AI.pick_target(self)
		State.FLEEING:
			avoid_player = true
			if is_in_corner(player.position):
				target = opposite_corner(player.position)
			else:
				target = nearest_corner(position)
		State.EATEN:
			target = home
		_:
			assert(false, "invalid state for request_new_path: %d" % state)

	emit_signal("request_path", self, target, avoid_player)


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


func _on_enemy_home_ready(home_area_):
	home_area = home_area_


func _on_maze_ready(maze_bounds_ : Rect2):
	maze_bounds = maze_bounds_


func _on_player_powered_up():
	if not is_at_home() and state != State.EATEN:
		set_state(State.FLEEING)


func _on_player_powered_down():
	if not is_at_home() and state != State.EATEN:
		set_state(State.ROAMING)


func _on_IdlingTimer_timeout():
	if state == State.IDLING:
		set_state(State.ROAMING)


func _on_InteractionArea_area_entered(area : Area2D):
	if area == home_area and state == State.EATEN:
		set_state(State.IDLING)
