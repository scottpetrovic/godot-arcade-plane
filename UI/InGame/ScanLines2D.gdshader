shader_type canvas_item;

uniform float base_scanline_count : hint_range(0, 1800) = 150.0;
uniform float scanline_animation_speed : hint_range(0.1, 10.0) = 1.0;
uniform float scanline_animation_intensity : hint_range(1.0, 100.0) = 20.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec2 uv_curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.3;
    
    //You can modify the numbers and try different values
    uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);
    
    //The scale part (you can delete it when you want)
    uv /= 1.2;
    
    uv = (uv/2.0) + 0.5;
    return uv;
}

void fragment()
{   
    //You can modify the *3.0, *-3.0 for a bigger or smaller 
    float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*0.0), 0.0).r;
    float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*3.0), 0.0).g;
    float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*-3.0), 0.0).b;
    
    // Oscillate the scanline count
    float animated_scanline_count = base_scanline_count + sin(TIME * scanline_animation_speed) * scanline_animation_intensity;
    
    //If you dont want scanlines you can just delete this part
    float s = sin(uv_curve(SCREEN_UV).y * animated_scanline_count * PI * 2.0);
    s = (s * 0.5 + 0.5) * 0.9 + 0.1;
    vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);
    
    COLOR = vec4(r, g, b, 1.0) * scan_line;
}