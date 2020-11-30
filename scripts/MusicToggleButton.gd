extends Button

var sound_on_texture = ImageTexture.new()
var sound_off_texture = ImageTexture.new()

func _ready():
	connect("button_up", self, "toggle_music")

	sound_on_texture.load(
		"res://assets/sprites/menu/music_on.svg")
	sound_off_texture.load(
		"res://assets/sprites/menu/music_off.svg")
		
	if AudioManager.get_music_enabled():
		self.set_button_icon(sound_on_texture)
	else:
		self.set_button_icon(sound_off_texture)

func toggle_music():
	if AudioManager.get_music_enabled():
		self.set_button_icon(sound_off_texture)
		AudioManager.set_music_enabled(false)
	else:
		self.set_button_icon(sound_on_texture)
		AudioManager.set_music_enabled(true)
