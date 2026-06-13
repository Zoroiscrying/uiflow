using System.Collections.Generic;
using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// Input Manager — routes input to the topmost page.
    /// Rules:
    /// 1. Input goes to the topmost page first
    /// 2. Modal pages intercept all input
    /// 3. Back/cancel is handled per-page via OnBack override
    /// </summary>
    public partial class UIFlowInputHandler : Node
    {
        [Signal]
        public delegate void BackPressedEventHandler();

        private UIFlowNavigator _navigator;
        private UIFlowInputActionManager _actionManager;
        private Control _defaultFocusNode;

        public void Setup(UIFlowNavigator navigator)
        {
            _navigator = navigator;
            _actionManager = new UIFlowInputActionManager();
            AddChild(_actionManager);
        }

        public void SetDefaultFocus(Control node)
        {
            _defaultFocusNode = node;
            if (node != null && GodotObject.IsInstanceValid(node) && node.IsInsideTree())
                node.GrabFocus();
        }

        public void GrabFocus(Control node)
        {
            if (node != null && GodotObject.IsInstanceValid(node) && node.IsInsideTree())
                node.GrabFocus();
        }

        public Godot.Collections.Array GetCurrentPrompts()
        {
            var topPage = GetTopPage();
            if (topPage != null && _actionManager != null)
                return _actionManager.GetPrompts(topPage);
            return new Godot.Collections.Array();
        }

        private UIFlowPage GetTopPage()
        {
            if (_navigator == null || _navigator.Stack.Count == 0)
                return null;
            return _navigator.Stack.Back()["instance"] as UIFlowPage;
        }

        public override void _UnhandledInput(InputEvent @event)
        {
            if (_navigator == null)
                return;

            if (!@event.IsActionPressed("ui_cancel"))
                return;

            var stack = _navigator.Stack;
            for (int i = stack.Count - 1; i >= 0; i--)
            {
                var page = stack[i]["instance"] as UIFlowPage;
                if (page == null || !GodotObject.IsInstanceValid(page))
                    continue;

                page.InvokeBack();
                GetViewport().SetInputAsHandled();
                return;
            }

            var topPage = stack.Count > 0 ? stack.Back()["instance"] as UIFlowPage : null;
            if (topPage != null && topPage.IsModal)
                GetViewport().SetInputAsHandled();
        }
    }
}
