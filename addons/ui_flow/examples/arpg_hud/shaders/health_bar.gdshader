// Health bar gradient shader — color transitions from green to yellow to red.
shader_type canvas_item;

uniform float fill : hint_range(0.0, 1.0) = 1.0;
uniform color color_high = vec4(0.2, 0.8, 0.3, 1.0);   // Green when healthy
uniform color color_mid = vec4(0.9, 0.8, 0.2, 1.0);    // Yellow when medium
uniform color color_low = vec4(0.9, 0.2, 0.2, 1.0);    // Red when low
uniform color color_bg = vec4(0.1, 0.1, 0.15, 0.8);    // Background
uniform float pulse_speed = 3.0;
uniform float pulse_threshold = 0.25;  // Pulse when below this %

void fragment() {
    // Background
    vec4 bg = color_bg;

    // Fill area
    float fill_edge = fill;
    float in_fill = step(UV.x, fill_edge);

    // Gradient based on fill amount
    vec4 fill_color;
    if (fill > 0.5) {
        float t = (fill - 0.5) * 2.0;
        fill_color = mix(color_mid, color_high, t);
    } else {
        float t = fill * 2.0;
        fill_color = mix(color_low, color_mid, t);
    }

    // Low health pulse
    float pulse = 0.0;
    if (fill < pulse_threshold) {
        pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
        fill_color.rgb *= pulse;
    }

    // Rounded corners (simple)
    vec2 uv = UV;
    float corner_radius = 0.15;
    vec2 corner_dist = min(uv, 1.0 - uv);
    float corner = smoothstep(0.0, corner_radius, min(corner_dist.x, corner_dist.y));

    vec4 result = mix(bg, fill_color, in_fill);
    result.a *= corner;

    COLOR = result;
}
