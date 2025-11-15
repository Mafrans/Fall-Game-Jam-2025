class_name Player
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if move.length_squared() > 0.01:
		translate(move * delta * 250)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
