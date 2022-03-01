class_name Enemy
extends Actor


signal request_path


var nav_path : PoolVector2Array = []
var player : Player


func _process(_delta):
	if nav_path.size() == 0:
		emit_signal("request_path", self, player.position)
		return

	var to_point_0 = nav_path[0] - position
	var facing_ = nearest_facing(to_point_0)

	if nav_path.size() <= 1:
		if to_point_0.length() < 16:
			emit_signal("request_path", self, player.position)
	else:
		if to_point_0.length() < 8:
			nav_path.remove(0)
		else:
			var to_point_1 = nav_path[1] - position
			var facing_1 = nearest_facing(to_point_1)
			if is_opposite_facing(facing_, facing_1):
				facing_ = facing_1
				nav_path.remove(0)

	queue_facing(facing_)


func _on_PathTimer_timeout():
	# TODO: We should request a path to where the player is about to go,
	# lest we get stuck when they're halfway between tiles
	emit_signal("request_path", self, player.position)
