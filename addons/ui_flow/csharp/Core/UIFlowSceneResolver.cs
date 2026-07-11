using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using UIFlow.Utils;

namespace UIFlow.Core;

/// <summary>
/// Resolves UIFlowPage class references to PackedScene resources.
/// Supports object pooling when enabled via UIFlowConfig.
/// </summary>
public class UIFlowSceneResolver
{
    private const string DefaultSceneDir = "res://UIScene/";
    private const string SettingSceneDir = "ui_flow/scene_directory";

    private readonly Dictionary<Script, PackedScene> _customMappings = new();
    private readonly Dictionary<Script, PackedScene> _cache = new();
    private readonly List<string> _sceneDirs = new();

    /// <summary>Object pool keyed by scene path.</summary>
    private readonly Dictionary<string, List<Control>> _pool = new();

    public UIFlowSceneResolver()
    {
        LoadSettings();
    }

    private void LoadSettings()
    {
        _sceneDirs.Clear();
        _sceneDirs.Add(DefaultSceneDir);

        if (ProjectSettings.HasSetting(SettingSceneDir))
        {
            var customDir = (string)ProjectSettings.GetSetting(SettingSceneDir);
            if (!string.IsNullOrEmpty(customDir) && customDir != DefaultSceneDir)
            {
                if (!customDir.EndsWith("/")) customDir += "/";
                if (!_sceneDirs.Contains(customDir))
                    _sceneDirs.Add(customDir);
            }
        }

        var addonDemoDir = "res://addons/ui_flow/examples/scenes/UIScene/";
        if (!_sceneDirs.Contains(addonDemoDir))
            _sceneDirs.Add(addonDemoDir);

        var proDir = "res://addons/ui_flow_pro/examples/scenes/";
        if (!_sceneDirs.Contains(proDir))
            _sceneDirs.Add(proDir);
    }

    public void RegisterScene(Script pageClass, PackedScene scene)
    {
        _customMappings[pageClass] = scene;
        _cache.Remove(pageClass);
    }

    public void AddSceneDir(string dir)
    {
        if (!dir.EndsWith("/")) dir += "/";
        if (!_sceneDirs.Contains(dir))
            _sceneDirs.Add(dir);
    }

    public PackedScene Resolve(Script pageClass)
    {
        if (_cache.TryGetValue(pageClass, out var cached))
            return cached;

        if (_customMappings.TryGetValue(pageClass, out var custom))
        {
            _cache[pageClass] = custom;
            return custom;
        }

        var path = FindScenePath(pageClass);
        if (string.IsNullOrEmpty(path))
            return null;

        var scene = GD.Load<PackedScene>(path);
        if (scene != null)
            _cache[pageClass] = scene;
        return scene;
    }

    public async Task<PackedScene> ResolveAsync(Script pageClass, CancellationToken ct = default)
    {
        if (_cache.TryGetValue(pageClass, out var cached))
            return cached;

        if (_customMappings.TryGetValue(pageClass, out var custom))
        {
            _cache[pageClass] = custom;
            return custom;
        }

        var path = FindScenePath(pageClass);
        if (string.IsNullOrEmpty(path))
            return null;

        ResourceLoader.LoadThreadedRequest(path, "PackedScene");
        while (true)
        {
            ct.ThrowIfCancellationRequested();
            var status = ResourceLoader.LoadThreadedGetStatus(path);
            if (status == ResourceLoader.ThreadLoadStatus.Loaded)
            {
                var scene = ResourceLoader.LoadThreadedGet(path) as PackedScene;
                if (scene != null)
                    _cache[pageClass] = scene;
                return scene;
            }
            if (status == ResourceLoader.ThreadLoadStatus.InvalidResource || status == ResourceLoader.ThreadLoadStatus.Failed)
            {
                GD.PushError($"UIFlow: Async load failed for scene: {path}");
                return null;
            }
            await UIFlowUtils.NextFrame();
        }
    }

    private string FindScenePath(Script pageClass)
    {
        var className = pageClass.GetGlobalName();
        if (string.IsNullOrEmpty(className))
        {
            GD.PushError($"UIFlow: Cannot resolve scene for unnamed script: {pageClass.ResourcePath}");
            return "";
        }

        var sceneFilename = className + ".tscn";
        foreach (var sceneDir in _sceneDirs)
        {
            var result = SearchRecursive(sceneDir, sceneFilename);
            if (!string.IsNullOrEmpty(result))
                return result;
        }

        GD.PushError($"UIFlow: Scene not found for class '{className}'. Searched in: {string.Join(", ", _sceneDirs)}. Use UIFlow.RegisterScene() to set a custom path.");
        return "";
    }

