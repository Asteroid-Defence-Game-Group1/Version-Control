extends CanvasLayer

signal build_selected(scene)

@export var missile_launcher_scene: PackedScene
@export var machine_gun_scene: PackedScene
@export var cannon_scene: PackedScene

@onready var health_bar = $HealthBar
@onready var score_label = $ScoreLabel
@onready var missile_button = $BuildPanel/MissileButton
@onready var machine_button = $BuildPanel/MachineGunButton
@onready var cannon_button = $BuildPanel/CannonButton

var score = 0

func _ready():
	missile_button.pressed.connect(func(): emit_signal("build_selected", missile_launcher_scene))
	machine_button.pressed.connect(func(): emit_signal("build_selected", machine_gun_scene))
	cannon_button.pressed.connect(func(): emit_signal("build_selected", cannon_scene))
	$PlayerName.text = PlayerData.nickname
	
func set_health(value):
	$HealthBar.value = value

func add_score(points: int):
	score += points
	if score < 0:
		score = 0
	score_label.text = str(score)

func reset_score():
	score = 0
	score_label.text = "0"

func get_score():
	return score
