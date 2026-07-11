using Godot;
using Godot.Collections;

namespace UIFlow.Resources
{
    /// <summary>
    /// UIFlow Theme Resource — semantic color palette and style config with inheritance.
    /// 
    /// All properties are stored internally in a Dictionary for extensibility.
    /// Standard properties are exposed as [Export] for editor UX.
    /// </summary>
    public partial class UIFlowTheme : Resource
    {
        public enum ColorSlot
        {
            Primary, Secondary, Accent,
            Error, Warning, Success, Info,
            Background, Surface,
            OnPrimary, OnSecondary, OnSurface
        }

        // ── Internal storage ─────────────────────────────────────────────────

        /// <summary>All theme values stored in a Dictionary for extensibility.</summary>
        private Dictionary _properties = new();

        /// <summary>Tracks which properties were explicitly set on this theme.</summary>
        private Dictionary _has = new();

        // ── Parent ───────────────────────────────────────────────────────────

        [Export] public UIFlowTheme ParentTheme { get; set; }

        // ── Theme Name ───────────────────────────────────────────────────────

        [Export]
        public string ThemeName
        {
            get => GetProperty("theme_name", "").AsString();
            set => SetProperty("theme_name", value);
        }

        // ── Internal helpers ─────────────────────────────────────────────────

        private Variant GetProp(string name, Variant defaultValue)
        {
            if (_properties.TryGetValue(name, out var value))
                return value;
            if (ParentTheme != null)
                return ParentTheme.GetProperty(name, defaultValue);
            return defaultValue;
        }

        private void SetProp(string name, Variant value)
        {
            _properties[name] = value;
            _has[name] = true;
            EmitChanged();
        }

        // ── @export properties (backed by _properties / _has) ─────────────

        [ExportGroup("Brand Colors")]
        [Export]
        public Color Primary
        {
            get => GetProp("primary", new Color(0.3f, 0.5f, 0.9f)).AsColor();
            set => SetProp("primary", value);
        }

        [Export]
        public Color Secondary
        {
            get => GetProp("secondary", new Color(0.5f, 0.5f, 0.5f)).AsColor();
            set => SetProp("secondary", value);
        }

        [Export]
        public Color Accent
        {
            get => GetProp("accent", new Color(0.9f, 0.6f, 0.2f)).AsColor();
            set => SetProp("accent", value);
        }

        [ExportGroup("Semantic Colors")]
        [Export]
        public Color Error
        {
            get => GetProp("error", new Color(0.9f, 0.3f, 0.3f)).AsColor();
            set => SetProp("error", value);
        }

        [Export]
        public Color Warning
        {
            get => GetProp("warning", new Color(0.9f, 0.7f, 0.2f)).AsColor();
            set => SetProp("warning", value);
        }

        [Export]
        public Color Success
        {
            get => GetProp("success", new Color(0.3f, 0.8f, 0.4f)).AsColor();
            set => SetProp("success", value);
        }

        [Export]
        public Color Info
        {
            get => GetProp("info", new Color(0.4f, 0.7f, 0.9f)).AsColor();
            set => SetProp("info", value);
        }

        [ExportGroup("Surface")]
        [Export]
        public Color Background
        {
            get => GetProp("background", new Color(0.1f, 0.1f, 0.12f)).AsColor();
            set => SetProp("background", value);
        }

        [Export]
        public Color Surface
        {
            get => GetProp("surface", new Color(0.15f, 0.15f, 0.18f)).AsColor();
            set => SetProp("surface", value);
        }

        [ExportGroup("Text")]
        [Export]
        public Color OnPrimary
        {
            get => GetProp("on_primary", Colors.White).AsColor();
            set => SetProp("on_primary", value);
        }

        [Export]
        public Color OnSecondary
        {
            get => GetProp("on_secondary", Colors.White).AsColor();
            set => SetProp("on_secondary", value);
        }

        [Export]
        public Color OnSurface
        {
            get => GetProp("on_surface", new Color(0.9f, 0.9f, 0.9f)).AsColor();
            set => SetProp("on_surface", value);
        }

        [ExportGroup("Typography")]
        [Export]
        public Font FontRegular
        {
            get => GetProp("font_regular", new Variant()).AsGodotObject() as Font;
            set => SetProp("font_regular", value ?? new Variant());
        }

        [Export]
        public Font FontBold
        {
            get => GetProp("font_bold", new Variant()).AsGodotObject() as Font;
            set => SetProp("font_bold", value ?? new Variant());
        }

