extends ColorRect

@export var wall_scene: PackedScene
@export var ball_scene: PackedScene

@export var audio_player: AudioStreamPlayer2D
@export var countdownTick: AudioStreamMP3
@export var countdownTickGo: AudioStreamMP3

@export var hud: Node

@export var use_cpu_player_2: bool = true
@export var difficulty: String = "middle"

var score_p1: int = 0
var score_p2: int = 0
var max_score: int = 5

var speed_boost_timer: Timer = Timer.new()
var paddle_grow_timer: Timer = Timer.new()
var ball_split_timer: Timer = Timer.new()

func _ready():
	var screen_height = get_viewport_rect().size.y
	
	audio_player.play()
	
	create_walls(screen_height)
	create_out_of_bounds()

func create_out_of_bounds():
	var out_left = $OutOfBoundLeft
	var out_right = $OutOfBoundRight

	out_left.connect("body_entered", Callable(self, "_on_out_of_bounds_body_entered").bind("OutOfBoundLeft"))
	out_right.connect("body_entered", Callable(self, "_on_out_of_bounds_body_entered").bind("OutOfBoundRight"))

func create_ball(screen_width, screen_height):
	var ball: Ball = ball_scene.instantiate();
	ball.position.x = screen_width / 2 - ball.get_node("Sprite2D").scale.x
	ball.position.y = screen_height / 2 - ball.get_node("Sprite2D").scale.y
	add_child(ball)

func create_walls(screen_height):
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

func start_new_game() -> void:
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	
	$PaddleRight.is_cpu = use_cpu_player_2
	$PaddleRight.selected_difficulty = difficulty
	
	create_ball(screen_width, screen_height)
	$PowerupTimer.start()

func get_valid_powerup_position(for_player: Node) -> Vector2:
	var viewport_size = get_viewport_rect().size
	var powerup_size = Vector2(32, 32)  # oder sprite.get_rect().size
	
	var y_min = 0 # top screen border
	var y_max = viewport_size.y - powerup_size.y
	
	var attempts = 10
	while attempts > 0:
		var pos = Vector2(
			for_player.global_position.x,
			randf_range(y_min, y_max)
		)
		
		var overlap = false
		for paddle in get_tree().get_nodes_in_group("paddles"):
			var dist = pos.distance_to(paddle.global_position)
			if dist < 64:  # Abstand sicherstellen (anpassbar)
				overlap = true
				break

		if not overlap:
			return pos

		attempts -= 1

	# Fallback: einfach irgendwo auf der achse
	return Vector2(
		for_player.global_position.x,
		randf_range(y_min, y_max)
	)

func spawn_powerup() -> void:
	var paddle_ref = $PaddleLeft if randi() % 2 == 0 else $PaddleRight
	
	var pos = get_valid_powerup_position(paddle_ref)
	var p = preload("res://Prefabs/powerup.tscn").instantiate()
	p.powerup_type = choose_random_type()
	
	p.global_position = pos
	p.connect("collected", Callable(self, "_on_powerup_collected"))
	add_child(p)

func choose_random_type() -> Enums.PowerupType:
	var values = Enums.PowerupType.values()
	return values[randi() % values.size()]

func apply_speed_boost() -> void:
	var ball = get_node("Ball")
	if not ball:
		return
	
	var speed_multiplier = 1.5
	var duration = 0.5
	
	if ball.has_method("apply_speed_multiplier"):
		ball.apply_speed_multiplier(speed_multiplier)
	
	speed_boost_timer.wait_time = duration
	speed_boost_timer.one_shot = true
	speed_boost_timer.connect("timeout", Callable(self, "_reset_speed_boost"))
	add_child(speed_boost_timer)
	speed_boost_timer.start()

func apply_paddle_grow(player: Node):
	var duration = 5.0
	var original_scale = player.scale
	var grow_scale = Vector2(original_scale.x, original_scale.y * 1.5)

	player.scale = grow_scale

	paddle_grow_timer.wait_time = duration
	paddle_grow_timer.one_shot = true
	paddle_grow_timer.connect("timeout", func():
		if is_instance_valid(player):
			player.scale = original_scale
	)
	add_child(paddle_grow_timer)
	paddle_grow_timer.start()

func apply_ball_split() -> void:
	var ball: Ball = get_node("Ball")
	if not ball:
		return
		
	var velocity = ball.linear_velocity.length()
	var pos = ball.global_position

	var splittedBall: Ball = ball_scene.instantiate()
	splittedBall.name = "BallSplit"
	splittedBall.global_position = pos
	splittedBall.linear_velocity = ball.linear_velocity.rotated(deg_to_rad(-15)).normalized() * velocity
	splittedBall.self_destruction_time = 5.0
	add_child(splittedBall)

####################### Signals #######################
func _reset_speed_boost():
	var ball = get_node("Ball")
	if not ball:
		return
	
	if ball.has_method("apply_speed_multiplier"):
		ball.apply_speed_multiplier(1.0)

func _on_powerup_collected(powerup_type: Enums.PowerupType, player: Node):
	match powerup_type:
		Enums.PowerupType.SpeedBoost: apply_speed_boost()
		Enums.PowerupType.PaddleGrowth: apply_paddle_grow(player)
		Enums.PowerupType.BallSplit: apply_ball_split()

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

func _on_hud_decrease_score() -> void:
	if max_score > 1:
		max_score -= 1;
	get_parent().get_node("HUD").update_current_goal(max_score)
	
func _on_hud_increase_score() -> void:
	if max_score < 20:
		max_score += 1;
	get_parent().get_node("HUD").update_current_goal(max_score)

func _on_hud_reset_score() -> void:
	$PowerupTimer.stop()
	score_p1 = 0
	score_p2 = 0
	update_score()

func _on_out_of_bounds_body_entered(body: Node, zone_name: String) -> void:
	if not body.name.begins_with("Ball"):
		return

	match zone_name:
		"OutOfBoundLeft":
			score_p2 += 1
		"OutOfBoundRight":
			score_p1 += 1
	update_score()
	
	if score_p1 >= max_score or score_p2 >= max_score:
		hud.get_child(2).show()
		var playerName = "P1" if score_p1 >= max_score else "P2"
		hud.get_child(2).get_child(0).get_child(0).text = "Spieler %s hat gewonnen!" % playerName
		$WinMusic.play()
		var screen_height = get_viewport_rect().size.y
		$PaddleLeft.position.y = screen_height / 2
		$PaddleRight.position.y = screen_height / 2
	else:
		$BallResetTimer.start()
	
	body.reset_ball()

func _on_powerup_timer_timeout() -> void:
	spawn_powerup()

func _on_hud_toggle_cpu() -> void:
	use_cpu_player_2 = !use_cpu_player_2

func _on_hud_choose_difficulty(difficulty_index: int) -> void:
	match difficulty_index:
		0: difficulty = "easy"
		1: difficulty = "middle"
		2: difficulty = "hard"
