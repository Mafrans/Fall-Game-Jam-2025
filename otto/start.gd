extends Node2D

var is_main_menu := true
var player: Player
var main_menu: Control
var start_btn: Button

func _ready():
	is_main_menu = !Global.has_died
	main_menu = $MainMenu
	player = $Player
	start_btn = $MainMenu/VBoxContainer/Start


func _process(delta: float) -> void:
	main_menu.visible = is_main_menu
	player.visible = !is_main_menu
	player.set_process(!is_main_menu)	
	player.set_physics_process(!is_main_menu)
	if is_main_menu:	
		start_btn.grab_focus()


func _on_start_pressed() -> void:
	is_main_menu = false
