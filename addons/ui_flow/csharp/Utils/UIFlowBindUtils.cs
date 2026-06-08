using Godot;
using System;

namespace UIFlow.Utils;

public static class UIFlowBindUtils
{
    public class UIFlowBinding : IDisposable
    {
        private Signal _signal;
        private Callable _callable;

        public UIFlowBinding(Signal signal, Callable callable)
        {
            _signal = signal;
            _callable = callable;
            if (!_signal.IsConnected(_callable))
                _signal.Connect(_callable);
        }

        public void Unbind()
        {
            if (_signal.IsConnected(_callable))
                _signal.Disconnect(_callable);
        }

        public void Dispose() => Unbind();
    }

    public static UIFlowBinding BindSignal(Node node, StringName prop, Signal signal)
    {
        Callable cb = new Callable(new Action<Variant>(value =>
        {
            if (IsInstanceValid(node)) node.Set(prop, value);
        }));
        return new UIFlowBinding(signal, cb);
    }

    public static UIFlowBinding BindSignalT<T>(Node node, StringName prop, Signal signal, Func<T, Variant> transform)
    {
        Callable cb = new Callable(new Action<T>(value =>
        {
            if (IsInstanceValid(node)) node.Set(prop, transform(value));
        }));
        return new UIFlowBinding(signal, cb);
    }

    public static UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
    {
        Callable cb = new Callable(new Action<float>(value =>
        {
            if (IsInstanceValid(node)) node.Visible = predicate(value);
        }));
        return new UIFlowBinding(signal, cb);
    }
}
