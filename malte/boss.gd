class_name Boss
extends Node2D

@export var player: Player = null
@onready var body: Body = $Body
@onready var head: Head = $Body/Head
@onready var left_hand: LeftHand = $"Body/Left Hand"
@onready var right_hand: RightHand = $"Body/Right Hand"

enum State {
	IDLE
}

var state = State.IDLE

# Called when the node enters the scene tree for the first timeas.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.IDLE:
		handle_state_idle(delta)
	
func handle_state_idle(delta: float) -> void:
	body.look_at_player(player)
	head.look_at_player(player, body)
	hands_idle(delta)
	

func hands_idle(delta: float) -> void:	
	var A = body.global_position
	var theta = body.rotation
	var phi = 1/12. * PI
	var r = 250
	
	left_hand.preferred_position = A + Vector2(cos(theta+phi), sin(theta+phi)) * r
	right_hand.preferred_position = A + Vector2(cos(theta-PI-phi), sin(theta-PI-phi)) * r

	left_hand.hover(delta)
	right_hand.hover(delta)
