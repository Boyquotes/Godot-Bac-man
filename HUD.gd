extends CanvasLayer


func _ready():
	update_label_text()


func update_label_text():
	$Score.text = "Score: %d" % Global.score
	$Lives.text = "×%d" % Global.player_lives
	$Level.text = "Level %d" % Global.current_scene_index
