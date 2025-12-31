shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform float thickness : hint_range(0., 1., 0.01) = 0.04; // in UV space
uniform float feather = 0.01; // soft edge / anti-alias
uniform float dash_repeat = 12.0; // How many dashes along an edge
uniform float dash_duty : hint_range(0., 1., 0.01) = 0.55; // Portion of the dash that's "on"
uniform float speed = 1.0;
uniform float alpha = 1.0;

uniform vec4 selectable_color : source_color = vec4(0., 1., 0., 1.);
uniform vec4 selected_color : source_color = vec4(0., 0., 1., 1.);
uniform vec4 adj_color : source_color = vec4(1., 0., 0., 1.);
instance uniform int mode : hint_enum("Unselected", "Selectable", "Selected", "Adjacent") = 0;

float dash_pattern(float t) {
	float x = fract(t * dash_repeat + TIME * speed);
	return step(x, dash_duty);
}

void fragment() {
	vec4 line_color;
	vec2 uv = UV;
	
	float d_left = uv.x;
	float d_right = 1. - uv.x;
	float d_bottom = uv.y;
	float d_top = 1. - uv.y;
	
	float d = min(min(d_left, d_right), min(d_bottom, d_top));
	float border = 1. - smoothstep(thickness, thickness + feather, d);
	
	float t = 0.0;
	
	if (d_left <= d_right && d_left <= d_bottom && d_left <= d_top) {
		t = uv.y;
	} else if (d_right <= d_left && d_right <= d_bottom && d_right <= d_top) {
		t = uv.y;
	} else if (d_bottom <= d_left && d_bottom <= d_right && d_bottom <= d_top) {
		t = uv.x;
	} else {
		t = uv.x;
	}
	
	switch (mode) {
		case 0:
			line_color = vec4(0., 0., 0., 0.);
			break;
		case 1:
			line_color = selectable_color;
			break;
		case 2:
			line_color = selected_color;
			break;
		case 3:
			line_color = adj_color;
			break;
	}
	
	float dash = dash_pattern(t);
	
	float a = border * dash * line_color.a * alpha;
	
	
	
	ALBEDO = line_color.rgb;
	ALPHA = a;
}