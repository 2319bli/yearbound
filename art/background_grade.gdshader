shader_type canvas_item;
render_mode unshaded;
uniform float separation = 0.46;
uniform vec3 air_color = vec3(0.60, 0.72, 0.69);
void fragment() {
	vec4 source = COLOR;
	// Keep the open sky blue; compress contrast where the landscape meets play.
	float depth = separation * mix(0.28, 1.0, smoothstep(0.20, 0.70, SCREEN_UV.y));
	float luminance = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 muted = mix(source.rgb, vec3(luminance), depth * 0.45);
	muted = (muted - vec3(0.5)) * (1.0 - depth * 0.50) + vec3(0.5);
	COLOR = vec4(mix(muted, air_color, depth * 0.42), source.a);
}
