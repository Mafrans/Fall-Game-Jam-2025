extends Node2D

@export var jolly_time := 0.0
@export var jolly_speed := 2.0 # How fast he swings back and forth
@export var jolly_angle := 5.0 # Maximum swing in degrees
var original_rotation: float

func _ready() -> void:
	original_rotation = rotation_degrees

func _process(delta: float) -> void:
	# Smooth jolly rotation
	jolly_time += delta * jolly_speed
	rotation_degrees = original_rotation + sin(jolly_time) * jolly_angle	
