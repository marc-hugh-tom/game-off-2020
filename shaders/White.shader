shader_type canvas_item;

uniform sampler2D day_palette;

void fragment() {
	vec4 rgba = texture(TEXTURE, UV);
	vec4 day_colour = texture(day_palette, vec2(0.0, rgba.r));
	COLOR = vec4(1.0, 1.0, 1.0, day_colour.a);
}