using Godot;
using System;
using System.Collections.Generic;
using UIFlow.Utils;

namespace UIFlow.Core
{
    /// <summary>
    /// UIFlow autoload singleton — main API entry point.
    /// </summary>
    public partial class UIFlow : Node
    {
        public static UIFlow Instance { get; private set; }

        public UIFlowNavigator Router { get; private set; }
        public UIFlowSceneResolver Scenes { get; private set; }
        public UIFlowThemeHelper ThemeHelper { get; private set; }
        public UIFlowInputHandler FlowInput { get; private set; }
        public UIFlowConfig Config { get; private set; }

        public event Action<Script> PageOpened;
        public event Action<Script> PageClosed;

        private Control _pageContainer;
        private Control _customUiRoot;
        private UIFlowGuard _guard;

        private const string ConfigPath = "res://ui_flow_config.tres";

        public override void _Ready()
        {
            Instance = this;
            _LoadConfig();

            Scenes = new UIFlowSceneResolver();
            ThemeHelper = new UIFlowThemeHelper();
            _guard = new UIFlowGuard();

            // Apply config to scene resolver
            if (Config != null && !string.IsNullOrEmpty(Config.SceneDirectory))
                Scenes.AddSceneDir(Config.SceneDirectory);

            var uiLayer = new CanvasLayer { Name = "UIFlowPageLayer", Layer = 10 };
            AddChild(uiLayer);

            _pageContainer = new Control { Name = "UIFlowPageContainer" };
            _pageContainer.SetAnchorsPreset(Control.LayoutPreset.FullRect);
            _pageContainer.GrowHorizontal = Control.GrowDirection.Both;
            _pageContainer.GrowVertical = Control.GrowDirection.Both;
            uiLayer.AddChild(_pageContainer);

            Router = new UIFlowNavigator();
            Router.Name = "UIFlowNavigator";
            AddChild(Router);
            Router.Setup(_pageContainer, Scenes, _guard);

            Router.PageOpened += c => PageOpened?.Invoke(c);
            Router.PageClosed += c => PageClosed?.Invoke(c);

            FlowInput = new UIFlowInputHandler();
            FlowInput.Name = "UIFlowInputHandler";
            AddChild(FlowInput);
            FlowInput.Setup(Router);

            ApplyThemeToContainer();
        }

        private void _LoadConfig()
        {
            if (ResourceLoader.Exists(ConfigPath))
                Config = GD.Load<UIFlowConfig>(ConfigPath);
            Config ??= new UIFlowConfig();
        }

        // ── Router shortcuts ─────────────────────────────────────────────────────

        public static Control Push<T>(Dictionary data = null, UIFlowTheme theme = null) where T : UIFlowPage
            => Instance?.Router.Push(typeof(T).GetGodotScript(), data, theme);

        public static Control Push(Script pageClass, Dictionary data = null, UIFlowTheme theme = null)
            => Instance?.Router.Push(pageClass, data, theme);

        public static Control PushInstance(Control instance, Dictionary data = null)
            => Instance?.Router.PushInstance(instance, data);

        public static void Pop() => Instance?.Router.Pop();

        public static Control Replace<T>(Dictionary data = null, UIFlowTheme theme = null) where T : UIFlowPage
            => Instance?.Router.Replace(typeof(T).GetGodotScript(), data, theme);

        public static Control Replace(Script pageClass, Dictionary data = null, UIFlowTheme theme = null)
            => Instance?.Router.Replace(pageClass, data, theme);

        public static void PopToRoot() => Instance?.Router.PopToRoot();

        public static void Close(Script pageClass) => Instance?.Router.Close(pageClass);

        public static bool IsOnTop(Script pageClass) => Instance?.Router.IsOnTop(pageClass) ?? false;

        public static T CurrentPage<T>() where T : UIFlowPage
            => Instance?.Router.CurrentPageInstance() as T;

        public static T GetPage<T>() where T : UIFlowPage
            => Instance?.Router.GetPage(typeof(T).GetGodotScript()) as T;

        public static bool HasPage<T>() where T : UIFlowPage
            => Instance?.Router.HasPage(typeof(T).GetGodotScript()) ?? false;

        public static int StackDepth() => Instance?.Router.Depth() ?? 0;

        public static StringName[] NavigationPath() => Instance?.Router.NavigationPath();

        // ── Async ────────────────────────────────────────────────────────────────

        public static async System.Threading.Tasks.Task<Control> PushAsync<T>(Dictionary data = null, UIFlowTheme theme = null) where T : UIFlowPage
        {
            var instance = Push<T>(data, theme);
            if (Instance != null)
                await Instance.ToSignal(Instance, SignalName.PageOpened);
            return instance;
        }

        public static async System.Threading.Tasks.Task PopAsync()
        {
            Pop();
            if (Instance != null)
                await Instance.ToSignal(Instance, SignalName.PageClosed);
        }

        // ── Guard shortcuts ──────────────────────────────────────────────────────

        public static void AddGuard(Func<Script, Script, object, bool> guard)
            => Instance?._guard.AddGuard(guard);

        public static void RemoveGuard(Func<Script, Script, object, bool> guard)
            => Instance?._guard.RemoveGuard(guard);

