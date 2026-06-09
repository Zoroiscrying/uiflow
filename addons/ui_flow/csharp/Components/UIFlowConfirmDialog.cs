using Godot;
using System;

namespace UIFlow.Components;

/// <summary>
/// Confirmation dialog — modal with Confirm/Cancel buttons.
/// </summary>
public partial class UIFlowConfirmDialog : Control
{
    private bool _active;

    public void Show(string title, string message, Action onConfirm = null, Action onCancel = null)
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

        var btnContainer = new HBoxContainer();
        btnContainer.Alignment = BoxContainer.AlignmentMode.Center;
        btnContainer.AddThemeConstantOverride("separation", 10);
        vbox.AddChild(btnContainer);

        var cancelBtn = new Button();
        cancelBtn.Text = "Cancel";
        cancelBtn.CustomMinimumSize = new Vector2(120, 40);
        btnContainer.AddChild(cancelBtn);

        var confirmBtn = new Button();
        confirmBtn.Text = "Confirm";
        confirmBtn.CustomMinimumSize = new Vector2(120, 40);
        btnContainer.AddChild(confirmBtn);

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

        cancelBtn.Pressed += () => { cleanup(); onCancel?.Invoke(); };
        confirmBtn.Pressed += () => { cleanup(); onConfirm?.Invoke(); };

        // Animate in
        overlay.Modulate = new Color(1, 1, 1, 0);
        panel.Modulate = new Color(1, 1, 1, 0);
        panel.Scale = new Vector2(0.9f, 0.9f);
        var tweenIn = CreateTween().SetParallel(true);
        tweenIn.TweenProperty(overlay, "modulate:a", 1f, 0.15f);
        tweenIn.TweenProperty(panel, "modulate:a", 1f, 0.15f);
        tweenIn.TweenProperty(panel, "scale", Vector2.One, 0.2f).SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Back);

        confirmBtn.GrabFocus();
    }
}
