shader_type canvas_item;

void fragment(){
	vec2 newuv = UV;
	newuv.x -= TIME * 0.05;
	newuv.y += TIME * 0.05;
	vec4 c = texture(TEXTURE, newuv);
	COLOR = c;
}