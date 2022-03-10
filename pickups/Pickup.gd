class_name Pickup
extends Area2D


signal collected (_self, type)


export var pickup_type : String


func _on_Pickup_area_entered(_area):
	emit_signal("collected", self, pickup_type)
	$AudioStreamPlayer.play()
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
