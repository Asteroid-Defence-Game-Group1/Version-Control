extends Node2D

@export var cost: int = 75 
var placed = false

func place():
	if not placed:
		placed = true
		var hud = get_tree().current_scene.get_node("HUD")
		if hud:
			hud.register_collector()
			
func can_place() -> bool:
	var hud = get_tree().current_scene.get_node("HUD")
	if hud and hud.spend_resources(cost):
		return true
	return false
