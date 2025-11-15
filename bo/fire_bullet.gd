extends Area2D

class_name FireBullet

var velocity := Vector2.ZERO
var lifetime := 3.

@onready var sprite := $Sprite2D

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	sprite.animation = str(rng.randi_range(1, 3))

func _physics_process(delta: float) -> void:
	position += velocity * delta
	rotation = velocity.angle() - PI / 2
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
