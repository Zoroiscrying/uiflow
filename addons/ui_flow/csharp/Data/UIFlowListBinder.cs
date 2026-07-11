using Godot;
using System;
using System.Collections.Generic;
using UIFlow.Utils;
using GodotArray = Godot.Collections.Array;

namespace UIFlow.Data;

/// <summary>
/// Binds an array signal to a UI template list.
/// Supports stable identity via an optional key function.
/// </summary>
public class UIFlowListBinder : IDisposable
{
    private readonly Node _container;
    private readonly PackedScene _template;
    private readonly Action<Control, object, int> _binder;
    private readonly Func<object, int, object> _keyFunc;
    private readonly Signal _signal;
    private readonly Callable _callback;
    private readonly List<Control> _instances = new();
    private readonly List<object> _itemKeys = new();

    public UIFlowListBinder(Node container, Signal signal, PackedScene template, Action<Control, object, int> binder, Func<object, int, object> keyFunc = null)
    {
        _container = container;
        _template = template;
        _binder = binder;
        _keyFunc = keyFunc;
        _signal = signal;
        _callback = Callable.From<GodotArray>(OnDataChanged);
        _signal.Connect(_callback);
    }

    private void OnDataChanged(GodotArray data) => UpdateList(data);

    private void UpdateList(GodotArray data)
    {
        var newKeys = ComputeKeys(data);

        // Build map: key -> instance
        var instanceMap = new Dictionary<object, Control>();
        for (int i = 0; i < _instances.Count; i++)
            instanceMap[_itemKeys[i]] = _instances[i];

        // Reorder / resize, reusing existing instances
        var newInstances = new List<Control>();
        for (int i = 0; i < data.Count; i++)
        {
            var key = newKeys[i];
            Control instance;
            if (instanceMap.TryGetValue(key, out instance))
            {
                instanceMap.Remove(key);
            }
            else
            {
                instance = _template.Instantiate<Control>();
                _container.AddChild(instance);
            }
            newInstances.Add(instance);
            _binder(instance, data[i], i);
        }

        // Destroy unused instances
        foreach (var unused in instanceMap.Values)
        {
            if (GodotObject.IsInstanceValid(unused))
            {
                _container.RemoveChild(unused);
                unused.QueueFree();
            }
        }

        _instances.Clear();
        _instances.AddRange(newInstances);
        _itemKeys.Clear();
        _itemKeys.AddRange(newKeys);
    }

    private List<object> ComputeKeys(GodotArray data)
    {
        var keys = new List<object>();
        if (_keyFunc != null)
        {
            for (int i = 0; i < data.Count; i++)
                keys.Add(_keyFunc(data[i], i));
        }
        else
        {
            for (int i = 0; i < data.Count; i++)
                keys.Add(i);
        }
        return keys;
    }

    public void Unbind()
    {
        if (_signal.IsConnected(_callback))
            _signal.Disconnect(_callback);
        foreach (var inst in _instances)
            if (GodotObject.IsInstanceValid(inst)) inst.QueueFree();
        _instances.Clear();
        _itemKeys.Clear();
    }

    public void Dispose() => Unbind();
}
