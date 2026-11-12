shader_type spatial;

uniform sampler2D tex : source_color, filter_nearest; // The texture for the tile.
uniform float highlight : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float col = floor(UV.x * 3.0);
	float row = floor(UV.y * 2.0);
	
	vec2 cell_uv = vec2(
		UV.x * 3.0 - col,
		UV.y * 2.0 - row
	);
	
	vec3 base = texture(tex, cell_uv).rgb;
	ALBEDO = mix(base, vec3(1.0), highlight * 0.5);
}