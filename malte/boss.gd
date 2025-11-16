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

@export var counter_threshold: float

@export var max_concurrent_attacks: int
@export var chill_chance: float

@onready var body: Body = $Body
@onready var head: Head = $Body/Head
@onready var left_hand: LeftHand = $"Body/Left Hand"
@onready var right_hand: RightHand = $"Body/Right Hand"
@onready var mouth: Node2D = $"Body/Head/Mouth"

var health := 0.
var delta := 0.

var animate_right_hand := true
var animate_left_hand := true
var animate_body := true

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	health = max_health
	state_machine()

func _process(new_delta: float) -> void:
	delta = new_delta
	if animate_body:
		body_idle()
	if animate_right_hand or animate_left_hand:
		hands_idle()

func body_idle() -> void:
	body.look_at_player(player)
	head.look_at_player(player, body)

func hands_idle() -> void:	
	var A = body.global_position
	var theta = body.rotation
	var phi = 1/12. * PI
	var r = 250
	
	if animate_right_hand:
		right_hand.preferred_position = A + Vector2(cos(theta-PI-phi), sin(theta-PI-phi)) * r
		right_hand.hover(delta)

	if animate_left_hand:
		left_hand.preferred_position = A + Vector2(cos(theta+phi), sin(theta+phi)) * r
		left_hand.hover(delta)

var attacks := [hover, fire_breath, stone_rain, swipe_right, swipe_left, double_swipe, counter]
var incompatible_attacks := {
	hover: [swipe_right, swipe_left, double_swipe],
	fire_breath: [],
	stone_rain: [],
	swipe_right: [hover, double_swipe],
	swipe_left: [hover, double_swipe],
	double_swipe: [swipe_right, swipe_left, hover],
	counter: []
}
var current_attacks := []

func state_machine():
	await wait_secs(1.5)
	while true:
		while len(current_attacks) >= max_concurrent_attacks:
			await wait_frame()
		
		if max_concurrent_attacks > 1 and rng.randf() < chill_chance:
			await wait_secs(2)
			continue
		
		await wait_secs(2 * (1 + len(current_attacks)) / max_concurrent_attacks)
		
		var available = get_available_attacks()
		if len(available) == 0:
			continue
		var attack_index := rng.randi_range(0, len(available) - 1)
		# do not await to run them concurrently
		do_attack(available[attack_index])

func get_available_attacks() -> Array:
	var result = []
	for attack in attacks:
		if current_attacks.has(attack):
			continue
		var found_incompat = false
		for incompatible in incompatible_attacks[attack]:
			if current_attacks.has(incompatible):
				found_incompat = true
				break
		if found_incompat:
			continue
		if (	
			attack == counter 
			and global_position.distance_to(player.global_position) > counter_threshold
		):
			continue
		result.append(attack)
	return result

func do_attack(method: Callable):
	current_attacks.push_back(method)
	await method.call()
	current_attacks.erase(method)

func swipe_right():
	animate_right_hand = false
	await swipe(right_hand, swipe_right_start)
	animate_right_hand = true

func swipe_left():
	animate_left_hand = false
	await swipe(left_hand, swipe_left_start)
	animate_left_hand = true

func swipe(hand: Node2D, start: Node2D):
	hand.preferred_position = start.global_position
	hand.preferred_rotation = start.global_rotation
	await wait_secs(0.8)
	hand.set_hurtbox_active(true)
	hand.preferred_position = swipe_end.global_position
	hand.preferred_rotation = swipe_end.global_rotation
	await wait_secs(0.4)
	hand.set_hurtbox_active(false)
	await wait_secs(1.6)

