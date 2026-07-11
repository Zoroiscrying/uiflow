using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using UIFlow.Resources;

namespace UIFlow.Core;

/// <summary>
/// Navigation stack manager for UIFlow pages.
/// Manages push/pop/replace operations and page lifecycle.
/// Navigation is protected by a lock to prevent race conditions during animations.
/// </summary>
public partial class UIFlowNavigator : Node
{
    public event Action<Script, Godot.Collections.Dictionary> PagePushed;
    public event Action<Script> PagePopped;
    public event Action<Script> PageOpened;
    public event Action<Script> PageClosed;

    private readonly List<StackEntry> _stack = new();
    private UIFlowSceneResolver _sceneResolver;
    private Control _container;

    private UIFlowGuard _guard;

    private record StackEntry(Script Class, Control Instance, PackedScene Scene);

    // ── Navigation lock ───────────────────────────────────────────────────────

    private bool _isNavigating;
    private readonly Queue<Action> _pendingNavigations = new();

    // Temporary state for async enter animation completion callback
    private Script _pendingOpenClass;
    private UIFlowPage _pendingOpenPage;

    public void Setup(Control container, UIFlowSceneResolver resolver, UIFlowGuard guard)
    {
        _container = container;
        _sceneResolver = resolver;
        _guard = guard;
    }

    private bool StartNavigation()
    {
        if (_isNavigating) return false;
        _isNavigating = true;
        return true;
    }

    private void FinishNavigation()
    {
        _isNavigating = false;
        ProcessPending();
    }

    private void ProcessPending()
    {
        if (_isNavigating || _pendingNavigations.Count == 0) return;
        var next = _pendingNavigations.Dequeue();
        next?.Invoke();
    }

    private void QueueNavigation(Action action) => _pendingNavigations.Enqueue(action);

    // ── Push ─────────────────────────────────────────────────────────────────

    /// <summary>
    /// Push a page onto the stack. If already in stack, moves it to the top.
    /// Returns the page instance. Returns null if blocked by a guard or busy.
    /// </summary>
    public Control Push(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme pageTheme = null)
    {
        if (!StartNavigation())
        {
            QueueNavigation(() => Push(pageClass, data, pageTheme));
            return null;
        }
        return DoPush(pageClass, data, pageTheme);
    }

    /// <summary>
    /// Push a page with asynchronous scene loading.
    /// </summary>
    public async Task<Control> PushAsync(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme pageTheme = null, CancellationToken ct = default)
    {
        if (!StartNavigation())
        {
            QueueNavigation(() => PushAsync(pageClass, data, pageTheme, ct));
            return null;
        }

        var scene = await _sceneResolver.ResolveAsync(pageClass, ct);
        if (scene == null)
        {
            FinishNavigation();
            return null;
        }

        return DoPush(pageClass, data, pageTheme);
    }

    private Control DoPush(Script pageClass, Godot.Collections.Dictionary data, UIFlowTheme pageTheme)
    {
        // If already in stack, move to top (no animation needed)
        var existing = GetPage(pageClass);
        if (existing != null)
        {
            MoveToTop(pageClass);
            FinishNavigation();
            return existing;
        }

        var scene = _sceneResolver.Resolve(pageClass);
        if (scene == null)
        {
            FinishNavigation();
            return null;
        }

        // Max stack depth check
        var maxDepth = UIFlow.Instance?.Config?.MaxStackDepth ?? 50;
        if (_stack.Count >= maxDepth)
        {
            GD.PushWarning($"UIFlow: Max stack depth ({maxDepth}) reached, cannot push new page.");
            FinishNavigation();
            return null;
        }

        // Guard check
        if (_guard != null && !_guard.CanNavigate(
            _stack.Count > 0 ? _stack[^1].Class : null,
            pageClass, data))
        {
            FinishNavigation();
            return null;
        }

        data ??= new Godot.Collections.Dictionary();

        // Notify current top page
        if (_stack.Count > 0)
        {
            var current = _stack[^1];
            if (current.Instance is UIFlowPage currentPage)
            {
                currentPage.InvokeHidden();
            }
        }

        // Try to acquire from pool, or instantiate new
        var instance = _sceneResolver.AcquirePooled(pageClass);
        var newPage = instance as UIFlowPage;
        if (instance == null)
        {
            instance = (Control)scene.Instantiate();
            newPage = instance as UIFlowPage;
        }
        else
        {
            newPage?.InvokeUnpooled();
        }

        // Lifecycle: created (before add_child)
        newPage?.InvokeCreated(data);

        bool startsHidden = false;
        if (newPage?.EnterEffect != null && newPage.EnterEffect.StartsHidden)
            startsHidden = true;

        instance.Visible = !startsHidden;
        if (!instance.IsInsideTree())
            _container.AddChild(instance);

        if (pageTheme != null)
            instance.Theme = pageTheme.BuildGodotTheme();

        _stack.Add(new StackEntry(pageClass, instance, scene));

        // Lifecycle: opened (after add_child, before animation)
        newPage?.InvokeOpened(data);

        // Play enter animation, then finish
        if (newPage != null)
        {
            _pendingOpenClass = pageClass;
            _pendingOpenPage = newPage;
            newPage.PlayEnterAnimation(new Callable(this, nameof(OnEnterAnimationComplete)));
        }
        else
        {
            PageOpened?.Invoke(pageClass);
            FinishNavigation();
        }

        PagePushed?.Invoke(pageClass, data);
        return instance;
    }

