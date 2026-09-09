shader_type canvas_item;
render_mode unshaded;

uniform sampler2D scene_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 pixel_grid = vec2(640.0, 360.0);

void fragment() {
	vec2 cell = (floor(SCREEN_UV * pixel_grid) + vec2(0.5)) / pixel_grid;
	COLOR = vec4(texture(scene_texture, cell).rgb, 1.0);
}
