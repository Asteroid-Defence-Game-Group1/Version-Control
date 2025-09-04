extends Node2D

@export var UFO_scene: PackedScene
@export var asteroid_scene: PackedScene
@export var hud_scene: PackedScene
@export var friendly_scene: PackedScene
@onready var player = $Player
@onready var ufo_timer = $UFOSpawnTimer

var base_spawn_time := 5.0  # initial spawn time in seconds
var min_spawn_time := 1.0   # minimum spawn interval
var score_checkpoint := 250  # every 250 points
var last_checkpoint := 0    #Points at the start of a game
var hud_instance
var structure_to_place: PackedScene = null
var placement_preview: Node2D = null

func _ready():      
	 # Fade in from black at the start of the game
	FadeLayer.fade_in(1.0)
	if $GameMusic:
		$GameMusic.play()
	#Start up for Spawn Timers of: UFOs, Asteroids and Friendly Ships
	$AsteroidTimer.timeout.connect(_on_AsteroidTimer_timeout)
	$AsteroidTimer.start()
	randomize()
	
	$UFOSpawnTimer.timeout.connect(_on_UFOSpawnTimer_timeout)
	$UFOSpawnTimer.start()
	ufo_timer.wait_time = base_spawn_time
	ufo_timer.start()
	
	$FriendlySpawnTimer.timeout.connect(spawn_friendly_ship)
	
	# Give player access to HUD
	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	player.hud = hud_instance
	
	# Connect the signal from HUD to Game
	hud_instance.build_selected.connect(_on_build_selected)
	
func _on_build_selected(scene: PackedScene):
	structure_to_place = scene
	# Make a transparent preview
	if placement_preview:
		placement_preview.queue_free()
	placement_preview = structure_to_place.instantiate()
	add_child(placement_preview)
	placement_preview.modulate = Color(1,1,1,0.5)  # semi-transparent

func _unhandled_input(event):
	if placement_preview:
		placement_preview.global_position = get_global_mouse_position()

		# Left click = place structure
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Instantiate the actual tower
			var tower = structure_to_place.instantiate()
			tower.global_position = placement_preview.global_position
			add_child(tower)

			# Start shooting
			tower.place()

			# Remove preview and reset selection
			placement_preview.queue_free()
			placement_preview = null
			structure_to_place = null

		# Right click = cancel placement
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			placement_preview.queue_free()
			placement_preview = null
			structure_to_place = null

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		PauseManager.toggle_pause()
			
func _process(delta):
	# Adjust UFO spawn time based on player score
	if is_instance_valid(player) and player.hud:
		var current_score = player.hud.get_score()  # Make sure HUD has get_score()
		var checkpoints_passed = int(current_score / score_checkpoint)
		if checkpoints_passed > last_checkpoint:
			# Reduce timer by 0.5 seconds per checkpoint
			ufo_timer.wait_time = max(base_spawn_time - 0.5 * checkpoints_passed, min_spawn_time)
			last_checkpoint = checkpoints_passed

func _on_AsteroidTimer_timeout():
	var asteroid = asteroid_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	asteroid.position = Vector2(randi() % int(screen_size.x), -500)
	add_child(asteroid)

func _on_UFOSpawnTimer_timeout():
	var ufo = UFO_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size

	# Spawn off the right edge
	var spawn_x = screen_size.x + 80
	var spawn_y = randi_range(0, screen_size.y)

	ufo.position = Vector2(spawn_x, spawn_y)
	ufo.direction = Vector2.LEFT

	ufo._update_rotation()  # Rotate UFO to face movement

	add_child(ufo)

func spawn_friendly_ship():
	var ship = friendly_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size

	# Get X spawn limits based on OuterLeft boundary position
	var left_x = $WorldCollisions/OuterBound_Left.position.x
	var right_x = left_x + 20
	var spawn_x = randf_range(left_x, right_x)

	# Spawn at bottom of screen
	var spawn_y = screen_size.y - 50

	ship.position = Vector2(spawn_x, spawn_y)
	add_child(ship)
