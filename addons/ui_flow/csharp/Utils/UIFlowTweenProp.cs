namespace UIFlow.Utils;

public enum UIFlowTweenProp
{
    PositionX, PositionY, Position,
    ModulateA, Modulate,
    ScaleX, ScaleY, Scale,
    Rotation, SizeX, SizeY, Size
}

public static class UIFlowTweenPropExtensions
{
    public static string ToPath(this UIFlowTweenProp prop) => prop switch
    {
        UIFlowTweenProp.PositionX => "position:x",
        UIFlowTweenProp.PositionY => "position:y",
        UIFlowTweenProp.Position => "position",
        UIFlowTweenProp.ModulateA => "modulate:a",
        UIFlowTweenProp.Modulate => "modulate",
        UIFlowTweenProp.ScaleX => "scale:x",
        UIFlowTweenProp.ScaleY => "scale:y",
        UIFlowTweenProp.Scale => "scale",
        UIFlowTweenProp.Rotation => "rotation",
        UIFlowTweenProp.SizeX => "size:x",
        UIFlowTweenProp.SizeY => "size:y",
        UIFlowTweenProp.Size => "size",
        _ => ""
    };
}
