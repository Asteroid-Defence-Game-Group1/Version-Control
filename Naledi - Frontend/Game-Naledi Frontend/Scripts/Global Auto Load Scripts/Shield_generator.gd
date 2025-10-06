extends Area2D

@export var cost: int = 100  # Resource cost to place
@export var shield_scene: PackedScene
var placed := false

func place():
	placed = true
	_add_shields_to_existing_towers()

	# Start listening for new towers
	get_tree().node_added.connect(_on_node_added)

# Called by placement system before actual placement
func can_place() -> bool:
	var hud = get_tree().current_scene.get_node("HUD")
	if hud and hud.spend_resources(cost):
		return true
	return false

func _add_shields_to_existing_towers():
	for tower in get_tree().get_nodes_in_group("Towers"):
		if not tower.has_node("Shield"):
			var shield = shield_scene.instantiate()
			tower.add_child(shield)
			shield.name = "Shield"
			if $Shield_Sound:
				$Shield_Sound.play()


func _on_node_added(node):
	if placed and node.is_in_group("Towers") and not node.has_node("Shield"):
		var shield = shield_scene.instantiate()
		node.add_child(shield)
		shield.name = "Shield"
		if $Shield_Sound:
			$Shield_Sound.play()
