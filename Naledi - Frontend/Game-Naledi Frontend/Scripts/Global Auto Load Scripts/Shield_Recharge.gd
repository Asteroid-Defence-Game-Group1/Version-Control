extends Node2D

@onready var particles = $CPUParticles2D

func _ready():
	if $Shield_Regen:
		$Shield_Regen.play()
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	await $Shield_Regen.finished
	queue_free()
