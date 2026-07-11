using Godot;

namespace UIFlow.Examples;

/// <summary>
/// Example showing how to call UIFlow from C# via the GDScript autoload.
///
/// NOTE: UIFlow also provides C# wrapper classes under addons/ui_flow/csharp/,
/// but those currently require additional setup/fixes to compile in a C# project.
/// This example uses direct Godot interop and works with the standard GDScript autoload.
/// </summary>
[GlobalClass]
public partial class CSharpExample : Node
{
    public override void _Ready()
    {
        // Access the UIFlow GDScript autoload by name.
        var uiflow = Engine.GetSingleton("UIFlow") as Node;
        if (uiflow == null)
        {
            GD.PushWarning("UIFlow autoload not found.");
            return;
        }

        // Example: push a page by class name using a Callable.
        // In a real project you would obtain the GDScript reference for the page class.
        // uiflow.Call("push", pageClass);

        GD.Print("CSharpExample is ready. UIFlow autoload found: ", uiflow.Name);
    }

    public void ShowToast(string message)
    {
        var uiflowUi = Engine.GetSingleton("UIFlowUI") as Node;
        if (uiflowUi == null)
        {
            GD.PushWarning("UIFlowUI autoload not found.");
            return;
        }
        var toast = uiflowUi.Get("Toast").AsGodotObject() as Node;
        toast?.Call("show_toast", message, "info", 3.0);
    }
}
