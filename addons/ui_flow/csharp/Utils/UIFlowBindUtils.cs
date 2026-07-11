using Godot;
using System;

namespace UIFlow.Utils
{
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
            Callable cb = Callable.From(new Action<Variant>(value =>
            {
                if (GodotObject.IsInstanceValid(node)) node.Set(prop, value);
            }));
            return new UIFlowBinding(signal, cb);
        }

        public static UIFlowBinding BindSignalT<T>(Node node, StringName prop, Signal signal, Func<T, Variant> transform)
        {
            Callable cb = Callable.From(new Action<T>(value =>
            {
                if (GodotObject.IsInstanceValid(node)) node.Set(prop, transform(value));
            }));
            return new UIFlowBinding(signal, cb);
        }

        public static UIFlowBinding BindVisible(Node node, Signal signal, Func<float, bool> predicate)
        {
            Callable cb = Callable.From(new Action<float>(value =>
            {
                if (GodotObject.IsInstanceValid(node) && node is CanvasItem ci)
                    ci.Visible = predicate(value);
            }));
            return new UIFlowBinding(signal, cb);
        }

        /// <summary>
        /// Bind signal value to a format string property.
        /// e.g., BindFormat(label, "text", signal, "HP: %s") → "HP: 100"
        /// </summary>
        public static UIFlowBinding BindFormat(Node node, StringName prop, Signal signal, string format)
        {
            Callable cb = Callable.From(new Action<Variant>(value =>
            {
                if (GodotObject.IsInstanceValid(node)) node.Set(prop, string.Format(format, value));
            }));
            return new UIFlowBinding(signal, cb);
        }

        /// <summary>
        /// Two-way slider binding. Signal updates slider, slider changes call setter.
        /// </summary>
        public static UIFlowBinding BindSlider(Godot.Range slider, Signal signal, Action<float> setter)
        {
            // Signal → slider
            Callable cb = Callable.From(new Action<float>(value =>
            {
                if (GodotObject.IsInstanceValid(slider)) slider.Value = value;
            }));
            var binding = new UIFlowBinding(signal, cb);

            // Slider → setter (no feedback loop)
            slider.ValueChanged += (value) => setter((float)value);

            return binding;
        }
    }
}
