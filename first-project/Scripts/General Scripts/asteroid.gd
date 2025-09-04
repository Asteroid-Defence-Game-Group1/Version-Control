extends Area2D

@export var speed: float = 100.0
@export var small_asteroid_scene: PackedScene

func _ready():
	if is_zero_approx(rotation):
		rotation = randf() * TAU
	set_process(true)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_area_entered(area):
	if area.name == "Laser":
		area.queue_free()
		on_hit()

func on_hit():
	call_deferred("_split")

func _split():
	if small_asteroid_scene:
		for i in range(2):
			var chunk = small_asteroid_scene.instantiate()
			chunk.global_position = global_position
			chunk.rotation = randf() * TAU
			get_tree().current_scene.add_child(chunk)
	queue_free()
