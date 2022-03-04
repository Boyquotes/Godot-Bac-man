extends Node2D


signal player_spawned (player)
signal enemy_home_ready (home)
signal player_powered_up
signal player_powered_down


onready var cell_offset : Vector2 = 0.5 * $Maze.cell_size * Vector2.ONE
onready var astar := AStar2D.new()
onready var map_rect : Rect2 = $Maze.get_used_rect()
onready var space_state := get_world_2d().direct_space_state
onready var pellet_count := get_tree().get_nodes_in_group("pellets").size()


func _ready():
	connect_signals()
	emit_signal("player_spawned", $Player)
	emit_signal("enemy_home_ready", $EnemyHome)
	restart()

	if astar.get_point_capacity() <= map_rect.size.x * map_rect.size.y:
		astar.reserve_space(int(map_rect.size.x * map_rect.size.y))

	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			astar.add_point(map_to_id(x, y), map_loc(Vector2(x, y)) + cell_offset)

	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var world_vec = map_loc(Vector2(x, y)) + cell_offset
			if x < map_rect.end.x - 1:
				var ray_result = space_state.intersect_ray(world_vec, world_vec + $Maze.cell_size * Vector2.RIGHT, [], 1)
				if !ray_result:
					astar.connect_points(map_to_id(x, y), map_to_id(x + 1, y))
			if y < map_rect.end.y - 1:
				var ray_result = space_state.intersect_ray(world_vec, world_vec + $Maze.cell_size * Vector2.DOWN, [], 1)
				if !ray_result:
					astar.connect_points(map_to_id(x, y), map_to_id(x, y + 1))


func connect_signals():
	for e in get_tree().get_nodes_in_group("enemies"):
		# warning-ignore: RETURN_VALUE_DISCARDED
		connect("player_spawned", e, "_on_player_spawned")
		# warning-ignore: RETURN_VALUE_DISCARDED
		connect("enemy_home_ready", e, "_on_enemy_home_ready")
		# warning-ignore: RETURN_VALUE_DISCARDED
		connect("player_powered_up", e, "_on_player_powered_up")
		# warning-ignore: RETURN_VALUE_DISCARDED
		connect("player_powered_down", e, "_on_player_powered_down")
		# warning-ignore: RETURN_VALUE_DISCARDED
		e.connect("request_path", self, "_on_Enemy_request_path")


func restart():
	$Player.reset()
	for e in get_tree().get_nodes_in_group("enemies"):
		e.reset()
	$RestartTimer.start()


func map_loc(v : Vector2):
	return $Maze.to_global($Maze.map_to_world(v))


func map_to_id(x, y):
	return x + map_rect.end.x * y


func _on_Enemy_request_path(enemy: Enemy, target: Vector2):
	var from_id = astar.get_closest_point(enemy.position)
	var to_id = astar.get_closest_point(target)
	var path = astar.get_point_path(from_id, to_id)
	enemy.set("nav_path", path)


func _on_Player_life_lost():
	Global.notify_event(Global.LIFE_LOST)
	restart()


func _on_RestartTimer_timeout():
	$Player.set_state(Player.State.ROAMING)
	for e in get_tree().get_nodes_in_group("enemies"):
		e.set_state(Enemy.State.IDLING)


func _on_Player_pickup_collected(type):
	match type:
		"pellet":
			Global.notify_event(Global.PELLET_COLLECTED)
			pellet_count -= 1
			if pellet_count <= 0:
				Global.notify_event(Global.SCENE_CLEAR)
		"big_pellet":
			Global.notify_event(Global.BIG_PELLET_COLLECTED)
			$Player.set_state(Player.State.POWERUP)
			emit_signal("player_powered_up")
		_:
			assert(false, "invalid pickup type: %s" % type)


func _on_Player_powerup_timedout():
	emit_signal("player_powered_down")


func _on_Player_entered_enemy(enemy):
	match enemy.state:
		Enemy.State.EATEN:
			pass
		_:
			Global.notify_event(Global.ENEMY_EATEN)
			enemy.set_state(Enemy.State.EATEN)
