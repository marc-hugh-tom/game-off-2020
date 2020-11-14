shader_type canvas_item;

uniform sampler2D day_palette;
uniform sampler2D night_palette;
uniform float t : hint_range(0, 1);

void fragment() {
	vec4 rgba = texture(TEXTURE, UV);
	vec4 day_colour = texture(day_palette, vec2(0.0, rgba.r));
	vec4 night_colour = texture(night_palette, vec2(0.0, rgba.r));
	vec4 final_colour = day_colour + (night_colour - day_colour) * t;
	
//	COLOR = day_colour; //Use to get an image to import into GIMP
	COLOR = final_colour; //Use in "production"
}