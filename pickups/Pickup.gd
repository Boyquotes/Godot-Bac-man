extends Area2D


export var pickup_type : String


func _on_Pickup_area_entered(area):
	area.owner.emit_signal("pickup_collected", pickup_type)
	$AudioStreamPlayer.play()
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
