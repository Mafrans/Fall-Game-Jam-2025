extends ProgressBar

@export var player: Player;

func _process(delta: float) -> void:
	max_value = player.max_stamina
	value = player.stamina
