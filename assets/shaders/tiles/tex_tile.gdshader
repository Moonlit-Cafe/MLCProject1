shader_type spatial;

uniform sampler2D tex : source_color, filter_nearest;
// Cell Notes
// Cell 1 (Front) : (0, 0)
// Cell 2 (Left)  : (0, 1)
// Cell 3 (Right) : (1, 0)
// Cell 4 (Back)  : (2, 0)
// Cell 5 (Top)   : (1, 1)
// Cell 6 (Bottom): (2, 1)

bool check_cell(vec2 uv_cell, vec2 cell_coord) {
	if (abs(uv_cell.x - cell_coord.x) <= 0.001) {
		if (abs(uv_cell.y - cell_coord.y) <= 0.001) {
			return true;
		}
	}
	
	return false;
}

void fragment() {
	vec2 cell_uv;
	
	float col = floor(UV.x * 3.0);
	float row = floor(UV.y * 2.0);
	float third = 1. / 3.;
	
	vec2 cell_pos = vec2(col, row);
	if (check_cell(cell_pos, vec2(0., 0.))) {
		cell_uv = vec2(
			(UV.x * 3. - col) / 3.,
			(UV.y * 2. - row) / 3.
		);
	} else if (check_cell(cell_pos, vec2(1., 0.))) {
		cell_uv = vec2(
			((UV.x * 3. - col) / 3.) + third,
			(UV.y * 2. - row) / 3.
		);
	} else if (check_cell(cell_pos, vec2(2., 0.))) {
		cell_uv = vec2(
			((UV.x * 3. - col) / 3.) + (2. * third),
			(UV.y * 2. - row) / 3.
		);
	} else if (check_cell(cell_pos, vec2(0., 1.))) {
		cell_uv = vec2(
			(UV.x * 3. - col) / 3.,
			((UV.y * 2. - row) / 3.) + third
		);
	} else if (check_cell(cell_pos, vec2(1., 1.))) {
		cell_uv = vec2(
			((UV.x * 3. - col) / 3.) + third,
			((UV.y * 2. - row) / 3.) + third
		);
	} else {
		cell_uv = vec2(
			(UV.x * 3. - col) / 3.,
			((UV.y * 2. - row) / 3.) + (2. * third)
		);
	}
	
	ALBEDO = texture(tex, cell_uv).rgb;
}