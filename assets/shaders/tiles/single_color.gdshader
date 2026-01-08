shader_type spatial;

uniform vec3 color : source_color = vec3(0., 0., 0.);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = color;
}
