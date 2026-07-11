using Godot;
using System;
using System.Threading;

namespace UIFlow.Transitions;

/// <summary>
/// Composite effect — plays multiple effects simultaneously.
/// </summary>
public partial class UIFlowCompositeEffect : UIFlowTransitionEffect
{
    [Export] public UIFlowTransitionEffect[] Effects { get; set; } = System.Array.Empty<UIFlowTransitionEffect>();

    public override void PlayEnter(Control node, Callable callback = default)
    {
        if (Effects.Length == 0) { OnFinished(callback); return; }
        node.Visible = true;
        int remaining = Effects.Length;
        foreach (var effect in Effects)
        {
            if (effect == null) { remaining--; continue; }
            Callable done = Callable.From(new Action(() =>
            {
                remaining--;
                if (remaining <= 0) OnFinished(callback);
            }));
            effect.PlayEnter(node, done);
        }
    }

    public override void PlayExit(Control node, Callable callback = default)
    {
        if (Effects.Length == 0) { OnFinished(callback); return; }
        int remaining = Effects.Length;
        foreach (var effect in Effects)
        {
            if (effect == null) { remaining--; continue; }
            Callable done = Callable.From(new Action(() =>
            {
                remaining--;
                if (remaining <= 0) OnFinished(callback);
            }));
            effect.PlayExit(node, done);
        }
    }
}
