extends TextureRect

@export var textures: Array[Texture2D]

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	texture = textures[rng.randi_range(0, len(textures) - 1)]
