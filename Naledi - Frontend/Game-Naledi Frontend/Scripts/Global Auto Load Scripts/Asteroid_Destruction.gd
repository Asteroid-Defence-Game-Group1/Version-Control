extends Node2D

@onready var particles = $DestructionParticle

func _ready():
	if $ExplosionSound:
		$ExplosionSound.play()
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	await $ExplosionSound.finished
	queue_free()
