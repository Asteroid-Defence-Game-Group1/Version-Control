extends Node2D

@onready var particles = $CPUParticles2D

func _ready():
	if $ExplosionSound:
		$ExplosionSound.play()
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	await $ExplosionSound.finished
	queue_free()
	
