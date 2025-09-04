extends CanvasLayer

@onready var final_score_label = $CenterContainer/VBoxContainer/HBoxContainer2/FinalScore
@onready var retry_button = $CenterContainer/VBoxContainer/HBoxContainer/RetryButton
@onready var quit_button = $CenterContainer/VBoxContainer/HBoxContainer/QuitButton

func set_final_score(score: int):
	final_score_label.text = "Score: " + str(score)

func _ready():
	visible = true
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_retry_pressed():
	get_tree().reload_current_scene()  # Restart the game

func _on_quit_pressed():
	get_tree().quit()  # Exit game
