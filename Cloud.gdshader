shader_type spatial;
render_mode blend_mix;

uniform sampler2D cloud_texture : hint_default_white;
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float texture_scale = 1.0;
uniform float displacement_amount : hint_range(0.0, 10.0) = 0.02;
uniform float displacement_speed : hint_range(0.01, 1.0) = 0.05;

// Function to create a layered noise effect
float layered_noise(vec3 position, float speed) {
    float noise = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        noise += amplitude * sin(dot(position * frequency, vec3(1.0, 1.3, 0.7)) + TIME * speed);
        amplitude *= 0.5;
        frequency *= 2.0;
        position = position.yzx; // Rotate the position for each layer
    }
    
    return noise * 0.5 + 0.5; // Normalize to 0.0 - 1.0 range
}

void vertex() {
    // Complex, slow-moving displacement
    float displacement = layered_noise(VERTEX, displacement_speed);
    VERTEX += NORMAL * displacement * displacement_amount;
}

void fragment() {
    // Sample cloud texture
    vec4 cloud = texture(cloud_texture, UV * texture_scale);
    
    // Mix cloud texture with cloud color
    ALBEDO = cloud.rgb * cloud_color.rgb;
    ALPHA = cloud.a * cloud_color.a;
    
}