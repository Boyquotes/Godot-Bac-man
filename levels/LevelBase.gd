extends TileMap


export var player_start = Vector2(0,0)


func _ready():
	$Player.position = 32 * player_start + Vector2(16, 16)
