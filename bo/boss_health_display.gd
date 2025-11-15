extends Label

@export var boss: Boss;

func _process(delta: float) -> void:
	text = "Boss Health: " + str(boss.health) + "/" + str(boss.max_health)
