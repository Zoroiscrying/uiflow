using System.Collections.Generic;
using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// Manages input actions per page with state tracking.
    /// </summary>
    public partial class UIFlowInputActionManager : Node
    {
        [Signal]
        public delegate void ActionEnabledChangedEventHandler(string actionName, bool enabled);

        private readonly Dictionary<ulong, List<UIInputActionNode>> _pageActions = new();
        private readonly Dictionary<StringName, bool> _buttonStates = new();
        private readonly Dictionary<StringName, float> _axis1dStates = new();
        private readonly Dictionary<StringName, Vector2> _axis2dStates = new();
        private readonly Dictionary<StringName, float> _holdTimers = new();

        public override void _Process(double delta)
        {
            UpdateHoldTimers((float)delta);
        }

        public void RegisterActions(Control page, Godot.Collections.Array actions)
        {
            var actionList = new List<UIInputActionNode>();
            foreach (var action in actions)
            {
                if (action is UIInputActionNode node)
                    actionList.Add(node);
            }
            _pageActions[page.GetInstanceId()] = actionList;
        }

        public void UnregisterActions(Control page)
        {
            _pageActions.Remove(page.GetInstanceId());
        }

        public Godot.Collections.Array GetActions(Control page)
        {
            var result = new Godot.Collections.Array();
            if (_pageActions.TryGetValue(page.GetInstanceId(), out var actions))
            {
                foreach (var action in actions)
                    result.Add(action);
            }
            return result;
        }

        public Godot.Collections.Array GetEnabledActions(Control page)
        {
            var result = new Godot.Collections.Array();
            if (_pageActions.TryGetValue(page.GetInstanceId(), out var actions))
            {
                foreach (var action in actions)
                {
                    if (action.Enabled)
                        result.Add(action);
                }
            }
            return result;
        }

        public void SetActionEnabled(Control page, StringName actionName, bool enabled)
        {
            if (_pageActions.TryGetValue(page.GetInstanceId(), out var actions))
            {
                foreach (var action in actions)
                {
                    if (action.ActionName == actionName)
                    {
                        action.Enabled = enabled;
                        EmitSignal(SignalName.ActionEnabledChanged, actionName, enabled);
                        return;
                    }
                }
            }
        }

        public bool IsActionPressed(StringName actionName)
        {
            return _buttonStates.GetValueOrDefault(actionName, false);
        }

        public float GetAxis1d(StringName actionName)
        {
            return _axis1dStates.GetValueOrDefault(actionName, 0f);
        }

        public Vector2 GetAxis2d(StringName actionName)
        {
            return _axis2dStates.GetValueOrDefault(actionName, Vector2.Zero);
        }

        public Godot.Collections.Array GetPrompts(Control page)
        {
            var prompts = new Godot.Collections.Array();
            if (_pageActions.TryGetValue(page.GetInstanceId(), out var actions))
            {
                foreach (var action in actions)
                {
                    prompts.Add(new Godot.Collections.Dictionary
                    {
                        { "label", action.Label },
                        { "icon", action.Icon },
                        { "enabled", action.Enabled },
                        { "type", (int)action.ActionType }
                    });
                }
            }
            return prompts;
        }

        private void UpdateHoldTimers(float delta)
        {
            var keys = new List<StringName>(_holdTimers.Keys);
            foreach (var key in keys)
                _holdTimers[key] += delta;
        }
    }
}
