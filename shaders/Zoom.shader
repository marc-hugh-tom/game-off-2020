shader_type canvas_item;

uniform float scale = 1.0;
//
void fragment() {
	vec2 sampling = UV / scale;
	vec2 offset = (1.0 - (1.0 / vec2(scale, scale))) / 2.0;
	
	vec4 rgba = texture(TEXTURE, offset+sampling);
	COLOR = rgba;
}