shader_type canvas_item;

uniform bool b_outglow_on = false;
uniform float outline_width = 0.06;
uniform float outline_min_alpha = 0.1;
uniform float outline_max_alpha = 1.0;
uniform vec4 modulate_color:source_color = vec4(1.0); // 默认白色
uniform vec4 outline_color:source_color = vec4(1.0); // 默认白色

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	vec4 color = texture(TEXTURE, uv) * modulate_color;

	if (b_outglow_on) {
		float Alpha = color.a;

		//中值模糊, 循环方形区域内每个像素
		for (float x = -10.0 ; x < 10.0; ++x)
		{
			for(float y = -10.0; y < 10.0; ++y)
			{
				vec2 offset = (vec2(x, y) * outline_width) / 10.0; // 计算该次采样点的uv偏移量, 除以10目的是限制采样区域在 outline_width 内
				Alpha += texture(TEXTURE, uv + offset).a; // 累加透明度值
			 }
		}

		Alpha /= 50.0; // 平均, 300 这个值可以试几次手动调节一下

		if(Alpha < outline_min_alpha) {
			discard;
		}

		Alpha = min(max(Alpha, 0), outline_max_alpha);

		if (color.a <= 0.005) {
			color.rgb = outline_color.rgb;
		}

		color.a += Alpha;
	}

	COLOR = color;
}
