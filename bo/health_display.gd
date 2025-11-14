extends Label

@export var player: Player;

func _process(delta: float) -> void:
	text = str(player.health) + "/" + str(player.max_health)
