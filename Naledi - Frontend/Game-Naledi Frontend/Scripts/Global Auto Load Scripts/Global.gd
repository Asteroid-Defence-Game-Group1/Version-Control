extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  SilentWolf.configure({
	"api_key": "L8ieeHOkED2cVu2Xd7VkJaJjnYrORwSs9vf0CZDr",
	"game_id": "asteroiddefence",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://Scenes/UI Elements/StartMenu.tscn"
  })