    // Helper: called when enter animation completes
    private void OnEnterAnimationComplete()
    {
        if (IsInstanceValid(_pendingOpenPage))
        {
            _pendingOpenPage.InvokeAfterOpened();
        }
        PageOpened?.Invoke(_pendingOpenClass);
        _pendingOpenClass = null;
        _pendingOpenPage = null;
        FinishNavigation();
    }

    /// <summary>
    /// Push a pre-instantiated page instance.
    /// </summary>
    public Control PushInstance(Control instance, Godot.Collections.Dictionary data = null)
    {
        if (!StartNavigation())
        {
            QueueNavigation(() => PushInstance(instance, data));
            return null;
        }
        return DoPushInstance(instance, data);
    }

    private Control DoPushInstance(Control instance, Godot.Collections.Dictionary data)
    {
        if (_stack.Count > 0)
        {
            var current = _stack[^1];
            if (current.Instance is UIFlowPage currentPage)
                currentPage.InvokeHidden();
        }

        bool startsHidden = false;
        if (instance is UIFlowPage page && page.EnterEffect != null && page.EnterEffect.StartsHidden)
            startsHidden = true;

        var pageClass = instance.GetScript().AsGodotObject() as Script;
        if (_guard != null && !_guard.CanNavigate(
            _stack.Count > 0 ? _stack[^1].Class : null,
            pageClass, data))
        {
            FinishNavigation();
            return null;
        }

        var newPage = instance as UIFlowPage;

        newPage?.InvokeCreated(data ?? new Godot.Collections.Dictionary());

        instance.Visible = !startsHidden;
        instance.Modulate = new Color(1, 1, 1, 1);
        _container.AddChild(instance);

        _stack.Add(new StackEntry(pageClass, instance, null));

        newPage?.InvokeOpened(data ?? new Godot.Collections.Dictionary());

        if (newPage != null)
        {
            _pendingOpenClass = pageClass;
            _pendingOpenPage = newPage;
            newPage.PlayEnterAnimation(new Callable(this, nameof(OnEnterAnimationComplete)));
        }
        else
        {
            PageOpened?.Invoke(pageClass);
            FinishNavigation();
        }

        PagePushed?.Invoke(instance.GetScript().AsGodotObject() as Script, data);
        return instance;
    }

    // ── Pop / Close ──────────────────────────────────────────────────────────

    /// <summary>
    /// Pop the top page off the stack.
    /// </summary>
    public void Pop()
    {
        if (_stack.Count == 0)
        {
            GD.PushWarning("UIFlow: Navigation stack is empty, cannot pop.");
            return;
        }

        if (!StartNavigation())
        {
            QueueNavigation(Pop);
            return;
        }

        var top = _stack[^1];
        _stack.RemoveAt(_stack.Count - 1);

        if (top.Instance is UIFlowPage page)
            page.InvokeBeforeClosed();

        if (top.Instance is UIFlowPage pageWithAnim)
        {
            pageWithAnim.PlayExitAnimation(Callable.From(() =>
            {
                CleanupAfterPop(top);
                FinishNavigation();
            }));
        }
        else
        {
            CleanupAfterPop(top);
            FinishNavigation();
        }
    }

    private void CleanupAfterPop(StackEntry top)
    {
        if (top.Instance is UIFlowPage page)
        {
            page.UnbindAll();
            page.InvokeClosed();
            page.InvokeDestroyed();
        }

        var pooled = false;
        if (top.Class is GDScript gdScript && _sceneResolver != null)
            pooled = _sceneResolver.ReleaseToPool(gdScript, top.Instance);

        if (!pooled)
        {
            if (IsInstanceValid(top.Instance) && top.Instance.IsInsideTree())
            {
                _container.RemoveChild(top.Instance);
                top.Instance.QueueFree();
            }
            if (top.Instance is UIFlowPage page2)
                page2._currentState = UIFlowPage.State.Destroyed;
        }
        else
        {
            if (IsInstanceValid(top.Instance) && top.Instance.IsInsideTree())
                _container.RemoveChild(top.Instance);
            if (top.Instance is UIFlowPage page2)
                page2._currentState = UIFlowPage.State.Idle;
        }

        if (_stack.Count > 0)
        {
            var below = _stack[^1];
            if (below.Instance is UIFlowPage belowPage && IsInstanceValid(belowPage))
                belowPage.InvokeShown();
        }

        PagePopped?.Invoke(top.Class);
        PageClosed?.Invoke(top.Class);
    }

