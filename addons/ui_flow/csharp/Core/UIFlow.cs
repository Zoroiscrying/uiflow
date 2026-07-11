using Godot;
using System;
using System.Collections.Generic;
using UIFlow.Data;
using UIFlow.Resources;
using UIFlow.Utils;

namespace UIFlow.Core
{
    /// <summary>
    /// UIFlow C# thin wrapper — delegates to the GDScript autoload when available.
    /// 
    /// If the GDScript UIFlow autoload is present (registered in ProjectSettings),
    /// all calls are forwarded to it. Otherwise, falls back to creating its own
    /// internal systems for C#-only projects.
    /// </summary>
    public partial class UIFlow : Node
    {
        public static UIFlow Instance { get; private set; }

        /// <summary>Reference to the GDScript autoload (if available).</summary>
        private Node _gdAutoload;

        /// <summary>Whether we are delegating to the GDScript autoload.</summary>
        private bool _isBridging => _gdAutoload != null && IsInstanceValid(_gdAutoload);

        // ── Own systems (fallback when no GDScript autoload) ───────────────────────

        public UIFlowNavigator Router { get; private set; }
        public UIFlowSceneResolver Scenes { get; private set; }
        public UIFlowThemeHelper ThemeHelper { get; private set; }
        public UIFlowInputHandler FlowInput { get; private set; }
        public UIFlowConfig Config { get; private set; }
        public UIFlowEventBus EventBus { get; private set; }

        public event Action<Script> PageOpened;
        public event Action<Script> PageClosed;

        private Control _pageContainer;
        private Control _customUiRoot;
        private UIFlowGuard _guard;

        /// <summary>
        /// Maps C# guard delegates to the Godot Callables forwarded to the GDScript autoload.
        /// Needed so RemoveGuard / RemovePageGuard can unregister the exact callable.
        /// </summary>
        private static readonly Dictionary<object, Callable> _guardForwarders = new();

        private const string ConfigPath = "res://ui_flow_config.tres";

        public override void _Ready()
        {
            Instance = this;

            // Try to find the GDScript autoload
            _gdAutoload = Engine.GetSingleton("UIFlow") as Node;
            if (_gdAutoload == this)
                _gdAutoload = null; // We are the singleton — no GDScript autoload

            if (_isBridging)
            {
                // Bridge mode: connect to GDScript autoload signals.
                // Fallback systems are not needed because all public API calls
                // are forwarded to the GDScript autoload.
                _gdAutoload.Connect("page_opened", Callable.From((Script c) => PageOpened?.Invoke(c)));
                _gdAutoload.Connect("page_closed", Callable.From((Script c) => PageClosed?.Invoke(c)));
                return;
            }

            // Fallback: create own systems (C#-only project)
            _CreateFallbackSystems();
        }

        private void _CreateFallbackSystems()
        {
            _LoadConfig();

            Scenes = new UIFlowSceneResolver();
            ThemeHelper = new UIFlowThemeHelper();
            EventBus = new UIFlowEventBus();
            _guard = new UIFlowGuard();

            if (Config != null && !string.IsNullOrEmpty(Config.SceneDirectory))
                Scenes.AddSceneDir(Config.SceneDirectory);

            if (Config != null && !string.IsNullOrEmpty(Config.DefaultThemeName))
                ThemeHelper.ApplyBuiltin(Config.DefaultThemeName);

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

            if (ProjectSettings.HasSetting("ui_flow/scene_directory"))
            {
                var dir = (string)ProjectSettings.GetSetting("ui_flow/scene_directory");
                if (!string.IsNullOrEmpty(dir))
                    Config.SceneDirectory = dir;
            }
            if (ProjectSettings.HasSetting("ui_flow/max_stack_depth"))
                Config.MaxStackDepth = (int)ProjectSettings.GetSetting("ui_flow/max_stack_depth");
            if (ProjectSettings.HasSetting("ui_flow/modal_close_on_back"))
                Config.ModalCloseOnBack = (bool)ProjectSettings.GetSetting("ui_flow/modal_close_on_back");
            if (ProjectSettings.HasSetting("ui_flow/default_theme_name"))
                Config.DefaultThemeName = (string)ProjectSettings.GetSetting("ui_flow/default_theme_name");
        }

