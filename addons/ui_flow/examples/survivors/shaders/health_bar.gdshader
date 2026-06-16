// Health bar gradient shader — color transitions from green to yellow to red.
shader_type canvas_item;

uniform float fill : hint_range(0.0, 1.0) = 1.0;
uniform vec4 color_high : source_color = vec4(0.2, 0.8, 0.3, 1.0);
uniform vec4 color_mid : source_color = vec4(0.9, 0.8, 0.2, 1.0);
uniform vec4 color_low : source_color = vec4(0.9, 0.2, 0.2, 1.0);
uniform vec4 color_bg : source_color = vec4(0.1, 0.1, 0.15, 0.8);
uniform float pulse_speed = 3.0;
uniform float pulse_threshold = 0.25;

void fragment() {
    float in_fill = step(UV.x, fill);

    vec4 fill_color;
    if (fill > 0.5) {
        float t = (fill - 0.5) * 2.0;
        fill_color = mix(color_mid, color_high, t);
    } else {
        float t = fill * 2.0;
        fill_color = mix(color_low, color_mid, t);
    }

    if (fill < pulse_threshold) {
        float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
        fill_color.rgb *= pulse;
    }

    vec2 corner_dist = min(UV, 1.0 - UV);
    float corner = smoothstep(0.0, 0.15, min(corner_dist.x, corner_dist.y));

    vec4 result = mix(color_bg, fill_color, in_fill);
    result.a *= corner;
    COLOR = result;
}
