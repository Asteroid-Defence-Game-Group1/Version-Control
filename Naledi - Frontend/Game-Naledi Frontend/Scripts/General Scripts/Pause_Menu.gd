extends Control

@onready var resume_button = $PanelContainer/VBoxContainer/Resume
@onready var quit_button = $PanelContainer/VBoxContainer/Quit
@onready var save_button = $PanelContainer/VBoxContainer/Save
func _ready():
	visible = false  # starts hidden

	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	save_button.pressed.connect(_on_save_pressed)

	# Listen to PauseManager signal (for hotkeys or other triggers)
	PauseManager.connect("pause_toggled", Callable(self, "_on_pause_toggled"))

func _on_pause_toggled(paused: bool):
	visible = paused

func _on_resume_pressed():
	$Sound_Effects/Game_Start.play()
	PauseManager.toggle_pause()  # this will unpause and hide the menu
	
func _on_save_pressed():
	$Sound_Effects/Button_Pressed.play()
	pass
	
func _on_quit_pressed():
	$Sound_Effects/Game_Start.play()
	get_tree().paused = false
	FadeLayer.fade_out(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/UI Elements/StartMenu.tscn")
	FadeLayer.fade_in(1.0)
