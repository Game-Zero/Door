shader_type canvas_item;

uniform sampler2D texture_mask;
uniform float speed;

void fragment() {
	vec2 uv = UV;
	uv.x -= speed * TIME;
	vec4 color = texture(TEXTURE, uv);
	vec4 color_mask = texture(texture_mask, UV);
	color.a *= color_mask.a;
	COLOR = color;
	// Called for every pixel the material is visible on.
}

