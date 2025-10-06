extends Area2D

@export var speed: float = 350.0
@export var turn_speed: float = 3.0
@export var explosion_scene: PackedScene = preload("res://Scenes/Effects/Expolsion.tscn")
@export var destruction_scene: PackedScene = preload("res://Scenes/Effects/Asteroid_Destruction.tscn")
@export var explosion_sound: AudioStream = null

var velocity = Vector2.ZERO
var target: Node2D = null
var is_tower_bullet = true  # distinguish from player/UFO lasers

func _ready():
	# Connect collision signal
	self.area_entered.connect(Callable(self, "_on_area_entered"))

func _physics_process(delta):
	# If target exists and is valid, adjust rotation towards it
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		var desired_angle = dir.angle()
		rotation = lerp_angle(rotation, desired_angle, turn_speed * delta)

	# Move bullet forward
	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta

func set_velocity(dir: Vector2):
	velocity = dir.normalized() * speed

func _on_area_entered(area: Area2D):
	if not is_tower_bullet:
		return

	if area.is_in_group("Enemy"):
		# Trigger explosion
		if explosion_scene:
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			get_tree().current_scene.add_child(explosion)
			# Destroy target if enemy
		if area.is_in_group("Enemy"):
			area.queue_free()
			queue_free()
			
	if area.is_in_group("asteroid"):
		if destruction_scene:
			var destruction = destruction_scene.instantiate()
			destruction.global_position = global_position
			get_tree().current_scene.add_child(destruction)
			
			# Destroy target if enemy
		if area.is_in_group("asteroid"):
			if area.has_method("on_hit"):
				area.on_hit()
		queue_free()
	
