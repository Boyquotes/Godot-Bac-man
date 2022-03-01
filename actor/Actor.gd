class_name Actor
extends KinematicBody2D


enum Facing { UP, RIGHT, LEFT, DOWN, NONE }

const unit_vectors = {
	Facing.UP: Vector2.UP,
	Facing.RIGHT: Vector2.RIGHT,
	Facing.LEFT: Vector2.LEFT,
	Facing.DOWN: Vector2.DOWN,
	Facing.NONE: Vector2.ZERO,
}


export var speed = 60

var facing = Facing.NONE setget set_facing
var queued_facing = Facing.NONE setget queue_facing
var movement_epsilon = 1

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var space_state = get_world_2d().direct_space_state


func _physics_process(delta):
	var frame_speed = speed * delta
	var velocity = frame_speed * unit_vectors[queued_facing]

	if facing != queued_facing:
		var collision = move_and_collide(velocity, true, true, true) # test_only true
		if collision and collision.travel.length() <= movement_epsilon:
			# We're flush against a wall; check if we can turn soon
			# TODO: un-hardcode the 8s
			var corner = position + 8 * unit_vectors[facing] + 8 * unit_vectors[queued_facing]
			# collision_layer: walls only
			var ray_result = space_state.intersect_ray(corner, corner + velocity, [], 1)
			if ray_result:
				# We're nowhere near a turn - flush the queued turn
				queue_facing(facing)
			velocity = frame_speed * unit_vectors[facing]
		else:
			# We can turn to the queued_facing
			set_facing(queued_facing)

	# warning-ignore: RETURN_VALUE_DISCARDED
	move_and_collide(velocity)

	# Modulus is a little awkward because floats, and also less flexible
	if position.x >= screen_width:
		position.x -= screen_width
	elif position.x < 0:
		position.x += screen_width

	if position.y >= screen_height:
		position.y -= screen_height
	elif position.y < 0:
		position.y += screen_height


func reset():
	set_facing(Facing.NONE)
	queue_facing(Facing.NONE)


func set_facing(facing_):
	match facing_:
		Facing.UP:
			$AnimatedSprite.play()
			turn_up()
		Facing.RIGHT:
			$AnimatedSprite.play()
			turn_right()
		Facing.DOWN:
			$AnimatedSprite.play()
			turn_down()
		Facing.LEFT:
			$AnimatedSprite.play()
			turn_left()
		Facing.NONE:
			$AnimatedSprite.stop()
			turn_right()

	facing = facing_


func queue_facing(facing_):
	queued_facing = facing_


func turn_left():
	$AnimatedSprite.rotation = 0
	$AnimatedSprite.flip_h = true


func turn_right():
	$AnimatedSprite.rotation = 0
	$AnimatedSprite.flip_h = false


func turn_up():
	$AnimatedSprite.rotation = -PI/2
	$AnimatedSprite.flip_h = false


func turn_down():
	$AnimatedSprite.rotation = PI/2
	$AnimatedSprite.flip_h = false


func nearest_facing(vec: Vector2):
	if abs(vec.x) >= abs(vec.y):
		if vec.x >= 0:
			return Facing.RIGHT
		else:
			return Facing.LEFT
	else:
		if vec.y >= 0:
			return Facing.DOWN
		else:
			return Facing.UP


func is_opposite_facing(f1, f2):
	return (
		(f1 == Facing.DOWN and f2 == Facing.UP)
		or (f1 == Facing.UP and f2 == Facing.DOWN)
		or (f1 == Facing.LEFT and f2 == Facing.RIGHT)
		or (f1 == Facing.RIGHT and f2 == Facing.LEFT)
	)