        public static void AddPageGuard(Script pageClass, Func<Script, object, bool> guard)
            => Instance?._guard.AddPageGuard(pageClass, guard);

        public static void RemovePageGuard(Script pageClass, Func<Script, object, bool> guard)
            => Instance?._guard.RemovePageGuard(pageClass, guard);

        public static void ClearGuards() => Instance?._guard.Clear();

        // ── Scene registration ───────────────────────────────────────────────────

        public static void RegisterScene(Script pageClass, PackedScene scene)
            => Instance?.Scenes.RegisterScene(pageClass, scene);

        // ── Animation ────────────────────────────────────────────────────────────

        public static Tween Animate(Node node, UIFlowTweenProp prop, Variant from, Variant to,
            float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
            Tween.TransitionType trans = Tween.TransitionType.Linear)
            => UIFlowAnimator.Animate(node, prop, from, to, duration, ease, trans);

        public static Tween AnimateRaw(Node node, string propPath, Variant from, Variant to,
            float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
            Tween.TransitionType trans = Tween.TransitionType.Linear)
            => UIFlowAnimator.AnimateRaw(node, propPath, from, to, duration, ease, trans);

        public static UIFlowSequencer Sequencer() => new();

        // Animation presets
        public static Tween AnimHoverEnter(Control node) => UIFlowAnimPresets.HoverScale(node);
        public static Tween AnimHoverExit(Control node) => UIFlowAnimPresets.HoverReset(node);
        public static Tween AnimPressDown(Control node) => UIFlowAnimPresets.PressDown(node);
        public static Tween AnimPressUp(Control node) => UIFlowAnimPresets.PressUp(node);
        public static Tween AnimShake(Control node, float intensity = 8f) => UIFlowAnimPresets.Shake(node, intensity);
        public static Tween AnimPulse(Control node) => UIFlowAnimPresets.Pulse(node);
        public static Tween AnimFadeIn(Control node, float duration = 0.2f) => UIFlowAnimPresets.FadeIn(node, duration);
        public static Tween AnimFadeOut(Control node, float duration = 0.2f) => UIFlowAnimPresets.FadeOut(node, duration);
        public static UIFlowSequencer AnimStaggerFade(Node parent) => UIFlowAnimPresets.StaggerFadeIn(parent);

        // ── Binding ──────────────────────────────────────────────────────────────

        public static UIFlowBindUtils.UIFlowBinding BindSignal(Node node, StringName prop, Signal signal)
            => UIFlowBindUtils.BindSignal(node, prop, signal);

        public static UIFlowBindUtils.UIFlowBinding BindSignalT<T>(Node node, StringName prop, Signal signal, Func<T, Variant> transform)
            => UIFlowBindUtils.BindSignalT(node, prop, signal, transform);

        public static UIFlowBindUtils.UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
            => UIFlowBindUtils.BindVisible(node, signal, predicate);

        public static UIFlowBindUtils.UIFlowBinding BindFormat(Node node, StringName prop, Signal signal, string format)
            => UIFlowBindUtils.BindFormat(node, prop, signal, format);

        public static UIFlowBindUtils.UIFlowBinding BindSlider(Range slider, Signal signal, Action<float> setter)
            => UIFlowBindUtils.BindSlider(slider, signal, setter);

        // ── Theme ────────────────────────────────────────────────────────────────

        public static UIFlowTheme GetTheme() => Instance?.ThemeHelper.GetCurrent();

        public static void ApplyTheme(UIFlowTheme theme)
        {
            Instance?.ThemeHelper.ApplyTheme(theme);
            Instance?.ApplyThemeToContainer();
        }

        public static void ApplyBuiltinTheme(string name)
        {
            Instance?.ThemeHelper.ApplyBuiltin(name);
            Instance?.ApplyThemeToContainer();
        }

        public static Color GetColor(UIFlowTheme.ColorSlot slot)
            => Instance?.ThemeHelper.GetColor(slot) ?? Colors.White;

        public static void SetColor(UIFlowTheme.ColorSlot slot, Color color)
            => Instance?.ThemeHelper.SetColor(slot, color);

        public static int GetFontSize(string sizeName)
            => Instance?.ThemeHelper.GetFontSize(sizeName) ?? 14;

        public static int GetSpacing(string sizeName)
            => Instance?.ThemeHelper.GetSpacing(sizeName) ?? 8;

        public static int GetRadius(string sizeName)
            => Instance?.ThemeHelper.GetRadius(sizeName) ?? 4;

        // ── Input ────────────────────────────────────────────────────────────────

        public static void SetDefaultFocus(Control node)
        {
            node?.GrabFocus();
        }

        // ── UI Root ──────────────────────────────────────────────────────────────

        public static void SetUiRoot(Control root)
        {
            if (Instance == null) return;
            Instance._customUiRoot = root;
            Instance._pageContainer = root;
            Instance.Router.Setup(Instance._pageContainer, Instance.Scenes);
            Instance.ApplyThemeToContainer();
        }

        private void ApplyThemeToContainer()
        {
            if (_pageContainer == null) return;
            var theme = ThemeHelper?.GetCurrent();
            if (theme == null) return;
            _pageContainer.Theme = theme.BuildGodotTheme();
        }
    }
}
