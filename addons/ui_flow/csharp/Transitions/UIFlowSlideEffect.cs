using Godot;

namespace UIFlow.Transitions;

public enum SlideDirection { Left, Right, Up, Down }

[GlobalClass]
public partial class UIFlowSlideEffect : UIFlowTransitionEffect
{
    [Export] public SlideDirection Direction { get; set; } = SlideDirection.Left;

    public UIFlowSlideEffect() => StartsHidden = true;

    public override void PlayEnter(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        node.Visible = true;
        if (!FromCurrent)
        {
            var vpSize = node.GetViewportRect().Size;
            node.Position += GetOffset(vpSize);
        }
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            var target = node.Position - (FromCurrent ? Vector2.Zero : GetOffset(node.GetViewportRect().Size));
            tween.TweenProperty(node, "position", target, Duration).SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { OnFinished(callback); }
    }

    public override void PlayExit(Control node, Callable callback = default)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }
        var vpSize = node.GetViewportRect().Size;
        var target = node.Position + GetOffset(vpSize);
        var tween = CreateTweenSafe(node);
        if (tween != null)
        {
            tween.TweenProperty(node, "position", target, Duration).SetEase(EaseType).SetTrans(TransType);
            tween.Finished += () => OnFinished(callback);
        }
        else { OnFinished(callback); }
    }

    private Vector2 GetOffset(Vector2 vpSize) => Direction switch
    {
        SlideDirection.Left => new Vector2(-vpSize.X, 0),
        SlideDirection.Right => new Vector2(vpSize.X, 0),
        SlideDirection.Up => new Vector2(0, -vpSize.Y),
        SlideDirection.Down => new Vector2(0, vpSize.Y),
        _ => Vector2.Zero
    };
}
