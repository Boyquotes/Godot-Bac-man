extends TileMap


export var player_start = Vector2(0,0)


func _ready():
	$Player.position = 16 * player_start + Vector2(16, 16)