    /// <summary>
    /// Replace the top page with a new one.
    /// </summary>
    public Control Replace(Script pageClass, Godot.Collections.Dictionary data = null, UIFlowTheme theme = null)
    {
        if (!StartNavigation())
        {
            QueueNavigation(() => Replace(pageClass, data, theme));
            return null;
        }

        if (_stack.Count == 0)
        {
            var result = DoPush(pageClass, data, theme);
            return result;
        }

        var old = _stack[^1];
        _stack.RemoveAt(_stack.Count - 1);

        if (old.Instance is UIFlowPage oldPage)
        {
            oldPage.InvokeBeforeClosed();
            oldPage.UnbindAll();
            oldPage.InvokeClosed();
            oldPage.InvokeDestroyed();
        }
        if (IsInstanceValid(old.Instance) && old.Instance.IsInsideTree())
        {
            _container.RemoveChild(old.Instance);
            old.Instance.QueueFree();
        }

        return DoPush(pageClass, data, theme);
    }

    /// <summary>
    /// Remove all pages except the root.
    /// </summary>
    public void PopToRoot()
    {
        if (!StartNavigation())
        {
            QueueNavigation(PopToRoot);
            return;
        }

        if (_stack.Count <= 1)
        {
            FinishNavigation();
            return;
        }

        // Remove middle pages directly (no animation)
        while (_stack.Count > 1)
        {
            var entry = _stack[0];
            _stack.RemoveAt(0);

            if (entry.Instance is UIFlowPage page)
            {
                page.UnbindAll();
                page.InvokeClosed();
                page.InvokeDestroyed();
            }
            if (IsInstanceValid(entry.Instance) && entry.Instance.IsInsideTree())
            {
                _container.RemoveChild(entry.Instance);
                entry.Instance.QueueFree();
            }
        }

        // Notify root
        var root = _stack[^1];
        if (root.Instance is UIFlowPage rootPage && IsInstanceValid(rootPage))
            rootPage.InvokeShown();

        FinishNavigation();
    }

    /// <summary>
    /// Close a specific page by class, anywhere in the stack.
    /// </summary>
    public void Close(Script pageClass)
    {
        if (_stack.Count == 0) return;

        int targetIndex = -1;
        for (int i = 0; i < _stack.Count; i++)
        {
            if (_stack[i].Class == pageClass)
            {
                targetIndex = i;
                break;
            }
        }

        if (targetIndex == -1)
        {
            GD.PushWarning($"UIFlow: Page class not found in stack, cannot close.");
            return;
        }

        if (targetIndex == _stack.Count - 1)
        {
            Pop();
            return;
        }

        var entry = _stack[targetIndex];
        _stack.RemoveAt(targetIndex);

        if (entry.Instance is UIFlowPage page)
        {
            page.UnbindAll();
            page.InvokeClosed();
            page.InvokeDestroyed();
        }

        if (IsInstanceValid(entry.Instance) && entry.Instance.IsInsideTree())
        {
            _container.RemoveChild(entry.Instance);
            entry.Instance.QueueFree();
        }

        PageClosed?.Invoke(entry.Class);
    }

    // ── Stack queries ───────────────────────────────────────────────────────

    public void MoveToTop(Script pageClass)
    {
        int targetIndex = -1;
        for (int i = 0; i < _stack.Count; i++)
        {
            if (_stack[i].Class == pageClass)
            {
                targetIndex = i;
                break;
            }
        }

        if (targetIndex == -1 || targetIndex == _stack.Count - 1)
            return;

        var currentTop = _stack[^1];
        if (currentTop.Instance is UIFlowPage currentPage)
            currentPage.InvokeHidden();

        var entry = _stack[targetIndex];
        _stack.RemoveAt(targetIndex);
        _stack.Add(entry);

        if (entry.Instance.IsInsideTree())
            _container.MoveChild(entry.Instance, _container.GetChildCount() - 1);

        if (entry.Instance is UIFlowPage movedPage)
            movedPage.InvokeShown();
    }

    public Control GetPage(Script pageClass)
    {
        foreach (var entry in _stack)
            if (entry.Class == pageClass) return entry.Instance;
        return null;
    }

    public bool HasPage(Script pageClass) => GetPage(pageClass) != null;

    public bool IsOnTop(Script pageClass) => _stack.Count > 0 && _stack[^1].Class == pageClass;

    public Script CurrentPageClass() => _stack.Count > 0 ? _stack[^1].Class : null;

    public Control CurrentPageInstance() => _stack.Count > 0 ? _stack[^1].Instance : null;

    public int Depth() => _stack.Count;

    public StringName[] NavigationPath()
    {
        var path = new StringName[_stack.Count];
        for (int i = 0; i < _stack.Count; i++)
            path[i] = _stack[i].Class.GetGlobalName();
        return path;
    }
}
