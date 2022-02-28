extends Area2D


export var pickup_type : String

onready var signal_name = "pickup_" + pickup_type


func _on_Pickup_area_entered(area):
	area.owner.emit_signal(signal_name)
	$AudioStreamPlayer.play()
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
