using Godot;
using System.Collections.Generic;

namespace UIFlow.Components;

/// <summary>
/// Toast notification system — auto-dismissing messages.
/// </summary>
public partial class UIFlowToast : Control
{
    private VBoxContainer _container;
    private readonly List<Control> _activeToasts = new();

    public override void _Ready()
    {
        MouseFilter = MouseFilterEnum.Ignore;
        _container = new VBoxContainer();
        _container.Name = "ToastContainer";
        _container.SetAnchorsPreset(LayoutPreset.FullRect);
        _container.MouseFilter = MouseFilterEnum.Ignore;
        _container.AddThemeConstantOverride("separation", 8);
        AddChild(_container);
    }

    public void Show(string message, string type = "info", float duration = 3f)
    {
        var bg = type switch
        {
            "success" => new Color(0.2f, 0.5f, 0.3f, 0.95f),
            "warning" => new Color(0.5f, 0.4f, 0.2f, 0.95f),
            "error" => new Color(0.5f, 0.2f, 0.2f, 0.95f),
            _ => new Color(0.2f, 0.3f, 0.5f, 0.95f),
        };

        var panel = new PanelContainer();
        panel.CustomMinimumSize = new Vector2(350, 0);
        panel.SizeFlagsHorizontal = SizeFlags.ExpandFill;

        var style = new StyleBoxFlat();
        style.BgColor = bg;
        style.SetCornerRadiusAll(8);
        style.SetContentMarginAll(12);
        panel.AddThemeStyleboxOverride("panel", style);

        var label = new Label();
        label.Text = message;
        label.AutowrapMode = TextServer.AutowrapMode.WordSmart;
        label.SizeFlagsHorizontal = SizeFlags.ExpandFill;
        label.AddThemeColorOverride("font_color", Colors.White);
        label.AddThemeFontSizeOverride("font_size", 16);
        panel.AddChild(label);

        _container.AddChild(panel);
        _activeToasts.Add(panel);

        panel.Modulate = new Color(1, 1, 1, 0);
        var tween = GetTree().CreateTween();
        tween.TweenProperty(panel, "modulate:a", 1f, 0.2f);

        GetTree().CreateTimer(duration).Timeout += () => Dismiss(panel);
    }

    private void Dismiss(Control toast)
    {
        if (!IsInstanceValid(toast) || !toast.IsInsideTree()) return;
        _activeToasts.Remove(toast);
        var tween = GetTree().CreateTween();
        tween.TweenProperty(toast, "modulate:a", 0f, 0.2f);
        tween.Finished += () => { if (IsInstanceValid(toast)) toast.QueueFree(); };
    }
}
