extends Node2D

@export var asteroid_scene: PackedScene
@export var hud_scene: PackedScene
@export var friendly_scene: PackedScene
@onready var player = $Player
@onready var wave_manager = $WaveManager   # <-- new wave system
@export var rain_scene: PackedScene = preload("res://Scenes/Effects/Rain.tscn")

var hud_instance
var structure_to_place: PackedScene = null
var placement_preview: Node2D = null

func _ready():      
	# Fade in from black at the start of the game
	FadeLayer.fade_in(1.0)
	if $GameMusic:
		$GameMusic.play()
	if rain_scene:
			var rain = rain_scene.instantiate()
			rain.global_position = global_position
			get_tree().current_scene.add_child(rain)
			

	# Give player access to HUD
	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	player.hud = hud_instance
	hud_instance.build_selected.connect(_on_build_selected)

	# Wave system setup
	wave_manager.connect("wave_started", Callable(self, "_on_wave_started"))
	wave_manager.connect("wave_completed", Callable(self, "_on_wave_completed"))
	wave_manager.start_next_wave()
		# Update HUD if present
func _on_build_selected(scene: PackedScene):
	structure_to_place = scene

	# Show available spots
	for spot in get_tree().get_nodes_in_group("PlacementSpot"):
		spot.highlight(true)

	# Show preview tower
	if placement_preview:
		placement_preview.queue_free()
	placement_preview = structure_to_place.instantiate()
	add_child(placement_preview)
	placement_preview.modulate = Color(1, 1, 1, 0.5)

func _unhandled_input(event):
	if placement_preview:
		placement_preview.global_position = get_global_mouse_position()

		# Left click → try to place tower
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var spot := _get_clicked_spot(get_global_mouse_position())
			if spot and not spot.occupied:
				# Check if we can place based on tower's cost
				if placement_preview.has_method("can_place") and not placement_preview.can_place():
					# Optionally: play "not enough resources" feedback here
					return  # Cannot place tower, stop early

				# Place tower at this spot
				var tower = structure_to_place.instantiate()
				tower.global_position = spot.global_position
				add_child(tower)
				spot.highlight(false)
				
				if tower.has_method("place"):
					tower.place()
					spot.highlight(false)
					
				# Mark spot as used
				spot.occupied = true
				spot.highlight(false)

				_finish_placement()
				return  # ✅ prevents accidental placement elsewhere

		# Right click → cancel
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_finish_placement()

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		PauseManager.toggle_pause()
			

func _get_clicked_spot(global_mouse: Vector2) -> Area2D:
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = global_mouse
	params.collide_with_areas = true
	# Optional: restrict to a specific layer (set in the inspector for spots)
	# params.collision_mask = 1 << 5

	var hits := space.intersect_point(params)
	for h in hits:
		var a: Object = h.collider
		if a and a is Area2D and a.is_in_group("PlacementSpot"):
			return a
	return null

func _finish_placement() -> void:
	if placement_preview:
		placement_preview.queue_free()
	placement_preview = null
	structure_to_place = null
	for spot in get_tree().get_nodes_in_group("PlacementSpot"):
		spot.highlight(false)

# WAVE SIGNAL HANDLING
func _on_wave_started(wave_number):
	print("🌊 Wave %d started!" % wave_number)

func _on_wave_completed(wave_number):
	print("🏁 Wave %d completed!" % wave_number)
