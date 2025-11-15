class_name Boss
extends Node2D

@export var player: Player = null

@export var max_health: float

@export var swipe_left_start: Node2D
@export var swipe_right_start: Node2D
@export var swipe_end: Node2D

@export var fire_bullet: PackedScene

@onready var body: Body = $Body
@onready var head: Head = $Body/Head
@onready var left_hand: LeftHand = $"Body/Left Hand"
@onready var right_hand: RightHand = $"Body/Right Hand"
@onready var mouth: Node2D = $"Body/Head/Mouth"

var health := 0.
var delta := 0.

var is_idle := true
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	health = max_health
	state_machine()

func _process(new_delta: float) -> void:
	delta = new_delta
	if is_idle:
		idle()

func idle() -> void:
	body.look_at_player(player)
	head.look_at_player(player, body)
	hands_idle()
	

func hands_idle() -> void:	
	var A = body.global_position
	var theta = body.rotation
	var phi = 1/12. * PI
	var r = 250
	
	left_hand.preferred_position = A + Vector2(cos(theta+phi), sin(theta+phi)) * r
	right_hand.preferred_position = A + Vector2(cos(theta-PI-phi), sin(theta-PI-phi)) * r

	left_hand.hover(delta)
	right_hand.hover(delta)

var attacks := [fire_breath]

func state_machine():
	while true:
		is_idle = true
		await wait_secs(2)
		is_idle = false
		var attack_index := rng.randi_range(0, len(attacks) - 1)
		await attacks[attack_index].call()

func swipe():
	var use_right_hand := rng.randf() > 0.5;
	var hand: Node2D = right_hand if use_right_hand else left_hand
	var start := swipe_right_start if use_right_hand else swipe_left_start
	
	hand.preferred_position = start.global_position
	await wait_secs(0.8)
	hand.set_hurtbox_active(true)
	hand.preferred_position = swipe_end.global_position
	await wait_secs(0.4)
	hand.set_hurtbox_active(false)
	await wait_secs(0.8)

func hover():
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 2.5 * 1000:
		var target := player.position + Vector2(0, -250.)
		right_hand.preferred_position = target
		await wait_frame()
	
	var target := player.position
	right_hand.preferred_position = target + Vector2(0, -300.)
	await wait_secs(0.2)
	
	right_hand.preferred_position = target
	right_hand.set_hurtbox_active(true)
	await wait_secs(0.4)
	
	right_hand.set_hurtbox_active(false)
	await wait_secs(0.8)

func fire_breath():
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 3 * 1000:
		var bullet := fire_bullet.instantiate()
		get_parent().add_child(bullet)
		(bullet as Node2D).global_position = mouth.global_position
		
		var dir = Vector2(0, 1).rotated(mouth.global_rotation)
		var x_vel := rng.randf_range(-0.15, 0.15)
		var vel = dir + Vector2(x_vel, 1).normalized() * 300
		(bullet as FireBullet).velocity = vel
		await wait_secs(0.05)

func wait_frame():
	await get_tree().process_frame

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout
