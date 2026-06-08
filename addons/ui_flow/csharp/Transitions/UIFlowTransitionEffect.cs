using Godot;

namespace UIFlow.Transitions;

/// <summary>
/// Base Resource for transition effects. Extend to create custom effects.
/// </summary>
[GlobalClass]
public partial class UIFlowTransitionEffect : Resource
{
    [Export] public bool StartsHidden { get; set; } = true;
    [Export] public bool FromCurrent { get; set; }
    [Export] public float Duration { get; set; } = 0.3f;
    [Export] public Tween.EaseType EaseType { get; set; } = Tween.EaseType.InOut;
    [Export] public Tween.TransitionType TransType { get; set; } = Tween.TransitionType.Linear;
    [Export] public float Delay { get; set; }

    public virtual void PlayEnter(Control node, Callable callback = default)
    {
        OnFinished(callback);
    }

    public virtual void PlayExit(Control node, Callable callback = default)
    {
        OnFinished(callback);
    }

    protected void OnFinished(Callable callback)
    {
        if (!callback.IsValid) return;
        if (Delay > 0)
        {
            var tree = (SceneTree)Engine.GetMainLoop();
            tree?.CreateTimer(Delay).Timeout += () => callback.Call();
        }
        else
        {
            callback.Call();
        }
    }

    protected Tween CreateTweenSafe(Node node)
    {
        if (!IsInstanceValid(node) || !node.IsInsideTree()) return null;
        return node.GetTree()?.CreateTween();
    }
}
