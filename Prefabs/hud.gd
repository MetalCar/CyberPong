extends Node

signal start_new_game

func _on_game_over_popup_start_new_game() -> void:
	$GameOverPopup.hide()
	start_new_game.emit()
