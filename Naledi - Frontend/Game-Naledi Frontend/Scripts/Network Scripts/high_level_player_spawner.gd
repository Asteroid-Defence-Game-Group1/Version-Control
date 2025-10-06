extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
	spawn_function = _spawn_player
	multiplayer.peer_connected.connect(_on_peer_connected)

	# Also spawn for self when we connect
	if multiplayer.is_server():
		_on_peer_connected(multiplayer.get_unique_id())
	else:
		multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		print("Server spawning player for peer:", id)
		spawn({ "id": id })

func _on_connected_to_server() -> void:
	# Client spawns itself (host will already spawn others for us)
	print("Client connected, spawning self:", multiplayer.get_unique_id())
	spawn({ "id": multiplayer.get_unique_id() })

func _spawn_player(data: Dictionary) -> Node:
	var player: Node = player_scene.instantiate()

	if data.has("id"):
		player.name = str(data["id"])
		player.set_multiplayer_authority(data["id"])
		print("Spawned player:", player.name, " | Authority:", data["id"])

	return player
