using Godot;

namespace UIFlow.Utils;

public static class UIFlowAnimator
{
    public static Tween Animate(Node node, UIFlowTweenProp prop, Variant from, Variant to,
        float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
        Tween.TransitionType trans = Tween.TransitionType.Linear)
    {
        if (!GodotObject.IsInstanceValid(node)) return null;
        var path = prop.ToPath();
        if (string.IsNullOrEmpty(path)) return null;

        node.Set(path, from);
        var tween = node.GetTree()?.CreateTween();
        tween?.TweenProperty(node, path, to, duration).SetEase(ease).SetTrans(trans);
        return tween;
    }

    public static Tween AnimateRaw(Node node, string path, Variant from, Variant to,
        float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
        Tween.TransitionType trans = Tween.TransitionType.Linear)
    {
        if (!GodotObject.IsInstanceValid(node) || string.IsNullOrEmpty(path)) return null;

        node.Set(path, from);
        var tween = node.GetTree()?.CreateTween();
        tween?.TweenProperty(node, path, to, duration).SetEase(ease).SetTrans(trans);
        return tween;
    }

    public static UIFlowSequencer Sequencer() => new UIFlowSequencer();
}
