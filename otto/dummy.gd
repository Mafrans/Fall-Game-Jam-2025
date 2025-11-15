extends CharacterBody2D

@export var shake_duration := 0.3
@export var shake_strength := 5.0 # degrees

var _shake_time := 0.0
var _original_rotation := 0.0

func start_shake():
	_shake_time = shake_duration
	_original_rotation = rotation_degrees

func _process(delta):
	if _shake_time > 0.0:
		_shake_time -= delta
		var t = _shake_time / shake_duration
		rotation_degrees = _original_rotation + (randf() * 2.0 - 1.0) * shake_strength * t
	else:
		rotation_degrees = _original_rotation

func _on_player_damage_target(power: float) -> void:
	start_shake()
