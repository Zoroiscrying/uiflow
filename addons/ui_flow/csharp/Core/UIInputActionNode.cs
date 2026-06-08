using Godot;

namespace UIFlow.Core;

/// <summary>
/// Input action declaration node. Add as a child of UIFlowPage.
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
}
