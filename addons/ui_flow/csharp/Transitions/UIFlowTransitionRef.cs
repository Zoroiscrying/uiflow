using Godot;

namespace UIFlow.Transitions;

/// <summary>
/// Transition configuration Resource. Holds enter/exit effects.
/// </summary>
[GlobalClass]
public partial class UIFlowTransitionRef : Resource
{
    [Export] public UIFlowTransitionEffect EnterEffect { get; set; }
    [Export] public UIFlowTransitionEffect ExitEffect { get; set; }

    public UIFlowTransitionEffect GetEnterEffect() => EnterEffect;
    public UIFlowTransitionEffect GetExitEffect() => ExitEffect;
}
