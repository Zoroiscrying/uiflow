using Godot;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// Base class for all UIFlow pages. Extend this for your UI pages.
/// </summary>
[GlobalClass]
public partial class UIFlowPage : Control
{
    [Export] public bool IsModal { get; set; }
    [Export] public UIFlowTransitionRef EnterTransition { get; set; }
    [Export] public UIFlowTransitionRef ExitTransition { get; set; }
    [Export] public NodePath DefaultFocusPath { get; set; }

    private Dictionary<StringName, UIInputActionNode> _actionNodes = new();

    public override void _Ready()
    {
        base._Ready();
        DiscoverActions();
    }

    private void DiscoverActions()
    {
        _actionNodes.Clear();
        foreach (var child in GetChildren())
        {
            if (child is UIInputActionNode action)
                _actionNodes[action.ActionName] = action;
        }
    }

    // ── Lifecycle (override in subclasses) ───────────────────────────────────

    protected virtual void OnCreated(Dictionary data) { }
    protected virtual void OnOpened(Dictionary data) { }
    protected virtual void OnHidden() { }
    protected virtual void OnShown() { }
    protected virtual void OnClosed() { }
    protected virtual void OnDestroyed() { }

    // ── Framework hooks (called by Navigator) ────────────────────────────────

    internal void OnCreated(Dictionary data) => OnCreated(data);
    internal void OnOpened(Dictionary data) => OnOpened(data);
    internal void OnHidden() => OnHidden();
    internal void OnShown() => OnShown();
    internal void OnClosed() => OnClosed();
    internal void OnDestroyed() => OnDestroyed();

    internal void PlayEnterAnimation()
    {
        if (EnterTransition == null) return;
        var effect = EnterTransition.GetEnterEffect();
        effect?.PlayEnter(this);
    }

    internal void PlayExitAnimation(Callable onComplete = default)
    {
        if (ExitTransition == null)
        {
            onComplete.Call();
            return;
        }
        var effect = ExitTransition.GetExitEffect();
        if (effect != null)
            effect.PlayExit(this, onComplete);
        else
            onComplete.Call();
    }

    internal void ApplyDefaultFocus()
    {
        if (DefaultFocusPath == null || DefaultFocusPath.IsEmpty) return;
        var node = GetNode<Control>(DefaultFocusPath);
        node?.GrabFocus();
    }

    // ── Input Actions ────────────────────────────────────────────────────────

    public UIInputActionNode GetAction(StringName name)
        => _actionNodes.GetValueOrDefault(name);

    public UIInputActionNode[] GetAllActions()
    {
        var arr = new UIInputActionNode[_actionNodes.Count];
        _actionNodes.Values.CopyTo(arr, 0);
        return arr;
    }

    public void SetActionEnabled(StringName name, bool enabled)
    {
        if (_actionNodes.TryGetValue(name, out var action))
            action.Enabled = enabled;
    }

    public bool IsActionPressed(StringName name)
    {
        if (_actionNodes.TryGetValue(name, out var action)
            && action.Enabled
            && action.ActionType == UIInputActionNode.Type.Button)
            return Input.IsActionPressed(action.GodotAction);
        return false;
    }
}
