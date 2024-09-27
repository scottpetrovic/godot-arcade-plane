shader_type canvas_item;
uniform float VchangeY = 15;

void vertex() {

	float vertPosX = cos(VERTEX.x) * 8.72f ;
	float vertPosY = sin(1.0f + VERTEX.y + VERTEX.x) * VchangeY;

	VERTEX.x += vertPosX;
	VERTEX.y += vertPosY;
}