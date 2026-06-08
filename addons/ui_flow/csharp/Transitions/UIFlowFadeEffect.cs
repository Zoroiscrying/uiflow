using Godot;

namespace UIFlow.Transitions;

[GlobalClass]
public partial class UIFlowFadeEffect : UIFlowTransitionEffect
{
    [Export] public float FromAlpha { get; set; }
    [Export] public float ToAlpha { get; set; } = 1f;

    public UIFlowFadeEffect() => StartsHidden = true;

    public override void PlayEnter(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        node.Visible = true;
        if (!FromCurrent) node.Modulate = new Color(1, 1, 1, FromAlpha);
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            tween.TweenProperty(node, "modulate:a", ToAlpha, Duration)
                .SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { node.Modulate = new Color(1, 1, 1, ToAlpha); OnFinished(callback); }
    }

    public override void PlayExit(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            tween.TweenProperty(node, "modulate:a", FromAlpha, Duration)
                .SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { OnFinished(callback); }
    }
}
