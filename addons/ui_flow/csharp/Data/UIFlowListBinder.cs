using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Data;

/// <summary>
/// Binds an array signal to a UI template list.
/// </summary>
public class UIFlowListBinder : IDisposable
{
    private readonly Node _container;
    private readonly PackedScene _template;
    private readonly Action<Control, object, int> _binder;
    private readonly Signal _signal;
    private readonly List<Control> _instances = new();

    public UIFlowListBinder(Node container, Signal signal, PackedScene template, Action<Control, object, int> binder)
    {
        _container = container;
        _template = template;
        _binder = binder;
        _signal = signal;
        _signal.Connect(new Callable(this, MethodName.OnDataChanged));
    }

    private void OnDataChanged(Array data) => UpdateList(data);

    private void UpdateList(Array data)
    {
        while (_instances.Count < data.Count)
        {
            var instance = _template.Instantiate<Control>();
            _container.AddChild(instance);
            _instances.Add(instance);
        }
        while (_instances.Count > data.Count)
        {
            var last = _instances[^1];
            _instances.RemoveAt(_instances.Count - 1);
            _container.RemoveChild(last);
            last.QueueFree();
        }
        for (int i = 0; i < data.Count; i++)
            _binder(_instances[i], data[i], i);
    }

    public void Unbind()
    {
        if (_signal.IsConnected(new Callable(this, MethodName.OnDataChanged)))
            _signal.Disconnect(new Callable(this, MethodName.OnDataChanged));
        foreach (var inst in _instances)
            if (GodotObject.IsInstanceValid(inst)) inst.QueueFree();
        _instances.Clear();
    }

    public void Dispose() => Unbind();
}
