class_name Paddle
extends CharacterBody2D

enum Players { P1, P2 }

var playerVelocityDifficulty = {
	"easy": 450,
	"middle": 400,
	"hard": 350
}
@export var player: Players

@export var is_cpu: bool = false

var fixed_x: float

var follow_y := global_position.y
var selected_difficulty = "middle"
var difficulty = {
	"easy": 0.2,
	"middle": 0.1,
	"hard": 0.0
}
var reaction_timer = 0.0

func _ready():
	fixed_x = global_position.x

func _physics_process(delta: float) -> void:
	var direction = 0
	var target = choose_target()
	if is_cpu and is_instance_valid(target):
		reaction_timer -= delta
		if reaction_timer <= 0.0:
			reaction_timer = difficulty[selected_difficulty]

		var desired_y = target.global_position.y
		follow_y = lerp(follow_y, desired_y, 0.1)
		direction = sign(follow_y - global_position.y)
	else:
		var upPressed = Input.is_action_pressed("move_up_p1" if player == Players.P1 else "move_up_p2")
		var downPressed = Input.is_action_pressed("move_down_p1" if player == Players.P1 else "move_down_p2")
		
		direction = -1 if upPressed else 1 if downPressed else 0;
		
	var motion = Vector2(0, direction * playerVelocityDifficulty[selected_difficulty] * delta)
	move_and_collide(motion)
	
	global_position.x = fixed_x
	
	var screen_height = get_viewport_rect().size.y
	if global_position.y < 0:
		global_position.y = 0
	elif global_position.y > screen_height:
		global_position.y = screen_height

func choose_target() -> Node2D:
	var closest_powerup = null
	var min_dist = INF

	for pu in get_tree().get_nodes_in_group("powerups"):
		if not is_instance_valid(pu):
			continue
		# nur Powerups auf der eigenen Seite berücksichtigen
		if sign(pu.global_position.x - global_position.x) == sign(global_position.x - get_viewport_rect().size.x / 2):
			var dist = global_position.distance_to(pu.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_powerup = pu

	# Priorität für Powerup, wenn in Reichweite
	if closest_powerup and min_dist < 200:  # Threshold einstellbar
		return closest_powerup

	# Sonst zum Ball
	var ball = get_parent().get_node("Ball")
	if not ball:
		return null
	return ball
