# Demo Hub

Demo Hub 是 UIFlow Free 的主入口示例，展示核心导航与页面过渡效果。

## 如何运行

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

项目默认主场景也是该场景。

## 包含内容

- 主菜单页面
- 设置页面（演示返回拦截与配置保存）
- 数据绑定示例页面
- 事件总线示例页面
- Timeline / Async 动画示例页面

![Demo Hub 主界面](/assets/screenshots/demo_hub_main.png)

## 学习重点

- 每个页面都是 `UIFlowPage` 子类，场景放在 `res://UIScene/` 或插件内部示例目录。
- 返回按钮和 ESC 都会触发 `_on_back()`。
- 页面切换使用了默认 transition 配置。