        [Export]
        public int FontSizeTitle
        {
            get => GetProp("font_size_title", 28).AsInt32();
            set => SetProp("font_size_title", value);
        }

        [Export]
        public int FontSizeHeading
        {
            get => GetProp("font_size_heading", 18).AsInt32();
            set => SetProp("font_size_heading", value);
        }

        [Export]
        public int FontSizeBody
        {
            get => GetProp("font_size_body", 14).AsInt32();
            set => SetProp("font_size_body", value);
        }

        [Export]
        public int FontSizeSmall
        {
            get => GetProp("font_size_small", 12).AsInt32();
            set => SetProp("font_size_small", value);
        }

        [ExportGroup("Spacing")]
        [Export]
        public int SpacingXs
        {
            get => GetProp("spacing_xs", 4).AsInt32();
            set => SetProp("spacing_xs", value);
        }

        [Export]
        public int SpacingSm
        {
            get => GetProp("spacing_sm", 8).AsInt32();
            set => SetProp("spacing_sm", value);
        }

        [Export]
        public int SpacingMd
        {
            get => GetProp("spacing_md", 12).AsInt32();
            set => SetProp("spacing_md", value);
        }

        [Export]
        public int SpacingLg
        {
            get => GetProp("spacing_lg", 20).AsInt32();
            set => SetProp("spacing_lg", value);
        }

        [Export]
        public int SpacingXl
        {
            get => GetProp("spacing_xl", 32).AsInt32();
            set => SetProp("spacing_xl", value);
        }

        [ExportGroup("Border Radius")]
        [Export]
        public int RadiusSm
        {
            get => GetProp("radius_sm", 4).AsInt32();
            set => SetProp("radius_sm", value);
        }

        [Export]
        public int RadiusMd
        {
            get => GetProp("radius_md", 8).AsInt32();
            set => SetProp("radius_md", value);
        }

        [Export]
        public int RadiusLg
        {
            get => GetProp("radius_lg", 12).AsInt32();
            set => SetProp("radius_lg", value);
        }

        // ── Public API ───────────────────────────────────────────────────────

        /// <summary>
        /// Get any property by name, walking the parent chain if not set locally.
        /// </summary>
        public Variant GetProperty(string propertyName, Variant defaultValue = new())
        {
            if (_properties.TryGetValue(propertyName, out var value))
                return value;
            if (ParentTheme != null)
                return ParentTheme.GetProperty(propertyName, defaultValue);
            return defaultValue;
        }

        /// <summary>
        /// Set any property by name.
        /// </summary>
        public void SetProperty(string propertyName, Variant value)
        {
            _properties[propertyName] = value;
            _has[propertyName] = true;
            EmitChanged();
        }

        /// <summary>
        /// Check if this theme has a local override for a given property.
        /// </summary>
        public bool HasOverride(string propertyName)
        {
            return _has.ContainsKey(propertyName);
        }

        /// <summary>
        /// Remove a local override, reverting to parent/inherited value.
        /// </summary>
        public void RemoveOverride(string propertyName)
        {
            _properties.Remove(propertyName);
            _has.Remove(propertyName);
            EmitChanged();
        }

        /// <summary>
        /// Get all property names that have local overrides.
        /// </summary>
        public Array GetLocalKeys()
        {
            return new Array(_has.Keys);
        }

        // ── Resolved getters (backward compatible, delegate to GetProperty) ──

