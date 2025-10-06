extends Node2D

@export var destruction_scene: PackedScene = preload("res://Scenes/Effects/Asteroid_Destruction.tscn")
@export var speed = 600
var Explosion = preload("res://Scenes/Effects/Expolsion.tscn")

var is_player_laser = true  # Set this when instantiating laser

func _physics_process(delta):
	position += transform.y * -speed * delta

func _ready():
	
	self.area_entered.connect(Callable(self, "_on_area_entered"))
	# Play sound when laser is spawned
	if $LaserSound:
		$LaserSound.play()


func _on_area_entered(area: Area2D):
	# PLAYER LASERS
	if is_player_laser:
		if area.is_in_group("asteroid"):
			area.on_hit()
			var destruction = destruction_scene.instantiate()
			destruction.global_position = global_position
			get_tree().current_scene.add_child(destruction)
			queue_free()
			var hud = get_tree().current_scene.get_node("HUD") # Adjust path if needed
			if hud:
				hud.add_score(5)
				
		elif area.is_in_group("Enemy"):
			area.queue_free()
			# Spawn explosion at projectile position
			var explosion = Explosion.instantiate()
			explosion.global_position = global_position
			get_tree().current_scene.add_child(explosion)
			queue_free()
			# Award points
			var hud = get_tree().current_scene.get_node("HUD")
			if hud:
				hud.add_score(15)  # 15 points for UFO
