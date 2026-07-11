using Godot;

namespace UIFlow.Transitions;

/// <summary>
/// Predefined transition types for UIFlow.
/// </summary>
public partial class UIFlowTransitionType : RefCounted
{
    public enum Type
    {
        NONE,
        FADE,
        SLIDE_LEFT,
        SLIDE_RIGHT,
        SLIDE_UP,
        SLIDE_DOWN,
        SCALE
    }

    /// <summary>
    /// Human-readable name for each transition type.
    /// </summary>
    public static string GetName(Type type)
    {
        return type switch
        {
            Type.NONE => "None",
            Type.FADE => "Fade",
            Type.SLIDE_LEFT => "Slide Left",
            Type.SLIDE_RIGHT => "Slide Right",
            Type.SLIDE_UP => "Slide Up",
            Type.SLIDE_DOWN => "Slide Down",
            Type.SCALE => "Scale",
            _ => "Unknown"
        };
    }
}
