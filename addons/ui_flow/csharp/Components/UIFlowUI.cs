using Godot;

namespace UIFlow.Components;

/// <summary>
/// UIFlowUI autoload — convenience components (Toast, Confirm, Alert).
/// </summary>
public partial class UIFlowUI : Node
{
    public static UIFlowUI Instance { get; private set; }

    public UIFlowToast Toast { get; private set; }
    public UIFlowConfirmDialog Confirm { get; private set; }
    public UIFlowAlertDialog Alert { get; private set; }

    public override void _Ready()
    {
        Instance = this;

        var layer = new CanvasLayer { Name = "UIFlowComponentLayer", Layer = 100 };
        AddChild(layer);

        Toast = new UIFlowToast();
        Toast.Name = "UIFlowToast";
        Toast.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        Toast.MouseFilter = Control.MouseFilterEnum.Ignore;
        layer.AddChild(Toast);

        Confirm = new UIFlowConfirmDialog();
        Confirm.Name = "UIFlowConfirm";
        Confirm.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        layer.AddChild(Confirm);

        Alert = new UIFlowAlertDialog();
        Alert.Name = "UIFlowAlert";
        Alert.SetAnchorsPreset(Control.LayoutPreset.FullRect);
        layer.AddChild(Alert);
    }
}
