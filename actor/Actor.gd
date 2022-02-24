class_name Actor
extends Area2D


enum Facing { UP, RIGHT, LEFT, DOWN, NONE }


export var speed = 60


var age = 0
var facing = Facing.NONE setget set_facing


func _ready():
	$AnimatedSprite.play("default")


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


func set_facing(facing_):
	match facing_:
		Facing.UP:
			turn_up()
		Facing.RIGHT:
			turn_right()
		Facing.DOWN:
			turn_down()
		Facing.LEFT:
			turn_left()
		Facing.NONE:
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
