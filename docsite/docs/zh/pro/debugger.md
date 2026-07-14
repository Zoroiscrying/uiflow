# Pro 运行时调试器

!!! tip "Pro 功能"
    运行时调试器仅在 **UIFlow Pro** 中提供。

UIFlow Pro 附带运行时调试器面板，可附加到运行中的游戏，将 UI 状态实时流式传输到 Godot 编辑器。

## 捕获的数据

调试器捕获以下通道：

| 通道 | 可见内容 |
|---|---|
| `stack` | 当前导航栈、页面状态、模态标志。 |
| `pool` | 对象池内容、获取/释放次数、池大小。 |
| `event_bus` | 活跃订阅、sticky 值、最近 emit。 |
| `memory` | 估计的 UI 节点数量和内存压力。 |
| `bindings` | 每个页面的活跃 property/signal/list 绑定。 |
| `log_snapshot` | 最近的 UIFlow 日志条目。 |

## 如何使用

1. 启用 **UIFlow Pro** 插件。
2. 从编辑器运行场景。
3. 打开 **UIFlow Debugger** 面板。
4. 选择通道查看实时数据。

调试器使用自定义调试桥接 autoload `UIFlowProDebugBridge`。它只在编辑器中运行，发布构建会自动移除。

## 使用场景

- 页面没打开：检查 `stack` 通道是否有被阻塞的导航或 guard 拒绝。
- 内存持续上涨：检查 `pool` 和 `memory` 是否有泄漏的页面实例。
- 绑定没更新：在 `bindings` 通道中确认绑定是否存在。
- 事件没触发：在 `event_bus` 通道中确认订阅情况。

## 安全说明

调试桥仅用于编辑器，不会在导出项目中暴露数据。请勿从游戏代码手动引用它。
