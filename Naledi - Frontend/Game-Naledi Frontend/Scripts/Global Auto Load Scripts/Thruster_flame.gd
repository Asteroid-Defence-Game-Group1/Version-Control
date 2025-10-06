extends Node2D

@onready var particles = $Thruster_Flame

func _ready():
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
