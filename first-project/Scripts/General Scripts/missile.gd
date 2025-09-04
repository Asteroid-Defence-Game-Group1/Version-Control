extends Area2D

@export var speed: float = 350.0
@export var turn_speed: float = 3.0
var velocity = Vector2.ZERO
var target: Node2D = null
var is_tower_bullet = true  # distinguish from player/UFO lasers

func _ready():
	self.area_entered.connect(Callable(self, "_on_area_entered"))
	
func _physics_process(delta):
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		var desired_angle = dir.angle()
		rotation = lerp_angle(rotation, desired_angle, turn_speed * delta)

	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta

func set_velocity(dir: Vector2):
	velocity = dir.normalized() * speed

func _on_area_entered(area: Area2D):
	if is_tower_bullet:
		if area.is_in_group("Enemy"):  # UFOs
			area.queue_free()
			queue_free()

		elif area.is_in_group("asteroid"):
			area.on_hit()
			queue_free()
