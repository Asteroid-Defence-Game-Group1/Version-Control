extends CanvasLayer

@onready var fade_rect = $FadeRect
@export var default_color: Color = Color.BLACK

func _ready():
	fade_rect.color = default_color
	fade_rect.modulate.a = 0.0  # fully transparent
	fade_rect.visible = true

func fade_in(duration: float = 2.0) -> void:
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)

func fade_out(duration: float = 2.0) -> void:
	fade_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
