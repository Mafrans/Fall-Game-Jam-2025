extends Label

@export var player: Player;

func _process(delta: float) -> void:
	text = "Stamina: " + str(player.stamina) + "/" + str(player.max_stamina)
