extends CharacterBody2D

class_name Player

@export var boss: Boss
@export var speed: float

@export var max_stamina: float
@export var stamina_regen: float

@export var roll_speed: float
@export var roll_cooldown: float
@export var roll_duration: float
@export var roll_dropoff: float

@export var roll_stamina_drain: float
@export var roll_stamina_penalty: float
@export var roll_stamina_penalty_duration: float

@export var max_health: int
@export var max_heal_pots: int
@export var heal_pot_duration: float
@export var heal_pot_heal: int

@export var attack_duration: float
@export var attack_cooldown: float
@export var attack_forward_thrust: float
@export var attack_forward_boost: float

var last_roll := 0
var last_input := Vector2.ZERO
var is_rolling := false

var stamina := 0.
var health := 0

var last_attack := 0
var is_attacking := false

var extra_velocity := Vector2.ZERO

var is_invincible := false

var is_using_heal_pot := false
var started_heal_pot_at := 0.
var heal_pots := 0

var is_dead := false

@onready var hand = $Hand
@onready var sword = $Hand/Sword
@onready var sword_sprite = $Hand/Sword/Sprite2D
@onready var sword_collision = $Hand/Sword/CollisionShape2D

func set_sword_enabled(enabled: bool):
	sword.set_process(enabled)
	sword_sprite.visible = enabled
	sword_collision.disabled = not enabled

func _ready() -> void:
	set_sword_enabled(false)
	stamina = max_stamina
	health = max_health
	heal_pots = max_heal_pots

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	update_stamina(delta)
	update_attack()
	update_movement(delta)
	update_heal_pot(delta)
	
	velocity += extra_velocity
	extra_velocity *= 0.8
	move_and_slide()

func update_movement(delta: float):
	var time := Time.get_ticks_msec()
	var roll_t := (time - last_roll) / (roll_duration * 1000)
	roll_t *= roll_t
	if roll_t > 1 and is_rolling:
		# stopped rolling
		is_invincible = false
	is_rolling = roll_t <= 1
	
	var input := Input.get_vector("left", "right", "up", "down")
	
	if is_rolling:
		velocity = (roll_speed - roll_dropoff * roll_t) * last_input
		rotate(delta * 2 * 3.14 / roll_duration)
		is_invincible = true
		return
	elif Input.is_action_just_pressed("roll"):
		if time - last_roll > roll_cooldown * 1000:
			if stamina >= roll_stamina_drain:
				last_roll = time
				stamina -= roll_stamina_drain
	
	if input.length() > 0:
		last_input = input
	if not is_attacking:
		hand.rotation = last_input.angle()
	
	velocity = speed * input
	if is_attacking:
		velocity *= 0.25
	if is_using_heal_pot:
		velocity *= 0.25
	
	rotation = 0

func update_stamina(delta: float):
	var time := Time.get_ticks_msec()
	var penalty := (
		roll_stamina_penalty 
		if time - last_roll < roll_stamina_penalty_duration * 1000 
		else 0.0
	)
	stamina = min(max_stamina, stamina + delta * (stamina_regen * (1.0 - penalty)))

func update_attack():
	var time := Time.get_ticks_msec()
	var attack_t = (time - last_attack) / (attack_duration * 1000)
	is_attacking = attack_t <= 1
	
	if is_attacking:
		pass
	elif (
		Input.is_action_just_pressed("attack") and 
		not is_rolling and
		(time - last_attack) > attack_cooldown * 1000
	):
		last_attack = time
		extra_velocity += attack_forward_thrust * last_input
		move_and_collide(attack_forward_boost * last_input)
		set_sword_enabled(true)
	else:
		set_sword_enabled(false)

func update_heal_pot(delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.
	if is_using_heal_pot:
		if not Input.is_action_pressed("heal") or is_rolling:
			is_using_heal_pot = false
		elif time - started_heal_pot_at > heal_pot_duration:
			is_using_heal_pot = false
			health += heal_pot_heal
			heal_pots -= 1
	elif Input.is_action_pressed("heal") and heal_pots >= 1:
		is_using_heal_pot = true
		started_heal_pot_at = time

func _on_sword_body_entered(body: Node2D) -> void:
	if body == self:
		return
	
	var direction := (position - body.position).normalized()
	extra_velocity += attack_forward_thrust * direction * 1.5
	
	boss.health -= 1.
	
	Engine.time_scale = 0.2
	await wait_secs(0.08)
	Engine.time_scale = 1

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout


func _on_sword_body_exited(body: Node2D) -> void:
	pass


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
	
	is_invincible = true
	($HitTimer as Timer).start()
	
	extra_velocity -= last_input * 5.0
	
	health -= 1
	if health <= 0:
		boss.set_process(false)
		is_dead = true
		($RespawnTimer as Timer).start()


func _on_hit_timer_timeout() -> void:
	is_invincible = false


func _on_respawn_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://bo/start.tscn")
