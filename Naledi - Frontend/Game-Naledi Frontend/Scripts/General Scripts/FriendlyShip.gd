extends Area2D

@export var outer_left_x: float = - 1150
@export var shoot_offset: float = - 500
@export var speed: float = 50.0
@export var laser_scene: PackedScene
@export var laser_speed: float = 250
@onready var gun_point = $GunPoint
@export var health := 1

var can_shoot = false
var shoot_cooldown = 1.5
var shoot_timer = 0.0
var direction = Vector2.RIGHT  # moves left → right

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	# Move ship
	position += direction * speed * delta

	var margin = 700 # Extra pixels outside screen before activation
	
	# Activate shooting when within range
	if not can_shoot and position.x >= (outer_left_x - shoot_offset):
		can_shoot = true

	if can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_laser()
			shoot_timer = shoot_cooldown

	# Despawn if completely off screen
	if position.x > get_viewport_rect().size.x + margin:
		queue_free()

func shoot_laser():
	if not laser_scene:
		return
	var laser = laser_scene.instantiate()
	laser.global_position = gun_point.global_position
	laser.rotation = global_rotation  # shoots in facing direction
	if laser.has_method("set_velocity"):
		laser.set_velocity(Vector2.RIGHT.rotated(global_rotation) * laser_speed)
	get_tree().current_scene.add_child(laser)

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
