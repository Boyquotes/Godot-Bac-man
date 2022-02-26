extends TileMap


export var player_start = Vector2(0,0)
export var enemy_start = Vector2(0,0)


func _ready():
	$Player.position = 16 * player_start + Vector2(16, 16)
	$Enemy.position = 16 * enemy_start + Vector2(16, 16)
	get_tree().call_group("enemies", "set", "player", $Player)


func _on_Enemy_request_path(enemy: Enemy, target: Vector2):
	enemy.set("nav_path", [enemy.position, target])
