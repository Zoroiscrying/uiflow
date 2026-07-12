# UIFlow

UIFlow 是面向 **Godot 4.6+** 的 UI 工作流框架，提供栈式页面导航、页面生命周期、过渡动画、数据绑定、事件总线以及一组可复用的 UI 组件。

本仓库仅包含 **UIFlow Free** 插件文档。Pro 插件的相关内容不在此处维护。

## 主要特性

- **栈式导航**：`push` / `pop` / `replace`，支持模态与返回拦截。
- **生命周期**：`_on_created` → `_on_opened` → `_on_after_opened` → `_on_hidden` / `_on_shown` → `_on_closed` / `_on_destroyed`。
- **过渡动画**：内置 Fade / Slide / Scale / Timeline 等多种效果，可按页面配置 enter / exit。
- **数据绑定**：`bind_property`、`bind_signal`、`bind_list`，页面关闭时自动解绑。
- **事件总线**：发布订阅、sticky 值、一次性订阅、按订阅者自动清理。
- **Async / Timeline**：用 `await` 串联动画、异步操作和页面流转。
- **可复用组件**：Toast、Confirm / Alert 对话框、DataGrid、VirtualList、Tooltip 等。

## 适用场景

- 需要维护复杂 UI 栈的 RPG / ARPG / 卡牌 / 模拟经营类游戏。
- 希望把每个界面作为独立页面管理的中小型项目。
- 想用 GDScript 为主、C# 为辅的方式组织 UI 代码的团队。

## 快速开始

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

或跟随 [安装与配置](getting-started/installation.md) 把插件集成到自己的项目中。