func double_swipe():
	animate_left_hand = false
	animate_right_hand = false
	
	var use_right_hand := rng.randf() > 0.5
	var hand: Node2D = right_hand if use_right_hand else left_hand
	var start := swipe_right_start if use_right_hand else swipe_left_start
	
	hand.preferred_position = start.global_position
	hand.preferred_rotation = start.global_rotation
	await wait_secs(0.8)
	
	hand.set_hurtbox_active(true)
	hand.preferred_position = swipe_end.global_position
	hand.preferred_rotation = swipe_end.global_rotation
	
	var other_hand = left_hand if use_right_hand else right_hand
	var other_start = swipe_left_start if use_right_hand else swipe_right_start
	
	other_hand.preferred_position = other_start.global_position
	other_hand.preferred_rotation = other_start.global_rotation
	
	await wait_secs(0.4)
	hand.set_hurtbox_active(false)
	
	await wait_secs(0.4)
	hand.preferred_position = start.global_position
	
	other_hand.set_hurtbox_active(true)
	other_hand.preferred_position = swipe_end.global_position
	other_hand.preferred_rotation = swipe_end.global_rotation
	
	await wait_secs(0.4)
	other_hand.set_hurtbox_active(false)
	
	await wait_secs(1.6)
	
	animate_left_hand = true
	animate_right_hand = true

func hover():
	animate_right_hand = false
	
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 2.5 * 1000:
		var target := player.position + Vector2(0, -350.)
		right_hand.preferred_position = target
		body_idle()
		await wait_frame()
	
	var final_target := player.position
	right_hand.preferred_position = final_target + Vector2(0, -380.)
	await wait_secs(0.4)
	
	right_hand.preferred_position = final_target
	right_hand.set_hurtbox_active(true)
	right_hand.set_punch_sprite(true)
	await wait_secs(0.4)
	
	right_hand.set_hurtbox_active(false)
	right_hand.set_punch_sprite(false)
	await wait_secs(1.6)
	right_hand.preferred_rotation = 0.
	
	animate_right_hand = true

func fire_breath():
	animate_body = false
	var inverse = rng.randf() < 0.5
	
	var start := Time.get_ticks_msec()
	var last_bullet_fire := start + 0.3 * 1000
	var head_start = head.global_position
	while true:
		var head_dir = Vector2(0, 1).rotated(mouth.global_rotation)
		head.preferred_position = head_start + head_dir * 50.0
		
		var time = Time.get_ticks_msec()
		if time - last_bullet_fire > 0.06 * 1000:
			var bullet := fire_bullet.instantiate()
			get_parent().add_child(bullet)
			(bullet as Node2D).global_position = mouth.global_position
			
			var bullet_dir = head_dir + Vector2(rng.randf_range(-0.5, 0.5), 0)
			var vel = bullet_dir.normalized() * 250
			(bullet as FireBullet).velocity = vel
			last_bullet_fire = time
			%Camera.shake(0.05, 5)
		
		var t = (time - start) / 2500.;
		if t >= 1:
			break
		
		var rot = lerp(PI / 2.5, -PI / 2.5, t)
		head.preferred_rotation = -rot if inverse else rot
		
		await wait_frame()
	
	animate_body = true

func stone_rain() -> void:
	var left = animate_left_hand
	var right = animate_right_hand
	
	if left:
		animate_left_hand = false
		left_hand.preferred_position = left_hand.global_position + Vector2(0, 75)
	if right:
		animate_right_hand = false
		right_hand.preferred_position = right_hand.global_position + Vector2(0, 75)
	await wait_secs(0.5)
	if left:
		left_hand.preferred_position = left_hand.global_position + Vector2(0, -75)
	if right:
		right_hand.preferred_position = right_hand.global_position + Vector2(0, -75)
	
	for i in range(5):
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
		await wait_secs(0.15)
	
	if right:
		animate_right_hand = true
	
	if left:
		animate_left_hand = true

func counter():
	animate_body = false
	
	if not animate_right_hand and not animate_left_hand:
		return
	
	var use_right_hand = player.global_position.x < global_position.x and animate_right_hand
	if use_right_hand:
		animate_right_hand = false
	else:
		animate_left_hand = false
	
	var hand = right_hand if use_right_hand else left_hand
	
	await wait_secs(0.8)
	hand.preferred_position = player.global_position + Vector2(0, 50)
	await wait_secs(0.4)
	
	if use_right_hand:
		animate_right_hand = true
	else:
		animate_left_hand = true
	await wait_secs(1)
	animate_body = true


func wait_frame():
	await get_tree().process_frame

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout


func _on_player_damage_target(power: float) -> void:
	health -= power
	head.on_damaged()
	%Camera.shake(0.2, 20)
