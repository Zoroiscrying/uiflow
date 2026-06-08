using Godot;
using System.Collections.Generic;

namespace UIFlow.Utils;

public class UIFlowThemeHelper
{
    private UIFlowTheme _current;
    private readonly Dictionary<string, UIFlowTheme> _loaded = new();

    public UIFlowThemeHelper()
    {
        LoadBuiltinThemes();
    }

    private void LoadBuiltinThemes()
    {
        var dark = GD.Load<UIFlowTheme>("res://addons/ui_flow/themes/dark.tres");
        var light = GD.Load<UIFlowTheme>("res://addons/ui_flow/themes/light.tres");
        if (dark != null) _loaded["dark"] = dark;
        if (light != null) _loaded["light"] = light;
        _current = dark ?? new UIFlowTheme();
    }

    public UIFlowTheme GetCurrent() => _current;

    public void ApplyTheme(UIFlowTheme theme)
    {
        if (theme != null) _current = theme;
    }

    public void ApplyBuiltin(string name)
    {
        if (_loaded.TryGetValue(name, out var theme))
            _current = theme;
        else
            GD.PushWarning($"UIFlowThemeHelper: Unknown built-in theme '{name}'");
    }

    public Color GetColor(UIFlowTheme.ColorSlot slot) => _current?.GetColor(slot) ?? Colors.White;
}
