shader_type canvas_item;

const float a = 1.0;
const float b = 1.0;
uniform float t : hint_range(0, 1);
uniform vec4 red_colour : hint_color;

void fragment() {
	vec4 rgba = texture(TEXTURE, UV);
	vec2 uv = UV - vec2(0.5, 0.5);
	
	bool in_ellipse = (pow(uv.x, 2.0) / pow(a*(t*2.0-1.0), 2.0) +
		pow(uv.y, 2.0) / pow(b, 2.0) <= 0.25);
	
	if (t >= 0.5) {
		if (in_ellipse || uv.x < 0.0) {
			COLOR = rgba * red_colour;
		} else {
			COLOR = rgba;
		}
	} else {
		if ((!in_ellipse) && uv.x < 0.0) {
			COLOR = rgba * red_colour;
		} else {
			COLOR = rgba;
		}
	}
}