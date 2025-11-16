extends Node2D

@export var boss: Boss

var bar: Node2D
var bar_full_width: float

@onready var rect := $Bar/ColorRect

var default_color: Color

func _ready() -> void:
	bar = $Bar
	bar_full_width = bar.scale.x
	default_color = rect.color

func _process(_delta: float) -> void:
	bar.scale.x = min(0, (boss.health / boss.max_health)*bar_full_width)


func _on_player_damage_target(power: float) -> void:
	rect.color = Color(1, 1, 1, 1)
	await wait_secs(0.1)
	rect.color = default_color

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout
