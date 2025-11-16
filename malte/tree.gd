class_name LobbyTree
extends Node2D

@onready var sprite: Sprite2D = $"Tree Sprite"
@export var sprites: Array[Texture2D] = []
@export var sway_min := 0.05
@export var sway_max := 0.15
@export var size_min := 0.8
@export var size_max := 1.2
var sway_amount := 0.


func _ready() -> void:
	sprite.texture = sprites[randi_range(0, 1)]
	sway_amount = randf_range(sway_min, sway_max)
	scale *= randf_range(size_min, size_max)

func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.
	var deg = t + position.y / 70.
	rotation = sway_amount * sin(deg)
