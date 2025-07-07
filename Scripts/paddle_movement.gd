extends StaticBody2D

enum Players { P1, P2 }

@export var playerVelocity = 300
@export var player: Players

func _process(delta: float) -> void:
	var upPressed = Input.is_action_pressed("move_up_p1" if player == Players.P1 else "move_up_p2")
	var downPressed = Input.is_action_pressed("move_down_p1" if player == Players.P1 else "move_down_p2")
	
	var direction = -1 if upPressed else 1 if downPressed else 0;
	
	var movement = direction * playerVelocity * delta
	var newPosition = clamp(position.y + movement, 0, get_viewport_rect().size.y)
	
	position = Vector2(position.x, newPosition)
