class_name Ball
extends RigidBody2D

signal reset

var speed_multiplier: float = 1.0
@export var initialBallVelocity = 200
@export var ballVelocityPerBounce = 20

@export var ghost_scene: PackedScene
@export var ghost_interval: float = 0.05
var _ghost_timer = 0.0

@export var self_destruction_time: float = 0.0 # On 0.0 the ball will never destruct himself

var ballVelocity = initialBallVelocity

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	connect("body_entered", Callable(self, "_on_body_entered"))
	start_ball()
	
	if self_destruction_time > 0.0:
		var timer = Timer.new()
		timer.wait_time = self_destruction_time
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_on_self_destruct"))
		add_child(timer)
		timer.start()

func _on_self_destruct():
	queue_free()

func _process(delta):
	_ghost_timer -= delta
	if _ghost_timer <= 0:
		spawn_ghost()
		_ghost_timer = ghost_interval

func spawn_ghost():
	var ghost = ghost_scene.instantiate()
	ghost.global_position = global_position
	ghost.rotation = rotation
	ghost.scale = scale
	get_parent().add_child(ghost)

func start_ball():
	var angle = randf_range(-0.25, 0.25)
	var direction = Vector2.RIGHT.rotated(angle)

	if randi() % 2 == 0:
		direction.x *= -1
	
	linear_velocity = direction.normalized() * ballVelocity * speed_multiplier
	
func apply_dynamic_bounce(paddle: Node):
	# Abstand zwischen Ball und Paddle-Mitte auf der Y-Achse
	var offset = global_position.y - paddle.global_position.y

	# Zugriff auf die Höhe des Paddle-Rectangles
	var shape = paddle.get_node("CollisionShape2D").shape
	if shape is RectangleShape2D:
		var half_height = shape.size.y / 2.0

		# Wert von -1 bis 1 → wie weit oben/unten wurde getroffen?
		var relative = clamp(offset / half_height, -1.0, 1.0)

		# Neue Richtung → X bleibt erhalten (links oder rechts), Y abhängig von Treffer
		var new_direction = Vector2(sign(linear_velocity.x), relative).normalized()
		
		ballVelocity += ballVelocityPerBounce
		ballVelocity = min(ballVelocity, 800)
		
		# Neue Geschwindigkeit anwenden
		linear_velocity = new_direction * ballVelocity * speed_multiplier

func _on_body_entered(body):
	if body.name.begins_with("Paddle"):
		$HitSound.play()
		apply_dynamic_bounce(body)
		ballVelocity += 50

func reset_ball() -> void:
	$DeathSound.play()
	await get_tree().create_timer(1).timeout
	queue_free()
	reset.emit()

func apply_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier
