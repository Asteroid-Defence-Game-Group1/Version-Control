extends CharacterBody2D

@export var laser_scene: PackedScene
@onready var gun_point = $GunPoint
@onready var thruster = $Thruster_Flame
var Explosion = preload("res://Scenes/Effects/Expolsion.tscn")
var fixed_x_position = -800  # Position on the left side
var speed = 200  # Only for up/down movement if you want lanes
# Player Health bar Ui
var hud
var health = 100

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _physics_process(delta):
	if is_multiplayer_authority(): 
	# Get input
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Normalize diagonal movement
		if input_vector.length() > 1:
			input_vector = input_vector.normalized()
	
	# Move player
		velocity = input_vector * speed
	move_and_slide()

	# Rotate to face the mouse
	look_at(get_global_mouse_position())

	# Update thruster direction and position
	if thruster:
		var flame_dir = Vector2.RIGHT.rotated(rotation + PI)  # opposite facing direction
		thruster.gravity = flame_dir * 200

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var laser = laser_scene.instantiate()
		laser.global_position = gun_point.global_position
		laser.global_rotation = gun_point.global_rotation
		laser.is_player_laser = true 
		get_tree().current_scene.add_child(laser)

func take_damage(amount):
	health -= amount
	health = clamp(health, 0, 100)

	if hud:
		hud.set_health(health)

	if health <= 0:
		
		# Hide HUD
		if hud:
			hud.visible = false
		
		# Spawn Game Over UI
		var game_over_ui = preload("res://Scenes/UI Elements/game_over_ui.tscn").instantiate()
		get_tree().current_scene.add_child(game_over_ui)

		# Pass the score from HUD to Game Over UI
		game_over_ui.set_final_score(hud.get_score())
		if Explosion:
			var explosion = Explosion.instantiate()
			explosion.global_position = global_position
			get_tree().current_scene.add_child(explosion)
		queue_free()  # Destroy player ship