        public Color ResolvedPrimary => GetProperty("primary", new Color(0.3f, 0.5f, 0.9f)).AsColor();
        public Color ResolvedSecondary => GetProperty("secondary", new Color(0.5f, 0.5f, 0.5f)).AsColor();
        public Color ResolvedAccent => GetProperty("accent", new Color(0.9f, 0.6f, 0.2f)).AsColor();
        public Color ResolvedError => GetProperty("error", new Color(0.9f, 0.3f, 0.3f)).AsColor();
        public Color ResolvedWarning => GetProperty("warning", new Color(0.9f, 0.7f, 0.2f)).AsColor();
        public Color ResolvedSuccess => GetProperty("success", new Color(0.3f, 0.8f, 0.4f)).AsColor();
        public Color ResolvedInfo => GetProperty("info", new Color(0.4f, 0.7f, 0.9f)).AsColor();
        public Color ResolvedBackground => GetProperty("background", new Color(0.1f, 0.1f, 0.12f)).AsColor();
        public Color ResolvedSurface => GetProperty("surface", new Color(0.15f, 0.15f, 0.18f)).AsColor();
        public Color ResolvedOnPrimary => GetProperty("on_primary", Colors.White).AsColor();
        public Color ResolvedOnSecondary => GetProperty("on_secondary", Colors.White).AsColor();
        public Color ResolvedOnSurface => GetProperty("on_surface", new Color(0.9f, 0.9f, 0.9f)).AsColor();
        public Font ResolvedFontRegular => GetProperty("font_regular", new Variant()).AsGodotObject() as Font;
        public Font ResolvedFontBold => GetProperty("font_bold", new Variant()).AsGodotObject() as Font;
        public int ResolvedFontSizeTitle => GetProperty("font_size_title", 28).AsInt32();
        public int ResolvedFontSizeHeading => GetProperty("font_size_heading", 18).AsInt32();
        public int ResolvedFontSizeBody => GetProperty("font_size_body", 14).AsInt32();
        public int ResolvedFontSizeSmall => GetProperty("font_size_small", 12).AsInt32();
        public int ResolvedSpacingXs => GetProperty("spacing_xs", 4).AsInt32();
        public int ResolvedSpacingSm => GetProperty("spacing_sm", 8).AsInt32();
        public int ResolvedSpacingMd => GetProperty("spacing_md", 12).AsInt32();
        public int ResolvedSpacingLg => GetProperty("spacing_lg", 20).AsInt32();
        public int ResolvedSpacingXl => GetProperty("spacing_xl", 32).AsInt32();
        public int ResolvedRadiusSm => GetProperty("radius_sm", 4).AsInt32();
        public int ResolvedRadiusMd => GetProperty("radius_md", 8).AsInt32();
        public int ResolvedRadiusLg => GetProperty("radius_lg", 12).AsInt32();

        /// <summary>
        /// Get resolved color by slot, walking parent chain.
        /// </summary>
        public Color GetColor(ColorSlot slot)
        {
            return slot switch
            {
                ColorSlot.Primary => ResolvedPrimary,
                ColorSlot.Secondary => ResolvedSecondary,
                ColorSlot.Accent => ResolvedAccent,
                ColorSlot.Error => ResolvedError,
                ColorSlot.Warning => ResolvedWarning,
                ColorSlot.Success => ResolvedSuccess,
                ColorSlot.Info => ResolvedInfo,
                ColorSlot.Background => ResolvedBackground,
                ColorSlot.Surface => ResolvedSurface,
                ColorSlot.OnPrimary => ResolvedOnPrimary,
                ColorSlot.OnSecondary => ResolvedOnSecondary,
                ColorSlot.OnSurface => ResolvedOnSurface,
                _ => Colors.White
            };
        }

        /// <summary>
        /// Set color by slot.
        /// </summary>
        public void SetColor(ColorSlot slot, Color color)
        {
            switch (slot)
            {
                case ColorSlot.Primary: Primary = color; break;
                case ColorSlot.Secondary: Secondary = color; break;
                case ColorSlot.Accent: Accent = color; break;
                case ColorSlot.Error: Error = color; break;
                case ColorSlot.Warning: Warning = color; break;
                case ColorSlot.Success: Success = color; break;
                case ColorSlot.Info: Info = color; break;
                case ColorSlot.Background: Background = color; break;
                case ColorSlot.Surface: Surface = color; break;
                case ColorSlot.OnPrimary: OnPrimary = color; break;
                case ColorSlot.OnSecondary: OnSecondary = color; break;
                case ColorSlot.OnSurface: OnSurface = color; break;
            }
        }

