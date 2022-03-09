extends Node2D


signal on_Actor_enter_warp (actor, destination)


# not working yet - does absolute position in the original scene
onready var left_zone_target : Vector2 = $RightZone.get_global_position()
onready var right_zone_target : Vector2 = $LeftZone.get_global_position()


func _on_LeftZone_area_entered(area : Area2D):
	emit_signal("on_Actor_enter_warp", area.owner, left_zone_target)


func _on_RightZone_area_entered(area : Area2D):
	emit_signal("on_Actor_enter_warp", area.owner, right_zone_target)
