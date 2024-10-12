shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(0.8, 0.8, 1.0, 0.3);
uniform float fresnel : hint_range(0.0, 1.0) = 0.2;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec3 normal = normalize(mix(NORMAL, VIEW, fresnel));
    float fresnel_effect = pow(1.0 - dot(normal, VIEW), 2.0);
    
    ALBEDO = albedo.rgb;
    ALPHA = albedo.a * fresnel_effect;
    ROUGHNESS = roughness;
    SPECULAR = 0.5;
}