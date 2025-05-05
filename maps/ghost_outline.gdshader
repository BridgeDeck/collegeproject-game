shader_type spatial;
render_mode unshaded, shadows_disabled, skip_vertex_transform;

uniform float transparency = 0.3;
uniform vec3  color : source_color = vec3(0,0,0);

void vertex() {
	VERTEX = VERTEX + VERTEX;
}

void fragment() {
	ALPHA = transparency;
	ALBEDO = color;
	EMISSION = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
