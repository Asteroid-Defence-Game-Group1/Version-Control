extends Area2D

@export var speed: float = 150.0

func _ready():
	rotation = randf() * TAU
	set_process(true)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func on_hit():
	queue_free()
