class_name RightHand
extends Node2D

var preferred_position = Vector2()
var preferred_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preferred_position = global_position
	preferred_rotation = global_rotation

func hover(delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000. + 5./7.
	var o = Vector2(
		cos(t) + cos(t*2)/2.,
		sin(t) + sin(t*2)/2.
	) * 12
	preferred_position += o
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = lerp(global_position, preferred_position, delta * 3)
	global_rotation = lerp(global_rotation, preferred_rotation, delta * 3)
