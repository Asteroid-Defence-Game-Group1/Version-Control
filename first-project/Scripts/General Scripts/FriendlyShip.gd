extends Area2D

@export var speed: float = 30
@export var health := 1  # 1 = destroyed in 1 hit

func _ready():
	add_to_group("friendly_ships")

func _process(delta):
	position.y -= speed * delta  # Move upwards

	# Despawn if off top of screen
	if position.y < - 1000:
		queue_free()
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()  # destroy the ship when health <= 0
