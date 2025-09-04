extends Control

@onready var email_input = $VBoxContainer/EmailLineEdit
@onready var password_input = $VBoxContainer/PasswordLineEdit
@onready var state_label = $VBoxContainer/StateLabel
@onready var nickname_input = $VBoxContainer/NicknameLineEdit

var COLLECTION_ID = "Users"
	
func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	
	
func _on_log_in_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	var nickname = nickname_input.text
	
	Firebase.Auth.login_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Logging In"


func _on_sign_up_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	var nickname = nickname_input.text

	Firebase.Auth.signup_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Signing Up"
	
	
func on_login_succeeded(auth):
	print(auth)
	$VBoxContainer/StateLabel.text = "Login Succes"
	Firebase.Auth.save_auth(auth)
	
	PlayerData.uid = auth.localid
	var nickname_text = $VBoxContainer/NicknameLineEdit.text.strip_edges()
	
	if nickname_text == "":
		# No nickname typed → load Firestore
		await load_data()
		# Optional: show loaded nickname in the input field
		$VBoxContainer/NicknameLineEdit.text = PlayerData.nickname
	else:
		# Nickname typed → overwrite Firestore
		PlayerData.nickname = nickname_text
		await save_data()

	_change_to_start_menu()

func on_signup_succeeded(auth):
	print(auth)
	$VBoxContainer/StateLabel.text = "Sign Up Succes"
	Firebase.Auth.save_auth(auth)
	PlayerData.uid = auth.localid
	PlayerData.email = $VBoxContainer/EmailLineEdit.text
	PlayerData.nickname = $VBoxContainer/NicknameLineEdit.text

	await save_data() # <-- store new user in Firestore
	_change_to_start_menu()
	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	$VBoxContainer/StateLabel.text = "Login Failed: Error: %s" %message
	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	$VBoxContainer/StateLabel.text = "Sign Up Failed: Error: %s" %message

func _change_to_start_menu():
	
	FadeLayer.fade_out(1.0)
	FadeLayer.fade_in(1.0)
	get_tree().change_scene_to_file("res://Scenes/UI Elements/StartMenu.tscn")

func save_data():
	var auth = Firebase.Auth.auth
	PlayerData.nickname = $VBoxContainer/NicknameLineEdit.text
	PlayerData.email = $VBoxContainer/EmailLineEdit.text
	PlayerData.uid = auth.localid
	
	if PlayerData.uid:
		var data: Dictionary = {
			"user_nickname": PlayerData.nickname,
			"user_email": PlayerData.email
		}
		
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task = await collection.get_doc(PlayerData.uid)
		
		if task: # doc exists
			await collection.update(FirestoreDocument.new(data))
			print("Updated existing Firestore doc for user:", PlayerData.uid)
		else: # doc does not exist
			await collection.add(auth.localid, data) # generates a random id
			print("Added new Firestore doc (random ID)")
			
func load_data():
	var collection: FirestoreCollection = Firebase.Firestore.collection("Users")
	var task = await collection.get_doc(PlayerData.uid)
	
	if task:
		PlayerData.nickname = task.fields.get("user_nickname", "").string_value
		PlayerData.email = task.fields.get("user_email", "").string_value
		print("Loaded Firestore data for:", PlayerData.uid)
	else:
		print("No Firestore doc found for:", PlayerData.uid)
