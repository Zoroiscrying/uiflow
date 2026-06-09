using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// UIFlow autoload singleton — main API entry point.
/// </summary>
public partial class UIFlow : Node
{
    public static UIFlow Instance { get; private set; }

    public UIFlowNavigator Router { get; private set; }
    public UIFlowSceneResolver Scenes { get; private set; }
    public UIFlowThemeHelper ThemeHelper { get; private set; }

    public event Action<Script> PageOpened;
    public event Action<Script> PageClosed;

    private Control _pageContainer;

    public override void _Ready()
    {
        Instance = this;
        Scenes = new UIFlowSceneResolver();
        ThemeHelper = new UIFlowThemeHelper();

        // Create page container
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
        Router.Setup(_pageContainer, Scenes);

        Router.PageOpened += c => PageOpened?.Invoke(c);
        Router.PageClosed += c => PageClosed?.Invoke(c);

        // Apply default theme
        ApplyThemeToContainer();
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

    // ── Async ────────────────────────────────────────────────────────────────

    public static async System.Threading.Tasks.Task<Control> PushAsync<T>(Dictionary data = null, UIFlowTheme theme = null) where T : UIFlowPage
    {
        var instance = Push<T>(data, theme);
        if (Instance != null)
            await Instance.ToSignal(Instance, UIFlow.SignalName.PageOpened);
        return instance;
    }

    public static async System.Threading.Tasks.Task PopAsync()
    {
        Pop();
        if (Instance != null)
            await Instance.ToSignal(Instance, UIFlow.SignalName.PageClosed);
    }

    public static T CurrentPage<T>() where T : UIFlowPage
        => Instance?.Router.CurrentPageInstance() as T;

    public static T GetPage<T>() where T : UIFlowPage
        => Instance?.Router.GetPage(typeof(T).GetGodotScript()) as T;

    public static bool HasPage<T>() where T : UIFlowPage
        => Instance?.Router.HasPage(typeof(T).GetGodotScript()) ?? false;

    public static int StackDepth() => Instance?.Router.Depth() ?? 0;

    // ── Scene registration ───────────────────────────────────────────────────

    public static void RegisterScene(Script pageClass, PackedScene scene)
        => Instance?.Scenes.RegisterScene(pageClass, scene);

    // ── Animation ────────────────────────────────────────────────────────────

    public static Tween Animate(Node node, UIFlowTweenProp.Prop prop, Variant from, Variant to,
        float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
        Tween.TransitionType trans = Tween.TransitionType.Linear)
        => UIFlowAnimator.Animate(node, prop, from, to, duration, ease, trans);

    public static UIFlowSequencer Sequencer() => new();

    // ── Binding ──────────────────────────────────────────────────────────────

    public static UIFlowBindUtils.UIFlowBinding BindSignal(Node node, StringName prop, Signal signal)
        => UIFlowBindUtils.BindSignal(node, prop, signal);

    public static UIFlowBindUtils.UIFlowBinding BindSignalT<T>(Node node, StringName prop, Signal signal, Func<T, Variant> transform)
        => UIFlowBindUtils.BindSignalT(node, prop, signal, transform);

    public static UIFlowBindUtils.UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
        => UIFlowBindUtils.BindVisible(node, signal, predicate);

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

    private void ApplyThemeToContainer()
    {
        if (_pageContainer == null) return;
        var theme = ThemeHelper?.GetCurrent();
        if (theme == null) return;
        _pageContainer.Theme = theme.BuildGodotTheme();
    }
}
