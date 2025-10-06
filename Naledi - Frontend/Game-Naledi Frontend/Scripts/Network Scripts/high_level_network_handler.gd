extends Node

const PORT: int = 42096 # Below 65535 (16-bit unsigned max value)
const GAME_SCENE := "res://Scenes/Game/game.tscn" # ⚠️ Replace with your actual game scene path

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT)
	if err != OK:
		push_error("Failed to start server: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % PORT)

	# Go to the game scene immediately (server is ready)
	_load_game()


func start_client(ip: String = "127.0.0.1") -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		push_error("Failed to connect: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Connecting to server at %s:%d" % [ip, PORT])

	# Wait until connection succeeds before loading the game
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_connected_to_server() -> void:
	print("Successfully connected to server!")
	_load_game()


func _load_game() -> void:
	
	var scene = load(GAME_SCENE)
	FadeLayer.fade_out(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(scene)
