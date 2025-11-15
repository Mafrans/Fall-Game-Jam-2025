extends CharacterBody2D

var shake_amount: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_position: Vector2

func _ready():
	original_position = position

func shake(amount: float = 5.0, duration: float = 0.2):
	shake_amount = amount
	shake_duration = duration
	shake_timer = duration

func _process(delta: float):
	if shake_timer > 0:
		shake_timer -= delta
		# random offset
		var offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		position = original_position + offset
	else:
		position = original_position
