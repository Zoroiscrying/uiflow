using Godot;

namespace UIFlow.Core;

/// <summary>
/// Input action declaration node. Add as a child of UIFlowPage.
/// Automatically registers itself with the nearest parent UIFlowPage.
/// </summary>
[GlobalClass]
public partial class UIInputActionNode : Node
{
    public enum Type { Button, Axis1D, Axis2D, LongPress, DoubleTap, Hold, Chord }

    [Export] public StringName ActionName { get; set; } = "";
    [Export] public Type ActionType { get; set; } = Type.Button;
    [Export] public StringName GodotAction { get; set; } = "";
    [Export] public string Label { get; set; } = "";
    [Export] public bool Enabled { get; set; } = true;
    [Export] public Texture2D Icon { get; set; }
    [Export] public float HoldDuration { get; set; } = 0.5f;

    [Signal] public delegate void EnabledChangedEventHandler(bool enabled);

    public override void _Ready()
    {
        TryRegister();
    }

    public override void _ExitTree()
    {
        TryUnregister();
    }

    private void TryRegister()
    {
        var parent = GetParent();
        while (parent != null)
        {
            if (parent is UIFlowPage page)
            {
                page.RegisterAction(this);
                return;
            }
            parent = parent.GetParent();
        }
    }

    private void TryUnregister()
    {
        var parent = GetParent();
        while (parent != null)
        {
            if (parent is UIFlowPage page)
            {
                page.UnregisterAction(this);
                return;
            }
            parent = parent.GetParent();
        }
    }
}
