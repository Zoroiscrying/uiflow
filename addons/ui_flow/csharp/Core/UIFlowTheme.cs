using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// UIFlow Theme Resource — semantic color palette and style config with inheritance.
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

        // Parent theme for inheritance
        [Export] public UIFlowTheme ParentTheme { get; set; }

        // Has-flags for inheritance tracking
        private bool _hasPrimary, _hasSecondary, _hasAccent;
        private bool _hasError, _hasWarning, _hasSuccess, _hasInfo;
        private bool _hasBackground, _hasSurface;
        private bool _hasOnPrimary, _hasOnSecondary, _hasOnSurface;
        private bool _hasFontRegular, _hasFontBold;
        private bool _hasFontSizeTitle, _hasFontSizeHeading, _hasFontSizeBody, _hasFontSizeSmall;
        private bool _hasSpacingXs, _hasSpacingSm, _hasSpacingMd, _hasSpacingLg, _hasSpacingXl;
        private bool _hasRadiusSm, _hasRadiusMd, _hasRadiusLg;

        // Backing fields
        private Color _primary = new(0.3f, 0.5f, 0.9f);
        private Color _secondary = new(0.5f, 0.5f, 0.5f);
        private Color _accent = new(0.9f, 0.6f, 0.2f);
        private Color _error = new(0.9f, 0.3f, 0.3f);
        private Color _warning = new(0.9f, 0.7f, 0.2f);
        private Color _success = new(0.3f, 0.8f, 0.4f);
        private Color _info = new(0.4f, 0.7f, 0.9f);
        private Color _background = new(0.1f, 0.1f, 0.12f);
        private Color _surface = new(0.15f, 0.15f, 0.18f);
        private Color _onPrimary = Colors.White;
        private Color _onSecondary = Colors.White;
        private Color _onSurface = new(0.9f, 0.9f, 0.9f);
        private Font _fontRegular;
        private Font _fontBold;
        private int _fontSizeTitle = 28;
        private int _fontSizeHeading = 18;
        private int _fontSizeBody = 14;
        private int _fontSizeSmall = 12;
        private int _spacingXs = 4;
        private int _spacingSm = 8;
        private int _spacingMd = 12;
        private int _spacingLg = 20;
        private int _spacingXl = 32;
        private int _radiusSm = 4;
        private int _radiusMd = 8;
        private int _radiusLg = 12;

        // Properties with has-flags
        [ExportGroup("Brand Colors")]
        [Export]
        public Color Primary
        {
            get => _primary;
            set { _primary = value; _hasPrimary = true; }
        }

        [Export]
        public Color Secondary
        {
            get => _secondary;
            set { _secondary = value; _hasSecondary = true; }
        }

        [Export]
        public Color Accent
        {
            get => _accent;
            set { _accent = value; _hasAccent = true; }
        }

        [ExportGroup("Semantic Colors")]
        [Export]
        public Color Error
        {
            get => _error;
            set { _error = value; _hasError = true; }
        }

        [Export]
        public Color Warning
        {
            get => _warning;
            set { _warning = value; _hasWarning = true; }
        }

        [Export]
        public Color Success
        {
            get => _success;
            set { _success = value; _hasSuccess = true; }
        }

        [Export]
        public Color Info
        {
            get => _info;
            set { _info = value; _hasInfo = true; }
        }

        [ExportGroup("Surface")]
        [Export]
        public Color Background
        {
            get => _background;
            set { _background = value; _hasBackground = true; }
        }

        [Export]
        public Color Surface
        {
            get => _surface;
            set { _surface = value; _hasSurface = true; }
        }

        [ExportGroup("Text")]
        [Export]
        public Color OnPrimary
        {
            get => _onPrimary;
            set { _onPrimary = value; _hasOnPrimary = true; }
        }

        [Export]
        public Color OnSecondary
        {
            get => _onSecondary;
            set { _onSecondary = value; _hasOnSecondary = true; }
        }

        [Export]
        public Color OnSurface
        {
            get => _onSurface;
            set { _onSurface = value; _hasOnSurface = true; }
        }

        [ExportGroup("Typography")]
        [Export]
        public Font FontRegular
        {
            get => _fontRegular;
            set { _fontRegular = value; _hasFontRegular = true; }
        }

        [Export]
        public Font FontBold
        {
            get => _fontBold;
            set { _fontBold = value; _hasFontBold = true; }
        }

        [Export]
        public int FontSizeTitle
        {
            get => _fontSizeTitle;
            set { _fontSizeTitle = value; _hasFontSizeTitle = true; }
        }

        [Export]
        public int FontSizeHeading
        {
            get => _fontSizeHeading;
            set { _fontSizeHeading = value; _hasFontSizeHeading = true; }
        }

        [Export]
        public int FontSizeBody
        {
            get => _fontSizeBody;
            set { _fontSizeBody = value; _hasFontSizeBody = true; }
        }

        [Export]
        public int FontSizeSmall
        {
            get => _fontSizeSmall;
            set { _fontSizeSmall = value; _hasFontSizeSmall = true; }
        }

        [ExportGroup("Spacing")]
        [Export]
        public int SpacingXs
        {
            get => _spacingXs;
            set { _spacingXs = value; _hasSpacingXs = true; }
        }

        [Export]
        public int SpacingSm
        {
            get => _spacingSm;
            set { _spacingSm = value; _hasSpacingSm = true; }
        }

        [Export]
        public int SpacingMd
        {
            get => _spacingMd;
            set { _spacingMd = value; _hasSpacingMd = true; }
        }

        [Export]
        public int SpacingLg
        {
            get => _spacingLg;
            set { _spacingLg = value; _hasSpacingLg = true; }
        }

        [Export]
        public int SpacingXl
        {
            get => _spacingXl;
            set { _spacingXl = value; _hasSpacingXl = true; }
        }

        [ExportGroup("Border Radius")]
        [Export]
        public int RadiusSm
        {
            get => _radiusSm;
            set { _radiusSm = value; _hasRadiusSm = true; }
        }

        [Export]
        public int RadiusMd
        {
            get => _radiusMd;
            set { _radiusMd = value; _hasRadiusMd = true; }
        }

        [Export]
        public int RadiusLg
        {
            get => _radiusLg;
            set { _radiusLg = value; _hasRadiusLg = true; }
        }

        // Resolved getters with parent chain walking
        public Color ResolvedPrimary => _hasPrimary ? _primary : ParentTheme?.ResolvedPrimary ?? _primary;
        public Color ResolvedSecondary => _hasSecondary ? _secondary : ParentTheme?.ResolvedSecondary ?? _secondary;
        public Color ResolvedAccent => _hasAccent ? _accent : ParentTheme?.ResolvedAccent ?? _accent;
        public Color ResolvedError => _hasError ? _error : ParentTheme?.ResolvedError ?? _error;
        public Color ResolvedWarning => _hasWarning ? _warning : ParentTheme?.ResolvedWarning ?? _warning;
        public Color ResolvedSuccess => _hasSuccess ? _success : ParentTheme?.ResolvedSuccess ?? _success;
        public Color ResolvedInfo => _hasInfo ? _info : ParentTheme?.ResolvedInfo ?? _info;
        public Color ResolvedBackground => _hasBackground ? _background : ParentTheme?.ResolvedBackground ?? _background;
        public Color ResolvedSurface => _hasSurface ? _surface : ParentTheme?.ResolvedSurface ?? _surface;
        public Color ResolvedOnPrimary => _hasOnPrimary ? _onPrimary : ParentTheme?.ResolvedOnPrimary ?? _onPrimary;
        public Color ResolvedOnSecondary => _hasOnSecondary ? _onSecondary : ParentTheme?.ResolvedOnSecondary ?? _onSecondary;
        public Color ResolvedOnSurface => _hasOnSurface ? _onSurface : ParentTheme?.ResolvedOnSurface ?? _onSurface;
        public Font ResolvedFontRegular => _hasFontRegular ? _fontRegular : ParentTheme?.ResolvedFontRegular ?? _fontRegular;
        public Font ResolvedFontBold => _hasFontBold ? _fontBold : ParentTheme?.ResolvedFontBold ?? _fontBold;
        public int ResolvedFontSizeTitle => _hasFontSizeTitle ? _fontSizeTitle : ParentTheme?.ResolvedFontSizeTitle ?? _fontSizeTitle;
        public int ResolvedFontSizeHeading => _hasFontSizeHeading ? _fontSizeHeading : ParentTheme?.ResolvedFontSizeHeading ?? _fontSizeHeading;
        public int ResolvedFontSizeBody => _hasFontSizeBody ? _fontSizeBody : ParentTheme?.ResolvedFontSizeBody ?? _fontSizeBody;
        public int ResolvedFontSizeSmall => _hasFontSizeSmall ? _fontSizeSmall : ParentTheme?.ResolvedFontSizeSmall ?? _fontSizeSmall;
        public int ResolvedSpacingXs => _hasSpacingXs ? _spacingXs : ParentTheme?.ResolvedSpacingXs ?? _spacingXs;
        public int ResolvedSpacingSm => _hasSpacingSm ? _spacingSm : ParentTheme?.ResolvedSpacingSm ?? _spacingSm;
        public int ResolvedSpacingMd => _hasSpacingMd ? _spacingMd : ParentTheme?.ResolvedSpacingMd ?? _spacingMd;
        public int ResolvedSpacingLg => _hasSpacingLg ? _spacingLg : ParentTheme?.ResolvedSpacingLg ?? _spacingLg;
        public int ResolvedSpacingXl => _hasSpacingXl ? _spacingXl : ParentTheme?.ResolvedSpacingXl ?? _spacingXl;
        public int ResolvedRadiusSm => _hasRadiusSm ? _radiusSm : ParentTheme?.ResolvedRadiusSm ?? _radiusSm;
        public int ResolvedRadiusMd => _hasRadiusMd ? _radiusMd : ParentTheme?.ResolvedRadiusMd ?? _radiusMd;
        public int ResolvedRadiusLg => _hasRadiusLg ? _radiusLg : ParentTheme?.ResolvedRadiusLg ?? _radiusLg;

        /// <summary>
        /// Check if a property has a local override (not inherited).
        /// </summary>
        public bool HasOverride(string propertyName)
        {
            return propertyName switch
            {
                "Primary" => _hasPrimary,
                "Secondary" => _hasSecondary,
                "Accent" => _hasAccent,
                "Error" => _hasError,
                "Warning" => _hasWarning,
                "Success" => _hasSuccess,
                "Info" => _hasInfo,
                "Background" => _hasBackground,
                "Surface" => _hasSurface,
                "OnPrimary" => _hasOnPrimary,
                "OnSecondary" => _hasOnSecondary,
                "OnSurface" => _hasOnSurface,
                _ => false
            };
        }

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