    /// <summary>Try to acquire a pooled instance for a page class.</summary>
    public Control AcquirePooled(Script pageClass)
    {
        var scene = Resolve(pageClass);
        if (scene == null) return null;

        var path = scene.ResourcePath;
        if (!_pool.TryGetValue(path, out var pool)) return null;

        while (pool.Count > 0)
        {
            var instance = pool[pool.Count - 1];
            pool.RemoveAt(pool.Count - 1);
            if (GodotObject.IsInstanceValid(instance))
            {
                if (instance is UIFlowPage page)
                    page.InvokeUnpooled();
                return instance;
            }
        }
        return null;
    }

    /// <summary>Return an instance to the pool. Returns true if pooled.</summary>
    public bool ReleaseToPool(Script pageClass, Control instance)
    {
        if (!IsPoolingEnabled()) return false;

        var scene = Resolve(pageClass);
        if (scene == null) return false;

        var path = scene.ResourcePath;
        if (!_pool.TryGetValue(path, out var pool))
        {
            pool = new List<Control>();
            _pool[path] = pool;
        }

        var maxSize = UIFlow.Instance?.Config?.MaxPoolSize ?? 5;
        if (pool.Count >= maxSize) return false;

        if (instance is UIFlowPage page)
            page.InvokePooled();

        instance.Visible = false;
        instance.Modulate = new Color(1, 1, 1, 1);
        instance.Scale = Vector2.One;
        instance.Position = Vector2.Zero;

        pool.Add(instance);
        return true;
    }

    /// <summary>Clear all pooled instances.</summary>
    public void ClearPool()
    {
        foreach (var kv in _pool)
        {
            foreach (var instance in kv.Value)
            {
                if (GodotObject.IsInstanceValid(instance))
                    instance.QueueFree();
            }
        }
        _pool.Clear();
    }

    /// <summary>Pre-instantiate pages for the pool.</summary>
    public void WarmUp(IEnumerable<Script> pageClasses)
    {
        if (!IsPoolingEnabled()) return;
        foreach (var pageClass in pageClasses)
        {
            var scene = Resolve(pageClass);
            WarmUpScene(scene);
        }
    }

    /// <summary>Asynchronously load scenes and pre-instantiate pages for the pool.</summary>
    public async Task WarmUpAsync(IEnumerable<Script> pageClasses, CancellationToken ct = default)
    {
        if (!IsPoolingEnabled()) return;
        foreach (var pageClass in pageClasses)
        {
            var scene = await ResolveAsync(pageClass, ct);
            WarmUpScene(scene);
        }
    }

    private void WarmUpScene(PackedScene scene)
    {
        if (scene == null) return;
        var path = scene.ResourcePath;
        if (!_pool.TryGetValue(path, out var pool))
        {
            pool = new List<Control>();
            _pool[path] = pool;
        }

        var maxSize = UIFlow.Instance?.Config?.MaxPoolSize ?? 5;
        while (pool.Count < maxSize)
        {
            var instance = (Control)scene.Instantiate();
            if (instance is UIFlowPage page)
                page.InvokePooled();
            instance.Visible = false;
            pool.Add(instance);
        }
    }

    private static bool IsPoolingEnabled()
        => UIFlow.Instance?.Config?.EnableObjectPooling ?? false;

    private static string SearchRecursive(string dirPath, string filename)
    {
        var directPath = dirPath + filename;
        if (ResourceLoader.Exists(directPath))
            return directPath;

        var dir = DirAccess.Open(dirPath);
        if (dir == null) return "";

        dir.ListDirBegin();
        var entry = dir.GetNext();
        while (entry != "")
        {
            if (entry.StartsWith("."))
            {
                entry = dir.GetNext();
                continue;
            }
            if (dir.CurrentIsDir())
            {
                var subPath = dirPath + entry + "/";
                var found = SearchRecursive(subPath, filename);
                if (!string.IsNullOrEmpty(found))
                {
                    dir.ListDirEnd();
                    return found;
                }
            }
            entry = dir.GetNext();
        }
        dir.ListDirEnd();

        return "";
    }
}
