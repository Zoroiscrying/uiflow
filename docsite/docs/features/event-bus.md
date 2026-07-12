# Event Bus

`UIFlowEventBus` provides a loose pub/sub mechanism with sticky values, one-shot subscriptions, and per-subscriber cleanup.

## Subscribe and Emit

```gdscript
# Subscribe
UIFlow.EventBus.subscribe("level_up", self, _on_level_up)

# Emit
UIFlow.EventBus.emit("level_up", {"level": 5})

func _on_level_up(data: Dictionary) -> void:
    print("Leveled up to ", data["level"])
```

## Sticky Values

When emitting with the sticky flag, new subscribers immediately receive the last value:

```gdscript
UIFlow.EventBus.emit("music_volume", 0.8, true)

# Subscribing later still receives 0.8 immediately
UIFlow.EventBus.subscribe("music_volume", self, _on_volume)
```

## One-shot Subscription

```gdscript
UIFlow.EventBus.subscribe_once("reward_claimed", self, _on_reward)
```

## Automatic Cleanup

When a page closes, `UIFlowPage` automatically calls `UIFlow.EventBus.clear_subscriber(self)`, so you do not need to unsubscribe manually.

## Recommendations

- Good for global events such as "player leveled up", "reward received", or "language changed".
- Avoid passing large payloads or using it as a replacement for direct page-to-page data passing.
