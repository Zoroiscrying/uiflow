using Godot;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// Resolves UIFlowPage class references to PackedScene resources.
/// Resolution order:
/// 1. Custom mappings registered via RegisterScene()
/// 2. Convention-based: searches in all registered scene directories (recursive)
/// </summary>
public class UIFlowSceneResolver
{
    private const string DefaultSceneDir = "res://UIScene/";
    private const string SettingSceneDir = "ui_flow/scene_directory";

    private readonly Dictionary<Script, PackedScene> _customMappings = new();
    private readonly Dictionary<Script, PackedScene> _cache = new();
    private readonly List<string> _sceneDirs = new();

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

        // Add addon internal scene directories (for demos)
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

        var className = pageClass.GetGlobalName();
        if (string.IsNullOrEmpty(className))
        {
            GD.PushError($"UIFlow: Cannot resolve scene for unnamed script: {pageClass.ResourcePath}");
            return null;
        }

        var sceneFilename = className + ".tscn";
        foreach (var sceneDir in _sceneDirs)
        {
            var result = SearchRecursive(sceneDir, sceneFilename);
            if (!string.IsNullOrEmpty(result))
            {
                var scene = GD.Load<PackedScene>(result);
                if (scene != null)
                {
                    _cache[pageClass] = scene;
                    return scene;
                }
            }
        }

        GD.PushError($"UIFlow: Scene not found for class '{className}'. Searched in: {string.Join(", ", _sceneDirs)}. Use UIFlow.RegisterScene() to set a custom path.");
        return null;
    }

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
