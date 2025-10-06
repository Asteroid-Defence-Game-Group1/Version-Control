extends Control

@export var startup_scene: PackedScene
@onready var email_input = $VBoxContainer/EmailLineEdit
@onready var password_input = $VBoxContainer/PasswordLineEdit
@onready var state_label = $VBoxContainer/StateLabel

func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)


		
func _on_log_in_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	Firebase.Auth.login_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Logging In"


func _on_sign_up_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Signing Up"
	
	
func on_login_succeeded(auth):
	print(auth)
	$VBoxContainer/StateLabel.text = "Login Succes"
	Firebase.Auth.save_auth(auth)
	
	
	_change_to_start_menu()

func on_signup_succeeded(auth):
	print(auth)
	$VBoxContainer/StateLabel.text = "Sign Up Succes"
	Firebase.Auth.save_auth(auth)
	
	
	_change_to_start_menu()
	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	$VBoxContainer/StateLabel.text = "Login Failed: Error: %s" %message
	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	$VBoxContainer/StateLabel.text = "Sign Up Failed: Error: %s" %message

func _change_to_start_menu(logged_in: bool=false, signed_up: bool=false):
	FadeLayer.fade_out(1.0)
	FadeLayer.fade_in(1.0)
	get_tree().change_scene_to_file("res://Scenes/UI Elements/StartMenu.tscn")
	
