extends Control

@export var game_scene: PackedScene

@onready var play_btn        = $"CenterContainer/VBoxContainer/PlayButton"
@onready var options_btn     = $"CenterContainer/VBoxContainer/OptionsButton"
@onready var quit_btn        = $"CenterContainer/VBoxContainer/QuitButton"
@onready var nickname_label  = $CenterContainer/VBoxContainer/PlayerName

func _ready():
	play_btn.pressed.connect(_on_play_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	nickname_label.text = "Welcome, " + PlayerData.nickname + "!"

func _on_play_pressed():
	FadeLayer.fade_out(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(game_scene)

func _on_options_pressed():
	print("Options coming soon!")

func _on_log_out_button_pressed() -> void:
	Firebase.Auth.logout()
	_logout()

func _on_quit_pressed():
	get_tree().quit()

func _logout():
	FadeLayer.fade_out(1.0)
	FadeLayer.fade_in(1.0)
	get_tree().change_scene_to_file("res://Scenes/UI Elements/Authentication.tscn")
