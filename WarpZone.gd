extends Node2D


signal on_Actor_enter_warp (actor, destination)


func _on_LeftZone_area_entered(area : Area2D):
	emit_signal("on_Actor_enter_warp", area.owner, Vector2(300, 50))


func _on_RightZone_area_entered(area : Area2D):
	emit_signal("on_Actor_enter_warp", area.owner, Vector2(50, 50))
