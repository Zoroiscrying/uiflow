using Godot;
using System.Collections.Generic;

namespace UIFlow.Core;

/// <summary>
/// Resolves UIFlowPage class references to PackedScene resources.
/// Convention: {scene_directory}/{ClassName}.tscn
/// </summary>
public class UIFlowSceneResolver
{
    private const string DefaultSceneDir = "res://UIScene/";
    private const string SettingSceneDir = "ui_flow/scene_directory";

    private readonly Dictionary<Script, PackedScene> _customMappings = new();
    private readonly Dictionary<Script, PackedScene> _cache = new();
    private string _sceneDir;

    public UIFlowSceneResolver()
    {
        LoadSettings();
    }

    private void LoadSettings()
    {
        _sceneDir = ProjectSettings.HasSetting(SettingSceneDir)
            ? (string)ProjectSettings.GetSetting(SettingSceneDir)
            : DefaultSceneDir;
        if (!_sceneDir.EndsWith("/")) _sceneDir += "/";
    }

    public void RegisterScene(Script pageClass, PackedScene scene)
    {
        _customMappings[pageClass] = scene;
        _cache.Remove(pageClass);
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

        var scenePath = _sceneDir + className + ".tscn";
        if (ResourceLoader.Exists(scenePath))
        {
            var scene = GD.Load<PackedScene>(scenePath);
            if (scene != null)
            {
                _cache[pageClass] = scene;
                return scene;
            }
        }

        GD.PushError($"UIFlow: Scene not found for class '{className}'. Expected at: {scenePath}");
        return null;
    }
}
