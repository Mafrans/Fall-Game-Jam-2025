class_name Boss
extends Node2D

@export var player: Player = null

@export var max_health: float

@export var swipe_left_start: Node2D
@export var swipe_right_start: Node2D
@export var swipe_end: Node2D

@export var fire_bullet: PackedScene

@export var stone_area_center: Vector2
@export var stone_area_size: Vector2
@export var stone_scene: PackedScene

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
	body_idle()
	hands_idle()

func body_idle() -> void:
	body.look_at_player(player)
	head.look_at_player(player, body)

func hands_idle() -> void:	
	var A = body.global_position
	var theta = body.rotation
	var phi = 1/12. * PI
	var r = 250
	
	left_hand.preferred_position = A + Vector2(cos(theta+phi), sin(theta+phi)) * r
	right_hand.preferred_position = A + Vector2(cos(theta-PI-phi), sin(theta-PI-phi)) * r

	left_hand.hover(delta)
	right_hand.hover(delta)

var attacks := [stone_rain]

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
	hand.preferred_rotation = start.global_rotation
	await wait_secs(0.8)
	hand.set_hurtbox_active(true)
	hand.preferred_position = swipe_end.global_position
	hand.preferred_rotation = swipe_end.global_rotation
	await wait_secs(0.4)
	hand.set_hurtbox_active(false)
	await wait_secs(0.8)

func hover():
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 2.5 * 1000:
		var target := player.position + Vector2(0, -350.)
		right_hand.preferred_position = target
		body_idle()
		await wait_frame()
	
	var target := player.position
	right_hand.preferred_position = target + Vector2(0, -380.)
	right_hand.preferred_rotation = PI / 2
	await wait_secs(0.2)
	
	right_hand.preferred_position = target
	right_hand.set_hurtbox_active(true)
	await wait_secs(0.4)
	
	right_hand.set_hurtbox_active(false)
	await wait_secs(0.8)
	right_hand.preferred_rotation = 0.

func fire_breath():
	var inverse = rng.randf() < 0.5
	
	var start := Time.get_ticks_msec()
	var last_bullet_fire := start + 0.3 * 1000
	var head_start = head.global_position
	while true:
		var head_dir = Vector2(0, 1).rotated(mouth.global_rotation)
		head.preferred_position = head_start + head_dir * 50.0
		
		var time = Time.get_ticks_msec()
		if time - last_bullet_fire > 0.03 * 1000:
			var bullet := fire_bullet.instantiate()
			get_parent().add_child(bullet)
			(bullet as Node2D).global_position = mouth.global_position
			
			var bullet_dir = head_dir + Vector2(rng.randf_range(-0.5, 0.5), 0)
			var vel = bullet_dir.normalized() * 250
			(bullet as FireBullet).velocity = vel
			last_bullet_fire = time
		
		var t = (time - start) / 2500.;
		if t >= 1:
			break
		
		var rot = lerp(PI / 2.5, -PI / 2.5, t)
		head.preferred_rotation = -rot if inverse else rot
		
		hands_idle()
		await wait_frame()

func stone_rain() -> void:
	for i in range(4):
		var target_pos := Vector2(rng.randf_range(
			stone_area_center.x - stone_area_size.x,
			stone_area_center.x + stone_area_size.x
		), rng.randf_range(
			stone_area_center.y - stone_area_size.y,
			stone_area_center.y + stone_area_size.y
		))
		
		var stone: Stone = stone_scene.instantiate()
		get_parent().add_child(stone)
		stone.set_target(target_pos)
		await wait_secs(0.5)

func wait_frame():
	await get_tree().process_frame

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout
