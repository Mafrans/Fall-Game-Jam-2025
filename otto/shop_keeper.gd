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

func _on_health_pressed() -> void:
	if pay(3):
		Global.max_health += 1
		player.health = Global.max_health
		set_dialog(DIALOGS["success"])
	else:
		set_dialog(DIALOGS["fail"])

func _on_agility_pressed() -> void:
	if pay(3):
		Global.agility += 1
		set_dialog(DIALOGS["success"])
	else:
		set_dialog(DIALOGS["fail"])

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

func player_leave() -> void:
	is_active = false
	ui.visible = false;
	

func _process(delta: float) -> void:
	var player_distance := position.distance_to(player.position)
	if player_distance < UI_DISTANCE:
		player_enter()
	elif player_distance > UI_DISTANCE + 50:
		player_leave()
		
	if is_typing:
		if typewriter.visible_ratio < 1:
			typewriter.visible_ratio += text_speed * delta;
			#visible_text_perc += text_speed * delta
			#typewriter.visible_characters = int(total_characters * visible_text_perc)
	#if distance_to()


	
