shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.42, 0.8, 0.77, 1.0);
uniform float glow_strength : hint_range(0.0, 3.0) = 1.2;
uniform float pulse_speed = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float pulse = 0.85 + 0.15 * sin(TIME * pulse_speed);
	vec3 glow = glow_color.rgb * glow_strength * pulse;
	COLOR = vec4(tex.rgb + glow * tex.a, tex.a);
}
