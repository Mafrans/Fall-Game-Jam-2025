class_name Head
extends Node2D

@export var normal_sprite: Texture2D
@export var left_sprite: Texture2D
@export var right_sprite: Texture2D
@export var damaged_sprite: Texture2D

var preferred_position = Vector2()
var preferred_rotation = 0

var is_damaged := false

@onready var sprite := $Sprite2D

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
	
	if not is_damaged:
		if global_rotation < -PI / 6.:
			sprite.texture = right_sprite
		elif global_rotation > PI / 6.:
			sprite.texture = left_sprite
		else:
			sprite.texture = normal_sprite

func on_damaged():
	is_damaged = true
	sprite.texture = damaged_sprite
	await wait_secs(0.2)
	is_damaged = false

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout
