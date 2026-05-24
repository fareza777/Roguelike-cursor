shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float n = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
	float a = tex.a * step(dissolve_amount, n);
	COLOR = vec4(tex.rgb, a);
}
