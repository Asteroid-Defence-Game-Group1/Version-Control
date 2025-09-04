extends CharacterBody2D
@export var laser_scene: PackedScene
@onready var thrust_flame = $ThrustFlame

var fixed_x_position = -800  # Position on the left side
var speed = 200  # Only for up/down movement if you want lanes

func _physics_process(delta):
	position.x = fixed_x_position  # Lock X axis

	# Optional: allow vertical movement for lane defense
	var input_dir = Input.get_axis("ui_up", "ui_down")
	velocity.y = input_dir * speed
	move_and_slide()

	# Rotate to face the mouse
	look_at(get_global_mouse_position())

@onready var gun_point = $GunPoint


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var laser = laser_scene.instantiate()
		laser.global_position = gun_point.global_position
		laser.global_rotation = gun_point.global_rotation
		laser.is_player_laser = true 
		get_tree().current_scene.add_child(laser)

# Player Health bar Ui
var hud
var health = 100

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
		
		queue_free()  # Destroy player ship
