extends Node

var listeners = []

var music_paths = {
	"main_menu": ["res://assets/music/main_menu.ogg", 0],
	"ring": ["res://assets/sounds/ring.ogg", 0],
	"ping": ["res://assets/sounds/ping.ogg", 0],
	"ping_2": ["res://assets/sounds/ping_2.ogg", 0],
	"ping_3": ["res://assets/sounds/ping_3.ogg", 0],
	"intro_chord": ["res://assets/sounds/intro_chord.ogg", 0]
}

var stream_library = {}

var current_music

var music = AudioStreamPlayer.new()

func init():
	for key in music_paths:
		var sound_node = AudioStreamPlayer.new()
		var stream  = load(music_paths[key][0])
		sound_node.set_stream(stream)
		sound_node.volume_db = music_paths[key][1]
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[key] = sound_node

func on_sound(node):
	if node != null:
		for listener in listeners:
			if listener != null:
				listener.on_sound(node)

func add_listener(listener):
	listeners.append(listener)

func remove_listener(listener):
	var index = listeners.find(listener)
	if index != -1:
		listeners.remove(index)

func play_sound(sound):
	if sound in stream_library:
		stream_library[sound].play()

func play_music(track):
	if track in stream_library:
		if current_music != track:
			if current_music != null:
				stream_library[current_music].stop()
			current_music = track
			music.set_stream(stream_library[track])
			stream_library[track].play()

func stop_music():
	if current_music != null:
		stream_library[current_music].stop()
	current_music = null

