extends Node2D

enum SoundType {
	WOOF
	ARGH
	SCREAM
}

class Sound:
	var path: String
	var volume: float
	
	func _init(in_path: String, in_volume: float):
		self.path = in_path
		self.volume = in_volume

var sound_library = {
	SoundType.WOOF: Sound.new("res://assets/sounds/woof.wav", 0),
	SoundType.ARGH: Sound.new("res://assets/sounds/argh.wav", 0),
	SoundType.SCREAM: Sound.new("res://assets/sounds/scream.ogg", 0),
}

var stream_library = {}

var listeners = []

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

func play_sound(sound, node = null):
	if sound in stream_library:
		stream_library[sound].play()

		if node != null:
			for listener in listeners:
				listener.on_sound(sound, node)

func add_listener(listener):
	listeners.append(listener)