        // ── Bridge helpers ───────────────────────────────────────────────────────────

        private Variant CallGD(string method, params Variant[] args)
        {
            if (_isBridging)
                return _gdAutoload.Callv(method, new Godot.Collections.Array(args));
            return default;
        }

        private T CallGD<T>(string method, params Variant[] args) where T : GodotObject
        {
            var result = CallGD(method, args);
            if (result.VariantType == Variant.Type.Nil) return null;
            return result.AsGodotObject() as T;
        }

        // ── Router shortcuts ───────────────────────────────────────────────────────

        /// <summary>
        /// Push a GDScript page by its script reference.
        /// </summary>
        public static Control Push(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme theme = null)
        {
            if (Instance == null) return null;
            if (Instance._isBridging && pageClass is GDScript)
            {
                var result = Instance.CallGD("push", pageClass, data ?? new Godot.Collections.Dictionary(), theme ?? new Variant());
                return result.AsGodotObject() as Control;
            }
            return Instance?.Router?.Push(pageClass, data, theme);
        }

        /// <summary>
        /// Push a pre-instantiated page instance (works for both GDScript and C# pages).
        /// </summary>
        public static Control PushInstance(Control instance, Godot.Collections.Dictionary data = null)
        {
            if (Instance == null) return null;
            if (Instance._isBridging)
            {
                var result = Instance.CallGD("push_instance", instance, data ?? new Godot.Collections.Dictionary());
                return result.AsGodotObject() as Control;
            }
            return Instance?.Router?.PushInstance(instance, data);
        }

        public static void Pop()
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("pop");
            else
                Instance?.Router?.Pop();
        }

        /// <summary>
        /// Replace the top page with a GDScript page by its script reference.
        /// </summary>
        public static Control Replace(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme theme = null)
        {
            if (Instance == null) return null;
            if (Instance._isBridging && pageClass is GDScript)
            {
                var result = Instance.CallGD("replace", pageClass, data ?? new Godot.Collections.Dictionary(), theme ?? new Variant());
                return result.AsGodotObject() as Control;
            }
            return Instance?.Router?.Replace(pageClass, data, theme);
        }

