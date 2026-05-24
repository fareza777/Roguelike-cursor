shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.16, 0.16, 0.23, 1.0);
uniform vec4 accent_color : source_color = vec4(0.25, 0.22, 0.35, 1.0);
uniform float noise_scale = 12.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float n = hash(floor(uv));
	vec3 col = mix(base_color.rgb, accent_color.rgb, n * 0.35);
	COLOR = vec4(col, 1.0);
}
