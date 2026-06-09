using Godot;
using System;

namespace UIFlow.Components;

/// <summary>
/// Alert dialog — modal with OK button.
/// </summary>
public partial class UIFlowAlertDialog : Control
{
    private bool _active;

    public void Show(string title, string message, Action onClose = null)
    {
        if (_active) return;
        _active = true;

        var overlay = new ColorRect();
        overlay.SetAnchorsPreset(LayoutPreset.FullRect);
        overlay.Color = new Color(0, 0, 0, 0.5f);
        overlay.MouseFilter = MouseFilterEnum.Stop;
        AddChild(overlay);

        var panel = new PanelContainer();
        panel.CustomMinimumSize = new Vector2(500, 0);
        panel.SetAnchorsPreset(LayoutPreset.Center);
        panel.GrowHorizontal = GrowDirection.Both;
        panel.GrowVertical = GrowDirection.Both;

        var style = new StyleBoxFlat();
        style.BgColor = new Color(0.15f, 0.15f, 0.2f);
        style.SetCornerRadiusAll(8);
        style.SetContentMarginAll(20);
        panel.AddThemeStyleboxOverride("panel", style);
        AddChild(panel);

        var vbox = new VBoxContainer();
        vbox.AddThemeConstantOverride("separation", 15);
        panel.AddChild(vbox);

        var titleLabel = new Label();
        titleLabel.Text = title;
        titleLabel.HorizontalAlignment = HorizontalAlignment.Center;
        titleLabel.AddThemeFontSizeOverride("font_size", 22);
        titleLabel.AddThemeColorOverride("font_color", new Color(0.9f, 0.9f, 0.9f));
        vbox.AddChild(titleLabel);

        var msgLabel = new Label();
        msgLabel.Text = message;
        msgLabel.AutowrapMode = TextServer.AutowrapMode.WordSmart;
        msgLabel.HorizontalAlignment = HorizontalAlignment.Center;
        msgLabel.AddThemeFontSizeOverride("font_size", 16);
        msgLabel.AddThemeColorOverride("font_color", new Color(0.9f, 0.9f, 0.9f));
        vbox.AddChild(msgLabel);

        var okBtn = new Button();
        okBtn.Text = "OK";
        okBtn.CustomMinimumSize = new Vector2(120, 40);
        var btnContainer = new HBoxContainer();
        btnContainer.Alignment = BoxContainer.AlignmentMode.Center;
        btnContainer.AddChild(okBtn);
        vbox.AddChild(btnContainer);

        Action cleanup = () =>
        {
            var tween = CreateTween().SetParallel(true);
            tween.TweenProperty(overlay, "modulate:a", 0f, 0.1f);
            tween.TweenProperty(panel, "modulate:a", 0f, 0.1f);
            tween.Finished += () =>
            {
                overlay.QueueFree();
                panel.QueueFree();
                _active = false;
            };
        };

        okBtn.Pressed += () => { cleanup(); onClose?.Invoke(); };

        // Animate in
        overlay.Modulate = new Color(1, 1, 1, 0);
        panel.Modulate = new Color(1, 1, 1, 0);
        panel.Scale = new Vector2(0.9f, 0.9f);
        var tweenIn = CreateTween().SetParallel(true);
        tweenIn.TweenProperty(overlay, "modulate:a", 1f, 0.15f);
        tweenIn.TweenProperty(panel, "modulate:a", 1f, 0.15f);
        tweenIn.TweenProperty(panel, "scale", Vector2.One, 0.2f).SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Back);

        okBtn.GrabFocus();
    }
}
