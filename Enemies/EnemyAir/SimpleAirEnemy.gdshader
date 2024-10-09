shader_type spatial;
render_mode unshaded;

uniform float amplitude : hint_range(0.0, 1.0) = 0.1;
uniform float frequency : hint_range(0.0, 5.0) = 1.0;
uniform float speed : hint_range(0.0, 15.0) = 1.0;
uniform vec4 top_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

varying vec3 v_original_vertex;

void vertex() {
    // Store the original vertex position
    v_original_vertex = VERTEX;
    
    // Calculate the offset based on a sine wave
    float offset = sin(VERTEX.x * frequency + TIME * speed) * amplitude;
    
    // Apply the offset to the y-coordinate of the vertex
    VERTEX.y += offset;
}

void fragment() {
    // Calculate the gradient factor based on the original vertex position
    float gradient_factor = (v_original_vertex.y + 0.5) * 0.5;
    gradient_factor = clamp(gradient_factor, 0.0, 1.0);
    
    // Interpolate between bottom and top colors
    vec4 gradient_color = mix(bottom_color, top_color, gradient_factor);
    
    // Set the gradient color and alpha, ignoring lighting
    ALBEDO = gradient_color.rgb;
    ALPHA = gradient_color.a * alpha;
    EMISSION = gradient_color.rgb;  // This makes the color self-illuminated
}