        public Theme BuildGodotTheme()
        {
            var t = new Theme();

            // Button - normal, hover, pressed, focus
            var btnNormal = new StyleBoxFlat();
            btnNormal.BgColor = ResolvedSurface;
            btnNormal.SetCornerRadiusAll(ResolvedRadiusSm);
            btnNormal.SetContentMarginAll(ResolvedSpacingMd);
            t.SetStylebox("normal", "Button", btnNormal);

            var btnHover = new StyleBoxFlat();
            btnHover.BgColor = ResolvedSurface.Lightened(0.1f);
            btnHover.SetCornerRadiusAll(ResolvedRadiusSm);
            btnHover.SetContentMarginAll(ResolvedSpacingMd);
            t.SetStylebox("hover", "Button", btnHover);

            var btnPressed = new StyleBoxFlat();
            btnPressed.BgColor = ResolvedSurface.Darkened(0.1f);
            btnPressed.SetCornerRadiusAll(ResolvedRadiusSm);
            btnPressed.SetContentMarginAll(ResolvedSpacingMd);
            t.SetStylebox("pressed", "Button", btnPressed);

            var btnFocus = new StyleBoxFlat();
            btnFocus.BgColor = ResolvedSurface;
            btnFocus.SetCornerRadiusAll(ResolvedRadiusSm);
            btnFocus.SetContentMarginAll(ResolvedSpacingMd);
            btnFocus.BorderColor = ResolvedPrimary;
            btnFocus.SetBorderWidthAll(2);
            t.SetStylebox("focus", "Button", btnFocus);

            t.SetColor("font_color", "Button", ResolvedOnSurface);
            t.SetFontSize("font_size", "Button", ResolvedFontSizeBody);

            // Label
            t.SetColor("font_color", "Label", ResolvedOnSurface);
            t.SetFontSize("font_size", "Label", ResolvedFontSizeBody);

            // Panel
            var panelStyle = new StyleBoxFlat();
            panelStyle.BgColor = ResolvedSurface;
            panelStyle.SetCornerRadiusAll(ResolvedRadiusMd);
            panelStyle.SetContentMarginAll(ResolvedSpacingMd);
            t.SetStylebox("panel", "Panel", panelStyle);
            t.SetStylebox("panel", "PanelContainer", panelStyle);

            // Slider
            var sliderStyle = new StyleBoxFlat();
            sliderStyle.BgColor = ResolvedSurface.Darkened(0.2f);
            sliderStyle.SetCornerRadiusAll(ResolvedRadiusSm);
            t.SetStylebox("slider", "HSlider", sliderStyle);

            // ProgressBar
            var progressBg = new StyleBoxFlat();
            progressBg.BgColor = ResolvedSurface.Darkened(0.2f);
            progressBg.SetCornerRadiusAll(ResolvedRadiusSm);
            t.SetStylebox("background", "ProgressBar", progressBg);

            var progressFill = new StyleBoxFlat();
            progressFill.BgColor = ResolvedPrimary;
            progressFill.SetCornerRadiusAll(ResolvedRadiusSm);
            t.SetStylebox("fill", "ProgressBar", progressFill);

            // CheckButton
            t.SetColor("font_color", "CheckButton", ResolvedOnSurface);

            // LineEdit
            var lineEditNormal = new StyleBoxFlat();
            lineEditNormal.BgColor = ResolvedBackground;
            lineEditNormal.SetCornerRadiusAll(ResolvedRadiusSm);
            lineEditNormal.SetContentMarginAll(ResolvedSpacingSm);
            lineEditNormal.BorderColor = ResolvedSurface.Lightened(0.2f);
            lineEditNormal.SetBorderWidthAll(1);
            t.SetStylebox("normal", "LineEdit", lineEditNormal);

            var lineEditFocus = new StyleBoxFlat();
            lineEditFocus.BgColor = ResolvedBackground;
            lineEditFocus.SetCornerRadiusAll(ResolvedRadiusSm);
            lineEditFocus.SetContentMarginAll(ResolvedSpacingSm);
            lineEditFocus.BorderColor = ResolvedPrimary;
            lineEditFocus.SetBorderWidthAll(1);
            t.SetStylebox("focus", "LineEdit", lineEditFocus);

            // Container spacing
            t.SetConstant("separation", "HBoxContainer", ResolvedSpacingSm);
            t.SetConstant("separation", "VBoxContainer", ResolvedSpacingSm);
            t.SetConstant("h_separation", "GridContainer", ResolvedSpacingSm);
            t.SetConstant("v_separation", "GridContainer", ResolvedSpacingSm);
            t.SetConstant("margin_left", "MarginContainer", ResolvedSpacingLg);
            t.SetConstant("margin_top", "MarginContainer", ResolvedSpacingLg);
            t.SetConstant("margin_right", "MarginContainer", ResolvedSpacingLg);
            t.SetConstant("margin_bottom", "MarginContainer", ResolvedSpacingLg);

            // Font
            if (ResolvedFontRegular != null)
            {
                t.SetFont("font", "Button", ResolvedFontRegular);
                t.SetFont("font", "Label", ResolvedFontRegular);
                t.SetFont("font", "LineEdit", ResolvedFontRegular);
                t.SetFont("font", "CheckButton", ResolvedFontRegular);
            }

            if (ResolvedFontBold != null)
                t.SetFont("font_bold", "Label", ResolvedFontBold);

            return t;
        }
    }
}
