using System;
using System.Collections.Generic;
using Godot;

namespace UIFlow.Core
{
    /// <summary>
    /// Route guard system for conditional navigation.
    /// Guards are checked before a page is pushed. If any guard returns false,
    /// the navigation is blocked.
    /// </summary>
    public class UIFlowGuard
    {
        private readonly List<Func<GDScript, GDScript, object, bool>> _globalGuards = new();
        private readonly Dictionary<GDScript, List<Func<GDScript, object, bool>>> _pageGuards = new();

        /// <summary>
        /// Add a global guard that checks all navigation.
        /// Guard receives (fromPage, toPage, data) and returns true to allow, false to block.
        /// </summary>
        public void AddGuard(Func<GDScript, GDScript, object, bool> guard)
        {
            _globalGuards.Add(guard);
        }

        /// <summary>
        /// Remove a global guard.
        /// </summary>
        public void RemoveGuard(Func<GDScript, GDScript, object, bool> guard)
        {
            _globalGuards.Remove(guard);
        }

        /// <summary>
        /// Add a guard for a specific target page.
        /// Guard receives (fromPage, data) and returns true to allow, false to block.
        /// </summary>
        public void AddPageGuard(GDScript pageClass, Func<GDScript, object, bool> guard)
        {
            if (!_pageGuards.ContainsKey(pageClass))
                _pageGuards[pageClass] = new List<Func<GDScript, object, bool>>();
            _pageGuards[pageClass].Add(guard);
        }

        /// <summary>
        /// Remove a page-specific guard.
        /// </summary>
        public void RemovePageGuard(GDScript pageClass, Func<GDScript, object, bool> guard)
        {
            if (_pageGuards.TryGetValue(pageClass, out var guards))
                guards.Remove(guard);
        }

        /// <summary>
        /// Check if navigation is allowed. Returns true if allowed, false if blocked.
        /// </summary>
        public bool CanNavigate(GDScript fromPage, GDScript toPage, object data = null)
        {
            foreach (var guard in _globalGuards)
            {
                if (!guard(fromPage, toPage, data))
                    return false;
            }

            if (_pageGuards.TryGetValue(toPage, out var pageGuards))
            {
                foreach (var guard in pageGuards)
                {
                    if (!guard(fromPage, data))
                        return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Clear all guards.
        /// </summary>
        public void Clear()
        {
            _globalGuards.Clear();
            _pageGuards.Clear();
        }
    }
}
