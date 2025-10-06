extends Control

@export var game_scene: PackedScene
@onready var play_btn        = $Base_Container/PlayButton
@onready var join_client     = $Play_Container/JoinFriendsButton
@onready var host_game       = $Play_Container/HostButton
@onready var options_btn     = $Base_Container/OptionsButton
@onready var quit_btn        = $Base_Container/QuitButton


func _ready():
	play_btn.pressed.connect(_on_play_pressed)
	join_client.pressed.connect(_on_join_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	host_game.pressed.connect(_on_host_pressed)
# Hide Resume if no saved data exists (we’ll check Firestore)

	if $Sound_Effects/StartMusic:
		$Sound_Effects/StartMusic.play()
		
func _on_play_pressed():
	$Sound_Effects/Button_Pressed.play()
	$Base_Container.visible = false
	$Play_Container.visible = true
	
func _on_campaign_button_pressed() -> void:
	$Sound_Effects/Game_Start.play()
	FadeLayer.fade_out(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(game_scene)
	
func _on_host_pressed():
	$Sound_Effects/Game_Start.play()
	HighLevelNetworkHandler.start_server()
	print("Hosting session")

func _on_join_pressed():
	$Sound_Effects/Game_Start.play()
	HighLevelNetworkHandler.start_client()
	print("Joining session")
	
func _on_back_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Base_Container.visible = true
	$Play_Container.visible = false

func _on_options_pressed():
	$Sound_Effects/Button_Pressed.play()
	$Base_Container.visible = false
	$Options_Container.visible = true

func _on_back_button_2_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Base_Container.visible = true
	$Options_Container.visible = false

func _on_change_name_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Options_Container.visible = false
	$Options_Expanded_Container.visible = true
	
func _on_submit_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	$Options_Expanded_Container/LineEdit.text = PlayerData.nickname
	print("Player Data successfully updated")
	$Options_Container.visible = true
	$Options_Expanded_Container.visible = false
	
func _on_customize_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	print("Future release...")

func _on_log_out_button_pressed() -> void:
	Firebase.Auth.logout()
	_logout()

func _on_quit_pressed():
	$Sound_Effects/Button_Pressed.play()
	get_tree().quit()

func _logout():
	$Sound_Effects/Button_Pressed.play()
	FadeLayer.fade_out(1.0)
	FadeLayer.fade_in(1.0)
	get_tree().change_scene_to_file("res://Scenes/UI Elements/Authentication.tscn")

	
func _on_leaderboard_button_pressed() -> void:
	$Sound_Effects/Button_Pressed.play()
	get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")

func _load_game() -> void:
	var scene = game_scene
	FadeLayer.fade_out(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(scene)
