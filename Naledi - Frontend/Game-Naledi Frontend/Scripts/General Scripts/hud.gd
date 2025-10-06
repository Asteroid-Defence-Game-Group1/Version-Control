extends CanvasLayer

signal build_selected(scene)

@export var missile_launcher_scene: PackedScene
@export var machine_gun_scene: PackedScene
@export var cannon_scene: PackedScene
@export var main_base_scene: PackedScene
@export var shield_gen_scene: PackedScene
@export var upgrade_st_scene: PackedScene
@export var defence_st_scence: PackedScene
@export var pause_menu:PackedScene
@export var starting_resources: int = 100
@export var resource_generation_rate: int = 10
@export var generation_interval: float = 2.0

@onready var health_bar = $HealthBar
@onready var score_label = $ScoreContainer/ScoreLabel
@onready var missile_button = $Defence_Container/BuildPanel/HBoxContainer/MissileButton
@onready var machine_button = $Defence_Container/BuildPanel/HBoxContainer/MachineGunButton
@onready var cannon_button = $Defence_Container/BuildPanel/HBoxContainer/CannonButton
@onready var main_base_button = $Resource_Container/BuildPanel2/HBoxContainer/Main_Base_Button
@onready var shield_gen_button = $Resource_Container/BuildPanel2/HBoxContainer/Shield_Gen_Button
@onready var upgrade_st_button = $Resource_Container/BuildPanel2/HBoxContainer/Upgrade_St_Button
@onready var defence_st_button = $Resource_Container/BuildPanel2/HBoxContainer/Defence_St_button
@onready var resource_counter_label =$ResourceCountContainer/Resource_Counter


var score: int = 0
var removal_mode: bool = false
var resources: int = 0
var collector_count: int = 0   # number of placed resource collectors
var timer: Timer
var COLLECTION_ID := "Users"

func _ready():
	# Button signals
	missile_button.pressed.connect(func(): emit_signal("build_selected", missile_launcher_scene))
	machine_button.pressed.connect(func(): emit_signal("build_selected", machine_gun_scene))
	cannon_button.pressed.connect(func(): emit_signal("build_selected", cannon_scene))
	main_base_button.pressed.connect(func(): emit_signal("build_selected", main_base_scene))
	shield_gen_button.pressed.connect(func(): emit_signal("build_selected", shield_gen_scene))
	upgrade_st_button.pressed.connect(func(): emit_signal("build_selected", upgrade_st_scene))
	defence_st_button.pressed.connect(func(): emit_signal("build_selected", defence_st_scence))

	$PlayerName.text = PlayerData.nickname

	# Initialize resources and UI
	resources = starting_resources
	_update_resource_counter()

	# Create a timer for generation
	timer = Timer.new()
	timer.wait_time = generation_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_generate_resources)
	add_child(timer)
	
	load_data()
# --- Score Management ---
func add_score(points: int) -> void:
	score = max(0, score + points)
	score_label.text = str(score)

func reset_score() -> void:
	score = 0
	score_label.text = "0"

func get_score() -> int:
	return score

func set_score(value: int) -> void:
	score = value
	score_label.text = str(score)

# --- Resource Management ---
func _generate_resources():
	if collector_count > 0:
		resources += collector_count * resource_generation_rate
		_update_resource_counter()

func spend_resources(amount: int) -> bool:
	if resources >= amount:
		resources -= amount
		_update_resource_counter()
		return true
	return false

func register_collector():
	collector_count += 1

func unregister_collector():
	collector_count = max(0, collector_count - 1)

func _update_resource_counter():
	resource_counter_label.text = str(resources)

func get_resources() -> int:
	return resources

func set_resources(value: int) -> void:
	resources = value
	_update_resource_counter()

# --- Other ---
func set_health(value: int) -> void:
	health_bar.value = value

func _on_remove_button_pressed():
	removal_mode = !removal_mode
	print("Removal mode:", removal_mode)

func _on_save_button_pressed() -> void:
	$Sound_Effects/Game_Start.play()
	save_data()

func save_data():
	var auth = Firebase.Auth.auth
	if auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var data: Dictionary = {
			"user_resources": resource_counter_label,
			"user_score": score_label
		}
		var document = await collection.get_doc(auth.localid)
		if document:
			print("Document exist, update it")
			await collection.update(FirestoreDocument.new(data))
		else:
			print("Document not exist, add new")
			await collection.add(auth.localid, data)

func load_data():
	var auth = Firebase.Auth.auth
	if auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var document = await collection.get_doc(auth.localid)
		if document:
			if document.get_value("user_resources"):
				resource_counter_label.text = str(document.get_value("user_resources"))
			if document.get_value("user_score"):
				score_label.text = str(document.get_value("user_score"))
		elif document:
			print(document.error)
		else:
			print("No document found")
	else:
		return

func _on_shop_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Button_Container.visible = false
	$Resource_Container.visible = true
	$Defence_Container.visible = true
	$BackButton.visible = true
	
func _on_back_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Button_Container.visible = true
	$Resource_Container.visible = false
	$Defence_Container.visible = false
	$BackButton.visible = false
	
func _on_pause_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	PauseManager.toggle_pause()
	pause_menu.can_instantiate()
	
