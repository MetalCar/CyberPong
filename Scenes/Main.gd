extends ColorRect

@export var wall_scene: PackedScene
@export var ball_scene: PackedScene

var score_p1: int = 0
var score_p2: int = 0

func _ready():
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	
	var top_wall = wall_scene.instantiate()
	var bottom_wall = wall_scene.instantiate()
	
	top_wall.name = "TopWall"
	bottom_wall.name = "BottomWall"
	
	var wall_height = top_wall.get_node("CollisionShape2D").shape.size.y
	
	top_wall.position.y = 0 - wall_height / 2
	bottom_wall.position.y = screen_height
	
	add_child(top_wall)
	add_child(bottom_wall)
	
	create_ball(screen_width, screen_height)
	
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
			print("Punkt für Spieler 2: ", score_p2)
		"OutOfBoundRight":
			score_p1 += 1
			print("Punkt für Spieler 1: ", score_p1)
	
	$BallResetTimer.start()
	body.reset_ball()
	
func create_ball(screen_width, screen_height):
	var ball = ball_scene.instantiate();
	ball.position.x = screen_width / 2 - ball.get_node("Sprite2D").scale.x
	ball.position.y = screen_width / 2 - ball.get_node("Sprite2D").scale.y
	add_child(ball)

func _on_ball_reset_timer_timeout() -> void:
	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x
	
	create_ball(screen_width, screen_height)
	$BallResetTimer.stop()
