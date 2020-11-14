extends Node2D

enum SoundType {
	WOOF
}

class Sound:
	var path: String
	var volume: float
	
	func _init(path: String, volume: float):
		self.path = path
		self.volume = volume

var sound_library = {
	SoundType.WOOF: Sound.new("res://assets/sounds/woof.wav", 0),
}

var stream_library = {}

func _ready():
	for sound in SoundType:
		var sound_node = AudioStreamPlayer.new()
		var sound_enum = SoundType[sound]
		var stream  = load(sound_library[sound_enum].path)
		sound_node.set_stream(stream)
		sound_node.volume_db = sound_library[sound_enum].volume
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[sound_enum] = sound_node

func play_sound(sound):
	if sound in stream_library:
		stream_library[sound].play()
