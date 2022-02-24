class_name Actor
extends Area2D


enum Facing { UP, RIGHT, LEFT, DOWN }


export var speed = 60


var age = 0
var facing = Facing.RIGHT


func _ready():
	$AnimatedSprite.play("default")


func _process(delta):
	age += 1
	if not age % 120:
		print("tock")
	elif not age % 60:
		print("tick")
	
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
