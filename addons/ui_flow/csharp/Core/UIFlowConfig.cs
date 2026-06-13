using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// Global UIFlow configuration resource.
    /// Create one of these in your project to customize UIFlow behavior.
    /// Save as res://ui_flow_config.tres
    /// </summary>
    [Tool]
    public partial class UIFlowConfig : Resource
    {
        [Export] public string SceneDirectory { get; set; } = "res://UIScene/";
        [Export] public UIFlowTransitionType.Type DefaultTransition { get; set; } = UIFlowTransitionType.Type.FADE;
        [Export] public float DefaultTransitionDuration { get; set; } = 0.3f;
        [Export] public string BackAction { get; set; } = "ui_cancel";
        [Export] public bool AutoFocusOnPush { get; set; } = true;
        [Export] public bool RestoreFocusOnPop { get; set; } = true;
    }
}
