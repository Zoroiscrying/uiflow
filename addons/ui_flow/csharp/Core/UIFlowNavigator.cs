using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// Navigation stack manager for UIFlow pages.
/// Manages push/pop/replace operations and page lifecycle.
/// </summary>
public partial class UIFlowNavigator : Node
{
    public event Action<Script, Dictionary> PagePushed;
    public event Action<Script> PagePopped;
    public event Action<Script> PageOpened;
    public event Action<Script> PageClosed;

    private readonly List<StackEntry> _stack = new();
    private UIFlowSceneResolver _sceneResolver;
    private Control _container;

    private UIFlowGuard _guard;

    private record StackEntry(Script Class, Control Instance, PackedScene Scene);

    public void Setup(Control container, UIFlowSceneResolver resolver, UIFlowGuard guard)
    {
        _container = container;
        _sceneResolver = resolver;
        _guard = guard;
    }

    /// <summary>
    /// Push a page onto the stack. If the page is already in the stack, moves it to the top.
    /// Returns the page instance. Returns null if blocked by a guard or scene not found.
    /// </summary>
    public Control Push(Script pageClass, Dictionary data = null, UIFlowTheme pageTheme = null)
    {
        // If already in stack, move to top
        var existing = GetPage(pageClass);
        if (existing != null)
        {
            MoveToTop(pageClass);
            return existing;
        }

        var scene = _sceneResolver.Resolve(pageClass);
        if (scene == null) return null;

        // Guard check
        if (_guard != null && !_guard.CanNavigate(
            _stack.Count > 0 ? _stack[^1].Class : null,
            pageClass, data))
            return null;

        data ??= new Dictionary();

        // Notify current top page
        if (_stack.Count > 0)
        {
            var current = _stack[^1];
            if (current.Instance is UIFlowPage currentPage)
                currentPage.InvokeHidden();
        }

        // Instantiate
        var instance = (Control)scene.Instantiate();

        // Check if page has enter animation that wants to start hidden
        bool startsHidden = false;
        if (instance is UIFlowPage page && page.EnterEffect != null && page.EnterEffect.StartsHidden)
            startsHidden = true;

        instance.Visible = !startsHidden;
        _container.AddChild(instance);

        // Apply theme
        if (pageTheme != null)
            instance.Theme = pageTheme.BuildGodotTheme();

        _stack.Add(new StackEntry(pageClass, instance, scene));

        // Lifecycle
        if (instance is UIFlowPage newPage)
        {
            newPage.InvokeCreated(data);
            newPage.InvokeOpened(data);
            newPage.PlayEnterAnimation();
            newPage.ApplyDefaultFocus();
        }

        PagePushed?.Invoke(pageClass, data);
        PageOpened?.Invoke(pageClass);
        return instance;
    }

    /// <summary>
    /// Push a pre-instantiated page instance.
    /// </summary>
    public Control PushInstance(Control instance, Dictionary data = null)
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

        var pageClass = instance.GetScript();
        if (_guard != null && !_guard.CanNavigate(
            _stack.Count > 0 ? _stack[^1].Class : null,
            pageClass, data))
            return null;

        instance.Visible = !startsHidden;
        _container.AddChild(instance);

        _stack.Add(new StackEntry(pageClass, instance, null));

        if (instance is UIFlowPage newPage)
        {
            data ??= new Dictionary();
            newPage.InvokeCreated(data);
            newPage.InvokeOpened(data);
            newPage.PlayEnterAnimation();
            newPage.ApplyDefaultFocus();
        }

        PagePushed?.Invoke(instance.GetScript(), data);
        return instance;
    }

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

        var top = _stack[^1];
        _stack.RemoveAt(_stack.Count - 1);

        if (top.Instance is UIFlowPage page)
            page.PlayExitAnimation(() => CleanupAfterPop(top));
        else
            CleanupAfterPop(top);
    }

    private void CleanupAfterPop(StackEntry top)
    {
        if (top.Instance is UIFlowPage page)
        {
            page.InvokeClosed();
            page.InvokeDestroyed();
        }

        if (IsInstanceValid(top.Instance) && top.Instance.IsInsideTree())
        {
            _container.RemoveChild(top.Instance);
            top.Instance.QueueFree();
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
    public Control Replace(Script pageClass, Dictionary data = null, UIFlowTheme theme = null)
    {
        if (_stack.Count == 0) return Push(pageClass, data, theme);

        var old = _stack[^1];
        _stack.RemoveAt(_stack.Count - 1);

        if (old.Instance is UIFlowPage oldPage)
        {
            oldPage.InvokeClosed();
            oldPage.InvokeDestroyed();
        }
        if (IsInstanceValid(old.Instance) && old.Instance.IsInsideTree())
        {
            _container.RemoveChild(old.Instance);
            old.Instance.QueueFree();
        }

        return Push(pageClass, data, theme);
    }

    /// <summary>
    /// Remove all pages except the root.
    /// </summary>
    public void PopToRoot()
    {
        while (_stack.Count > 1)
            Pop();
    }

    /// <summary>
    /// Close a specific page by class, anywhere in the stack.
    /// If the page is the top page, plays exit animation first.
    /// If the page is in the middle, removes it directly.
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

        // If it's the top page, use Pop() for proper exit animation
        if (targetIndex == _stack.Count - 1)
        {
            Pop();
            return;
        }

        // Otherwise, remove directly
        var entry = _stack[targetIndex];
        _stack.RemoveAt(targetIndex);

        if (entry.Instance is UIFlowPage page)
        {
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

    /// <summary>
    /// Move an existing page to the top of the stack.
    /// </summary>
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
            return; // Not found or already on top

        // Notify current top it's being hidden
        var currentTop = _stack[^1];
        if (currentTop.Instance is UIFlowPage currentPage)
            currentPage.InvokeHidden();

        // Move to top
        var entry = _stack[targetIndex];
        _stack.RemoveAt(targetIndex);
        _stack.Add(entry);

        // Bring to front in the scene tree
        if (entry.Instance.IsInsideTree())
            _container.MoveChild(entry.Instance, _container.GetChildCount() - 1);

        // Notify moved page it's now shown
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
