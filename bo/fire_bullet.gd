extends Area2D

class_name FireBullet

var velocity := Vector2.ZERO
var lifetime := 3.

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
