class_name LeftHand
extends Node2D

var preferred_position = Vector2()
var preferred_rotation = 0

@onready var hurtbox := $CollisionShape2D

func _ready() -> void:
	preferred_position = global_position
	preferred_rotation = global_rotation

func set_hurtbox_active(active: bool) -> void:
	hurtbox.disabled = !active

func hover(delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.
	var o = Vector2(
		cos(t) + cos(t*2)/2.,
		sin(t) + sin(t*2)/2.
	) * 12
	preferred_position += o
	

func _process(delta: float) -> void:
	global_position = lerp(global_position, preferred_position, delta * 10)
	global_rotation = lerp(global_rotation, preferred_rotation, delta * 10)
