extends CharacterBody2D

@export var ui: Node2D
@export var player: Player
@export var typewriter: Label

var UI_DISTANCE = 200

var text_speed := 2
var is_typing := false
var is_active := false

var DIALOGS := {
	"welcome": "Welcome to the shop",
	"success": "Thank you come again",
	"fail": "Go to hell poor bastard"
}

# Returns true if the purchase was succesfull
func pay(amount: int) -> bool:
	if Global.gold < amount:
		return false
	Global.gold -= amount
	return true

func _ready() -> void:
	typewriter.autowrap_mode = TextServer.AUTOWRAP_WORD

func set_dialog(message: String) -> void:
	typewriter.text = message
	# total_characters = typewriter.text.length()
	typewriter.visible_characters = 0
	is_typing = true

func player_enter() -> void:
	if is_active:
		return
	is_active = true
	set_dialog(DIALOGS["welcome"])
	ui.visible = true;
	$UI/Shop/Health.grab_focus()
	$InteractAudio.play_random()

func player_leave() -> void:
	is_active = false
	ui.visible = false;

func mood_angry() -> void:
	pass
	# $Sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)	

func _process(delta: float) -> void:
	var player_distance := position.distance_to(player.position)
	if player_distance < UI_DISTANCE:
		player_enter()
	elif player_distance > UI_DISTANCE + 50:
		player_leave()
		
	if is_typing:
		if typewriter.visible_ratio < 1:
			typewriter.visible_ratio += text_speed * delta;

func _on_health_pressed() -> void:
	if pay(3):
		Global.max_health += 1
		player.health = Global.max_health
		set_dialog(DIALOGS["success"])
		$BuyAudio.play_random()
	else:
		set_dialog(DIALOGS["fail"])
		mood_angry()

func _on_speed_pressed() -> void:
	if pay(2):
		Global.speed += 1
		set_dialog(DIALOGS["success"])
		$BuyAudio.play_random()
	else:
		set_dialog(DIALOGS["fail"])
		mood_angry()

func _on_potion_pressed() -> void:
	if pay(6):
		Global.potion += 1
		player.max_heal_pots = Global.potion
		player.heal_pots = player.max_heal_pots
		set_dialog(DIALOGS["success"])
		$BuyAudio.play_random()
	else:
		set_dialog(DIALOGS["fail"])
		mood_angry()


func _on_agility_pressed() -> void:
	if pay(2):
		Global.agility += 1
		set_dialog(DIALOGS["success"])
		$BuyAudio.play_random()
	else:
		set_dialog(DIALOGS["fail"])
		mood_angry()


func _on_damage_pressed() -> void:
	if pay(3):
		Global.damage += 1
		set_dialog(DIALOGS["success"])
		$BuyAudio.play_random()
	else:
		set_dialog(DIALOGS["fail"])
		mood_angry()

func wait_secs(secs: float):
	await get_tree().create_timer(secs).timeout
