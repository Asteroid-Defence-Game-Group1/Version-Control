extends Node

@export var spawn_interval: float = 3.0
@export var asteroid_scenes: Array[PackedScene]   # Drag all your asteroid variations here
@onready var spawn_timer: Timer = Timer.new()

func _ready():
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if asteroid_scenes.is_empty():
		return

	# Pick a random asteroid variation
	var asteroid_scene: PackedScene = asteroid_scenes[randi() % asteroid_scenes.size()]
	var asteroid = asteroid_scene.instantiate()

	# Make sure spawned asteroid is in the "Big_Asteroids" group
	if not asteroid.is_in_group("Big_Asteroids"):
		asteroid.add_to_group("Big_Asteroids")

	# Spawn position = top right of the screen
	var screen_size = get_viewport().get_visible_rect().size

	# Spawn from just off the top-right corner
	var spawn_x = screen_size.x + 80
	var spawn_y = randf_range(-100, 100)  # some vertical jitter near top
	asteroid.position = Vector2(spawn_x, spawn_y)

	# Set its rotation to vaguely point down-left
	var base_angle = deg_to_rad(200)  # ~200° points down-left
	var jitter = randf_range(-0.3, 0.3)  # add randomness
	asteroid.rotation = base_angle + jitter

	get_parent().add_child(asteroid)
