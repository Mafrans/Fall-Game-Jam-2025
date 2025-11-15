extends CharacterBody2D

var shake_amount := 0.0
var shake_duration := 0.0
var shake_timer := 0.0
var original_position: Vector2

# tuning values for gentleness
var shake_speed := 12.0
var vertical_ratio := 0.6

func _ready():
	original_position = position

func shake(amount := 4.0, duration := 0.35):
	shake_amount = amount
	shake_duration = duration
	shake_timer = duration

func smootherstep(t: float) -> float:
	# 6t⁵ − 15t⁴ + 10t³ (ultra-smooth ease-in/out)
	return t * t * t * (t * (t * 6 - 15) + 10)

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta

		var t = shake_timer / shake_duration
		t = clamp(t, 0.0, 1.0)

		# better fade curve
		var fade = smootherstep(t)

		var time := Time.get_ticks_msec() * 0.001 * shake_speed

		var offset = Vector2(
			sin(time) * shake_amount * fade,
			cos(time * 0.9) * shake_amount * vertical_ratio * fade
		)

		# slight easing toward the rest position for smooth landing
		position = position.lerp(original_position + offset, 0.25)
	else:
		# ease back to original instead of snapping
		position = position.lerp(original_position, 0.25)

func _on_player_damage_target(power: float) -> void:
	shake(power * 20, 0.2)
