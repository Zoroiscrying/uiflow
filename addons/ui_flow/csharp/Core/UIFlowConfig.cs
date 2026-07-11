using Godot;
using UIFlow.Transitions;

namespace UIFlow.Core
{
    /// <summary>
    /// Global UIFlow configuration resource.
    /// Create one of these in your project to customize UIFlow behavior.
    /// Settings can also be configured via Project Settings → UIFlow.
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

        [Export(PropertyHint.Range, "1,200,1")] public int MaxStackDepth { get; set; } = 50;
        [Export] public bool ModalCloseOnBack { get; set; } = true;
        [Export] public string DefaultThemeName { get; set; } = "dark";
        [Export] public bool EnableObjectPooling { get; set; } = false;
        [Export(PropertyHint.Range, "1,50,1")] public int MaxPoolSize { get; set; } = 5;
    }
}
