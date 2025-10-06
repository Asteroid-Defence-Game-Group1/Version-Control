extends Area2D

@export var outer_right_x: float = 1150  # set this to your OuterBound_Right X coordinate
@export var shoot_offset: float = 500   # pixels to the left of OuterRight boundary
@export var speed: float = 50.0
@export var laser_scene: PackedScene
@export var laser_speed: float = 250
@onready var gun_point = $GunPoint
@export var target_group: String = "friendly_ships"
signal enemy_died

var can_shoot = false
var shoot_cooldown = 1.5  # seconds between shots
var shoot_timer = 0.0
var direction = Vector2.ZERO  # Set externally on spawn

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	
func _on_area_entered(area):
	# Remove if it collides with a world boundary
	if area.is_in_group("world_boundary"):
		queue_free()

func _process(delta):
	# Move UFO
	position += direction * speed * delta
	
	var margin = 700  # Extra pixels outside screen before activation
	var _screen_rect = get_viewport_rect().grow(margin)
	
	# Activate shooting when inside expanded viewport
	if not can_shoot and position.x <= (outer_right_x - shoot_offset):
		can_shoot = true

	# Shooting logic
	if can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_laser()
			shoot_timer = shoot_cooldown

	# Despawn if completely off the left side of the screen
	if position.x < -margin:
		queue_free()

func shoot_laser():
	var laser = laser_scene.instantiate()
	laser.position = gun_point.global_position
	laser.rotation = global_rotation + PI
	get_tree().current_scene.add_child(laser)
	
func _update_rotation():
	rotation = direction.angle() + - PI / 2 

func die():
	emit_signal("enemy_died")
	queue_free()
