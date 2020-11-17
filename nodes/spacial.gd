extends Spatial

var camera_position_noon = -1
var camera_position_midnight = 0

func _ready():
	var viewport = $Viewport
	$Viewport.set_clear_mode(Viewport.CLEAR_MODE_ALWAYS)
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()

func _process(_delta):
	update_map_scale()

func update_map_scale():
	var fraction = get_day_night_fraction_easing()
	
	var pos_range = abs(camera_position_midnight - camera_position_noon)
	var new_z = camera_position_midnight - (pos_range * fraction)
	$Camera.translation.z = new_z

func get_day_night_fraction_easing():
	return (1 + (sin(TimeManager.get_day_night_fraction() * PI / 2))) / 2
