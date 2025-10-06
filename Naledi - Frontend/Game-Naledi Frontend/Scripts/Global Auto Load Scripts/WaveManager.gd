extends Node

signal wave_started(current_wave: int)
signal wave_completed(completed_wave: int)

@export var ufo_scenes: Array[PackedScene] = []   # Multiple UFO scenes
@export var waves: Array = [10, 15, 20]           # number of UFOs per wave
@export var spawn_interval: float = 5.0           # delay between individual UFO spawns
@export var wave_interval: float = 20.0           # delay between waves

var current_wave := 0
var enemies_alive := 0

func _ready():
	start_next_wave()

func start_next_wave():
	if current_wave >= waves.size():
		print("All waves complete!")
		return
	spawn_wave(current_wave)

# Coroutine to spawn a single wave with delays
func spawn_wave(index: int) -> void:
	var enemy_count = waves[index]
	enemies_alive = enemy_count
	emit_signal("wave_started", index + 1)
	print("Starting wave %s with %s UFOs" % [index + 1, enemy_count])

	# Spawn each enemy with a delay
	for i in range(enemy_count):
		spawn_enemy()
		await get_tree().create_timer(spawn_interval).timeout

	# Wait until all enemies are destroyed before starting next wave
	await wait_for_wave_completion()
	current_wave += 1
	await get_tree().create_timer(wave_interval).timeout
	start_next_wave()

func spawn_enemy() -> void:
	if ufo_scenes.is_empty():
		push_warning("⚠ WaveManager has no UFO scenes assigned!")
		return

	# Pick random UFO scene
	var ufo_scene: PackedScene = ufo_scenes[randi() % ufo_scenes.size()]
	var ufo = ufo_scene.instantiate()

	# Spawn at right edge of screen
	var screen_size = get_viewport().get_visible_rect().size
	ufo.position = Vector2(screen_size.x + 80, randi_range(0, screen_size.y))
	ufo.direction = Vector2.LEFT
	ufo._update_rotation()

	add_child(ufo)
	ufo.tree_exited.connect(_on_enemy_killed)

func _on_enemy_killed() -> void:
	enemies_alive -= 1

# Wait until all enemies are destroyed
func wait_for_wave_completion():
	while enemies_alive > 0:
		await get_tree().process_frame
