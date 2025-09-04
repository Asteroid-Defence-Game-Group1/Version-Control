extends Area2D

@export var cannon_bullet_scene: PackedScene
@export var fire_rate: float = 0.2  # seconds between shots
@onready var gun_points = [$Cannon_Point_1]# Add your two gunpoints as children

var shoot_timer = 0.0
var placed := false  # Only shoot when true

func _process(delta):
	if not placed:
		return  # Do nothing until tower is placed
		
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot()
		shoot_timer = fire_rate

func shoot():
	if not cannon_bullet_scene:
		return

	for gun in gun_points:
		var cannon = cannon_bullet_scene.instantiate()
		cannon.global_position = gun.global_position
		cannon.rotation = gun.global_rotation

		# Each gunpoint chooses its own nearest enemy
		var target = _get_nearest_enemy(gun.global_position)
		if target:
			cannon.target = target

		# Optional if still using velocity
		if cannon.has_method("set_velocity"):
			cannon.set_velocity(Vector2.RIGHT.rotated(gun.global_rotation))

		get_tree().current_scene.add_child(cannon)

# helper: closest enemy to a specific position
func _get_nearest_enemy(pos: Vector2) -> Node2D:
	var nearest: Node2D = null
	var min_dist := INF
	for enemy in get_tree().get_nodes_in_group("Enemy"):  # or "asteroid"
		if not is_instance_valid(enemy):
			continue
		var d = pos.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			nearest = enemy
	return nearest

func place():
	placed = true
