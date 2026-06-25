shader_type spatial;

uniform sampler2D tex : source_color, filter_nearest; // The texture for the tile.

void fragment() {
	float col = floor(UV.x * 3.0);
	float row = floor(UV.y * 2.0);
	
	vec2 cell_uv = vec2(
		UV.x * 3.0 - col,
		UV.y * 2.0 - row
	);
	
	ALBEDO = texture(tex, cell_uv).rgb;
}