extends Reference


func roam(owner : Enemy):
	owner.follow_path()


func pick_target(owner : Enemy):
	return owner.player.position
