shader_type canvas_item;

render_mode blend_add;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float glow_strength = 1.5;
uniform float glow_radius = 2.0;
uniform float pulse_speed = 1.0;

void fragment() {
	vec2 uv_centered = UV - vec2(0.5);
	float dist = length(uv_centered * glow_radius);

	// Glow-Falloff + Pulsieren
	float glow = (1.0 - smoothstep(0.0, 1.0, dist)) * (0.5 + 0.5 * sin(TIME * pulse_speed));

	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color + glow * glow_color * glow_strength;
}
