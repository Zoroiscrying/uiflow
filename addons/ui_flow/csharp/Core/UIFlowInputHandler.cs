using System.Collections.Generic;
using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// Input Manager — routes back/cancel input to the topmost page.
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
            if (_navigator == null || _navigator.Depth() == 0)
                return null;
            return _navigator.CurrentPageInstance() as UIFlowPage;
        }

        public override void _UnhandledInput(InputEvent @event)
        {
            if (_navigator == null || _navigator.Depth() == 0)
                return;
            if (!@event.IsActionPressed("ui_cancel"))
                return;

            var topPage = GetTopPage();
            if (topPage == null || !GodotObject.IsInstanceValid(topPage))
                return;

            // Modal pages intercept back input
            if (topPage.IsModal)
            {
                topPage.InvokeBack();
                if (UIFlow.Instance?.Config?.ModalCloseOnBack ?? true)
                {
                    if (_navigator.Depth() > 1)
                        _navigator.Pop();
                    else
                        EmitSignal(SignalName.BackPressed);
                }
                GetViewport().SetInputAsHandled();
                return;
            }

            // Non-modal: try page-specific back handler
            topPage.InvokeBack();
            if (_navigator.Depth() > 1)
            {
                _navigator.Pop();
                GetViewport().SetInputAsHandled();
                return;
            }

            // Root page
            EmitSignal(SignalName.BackPressed);
            GetViewport().SetInputAsHandled();
        }
    }
}
