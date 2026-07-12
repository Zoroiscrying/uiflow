# 事件总线

`UIFlowEventBus` 提供松散的发布/订阅机制，支持 sticky 值、一次性订阅和按订阅者清理。

## 订阅与发布

```gdscript
# 订阅
UIFlow.EventBus.subscribe("level_up", self, _on_level_up)

# 发布
UIFlow.EventBus.emit("level_up", {"level": 5})

func _on_level_up(data: Dictionary) -> void:
    print("升级到 ", data["level"])
```

## Sticky 值

发布时标记为 sticky，新订阅者会立即收到最后一次值：

```gdscript
UIFlow.EventBus.emit("music_volume", 0.8, true)

# 稍后订阅也能立刻拿到 0.8
UIFlow.EventBus.subscribe("music_volume", self, _on_volume)
```

## 一次性订阅

```gdscript
UIFlow.EventBus.subscribe_once("reward_claimed", self, _on_reward)
```

## 自动清理

页面关闭时，UIFlowPage 会自动调用 `UIFlow.EventBus.clear_subscriber(self)`，无需手动取消订阅。

## 使用建议

- 适合“玩家升级”、“获得奖励”、“语言切换”等全局事件。
- 不建议在总线中传递大量数据或替代页面间直接传参。
