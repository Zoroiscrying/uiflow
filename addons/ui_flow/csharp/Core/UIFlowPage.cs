using Godot;
using System;
using System.Collections.Generic;
using UIFlow.Transitions;
using UIFlow.Utils;

namespace UIFlow.Core;

/// <summary>
/// Base class for all UIFlow pages.
/// </summary>
public partial class UIFlowPage : Control
{
    [Export] public bool IsModal { get; set; }
    [Export] public UIFlowTransitionEffect EnterEffect { get; set; }
    [Export] public UIFlowTransitionEffect ExitEffect { get; set; }
    [Export] public bool ExitReversesEnter { get; set; }
    [Export] public NodePath DefaultFocusPath { get; set; }

    private Dictionary<StringName, UIInputActionNode> _actionNodes = new();
    private readonly List<UIFlowBindUtils.UIFlowBinding> _bindings = new();

    public override void _Ready()
    {
        base._Ready();
        DiscoverActions();
    }

    private void DiscoverActions()
    {
        _actionNodes.Clear();
        foreach (var descendant in FindDescendants(this))
        {
            if (descendant is UIInputActionNode action)
                _actionNodes[action.ActionName] = action;
        }
    }

    private static List<Node> FindDescendants(Node node)
    {
        var result = new List<Node>();
        foreach (var child in node.GetChildren())
        {
            result.Add(child);
            result.AddRange(FindDescendants(child));
        }
        return result;
    }

    /// <summary>Called by UIInputActionNode when it enters the tree.</summary>
    public void RegisterAction(UIInputActionNode action)
    {
        _actionNodes[action.ActionName] = action;
    }

    /// <summary>Called by UIInputActionNode when it exits the tree.</summary>
    public void UnregisterAction(UIInputActionNode action)
    {
        _actionNodes.Remove(action.ActionName);
    }

    // ── Auto-managed Data Bindings (unbound on page close) ─────────────────────

    public UIFlowBindUtils.UIFlowBinding BindSignal(Node node, StringName propName, Signal signal)
    {
        var binding = UIFlowBindUtils.BindSignal(node, propName, signal);
        _bindings.Add(binding);
        return binding;
    }

    public UIFlowBindUtils.UIFlowBinding BindSignalT<T>(Node node, StringName propName, Signal signal, Func<T, Variant> transform)
    {
        var binding = UIFlowBindUtils.BindSignalT(node, propName, signal, transform);
        _bindings.Add(binding);
        return binding;
    }

    public UIFlowBindUtils.UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
    {
        var binding = UIFlowBindUtils.BindVisible(node, signal, predicate);
        _bindings.Add(binding);
        return binding;
    }

    public UIFlowBindUtils.UIFlowBinding BindFormat(Node node, StringName propName, Signal signal, string format)
    {
        var binding = UIFlowBindUtils.BindFormat(node, propName, signal, format);
        _bindings.Add(binding);
        return binding;
    }

    public UIFlowBindUtils.UIFlowBinding BindSlider(Godot.Range slider, Signal signal, Action<float> setter)
    {
        var binding = UIFlowBindUtils.BindSlider(slider, signal, setter);
        _bindings.Add(binding);
        return binding;
    }

    public void UnbindAll()
    {
        foreach (var binding in _bindings)
            binding?.Unbind();
        _bindings.Clear();
        // Auto-clear event bus subscriptions owned by this page
        UIFlow.Instance?.EventBus?.ClearSubscriber(this);
    }

    // ── Page State ───────────────────────────────────────────────────────────

    public enum State
    {
        Idle,        // Page instantiated but not yet in navigation stack
        Creating,    // _on_created is being called (before add_child)
        Entering,    // Enter animation is playing
        Opened,      // Fully opened, interactive, on top of stack
        Hidden,      // In stack but covered by another page
        Exiting,     // Exit animation is playing
        Closed,      // Removed from stack, awaiting cleanup
        Destroyed,   // Node has been freed
    }

    internal State _currentState = State.Idle;
    public State GetState() => _currentState;
    public bool IsActive() => _currentState is State.Entering or State.Opened;
    public bool IsAnimating() => _currentState is State.Creating or State.Entering or State.Exiting;

    // ── Lifecycle (override in subclasses) ───────────────────────────────────

    protected virtual void OnCreated(Godot.Collections.Dictionary data) { }
    protected virtual void OnOpened(Godot.Collections.Dictionary data) { }
    protected virtual void OnAfterOpened() { }     // after animation + focus
    protected virtual void OnHidden() { }
    protected virtual void OnShown() { }
    protected virtual void OnBeforeClosed() { }     // before exit animation
    protected virtual void OnClosed() { }
    protected virtual void OnDestroyed() { }
    protected virtual void OnPooled() { }      // when returned to object pool
    protected virtual void OnUnpooled() { }     // when taken from object pool for reuse
    protected virtual void OnBack() { UIFlow.Pop(); }

    // ── Framework hooks (called by Navigator via Invoke* methods) ────────────

    internal void InvokeCreated(Godot.Collections.Dictionary data) { _currentState = State.Creating; OnCreated(data); }
    internal void InvokeOpened(Godot.Collections.Dictionary data) => OnOpened(data);
    internal void InvokeAfterOpened() => OnAfterOpened();
    internal void InvokeHidden() { _currentState = State.Hidden; OnHidden(); }
    internal void InvokeShown() { _currentState = State.Opened; OnShown(); }
    internal void InvokeBeforeClosed() => OnBeforeClosed();
    internal void InvokeClosed() { _currentState = State.Closed; OnClosed(); }
    internal void InvokeDestroyed() { _currentState = State.Destroyed; OnDestroyed(); }
    internal void InvokePooled() { OnPooled(); }
    internal void InvokeUnpooled() { OnUnpooled(); }
    internal void InvokeBack() => OnBack();

    internal void PlayEnterAnimation(Callable onComplete = default)
    {
        _currentState = State.Entering;
        if (EnterEffect != null)
            EnterEffect.PlayEnter(this, onComplete);
        else if (onComplete.IsValid())
            onComplete.Call();
    }

    internal void PlayExitAnimation(Callable onComplete = default)
    {
        _currentState = State.Exiting;
        if (ExitEffect != null)
            ExitEffect.PlayExit(this, onComplete);
        else if (onComplete.IsValid())
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