        public static void PopToRoot()
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("pop_to_root");
            else
                Instance?.Router?.PopToRoot();
        }

        public static void Close(Script pageClass)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("close", pageClass);
            else
                Instance?.Router?.Close(pageClass);
        }

        public static bool IsOnTop(Script pageClass)
        {
            if (Instance == null) return false;
            if (Instance._isBridging)
                return Instance.CallGD("is_on_top", pageClass).AsBool();
            return Instance?.Router?.IsOnTop(pageClass) ?? false;
        }

        public static T CurrentPage<T>() where T : UIFlowPage
            => Instance?.Router?.CurrentPageInstance() as T;

        public static Control GetPage(Script pageClass)
        {
            if (Instance == null) return null;
            if (Instance._isBridging)
                return Instance.CallGD("get_page", pageClass).AsGodotObject() as Control;
            return Instance?.Router?.GetPage(pageClass);
        }

        public static bool HasPage(Script pageClass)
        {
            if (Instance == null) return false;
            if (Instance._isBridging)
                return Instance.CallGD("has_page", pageClass).AsBool();
            return Instance?.Router?.HasPage(pageClass) ?? false;
        }

        public static int StackDepth()
        {
            if (Instance == null) return 0;
            if (Instance._isBridging)
                return Instance.CallGD("stack_depth").AsInt32();
            return Instance?.Router?.Depth() ?? 0;
        }

        public static StringName[] NavigationPath()
        {
            if (Instance == null) return System.Array.Empty<StringName>();
            if (Instance._isBridging)
            {
                var result = Instance.CallGD("navigation_path");
                if (result.VariantType == Variant.Type.Array)
                {
                    var arr = result.AsGodotArray();
                    var path = new StringName[arr.Count];
                    for (int i = 0; i < arr.Count; i++)
                        path[i] = arr[i].AsStringName();
                    return path;
                }
                return System.Array.Empty<StringName>();
            }
            return Instance?.Router?.NavigationPath() ?? System.Array.Empty<StringName>();
        }

        // ── Async ──────────────────────────────────────────────────────────────────

        public static async System.Threading.Tasks.Task<Control> PushAsync(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme theme = null)
        {
            var tcs = new System.Threading.Tasks.TaskCompletionSource<object>();
            Action<Script> handler = _ => tcs.TrySetResult(null);
            if (Instance != null)
                Instance.PageOpened += handler;

            Control instance;
            if (Instance?._isBridging == true && pageClass is GDScript)
            {
                instance = Push(pageClass, data, theme);
            }
            else
            {
                instance = await (Instance?.Router?.PushAsync(pageClass, data, theme) ?? System.Threading.Tasks.Task.FromResult<Control>(null));
            }

            if (Instance != null)
            {
                await tcs.Task;
                Instance.PageOpened -= handler;
            }
            return instance;
        }

        public static async System.Threading.Tasks.Task PopAsync()
        {
            var tcs = new System.Threading.Tasks.TaskCompletionSource<object>();
            Action<Script> handler = _ => tcs.TrySetResult(null);
            if (Instance != null)
                Instance.PageClosed += handler;
            Pop();
            if (Instance != null)
            {
                await tcs.Task;
                Instance.PageClosed -= handler;
            }
        }

        // ── Guard shortcuts ────────────────────────────────────────────────────────

        public static void AddGuard(Func<Script, Script, object, bool> guard)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                var callable = Callable.From((Variant fromPage, Variant toPage, Variant data) =>
                    guard(fromPage.AsGodotObject() as Script, toPage.AsGodotObject() as Script, data.Obj));
                _guardForwarders[guard] = callable;
                Instance.CallGD("add_guard", callable);
                return;
            }
            Instance._guard?.AddGuard(guard);
        }

        public static void RemoveGuard(Func<Script, Script, object, bool> guard)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                if (_guardForwarders.TryGetValue(guard, out var callable))
                {
                    Instance.CallGD("remove_guard", callable);
                    _guardForwarders.Remove(guard);
                }
                return;
            }
            Instance._guard?.RemoveGuard(guard);
        }

        public static void AddPageGuard(Script pageClass, Func<Script, object, bool> guard)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                var callable = Callable.From((Variant fromPage, Variant data) =>
                    guard(fromPage.AsGodotObject() as Script, data.Obj));
                _guardForwarders[guard] = callable;
                Instance.CallGD("add_page_guard", pageClass, callable);
                return;
            }
            Instance._guard?.AddPageGuard(pageClass, guard);
        }

        public static void RemovePageGuard(Script pageClass, Func<Script, object, bool> guard)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                if (_guardForwarders.TryGetValue(guard, out var callable))
                {
                    Instance.CallGD("remove_page_guard", pageClass, callable);
                    _guardForwarders.Remove(guard);
                }
                return;
            }
            Instance._guard?.RemovePageGuard(pageClass, guard);
        }

        public static void ClearGuards()
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                Instance.CallGD("clear_guards");
                _guardForwarders.Clear();
                return;
            }
            Instance._guard?.Clear();
        }

        // ── Scene registration ─────────────────────────────────────────────────────

        public static void RegisterScene(Script pageClass, PackedScene scene)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("register_scene", pageClass, scene);
            else
                Instance?.Scenes?.RegisterScene(pageClass, scene);
        }

        // ── Animation ──────────────────────────────────────────────────────────────

        public static Tween Animate(Node node, UIFlowTweenProp prop, Variant from, Variant to,
            float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
            Tween.TransitionType trans = Tween.TransitionType.Linear)
            => UIFlowAnimator.Animate(node, prop, from, to, duration, ease, trans);

        public static Tween AnimateRaw(Node node, string propPath, Variant from, Variant to,
            float duration = 0.3f, Tween.EaseType ease = Tween.EaseType.InOut,
            Tween.TransitionType trans = Tween.TransitionType.Linear)
            => UIFlowAnimator.AnimateRaw(node, propPath, from, to, duration, ease, trans);

        public static UIFlowSequencer Sequencer() => new();

        public static Tween AnimHoverEnter(Control node) => UIFlowAnimPresets.HoverScale(node);
        public static Tween AnimHoverExit(Control node) => UIFlowAnimPresets.HoverReset(node);
        public static Tween AnimPressDown(Control node) => UIFlowAnimPresets.PressDown(node);
        public static Tween AnimPressUp(Control node) => UIFlowAnimPresets.PressUp(node);
        public static Tween AnimShake(Control node, float intensity = 8f) => UIFlowAnimPresets.Shake(node, intensity);
        public static Tween AnimPulse(Control node) => UIFlowAnimPresets.Pulse(node);
        public static Tween AnimFadeIn(Control node, float duration = 0.2f) => UIFlowAnimPresets.FadeIn(node, duration);
        public static Tween AnimFadeOut(Control node, float duration = 0.2f) => UIFlowAnimPresets.FadeOut(node, duration);
        public static UIFlowSequencer AnimStaggerFade(Node parent) => UIFlowAnimPresets.StaggerFadeIn(parent);

        // ── Binding ────────────────────────────────────────────────────────────────

        public static UIFlowBindUtils.UIFlowBinding BindSignal(Node node, StringName prop, Signal signal)
            => UIFlowBindUtils.BindSignal(node, prop, signal);

        public static UIFlowBindUtils.UIFlowBinding BindSignalT<T>(Node node, StringName prop, Signal signal, Func<T, Variant> transform)
            => UIFlowBindUtils.BindSignalT(node, prop, signal, transform);

        public static UIFlowBindUtils.UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
            => UIFlowBindUtils.BindVisible(node, signal, predicate);

        public static UIFlowBindUtils.UIFlowBinding BindFormat(Node node, StringName prop, Signal signal, string format)
            => UIFlowBindUtils.BindFormat(node, prop, signal, format);

        public static UIFlowBindUtils.UIFlowBinding BindSlider(Godot.Range slider, Signal signal, Action<float> setter)
            => UIFlowBindUtils.BindSlider(slider, signal, setter);

        public static UIFlowListBinder BindList(Node container, Signal signal, PackedScene template, Action<Control, object, int> binder, Func<object, int, object> keyFunc = null)
            => new UIFlowListBinder(container, signal, template, binder, keyFunc);

        // ── Theme ──────────────────────────────────────────────────────────────────

        public static UIFlowTheme GetTheme()
        {
            if (Instance == null) return null;
            if (Instance._isBridging)
            {
                var result = Instance.CallGD("get_theme");
                return result.AsGodotObject() as UIFlowTheme;
            }
            return Instance?.ThemeHelper?.GetCurrent();
        }

        public static void ApplyTheme(UIFlowTheme theme)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("apply_theme", theme);
            else
            {
                Instance?.ThemeHelper?.ApplyTheme(theme);
                Instance?.ApplyThemeToContainer();
            }
        }

        public static void ApplyBuiltinTheme(string name)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("apply_builtin_theme", name);
            else
            {
                Instance?.ThemeHelper?.ApplyBuiltin(name);
                Instance?.ApplyThemeToContainer();
            }
        }

        public static Color GetColor(UIFlowTheme.ColorSlot slot)
        {
            if (Instance == null) return Colors.White;
            if (Instance._isBridging)
                return Instance.CallGD("get_color", (int)slot).AsColor();
            return Instance?.ThemeHelper?.GetColor(slot) ?? Colors.White;
        }

        public static void SetColor(UIFlowTheme.ColorSlot slot, Color color)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("set_color", (int)slot, color);
            else
                Instance?.ThemeHelper?.SetColor(slot, color);
        }

        public static int GetFontSize(string sizeName)
        {
            if (Instance == null) return 14;
            if (Instance._isBridging)
                return Instance.CallGD("get_font_size", sizeName).AsInt32();
            return Instance?.ThemeHelper?.GetFontSize(sizeName) ?? 14;
        }

        public static int GetSpacing(string sizeName)
        {
            if (Instance == null) return 8;
            if (Instance._isBridging)
                return Instance.CallGD("get_spacing", sizeName).AsInt32();
            return Instance?.ThemeHelper?.GetSpacing(sizeName) ?? 8;
        }

        public static int GetRadius(string sizeName)
        {
            if (Instance == null) return 4;
            if (Instance._isBridging)
                return Instance.CallGD("get_radius", sizeName).AsInt32();
            return Instance?.ThemeHelper?.GetRadius(sizeName) ?? 4;
        }

        // ── Input ────────────────────────────────────────────────────────────────────

        public static void SetDefaultFocus(Control node) => node?.GrabFocus();

        // ── UI Root ──────────────────────────────────────────────────────────────────

        public static void SetUiRoot(Control root)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                Instance.CallGD("set_ui_root", root);
                return;
            }
            Instance._customUiRoot = root;
            Instance._pageContainer = root;
            Instance.Router?.Setup(Instance._pageContainer, Instance.Scenes, Instance._guard);
            Instance.ApplyThemeToContainer();
        }

        private void ApplyThemeToContainer()
        {
            if (_pageContainer == null) return;
            var theme = ThemeHelper?.GetCurrent();
            if (theme == null) return;
            _pageContainer.Theme = theme.BuildGodotTheme();
        }

        // ── Event Bus ──────────────────────────────────────────────────────────────

        public static void Publish(string topic, Variant data = new())
            => Instance?.EventBus?.Publish(topic, data);

        public static void PublishSticky(string topic, Variant data = new())
            => Instance?.EventBus?.PublishSticky(topic, data);

        public static int Subscribe(string topic, Callable callback, GodotObject subscriber = null, bool once = false)
            => Instance?.EventBus?.Subscribe(topic, callback, subscriber, once) ?? -1;

        public static int SubscribeOnce(string topic, Callable callback, GodotObject subscriber = null)
            => Instance?.EventBus?.SubscribeOnce(topic, callback, subscriber) ?? -1;

        public static void Unsubscribe(int token)
            => Instance?.EventBus?.Unsubscribe(token);

        public static Variant GetSticky(string topic)
            => Instance?.EventBus?.GetSticky(topic) ?? new Variant();

        // ── Object Pool ──────────────────────────────────────────────────────────

        public static void WarmUp(params Script[] pageClasses)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("warm_up", new Godot.Collections.Array(pageClasses));
            else
                Instance?.Scenes?.WarmUp(pageClasses);
        }

        public static async System.Threading.Tasks.Task WarmUpAsync(params Script[] pageClasses)
        {
            if (Instance == null) return;
            if (Instance._isBridging)
            {
                // GDScript warm_up_async is a coroutine; call it to start async loading.
                Instance.CallGD("warm_up_async", new Godot.Collections.Array(pageClasses));
                return;
            }
            if (Instance?.Scenes != null)
                await Instance.Scenes.WarmUpAsync(pageClasses);
        }

        public static void ClearPool()
        {
            if (Instance == null) return;
            if (Instance._isBridging)
                Instance.CallGD("clear_pool");
            else
                Instance?.Scenes?.ClearPool();
        }
    }
}
