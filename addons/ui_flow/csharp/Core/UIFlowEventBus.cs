using Godot;
using System;
using System.Collections.Generic;
using UIFlow.Utils;

namespace UIFlow.Core;

/// <summary>
/// Lightweight pub/sub event bus for cross-page communication.
/// Supports sticky events and automatic cleanup.
/// </summary>
public class UIFlowEventBus
{
    public class Subscription
    {
        public int Token;
        public string Topic;
        public Callable Callback;
        public bool Once;
        public GodotObject Subscriber; // Used for auto-cleanup
    }

    private int _nextToken = 1;
    private readonly Dictionary<int, Subscription> _subscriptions = new();
    private readonly Dictionary<string, List<int>> _topicSubs = new();
    private readonly Dictionary<string, Variant> _sticky = new();

    /// <summary>Publish an event to all subscribers of a topic.</summary>
    public void Publish(string topic, Variant data = new())
    {
        if (!_topicSubs.TryGetValue(topic, out var tokens)) return;
        var copy = new List<int>(tokens);
        foreach (var token in copy)
        {
            if (_subscriptions.TryGetValue(token, out var sub))
            {
                if (sub.Callback.IsValid())
                    sub.Callback.Call(data);
                if (sub.Once)
                    Unsubscribe(token);
            }
        }
    }

    /// <summary>Publish a sticky event. New subscribers will immediately receive this value.</summary>
    public void PublishSticky(string topic, Variant data = new())
    {
        _sticky[topic] = data;
        Publish(topic, data);
    }

    /// <summary>Subscribe to a topic. Returns a token for unsubscribing.</summary>
    public int Subscribe(string topic, Callable callback, GodotObject subscriber = null, bool once = false)
    {
        var token = _nextToken++;
        var sub = new Subscription
        {
            Token = token,
            Topic = topic,
            Callback = callback,
            Once = once,
            Subscriber = subscriber
        };
        _subscriptions[token] = sub;
        if (!_topicSubs.ContainsKey(topic))
            _topicSubs[topic] = new List<int>();
        _topicSubs[topic].Add(token);

        if (_sticky.TryGetValue(topic, out var stickyData))
            callback.Call(stickyData);

        return token;
    }

    /// <summary>Subscribe once, auto-removing after the first event.</summary>
    public int SubscribeOnce(string topic, Callable callback, GodotObject subscriber = null)
        => Subscribe(topic, callback, subscriber, true);

    /// <summary>Unsubscribe by token.</summary>
    public void Unsubscribe(int token)
    {
        if (!_subscriptions.TryGetValue(token, out var sub)) return;
        _subscriptions.Remove(token);
        if (_topicSubs.TryGetValue(sub.Topic, out var tokens))
        {
            tokens.Remove(token);
            if (tokens.Count == 0)
                _topicSubs.Remove(sub.Topic);
        }
    }

    /// <summary>Remove all subscriptions owned by a given subscriber.</summary>
    public void ClearSubscriber(GodotObject subscriber)
    {
        if (subscriber == null) return;
        var toRemove = new List<int>();
        foreach (var kv in _subscriptions)
        {
            if (kv.Value.Subscriber == subscriber)
                toRemove.Add(kv.Key);
        }
        foreach (var token in toRemove)
            Unsubscribe(token);
    }

    /// <summary>Get the latest sticky value for a topic, or null if none.</summary>
    public Variant GetSticky(string topic)
        => _sticky.TryGetValue(topic, out var data) ? data : new Variant();

    /// <summary>Clear all subscriptions and sticky values.</summary>
    public void Clear()
    {
        _subscriptions.Clear();
        _topicSubs.Clear();
        _sticky.Clear();
    }
}
