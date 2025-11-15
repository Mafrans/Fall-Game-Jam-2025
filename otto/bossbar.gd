extends Node2D

@export var boss: Boss
var bar: Node2D
var bar_full_width: float

func _ready() -> void:
	bar = $Bar
	bar_full_width = bar.scale.x

func _process(_delta: float) -> void:
	bar.scale.x = (boss.health / boss.max_health)*bar_full_width
