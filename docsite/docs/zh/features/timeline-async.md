# Timeline 与 Async

UIFlow 支持把多个动画/等待组合成一段 **Timeline**，并通过 `await` 与异步逻辑结合。

## Timeline 效果

`UIFlowTimelineEffect` 由多个 `UIFlowEffect` 步骤组成，可配置：

- **Effects**：每段效果数组。
- **Step Delays**：每段开始前的延迟。
- **Step Wait for Completion**：是否等待该段完成才进入下一段。

## 两段式 Scale Punch 示例

![Timeline 配置](/assets/screenshots/timeline_scale_config.png)

```gdscript
# 配置内容：
# Step 0: UIFlowScaleEffect，duration 0.15，from 0.0 to 0.5，curve punch out
# Step 1: UIFlowScaleEffect，duration 0.15，from 0.5 to 1.0，curve punch out
```

这样页面进入时会先快速放大到 0.5，再弹到正常尺寸，形成 punch 弹性效果。

## Async 流程

在页面中可以直接 `await` UIFlow 动画：

```gdscript
func _play_open_sequence() -> void:
    await UIFlow.Animator.tween(self, UIFlowTweenProp.MODULATE, Color.WHITE, 0.2).finished
    await UIFlow.Animator.tween(self, UIFlowTweenProp.SCALE, Vector2.ONE, 0.3).finished
    _enable_input()
```

## 与导航结合

```gdscript
func _on_start() -> void:
    await UIFlow.Animator.tween(self, UIFlowTweenProp.OPACITY, 0.0, 0.2).finished
    UIFlow.push(GamePage)
```

## 异步导航与加载页

场景较大时，用 `push_async()` 在后台线程加载场景，避免卡顿：

```gdscript
await UIFlow.push_async(InventoryPage)
```

`push_async_with_loading()` 在目标场景加载期间显示一个加载页，加载完成后自动替换为目标页：

```gdscript
# 显式指定加载页：
await UIFlow.push_async_with_loading(WorldPage, {"level": 3}, null, MyLoadingPage)

# 或者配置一次默认加载页（参数省略时使用）：
UIFlow.Config.loading_page_class = MyLoadingPage
await UIFlow.push_async_with_loading(WorldPage)
```

**进度协议。** 加载页实现了 `set_progress(float)` 时，导航器会把线程加载进度转发给它（0.0–1.0，必定以 1.0 结束，命中缓存也一样）：

```gdscript
class_name MyLoadingPage extends UIFlowPage

@onready var _bar: ProgressBar = $Center/ProgressBar

func set_progress(p: float) -> void:
    _bar.value = p * 100.0
```

加载页就是普通的 `UIFlowPage`，完全可以换皮——主题、过渡、布局随你定制。完整示例见免费 demo 中的 `AsyncLoadingPage`（Timeline & Async 演示）。

**预热。** 想让首次 push 秒开，可以提前预加载场景：

```gdscript
await UIFlow.load_scenes_async([WorldPage, InventoryPage])
```

## 建议

- 复杂 enter / exit 优先使用 `UIFlowTimelineEffect` 资源，而不是在代码里手写。
- 简单一次性动画可在代码中用 `await` 快速实现。
