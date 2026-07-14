# Survivors ARPG 演示

!!! tip "Pro 功能"
    Survivors 演示仅在 **UIFlow Pro** 中提供。

Survivors 演示是一个完整的类 ARPG 示例，使用 UIFlow Pro 构建，展示如何在真实游戏循环中使用 Pro 组件和过渡效果。

## 如何运行

打开 Pro 示例文件夹并运行 Survivors 主场景：

```bash
godot --path . --scene res://addons/ui_flow_pro/examples/survivors/main.tscn
```

## 包含的页面

- **主 HUD**：血条、经验条、小地图、波次计时器。
- **升级页面**：使用 `UIFlowProTreeView` 选择技能。
- **装备页面**：使用 `UIFlowProInventoryGrid` 管理背包与装备槽。
- **商店页面**：使用 `UIFlowProDataGrid` 购买 / 出售道具。
- **暂停页面**：设置、继续、退出及确认对话框。
- **波次总结页面**：每波结束后的统计与奖励。

## 使用的 Pro 功能

- **Pro 过渡**：菜单的高级进入 / 退出效果。
- **Pro 组件**：`UIFlowProInventoryGrid`、`UIFlowProDataGrid`、`UIFlowProTreeView`。
- **运行时调试器**：游戏运行时检查栈和池状态。
- **主题编辑器**：演示使用自定义 Pro 主题。

## 学习要点

- HUD 页面使用无过渡 push，避免打断游戏。
- 模态页面（商店、升级、暂停）会拦截游戏世界输入。
- 事件总线协调波次状态、玩家属性和 UI 更新。

![Survivors 演示截图](../assets/screenshots/survivors_demo.png)
