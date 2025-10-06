extends Area2D

@export var destruction_scene: PackedScene = preload("res://Scenes/Effects/Asteroid_Destruction.tscn")
@export var speed = 600
var Explosion = preload("res://Scenes/Effects/Expolsion.tscn")

func _ready() -> void:
	self.area_entered.connect(Callable(self, "_on_area_entered"))
	# Play sound when laser is spawned
	if $LaserSound:
		$LaserSound.play()
		
	if self.has_signal("body_entered"):
		self.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += transform.y * -speed * delta

func _on_area_entered(area: Area2D):
	# ENEMY LASERS
		if area.is_in_group("Shields"):
			if area.has_method("take_damage"):
				area.take_damage(1)  # reduce shield health
			queue_free()  # projectile absorbed
		if area.is_in_group("friendly_ships"):
			if area.has_method("take_damage"):
				area.take_damage(1)  # apply damage
				area.queue_free()
				# Spawn explosion at projectile position
				var explosion = Explosion.instantiate()
				explosion.global_position = global_position
				get_tree().current_scene.add_child(explosion)
			queue_free()  # destroy the laser
			# Deduct points
			var hud = get_tree().current_scene.get_node("HUD")
			if hud:
				hud.add_score(-10)
		# Asteroid collision
		elif area.is_in_group("asteroid"):
			area.on_hit()
			var destruction = destruction_scene.instantiate()
			destruction.global_position = global_position
			get_tree().current_scene.add_child(destruction)
			queue_free()
			
func _on_body_entered(body):
	# Enemy laser hitting the Player (CharacterBody2D is a Body)
	if not is_in_group("Friendly_Projectiles") and body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(10)  # adjust damage as you like
		queue_free()
