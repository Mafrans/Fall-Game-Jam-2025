extends Node2D

@export var amplitude: float = 5.0
@export var period: float = 2.0
var start_pos: Vector2
var time_acc: float = 0.0

func _ready():
	start_pos = position

func _process(delta):
	time_acc += delta
	var y_offset = amplitude * sin(2.0 * PI * time_acc / period)
	position.y = start_pos.y + y_offset
