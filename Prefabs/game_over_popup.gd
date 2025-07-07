extends Control

signal start_new_game

func _ready() -> void:
	hide()


func _on_button_pressed() -> void:
	start_new_game.emit()
