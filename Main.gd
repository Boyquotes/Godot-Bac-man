extends Node


enum GameState {
	Title,
	Level,
}

export(PackedScene) var maze_data

var game_state = GameState.Title


func _input(event):
	match game_state:
		GameState.Title:
			if !event.is_action_pressed("ui_right"):
				get_tree().set_input_as_handled()
		GameState.Level:
			pass
