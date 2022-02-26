extends TileMap


export var player_start = Vector2(0,0)
export var enemy_start = Vector2(0,0)


func _ready():
	$Player.position = 16 * player_start + Vector2(16, 16)
	$Enemy.position = 16 * enemy_start + Vector2(16, 16)
