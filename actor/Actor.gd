class_name Actor
extends Area2D


export var speed = 60


var age = 0


func _ready():
	$AnimatedSprite.play("default")


func _process(_delta):
	age += 1
	if not age % 120:
		print("tock")
	elif not age % 60:
		print("tick")
