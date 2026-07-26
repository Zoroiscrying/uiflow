<div class="uf-docs-hero" markdown="0">
  <img src="../assets/icon.png" alt="UIFlow" width="88" height="88" />
  <div>
    <p class="uf-kicker">Godot 4.6 · Free MIT</p>
    <h1>UIFlow 文档</h1>
    <p>栈式页面导航、生命周期、过渡动画、数据绑定与手柄提示 —— 为真正要上线的菜单而写，而不是每次重新造轮子。</p>
    <div class="uf-cta-row">
      <a class="uf-cta uf-cta-primary" href="https://indieshade.github.io/uiflow/">产品页</a>
      <a class="uf-cta uf-cta-ghost" href="getting-started/installation/">安装 Free</a>
      <a class="uf-cta uf-cta-ghost" href="https://github.com/indieshade/uiflow">GitHub</a>
    </div>
  </div>
</div>

UIFlow 是面向 **Godot 4.6+** 的 UI 工作流框架，提供栈式页面导航、页面生命周期、过渡动画、数据绑定、事件总线以及一组可复用的 UI 组件。

本文档以 **UIFlow Free** 为主。Pro 相关能力在 [Pro](pro/index.md) 章节中单独说明。

## 主要特性

- **栈式导航**：`push` / `pop` / `replace`，支持模态与返回拦截。
- **生命周期**：`_on_created` → `_on_opened` → `_on_after_opened` → `_on_hidden` / `_on_shown` → `_on_closed` / `_on_destroyed`。
- **过渡动画**：内置 Fade / Slide / Scale / Timeline 等多种效果，可按页面配置 enter / exit。
- **数据绑定**：`bind_property`、`bind_signal`、`bind_list`，页面关闭时自动解绑。
- **事件总线**：发布订阅、sticky 值、一次性订阅、按订阅者自动清理。
- **Async / Timeline**：用 `await` 串联动画、异步操作和页面流转。
- **可复用组件**：Toast、Confirm / Alert 对话框、DataGrid、VirtualList、Tooltip、workflow glue、按键提示等。
- **手柄体验**：顶层页焦点导航、设备感知 ActionBar 提示、AxisBinder 右摇杆调 Slider。

## 适用场景

- 需要维护复杂 UI 栈的 RPG / ARPG / 卡牌 / 模拟经营类游戏。
- 希望把每个界面作为独立页面管理的中小型项目。
- 想用 GDScript 为主、C# 为辅的方式组织 UI 代码的团队。

## 快速开始

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

或跟随 [安装与配置](getting-started/installation.md) 把插件集成到自己的项目中。
