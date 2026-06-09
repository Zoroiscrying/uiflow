using Godot;
using System;

namespace UIFlow.Transitions;

/// <summary>
/// Sequenced effect — plays multiple effects one after another.
/// </summary>
[GlobalClass]
public partial class UIFlowSequencedEffect : UIFlowTransitionEffect
{
    [Export] public UIFlowTransitionEffect[] Effects { get; set; } = Array.Empty<UIFlowTransitionEffect>();

    public override void PlayEnter(Control node, Callable callback = default)
    {
        if (Effects.Length == 0) { OnFinished(callback); return; }
        node.Visible = true;
        PlaySequence(node, callback, 0, true);
    }

    public override void PlayExit(Control node, Callable callback = default)
    {
        if (Effects.Length == 0) { OnFinished(callback); return; }
        PlaySequence(node, callback, Effects.Length - 1, false);
    }

    private void PlaySequence(Control node, Callable callback, int index, bool isEnter)
    {
        if (isEnter && index >= Effects.Length) { OnFinished(callback); return; }
        if (!isEnter && index < 0) { OnFinished(callback); return; }
        if (!IsInstanceValid(node) || !node.IsInsideTree()) { OnFinished(callback); return; }

        var effect = Effects[index];
        if (effect == null) { Advance(node, callback, index, isEnter); return; }

        Callable next = new Callable(new Action(() =>
        {
            if (IsInstanceValid(node))
                Advance(node, callback, index, isEnter);
            else
                OnFinished(callback);
        }));

        if (isEnter) effect.PlayEnter(node, next);
        else effect.PlayExit(node, next);
    }

    private void Advance(Control node, Callable callback, int currentIndex, bool isEnter)
    {
        PlaySequence(node, callback, isEnter ? currentIndex + 1 : currentIndex - 1, isEnter);
    }
}
