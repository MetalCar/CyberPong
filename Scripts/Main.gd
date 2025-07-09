extends ColorRect

@export var wall_scene: PackedScene
@export var ball_scene: PackedScene

@export var audio_player: AudioStreamPlayer2D
@export var countdownTick: AudioStreamMP3
@export var countdownTickGo: AudioStreamMP3

@export var hud: Node

var score_p1: int = 0
var score_p2: int = 0

func _ready():
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	
	audio_player.play()
	
	create_walls(screen_width, screen_height)
	create_out_of_bounds()

func create_out_of_bounds():
	var out_left = $OutOfBoundLeft
	var out_right = $OutOfBoundRight

	out_left.connect("body_entered", Callable(self, "_on_out_of_bounds_body_entered").bind("OutOfBoundLeft"))
	out_right.connect("body_entered", Callable(self, "_on_out_of_bounds_body_entered").bind("OutOfBoundRight"))

func _on_out_of_bounds_body_entered(body: Node, zone_name: String) -> void:
	if body.name != "Ball":
		return

	match zone_name:
		"OutOfBoundLeft":
			score_p2 += 1
		"OutOfBoundRight":
			score_p1 += 1
	update_score()
	
	if score_p1 >= 5 or score_p2 >= 5:
		hud.get_child(2).show()
		var playerName = "P1" if score_p1 >= 5 else "P2"
		hud.get_child(2).get_child(0).get_child(0).text = "Spieler %s hat gewonnen!" % playerName
		$WinMusic.play()
		var screen_height = get_viewport_rect().size.y
		$PaddleLeft.position.y = screen_height / 2
		$PaddleRight.position.y = screen_height / 2
	else:
		$BallResetTimer.start()
	
	body.reset_ball()

func create_ball(screen_width, screen_height):
	var ball = ball_scene.instantiate();
	ball.position.x = screen_width / 2 - ball.get_node("Sprite2D").scale.x
	ball.position.y = screen_width / 2 - ball.get_node("Sprite2D").scale.y
	add_child(ball)

func create_walls(screen_width, screen_height):
	var top_wall = wall_scene.instantiate()
	var bottom_wall = wall_scene.instantiate()
	
	top_wall.name = "TopWall"
	bottom_wall.name = "BottomWall"
	
	var wall_height = top_wall.get_node("CollisionShape2D").shape.size.y
	
	top_wall.position.y = 0 - wall_height / 2
	bottom_wall.position.y = screen_height
	
	add_child(top_wall)
	add_child(bottom_wall)

func update_score():
	hud.get_child(1).text = "Score: %s" % score_p2
	hud.get_child(0).text = "Score: %s" % score_p1

func _on_ball_reset_timer_timeout() -> void:
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	
	create_ball(screen_width, screen_height)
	$BallResetTimer.stop()

func _on_hud_start_new_game() -> void:
	hud.get_node("TimerScreen").show()
	for time in [3, 2, 1, 0]:
		hud.update_timer_label(str(time))
		if time > 0:
			$CountdownMusic.stream = countdownTick
		else:
			$CountdownMusic.stream = countdownTickGo
		$CountdownMusic.play()
		await get_tree().create_timer(1).timeout
	hud.get_node("TimerScreen").hide()
	start_new_game()

func start_new_game() -> void:
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	score_p1 = 0
	score_p2 = 0
	update_score()
	create_ball(screen_width, screen_height)
