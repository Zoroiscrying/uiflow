using Godot;
using System;
using System.Collections.Generic;

namespace UIFlow.Utils;

/// <summary>
/// Common UI utility functions.
/// </summary>
public static class UIFlowUtils
{
    // ── Traverse / Find ──────────────────────────────────────────────────────

    public static void ForEachChild(Node node, Action<Node, int> callback)
    {
        for (int i = 0; i < node.GetChildCount(); i++)
            callback(node.GetChild(i), i);
    }

    public static void ForEachDescendant(Node node, Action<Node> callback)
    {
        foreach (var child in node.GetChildren())
        {
            callback(child);
            ForEachDescendant(child, callback);
        }
    }

    public static Node FindChild(Node node, Func<Node, bool> predicate)
    {
        foreach (var child in node.GetChildren())
            if (predicate(child)) return child;
        return null;
    }

    public static List<Node> FindChildren(Node node, Func<Node, bool> predicate)
    {
        var result = new List<Node>();
        foreach (var child in node.GetChildren())
            if (predicate(child)) result.Add(child);
        return result;
    }

    public static T FindChildByType<T>(Node node) where T : Node
    {
        foreach (var child in node.GetChildren())
            if (child is T typed) return typed;
        return null;
    }

    public static List<T> FindChildrenByType<T>(Node node) where T : Node
    {
        var result = new List<T>();
        foreach (var child in node.GetChildren())
            if (child is T typed) result.Add(typed);
        return result;
    }

    public static Node FindChildByName(Node node, string name)
    {
        foreach (var child in node.GetChildren())
            if (child.Name == name) return child;
        return null;
    }

    public static Node FindDescendantByName(Node node, string name)
    {
        foreach (var child in node.GetChildren())
        {
            if (child.Name == name) return child;
            var found = FindDescendantByName(child, name);
            if (found != null) return found;
        }
        return null;
    }

    // ── ReserveChildren ──────────────────────────────────────────────────────

    public static void ReserveChildren(Node parent, int count, PackedScene template, Action<Control, int> onUpdate = null)
    {
        while (parent.GetChildCount() < count)
        {
            var instance = template.Instantiate<Control>();
            parent.AddChild(instance);
        }
        while (parent.GetChildCount() > count)
        {
            var last = parent.GetChild(parent.GetChildCount() - 1);
            parent.RemoveChild(last);
            last.QueueFree();
        }
        if (onUpdate != null)
        {
            for (int i = 0; i < count; i++)
                onUpdate((Control)parent.GetChild(i), i);
        }
    }

    public static void ReserveChildrenFactory(Node parent, int count, Func<Node> factory, Action<Node, int> onUpdate = null)
    {
        while (parent.GetChildCount() < count)
        {
            var instance = factory();
            parent.AddChild(instance);
        }
        while (parent.GetChildCount() > count)
        {
            var last = parent.GetChild(parent.GetChildCount() - 1);
            parent.RemoveChild(last);
            last.QueueFree();
        }
        if (onUpdate != null)
        {
            for (int i = 0; i < count; i++)
                onUpdate(parent.GetChild(i), i);
        }
    }

    // ── Batch Operations ─────────────────────────────────────────────────────

    public static void SetVisible(IEnumerable<Control> nodes, bool visible)
    {
        foreach (var node in nodes)
            if (IsInstanceValid(node)) node.Visible = visible;
    }

    public static void SetAlpha(IEnumerable<CanvasItem> nodes, float alpha)
    {
        foreach (var node in nodes)
            if (IsInstanceValid(node)) node.Modulate = new Color(1, 1, 1, alpha);
    }

    public static void SetButtonsEnabled(IEnumerable<BaseButton> buttons, bool enabled)
    {
        foreach (var btn in buttons)
            if (IsInstanceValid(btn)) btn.Disabled = !enabled;
    }

    public static void ClearChildren(Node parent)
    {
        foreach (var child in parent.GetChildren())
        {
            parent.RemoveChild(child);
            child.QueueFree();
        }
    }
}
