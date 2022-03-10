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
signal get_eaten ()


var nav_path : PoolVector2Array = []
var player : Player
var home_area : Area2D
var state = State.ROAMING setget set_state

onready var speed_roaming = speed
onready var home = position # TODO: home_area.position?
onready var AI = roam_ai.new()

export var speed_idling = 40
export var speed_fleeing = 40
export var speed_eaten = 100
export var roam_ai : Script
export var sprite_colour : Color = Color.red


func _ready():
	$AnimatedSprite.material.set_shader_param("swap_colour", sprite_colour)


func _process(_delta):
	match state:
		State.WAITING:
			pass
		State.IDLING:
			idle_around()
		State.ROAMING:
			AI.roam(self)
		State.FLEEING:
			flee(player.position)
		State.EATEN:
			follow_path()
		_:
			assert(false, "unhandled Enemy state: %d" % state)


func is_following_path():
	return (
			state == State.ROAMING
			or state == State.EATEN
	)


func is_at_home():
	return $InteractionArea.overlaps_area(home_area)


func follow_path():
	# Hacky length condition to properly cross WarpZones (1/2)
	if nav_path.size() == 0 or (nav_path[0] - position).length() > 64:
		request_new_path()
		return

	var to_point_0 = nav_path[0] - position
	var facing_ = nearest_facing(to_point_0) # TODO: what if (0,0)?

	if nav_path.size() <= 1:
		if to_point_0.length() < 16:
			request_new_path()
	else:
		if to_point_0.length() < 8:
			nav_path.remove(0)
		else:
			var to_point_1 = nav_path[1] - position
			var facing_1 = nearest_facing(to_point_1)
			# Hacky length condition to properly cross WarpZones (2/2)
			if to_point_1.length() < 32 and is_opposite_facing(facing_, facing_1):
				facing_ = facing_1
				nav_path.remove(0)

	queue_facing(facing_)


func idle_around():
	if facing == Facing.NONE:
		queue_facing(Facing.LEFT)
	elif not can_move_in(facing):
		queue_facing(get_left_facing(get_left_facing(facing)))


func move_randomly():
	if facing == Facing.NONE:
		for f in [Facing.LEFT, Facing.DOWN, Facing.RIGHT, Facing.UP]:
			if can_move_in(f):
				queue_facing(f)
				return
	else:
		if can_move_in(facing):
			var ljunc = can_move_in(get_left_facing(facing))
			var rjunc = can_move_in(get_right_facing(facing))
			var r = randf()
			if ljunc and rjunc:
				if r < 0.33:
					queue_facing(get_left_facing(facing))
				elif r < 0.66:
					queue_facing(get_right_facing(facing))
			elif ljunc and r < 0.5:
				queue_facing(get_left_facing(facing))
			elif rjunc and r < 0.5:
				queue_facing(get_right_facing(facing))
			return
		elif can_move_in(get_left_facing(facing)) and can_move_in(get_right_facing(facing)):
			if randf() < 0.5:
				queue_facing(get_left_facing(facing))
			else:
				queue_facing(get_right_facing(facing))
		elif can_move_in(get_left_facing(facing)):
			queue_facing(get_left_facing(facing))
		elif can_move_in(get_right_facing(facing)):
			queue_facing(get_right_facing(facing))
		else:
			queue_facing(get_left_facing(get_left_facing(facing)))


func flee(pos : Vector2):
	var away_from = nearest_facing(position - pos)
	if is_opposite_facing(facing, away_from):
		if can_move_in(away_from):
			queue_facing(away_from)
		elif can_move_in(get_left_facing(away_from)):
			queue_facing(get_left_facing(away_from))
		elif can_move_in(get_right_facing(away_from)):
			queue_facing(get_right_facing(away_from))
		else:
			pass
	else:
		move_randomly()


func request_new_path():
	if not is_following_path():
		return

	var target := position
	match state:
		State.ROAMING:
			target = AI.pick_target(self)
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
			hurts_player = false
			speed = 0
			$AnimatedSprite.play("walk")
		State.IDLING:
			hurts_player = true
			speed = speed_idling
			$IdlingTimer.start()
			$AnimatedSprite.play("walk")
		State.ROAMING:
			hurts_player = true
			speed = speed_roaming
			$AnimatedSprite.play("walk")
		State.FLEEING:
			hurts_player = false
			speed = speed_fleeing
			$AnimatedSprite.play("flee")
		State.EATEN:
			hurts_player = false
			speed = speed_eaten
			$EatenSound.play()
			$AnimatedSprite.play("eaten")
			emit_signal("get_eaten")
		_:
			assert(false, "unhandled state change to %d" % state_)


func _on_player_powered_up():
	if not is_at_home():
		match state:
			State.IDLING, State.ROAMING:
				set_state(State.FLEEING)
			_:
				pass


func _on_player_powered_down():
	if not is_at_home():
		match state:
			State.FLEEING:
				set_state(State.ROAMING)
			_:
				pass


func _on_IdlingTimer_timeout():
	if state == State.IDLING:
		set_state(State.ROAMING)


func _on_InteractionArea_area_entered(area : Area2D):
	if area == home_area:
		set_state(State.IDLING)
	elif area.owner is Actor:
		if state == State.FLEEING and area.owner.eats_ghosts:
			set_state(State.EATEN)
