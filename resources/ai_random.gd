extends Reference


func roam(owner : Enemy):
	owner.move_randomly()


func pick_target(owner : Enemy):
	return owner.player.position
