extends Node2D

@export var amplitude: float = 5.0   # pixels from start position
@export var duration: float = 1.0     # seconds for one-way
var start_pos: Vector2

func _ready():
	start_pos = position
	_start_tween()

func _start_tween():
	var t = create_tween()                    # Godot 4
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "position:y", start_pos.y - amplitude, duration).as_relative()
	t.tween_callback(Callable(self, "_reverse_tween")).set_delay(0)
	# Chain repeats by reversing when finished

func _reverse_tween():
	var t = create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "position:y", start_pos.y + amplitude, duration)
	t.tween_callback(Callable(self, "_start_tween")).set_delay(0)
