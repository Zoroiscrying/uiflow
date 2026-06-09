using Godot;

namespace UIFlow.Transitions;

[GlobalClass]
public partial class UIFlowScaleEffect : UIFlowTransitionEffect
{
    [Export] public Vector2 FromScale { get; set; } = Vector2.Zero;
    [Export] public Vector2 ToScale { get; set; } = Vector2.One;

    public UIFlowScaleEffect() => StartsHidden = true;

    public override void PlayEnter(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        node.Visible = true;
        if (!FromCurrent) node.Scale = FromScale;
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            tween.TweenProperty(node, "scale", ToScale, Duration).SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { node.Scale = ToScale; OnFinished(callback); }
    }

    public override void PlayExit(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            tween.TweenProperty(node, "scale", FromScale, Duration).SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { OnFinished(callback); }
    }
}
