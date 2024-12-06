shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
varying vec4 modulate;

void vertex() {
	// Called for every vertex the material is visible on.
	modulate = COLOR;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(screen_texture, SCREEN_UV);
	vec4 light_color = texture(TEXTURE, UV);
	COLOR = light_color * modulate * color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
