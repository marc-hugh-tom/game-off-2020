extends Node2D

func _ready():
	AudioManager.play_sound(AudioManager.SoundType.WOOF, self)
