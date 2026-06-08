using Godot;

namespace UIFlow.Core;

/// <summary>
/// UIFlow Theme Resource — semantic color palette and style config.
/// </summary>
[GlobalClass]
public partial class UIFlowTheme : Resource
{
    public enum ColorSlot
    {
        Primary, Secondary, Accent,
        Error, Warning, Success, Info,
        Background, Surface,
        OnPrimary, OnSecondary, OnSurface
    }

    [ExportGroup("Brand Colors")]
    [Export] public Color Primary { get; set; } = new(0.3f, 0.5f, 0.9f);
    [Export] public Color Secondary { get; set; } = new(0.5f, 0.5f, 0.5f);
    [Export] public Color Accent { get; set; } = new(0.9f, 0.6f, 0.2f);

    [ExportGroup("Semantic Colors")]
    [Export] public Color Error { get; set; } = new(0.9f, 0.3f, 0.3f);
    [Export] public Color Warning { get; set; } = new(0.9f, 0.7f, 0.2f);
    [Export] public Color Success { get; set; } = new(0.3f, 0.8f, 0.4f);
    [Export] public Color Info { get; set; } = new(0.4f, 0.7f, 0.9f);

    [ExportGroup("Surface")]
    [Export] public Color Background { get; set; } = new(0.1f, 0.1f, 0.12f);
    [Export] public Color Surface { get; set; } = new(0.15f, 0.15f, 0.18f);

    [ExportGroup("Text")]
    [Export] public Color OnPrimary { get; set; } = Colors.White;
    [Export] public Color OnSecondary { get; set; } = Colors.White;
    [Export] public Color OnSurface { get; set; } = new(0.9f, 0.9f, 0.9f);

    [ExportGroup("Typography")]
    [Export] public Font FontRegular { get; set; }
    [Export] public Font FontBold { get; set; }
    [Export] public int FontSizeTitle { get; set; } = 28;
    [Export] public int FontSizeHeading { get; set; } = 18;
    [Export] public int FontSizeBody { get; set; } = 14;
    [Export] public int FontSizeSmall { get; set; } = 12;

    [ExportGroup("Spacing")]
    [Export] public int SpacingXs { get; set; } = 4;
    [Export] public int SpacingSm { get; set; } = 8;
    [Export] public int SpacingMd { get; set; } = 12;
    [Export] public int SpacingLg { get; set; } = 20;
    [Export] public int SpacingXl { get; set; } = 32;

    [ExportGroup("Border Radius")]
    [Export] public int RadiusSm { get; set; } = 4;
    [Export] public int RadiusMd { get; set; } = 8;
    [Export] public int RadiusLg { get; set; } = 12;

    public Color GetColor(ColorSlot slot) => slot switch
    {
        ColorSlot.Primary => Primary,
        ColorSlot.Secondary => Secondary,
        ColorSlot.Accent => Accent,
        ColorSlot.Error => Error,
        ColorSlot.Warning => Warning,
        ColorSlot.Success => Success,
        ColorSlot.Info => Info,
        ColorSlot.Background => Background,
        ColorSlot.Surface => Surface,
        ColorSlot.OnPrimary => OnPrimary,
        ColorSlot.OnSecondary => OnSecondary,
        ColorSlot.OnSurface => OnSurface,
        _ => Colors.White
    };

    public Theme BuildGodotTheme()
    {
        var t = new Theme();

        // Button
        var btnNormal = new StyleBoxFlat();
        btnNormal.BgColor = Surface;
        btnNormal.SetCornerRadiusAll(RadiusSm);
        btnNormal.SetContentMarginAll(SpacingMd);
        t.SetStylebox("normal", "Button", btnNormal);

        t.SetColor("font_color", "Button", OnSurface);
        t.SetFontSize("font_size", "Button", FontSizeBody);

        // Label
        t.SetColor("font_color", "Label", OnSurface);
        t.SetFontSize("font_size", "Label", FontSizeBody);

        // Panel
        var panelStyle = new StyleBoxFlat();
        panelStyle.BgColor = Surface;
        panelStyle.SetCornerRadiusAll(RadiusMd);
        panelStyle.SetContentMarginAll(SpacingMd);
        t.SetStylebox("panel", "Panel", panelStyle);
        t.SetStylebox("panel", "PanelContainer", panelStyle);

        // Container spacing
        t.SetConstant("separation", "HBoxContainer", SpacingSm);
        t.SetConstant("separation", "VBoxContainer", SpacingSm);
        t.SetConstant("margin_left", "MarginContainer", SpacingLg);
        t.SetConstant("margin_top", "MarginContainer", SpacingLg);
        t.SetConstant("margin_right", "MarginContainer", SpacingLg);
        t.SetConstant("margin_bottom", "MarginContainer", SpacingLg);

        // Font
        if (FontRegular != null)
        {
            t.SetFont("font", "Button", FontRegular);
            t.SetFont("font", "Label", FontRegular);
            t.SetFont("font", "LineEdit", FontRegular);
        }

        return t;
    }
}
