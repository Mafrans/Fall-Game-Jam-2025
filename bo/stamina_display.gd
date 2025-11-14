extends Label

@export var player: Player;

func _process(delta: float) -> void:
	text = str(player.stamina) + "/" + str(player.max_stamina)
