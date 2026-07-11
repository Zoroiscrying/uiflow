using Godot;

namespace UIFlow.Utils;

/// <summary>
/// Extension methods that smooth over differences between the Godot engine API
/// and the GodotSharp NuGet package used by command-line builds.
/// </summary>
public static class UIFlowGodotExtensions
{
    /// <summary>
    /// Checks whether a callable can still be invoked.
    /// </summary>
    public static bool IsValid(this Callable callable)
    {
        if (callable.Delegate != null)
            return true;
        return callable.Target != null && GodotObject.IsInstanceValid(callable.Target);
    }

    /// <summary>
    /// Connects a callable to the signal.
    /// </summary>
    public static void Connect(this Signal signal, Callable callable, uint flags = 0)
        => signal.Owner.Connect(signal.Name, callable, flags);

    /// <summary>
    /// Disconnects a callable from the signal.
    /// </summary>
    public static void Disconnect(this Signal signal, Callable callable)
        => signal.Owner.Disconnect(signal.Name, callable);

    /// <summary>
    /// Returns whether the callable is connected to the signal.
    /// </summary>
    public static bool IsConnected(this Signal signal, Callable callable)
        => signal.Owner.IsConnected(signal.Name, callable);
}
