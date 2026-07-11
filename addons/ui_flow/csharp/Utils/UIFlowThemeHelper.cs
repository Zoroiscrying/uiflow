using Godot;
using System.Collections.Generic;
using UIFlow.Resources;

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
        var names = new[] { "dark", "light", "ocean", "forest", "high_contrast", "warm" };
        UIFlowTheme fallback = null;
        foreach (var name in names)
        {
            var theme = GD.Load<UIFlowTheme>($"res://addons/ui_flow/themes/{name}.tres");
            if (theme == null) continue;
            _loaded[name] = theme;
            if (fallback == null) fallback = theme;
        }
        _current = fallback ?? new UIFlowTheme();
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

    public void SetColor(UIFlowTheme.ColorSlot slot, Color color) => _current?.SetColor(slot, color);

    public int GetFontSize(string sizeName)
    {
        if (_current == null) return 14;
        return sizeName.ToLower() switch
        {
            "title" => _current.FontSizeTitle,
            "heading" => _current.FontSizeHeading,
            "body" => _current.FontSizeBody,
            "small" => _current.FontSizeSmall,
            _ => _current.FontSizeBody
        };
    }

    public int GetSpacing(string sizeName)
    {
        if (_current == null) return 8;
        return sizeName.ToLower() switch
        {
            "xs" => _current.SpacingXs,
            "sm" => _current.SpacingSm,
            "md" => _current.SpacingMd,
            "lg" => _current.SpacingLg,
            "xl" => _current.SpacingXl,
            _ => _current.SpacingMd
        };
    }

    public int GetRadius(string sizeName)
    {
        if (_current == null) return 4;
        return sizeName.ToLower() switch
        {
            "sm" => _current.RadiusSm,
            "md" => _current.RadiusMd,
            "lg" => _current.RadiusLg,
            _ => _current.RadiusMd
        };
    }
}
