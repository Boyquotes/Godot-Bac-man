extends Node2D


var can_spawn_fruit := false

export var fruit_scene : PackedScene


func _on_BigPellet_collected(_pickup : Pickup, _type : String):
	can_spawn_fruit = true


func spawn_fruit() -> Pickup:
	if not can_spawn_fruit:
		return null
	else:
		var fruit_instance = fruit_scene.instance()
		call_deferred("add_child", fruit_instance)
		can_spawn_fruit = false
		return fruit_instance
