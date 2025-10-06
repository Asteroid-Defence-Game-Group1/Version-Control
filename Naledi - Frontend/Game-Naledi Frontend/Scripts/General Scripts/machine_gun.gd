extends Area2D

@export var cost: int = 110   # Resource cost to place
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2  # optional cooldown between reactive shots
@onready var gun_points = [$Machine_Point_1, $Machine_Point_2]

var placed := false  # Only shoot when tower is placed
var cooldown := 0.0  # small delay to prevent spamming

func _process(delta):
	if not placed:
		return

	cooldown -= delta

	# check each gun for a target
	for gun in gun_points:
		var target = _get_nearest_enemy(gun.global_position)
		if target and cooldown <= 0:
			shoot()
			cooldown = fire_rate  # reset cooldown

# shoot a bullet from a specific gun towards target
func shoot():
	if not bullet_scene:
		return

	for gun in gun_points:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = gun.global_position
		bullet.rotation = gun.global_rotation

		# Assign nearest enemy as target
		var target = _get_nearest_enemy(gun.global_position)
		if target:
			bullet.target = target   # directly assign, no checks needed

		# Optional if still using velocity
		if bullet.has_method("set_velocity"):
			bullet.set_velocity(Vector2.RIGHT.rotated(gun.global_rotation))

		get_tree().current_scene.add_child(bullet)

# helper: closest enemy to a specific position
func _get_nearest_enemy(pos: Vector2) -> Node2D:
	var nearest: Node2D = null
	var min_dist := INF
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		var d = pos.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			nearest = enemy
	return nearest
	
# Called by placement system before actual placement
func can_place() -> bool:
	var hud = get_tree().current_scene.get_node("HUD")
	if hud and hud.spend_resources(cost):
		return true
	return false

func place():
	placed = true
	add_to_group("Towers")
