extends Area2D

@export var radius: float = 90
@export var max_health: int = 5
@export var regen_delay: float = 3.0
@export var regen_rate: float = 2.0

@export var destruction_scene: PackedScene = null
@export var recharge_scene: PackedScene = null

var shield_health: float
var is_broken: bool = false
var regen_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready():
	shield_health = max_health

	# Scale shield to match desired radius
	_fit_to_radius(radius)

	# Ensure shield is in the Shield group
	add_to_group("Shields")

	# Snap to tower if placed on one
	if owner:
		global_position = owner.global_position


func _process(delta):
	if owner:
		global_position = owner.global_position

	# Handle regen if broken
	if is_broken:
		regen_timer -= delta
		if regen_timer <= 0:
			shield_health += regen_rate * delta
			if shield_health >= max_health:
				shield_health = max_health
				_restore_shield()


func _fit_to_radius(r: float):
	# Scale collision
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = r

	# Scale sprite visually based on its texture size
	if sprite and sprite.texture:
		var tex_size = sprite.texture.get_size().x / 2.0  # half-width = base radius
		var scale_factor = r / tex_size
		sprite.scale = Vector2.ONE * scale_factor


func take_damage(amount: int = 1) -> void:
	if is_broken:
		return

	shield_health -= amount
	if shield_health <= 0:
		_break_shield()


func _break_shield():
	is_broken = true
	visible = false
	shape.set_deferred("disabled", false) 
	regen_timer = regen_delay

	if destruction_scene:
		var fx = destruction_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
	
	if recharge_scene:
		var fx = recharge_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)

func _restore_shield():
	is_broken = false
	visible = true
	shape.disabled = false
