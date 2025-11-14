class_name Body
extends Node2D

var preferred_position = Vector2()
var preferred_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preferred_position = global_position
	preferred_rotation = global_rotation
	pass # Replace with function body.

func look_at_player(player: Player) -> void:
	var vec = player.global_position - global_position
	var rot = vec.angle()
	preferred_rotation = (rot - PI/2) * 1/5

func draw_neck(head: Head) -> void:	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = lerp(global_position, preferred_position, delta * 3)
	global_rotation = lerp(global_rotation, preferred_rotation, delta * 3)
