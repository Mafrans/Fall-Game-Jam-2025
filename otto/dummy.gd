extends CharacterBody2D
var shake_amount := 0.0
var shake_duration := 0.0
var shake_timer := 0.0
var original_position: Vector2

# tuning values for gentleness
var shake_speed := 12.0      # lower = slower, softer
var vertical_ratio := 0.6    # less vertical movement

func _ready():
	original_position = position

func shake(amount := 4.0, duration := 0.35):
	shake_amount = amount
	shake_duration = duration
	shake_timer = duration

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta

		# more gentle fade-out curve (smoothstep)
		var t = shake_timer / shake_duration
		var fade = t * t * (3.0 - 2.0 * t)   # smoothstep

		var time := Time.get_ticks_msec() * 0.001 * shake_speed

		var offset = Vector2(
			sin(time) * shake_amount * fade,
			cos(time * 0.9) * shake_amount * vertical_ratio * fade
		)

		position = original_position + offset
	else:
		position = original_position

func _on_player_damage_target(power: float) -> void:
	shake(power * 20, 0.2)
