shader_type canvas_item;

uniform sampler2D base_colour;
uniform vec4 swap_colour;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR == texture(base_colour, vec2(0, 0))) {
		COLOR = swap_colour;
	}
}
