extends HBoxContainer

@export var heart: PackedScene;
@export var player: Player

var hearts: Array[Control] = []

func _process(delta: float) -> void:
	while true:
		if len(hearts) > player.health:
			var last_heart = hearts.pop_back()
			last_heart.queue_free()
		elif len(hearts) < player.health:
			var new_heart = heart.instantiate()
			add_child(new_heart)
			hearts.push_back(new_heart)
		else:
			break
