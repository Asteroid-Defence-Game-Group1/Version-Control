extends Area2D

@onready var indicator := $Sprite2D
var occupied := false

func highlight(enable: bool) -> void:
	if not occupied:
		indicator.visible = enable
