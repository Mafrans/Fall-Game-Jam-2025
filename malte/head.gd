class_name Head
extends Node2D

var preferred_position = Vector2()
var preferred_rotation = 0

func _ready() -> void:
	preferred_position = global_position
	preferred_rotation = global_rotation
	
func look_at_player(player: Player, body: Body) -> void:
	var vec = player.global_position - global_position
	var rot = vec.angle()
	preferred_position = body.global_position + Vector2(cos(rot)*2/3, sin(rot)/2) * (vec.length_squared()/(40**2))
	preferred_rotation = (rot - PI/2.) * 2./3

func _process(delta: float) -> void:
	global_position = lerp(global_position, preferred_position, delta*3)
	global_rotation = lerp(global_rotation, preferred_rotation, delta*3)
