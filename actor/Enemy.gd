class_name Enemy
extends Actor


signal request_path


var nav_path : PoolVector2Array = []
var player : Player


func _process(_delta):
	if nav_path.size() <= 1:
		emit_signal("request_path", self, player.position)
		return

	# TODO: Anticipated bug involving enemies getting stuck at narrow gaps,
	# going back and forth and never trying to turn into them.
	var facing_ : int
	var to_point_0 = nav_path[0] - position
	var to_point_1 = nav_path[1] - position
	if facing == nearest_facing(to_point_0) and to_point_0.length() < 4: # TODO: Magic number
		facing_ = nearest_facing(to_point_1)
	elif facing == nearest_facing(to_point_1) and is_opposite_facing(facing, facing_):
		facing_ = facing
		nav_path.remove(0)
	else:
		facing_ = nearest_facing(to_point_0)

	if facing_ != facing:
		nav_path.remove(0)
		queue_facing(facing_)


func _on_PathTimer_timeout():
	# TODO: We should request a path to where the player is about to go,
	# lest we get stuck when they're halfway between tiles
	emit_signal("request_path", self, player.position)
