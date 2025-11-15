extends Label

@export var player: Player;

func _process(delta: float) -> void:
	text = "Heal Potions: " + str(player.heal_pots) + "/" + str(player.max_heal_pots)
