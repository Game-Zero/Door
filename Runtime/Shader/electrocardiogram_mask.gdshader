shader_type canvas_item;

uniform vec4 modulate_color: source_color = vec4(1.0); // 默认白色
uniform float mask_screen_position_x = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	vec2 screen_uv = SCREEN_UV;

	if (screen_uv.x <= mask_screen_position_x) {
		COLOR = texture(TEXTURE, uv) * modulate_color;
	} else {
		discard;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
