extends Reference


var cutoff_length : int


func _init(cutoff_length_ := 96):
	cutoff_length = cutoff_length_


func roam(owner : Enemy):
	owner.follow_path()


# Scans ahead of the Player, turning around walls as it hits them.
# If the owning Enemy is on this path, we target the Player instead.
func pick_target(owner : Enemy):
	var p = owner.player
	if p.facing == p.Facing.NONE:
		return p.position

	var ss = owner.space_state
	var uv = p.unit_vectors
	var travelled := 0.0
	var facing = p.facing
	var position = p.position
	while travelled < cutoff_length:
		var start = position + 8 * uv[facing]
		var end = start + (cutoff_length - travelled) * uv[facing]
		# collision_layer: intersect walls and enemies
		# collide_with_areas: true
		var ray_result = ss.intersect_ray(start, end, [], 1 | 4, true, true)
		if not ray_result:
			travelled = cutoff_length
			position = end - 8 * uv[facing]
		else:
			if ray_result.collider.owner == owner:
				# Player is about to walk into us - just target them instead
				return p.position

			var new_position = ray_result.position - 8 * uv[facing]
			travelled += (new_position - position).length()
			position = new_position

			# Check if player can turn left...
			var direction_left = p.get_left_facing(facing)
			var ray_left = ss.intersect_ray(position, position + 9 * uv[direction_left], [], 1)
			if not ray_left:
				facing = direction_left
				continue

			# ... or right...
			var direction_right = p.get_right_facing(facing)
			var ray_right = ss.intersect_ray(position, position + 9 * uv[direction_right], [], 1)
			if not ray_right:
				facing = direction_right
				continue

			# ... otherwise, we've hit a dead-end - just target that.
			break

	return position
