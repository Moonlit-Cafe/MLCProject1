shader_type spatial;

render_mode cull_disabled;

uniform float line_thickness = 0.1;
uniform vec3 selected_color : source_color = vec3(0., 0., 1.);
uniform vec3 adj_color : source_color = vec3(1., 0., 0.);
uniform int mode : hint_enum("Unselected", "Selectable", "Selected", "Adjacent") = 0;

void fragment() {
	vec3 col;
	float alph = 1.;

	switch (mode) {
		case 0:
			col = vec3(0., 0., 0.);
			alph = 0.;
			break;
		case 1:
			col = selected_color;
			break;
		case 2:
			col = selected_color;
			break;
		case 3:
			col = adj_color;
			break;
	}

	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = col;
	ALPHA = alph;
}
