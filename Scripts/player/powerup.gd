extends Area2D

@export var powerup_type: Enums.PowerupType = Enums.PowerupType.SpeedBoost

@export var speed_boost_texture: Texture2D
@export var paddle_grow_texture: Texture2D
@export var ball_split_texture: Texture2D

signal collected(powerup_type: Enums.PowerupType, player: Node)

func _ready():
	monitoring = true
	monitorable = true
	connect("body_entered", Callable(self, "_on_body_entered"))
	$DespawnTimer.start()
	
	switch_texture()

func switch_texture() -> void:
	match powerup_type:
		Enums.PowerupType.SpeedBoost: $Sprite2D.texture = speed_boost_texture
		Enums.PowerupType.PaddleGrowth: $Sprite2D.texture = paddle_grow_texture
		Enums.PowerupType.BallSplit: $Sprite2D.texture = ball_split_texture

func _on_body_entered(body: Node):
	if body is CharacterBody2D and body.name.begins_with("Paddle"):
		emit_signal("collected", powerup_type, body)
		queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
