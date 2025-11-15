extends CharacterBody2D

class_name Stone

@export var acceleration: float
@export var start_speed: float
@export var lifetime: float
@export var damage_threshold: float

var fall_velocity := Vector2.ZERO
var target_pos := Vector2.ZERO

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var hitbox: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	fall_velocity = Vector2(0, start_speed)

func set_target(target: Vector2) -> void:
	target_pos = target
	position = target + Vector2(0, -1000)
	collider.disabled = true
	hitbox.disabled = true

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		queue_free()
		return
	
	if position.y > target_pos.y:
		collider.disabled = false
		hitbox.disabled = true
		return
	
	if position.distance_to(target_pos) < damage_threshold:
		hitbox.disabled = false
	
	fall_velocity += Vector2(0, acceleration * delta)
	move_and_collide(fall_velocity * delta)
