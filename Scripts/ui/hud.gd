extends Node

signal reset_score
signal start_new_game
signal decrease_score
signal increase_score
signal toggle_cpu
signal choose_difficulty(difficulty_index: int)

func _on_game_over_popup_start_new_game() -> void:
	$GameOverPopup.hide()
	$ScoreP1.hide()
	$ScoreP2.hide()
	$StartScreen.show()
	reset_score.emit()

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

func update_current_goal(new_score: int) -> void:
	$StartScreen/GameOptions/CurrentScore.text = str(new_score)

func _on_decrease_button_pressed() -> void:
	decrease_score.emit()

func _on_increase_button_pressed() -> void:
	increase_score.emit()

func _on_cpu_active_pressed() -> void:
	toggle_cpu.emit()

func _on_difficulty_item_selected(index: int) -> void:
	choose_difficulty.emit(index)
