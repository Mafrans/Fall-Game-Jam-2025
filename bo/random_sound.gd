extends AudioStreamPlayer2D

@export var sounds: Array[AudioStream]

var rng = RandomNumberGenerator.new()

func play_random():
	stream = sounds[rng.randi_range(0, len(sounds) - 1)]
	play()
