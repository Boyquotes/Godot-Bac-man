class_name Actor
extends Area2D


enum Facing { UP, RIGHT, LEFT, DOWN, NONE }


export var speed = 60


var age = 0
var facing = Facing.NONE setget set_facing
onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y


func _process(delta):
	var frame_speed = speed * delta
	match facing:
		Facing.UP:
			position.y -= frame_speed
		Facing.RIGHT:
			position.x += frame_speed
		Facing.DOWN:
			position.y += frame_speed
		Facing.LEFT:
			position.x -= frame_speed
		Facing.NONE:
			pass

	# Modulus is a little awkward because floats, and also less flexible
	if position.x >= screen_width:
		position.x -= screen_width
	elif position.x < 0:
		position.x += screen_width

	if position.y >= screen_height:
		position.y -= screen_height
	elif position.y < 0:
		position.y += screen_height


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
