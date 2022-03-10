extends CanvasLayer


var score_popup = preload("res://ScorePopup.tscn")


func _ready():
	update_label_text()


func update_label_text():
	$Score.text = "Score: %d" % Global.score
	$Lives.text = "×%d" % Global.player_lives
	$Level.text = "Level %d" % Global.current_scene_index


func spawn_score_label(position : Vector2, score : int):
	var popup = score_popup.instance()
	add_child(popup)
	popup.get_node("Label").text = str(score)
	popup.position = position
