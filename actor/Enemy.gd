class_name Enemy
extends Actor


signal request_path


var nav_path = []
var player : Player


func _process(_delta):
	pass


func _on_PathTimer_timeout():
	emit_signal("request_path", self, player.position)
