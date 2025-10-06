extends CanvasLayer

@onready var final_score_label = $CenterContainer/VBoxContainer/HBoxContainer2/FinalScore
@onready var retry_button = $CenterContainer/VBoxContainer/HBoxContainer/RetryButton
@onready var quit_button = $CenterContainer/VBoxContainer/HBoxContainer/QuitButton

var player_name

func set_final_score(score: int):
	final_score_label.text = str(score)

func _ready():
	visible = true
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	if $GameOver:
		$GameOver.play()
	await $GameOver.finished
func _on_retry_pressed():
	get_tree().reload_current_scene()  # Restart the game

func _on_quit_pressed():
	get_tree().quit()  # Exit game


func _on_submit_button_pressed(score: int) -> void:
	if $CenterContainer/VBoxContainer/LineEdit.text != "":
		player_name = $CenterContainer/VBoxContainer/LineEdit.text
		SilentWolf.Scores.save_score(player_name, score)
		get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")
