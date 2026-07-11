using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Utils;

public class UIFlowSequencer
{
    public event Action Finished;

    private readonly List<Step> _steps = new();

    public UIFlowSequencer Add(Node node, UIFlowTweenProp prop, Variant from, Variant to,
        float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
        Tween.TransitionType trans = Tween.TransitionType.Linear)
    {
        _steps.Add(new Step(node, prop, from, to, duration, ease, trans, 0f));
        return this;
    }

    public UIFlowSequencer Delay(float seconds)
    {
        if (_steps.Count > 0)
            _steps[^1] = _steps[^1] with { Delay = seconds };
        return this;
    }

    public void Play() => PlayNext(0);

    private void PlayNext(int index)
    {
        if (index >= _steps.Count) { Finished?.Invoke(); return; }
        var step = _steps[index];
        if (!GodotObject.IsInstanceValid(step.Node) || !step.Node.IsInsideTree())
        {
            PlayNext(index + 1);
            return;
        }
        if (step.Delay > 0)
        {
            step.Node.GetTree().CreateTimer(step.Delay).Timeout += () => PlayStep(index);
        }
        else
        {
            PlayStep(index);
        }
    }

    private void PlayStep(int index)
    {
        if (index >= _steps.Count) { Finished?.Invoke(); return; }
        var step = _steps[index];
        if (!GodotObject.IsInstanceValid(step.Node) || !step.Node.IsInsideTree())
        {
            PlayNext(index + 1);
            return;
        }
        var tween = UIFlowAnimator.Animate(step.Node, step.Prop, step.From, step.To,
            step.Duration, step.Ease, step.Trans);
        if (tween != null)
            tween.Finished += () => PlayNext(index + 1);
        else
            PlayNext(index + 1);
    }

    private record struct Step(
        Node Node, UIFlowTweenProp Prop, Variant From, Variant To,
        float Duration, Tween.EaseType Ease, Tween.TransitionType Trans, float Delay);
}
