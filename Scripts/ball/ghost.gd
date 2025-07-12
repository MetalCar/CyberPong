extends Sprite2D

@export var fade_speed: float = 2.0

func _process(delta):
	modulate.a -= fade_speed * delta
	if modulate.a <= 0:
		queue_free()
