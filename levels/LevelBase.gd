extends TileMap


export var player_start = Vector2(0,0)
export var enemy_start = Vector2(0,0)

onready var cell_offset = 0.5 * cell_size * Vector2.ONE


func _ready():
	$Player.position = map_to_world(player_start) + cell_offset
	$Enemy.position = map_to_world(enemy_start) + cell_offset
	get_tree().call_group("enemies", "set", "player", $Player)


func _on_Enemy_request_path(enemy: Enemy, target: Vector2):
	enemy.set("nav_path", [enemy.position, target])
