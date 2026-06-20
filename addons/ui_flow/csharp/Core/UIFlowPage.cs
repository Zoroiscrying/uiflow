using Godot;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// Base class for all UIFlow pages.
/// </summary>
[GlobalClass]
public partial class UIFlowPage : Control
{
    [Export] public bool IsModal { get; set; }
    [Export] public UIFlowTransitionEffect EnterEffect { get; set; }
    [Export] public UIFlowTransitionEffect ExitEffect { get; set; }
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
    protected virtual void OnBack() { UIFlow.Pop(); }

    // ── Framework hooks (called by Navigator via Invoke* methods) ────────────

    internal void InvokeCreated(Dictionary data) => OnCreated(data);
    internal void InvokeOpened(Dictionary data) => OnOpened(data);
    internal void InvokeHidden() => OnHidden();
    internal void InvokeShown() => OnShown();
    internal void InvokeClosed() => OnClosed();
    internal void InvokeDestroyed() => OnDestroyed();
    internal void InvokeBack() => OnBack();

    internal void PlayEnterAnimation()
    {
        EnterEffect?.PlayEnter(this);
    }

    internal void PlayExitAnimation(Callable onComplete = default)
    {
        if (ExitEffect != null)
            ExitEffect.PlayExit(this, onComplete);
        else if (onComplete.IsValid)
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
