extends Area2D

@export var cost: int = 125
@export var friendly_ship_scene: PackedScene
@export var spawn_interval: float = 20
@export var spawn_y_range: Vector2 = Vector2(100, 600)  # vertical spawn limits

var placed := false
var timer: Timer

# Called by placement system before actually placing
func can_place() -> bool:
	var hud = get_tree().current_scene.get_node("HUD")
	if hud and hud.spend_resources(cost):
		return true
	return false

# Called when the station is successfully placed
func place():
	if not placed:
		placed = true
		add_to_group("Towers")

		# Start spawning friendly ships
		timer = Timer.new()
		timer.wait_time = spawn_interval
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_spawn_friendly_ship)
		add_child(timer)
		timer.start()

func _spawn_friendly_ship():
	if not friendly_ship_scene:
		return

	var ship = friendly_ship_scene.instantiate()

	# Spawn offscreen left
	ship.position = Vector2(-800, randf_range(spawn_y_range.x, spawn_y_range.y))
	ship.direction = Vector2.RIGHT  # move left → right
	

	get_tree().current_scene.add_child(ship)
