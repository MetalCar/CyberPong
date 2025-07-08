extends Node

signal start_new_game

func _on_game_over_popup_start_new_game() -> void:
	$GameOverPopup.hide()
	start_new_game.emit()

func _on_button_pressed() -> void:
	$StartScreen.hide()
	$ScoreP1.show()
	$ScoreP2.show()
	start_new_game.emit()

func update_timer_label(timer):
	match timer:
		"3":
			$TimerScreen/ColorRect/Label.text = "3..."
		"2":
			$TimerScreen/ColorRect/Label.text = "2..."
		"1":
			$TimerScreen/ColorRect/Label.text = "1..."
		"0":
			$TimerScreen/ColorRect/Label.text = "START"
