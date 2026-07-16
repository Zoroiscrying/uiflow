# 安装与配置

## 获取插件

UIFlow Free 以文件夹形式分发，路径为 `addons/ui_flow/`。

1. 从发布包或源码复制 `addons/ui_flow/` 到你的 Godot 项目 `addons/` 目录。
2. 打开 **项目设置 → 插件**，启用 **UI Flow**。
3. 启用后会自动注册两个 autoload：
   - `UIFlow`：核心导航、绑定、主题、事件总线 API。
   - `UIFlowUI`：Toast、Confirm、Alert 等便捷组件。

## 项目设置

可在 **项目设置 → UI Flow** 中修改以下配置：

| 配置项 | 说明 | 默认值 |
|---|---|---|
| `ui_flow/scene_directory` | 页面场景默认搜索目录 | `res://UIScene/` |
| `ui_flow/max_stack_depth` | 导航栈最大深度 | `32` |
| `ui_flow/modal_close_on_back` | 点击返回时是否关闭模态页 | `true` |
| `ui_flow/default_theme_name` | 默认主题名称（legacy `UIFlowTheme`） | `dark` |

也可以创建 `res://ui_flow_config.tres` 作为自定义 `UIFlowConfig` 资源覆盖更多选项，包括 `default_godot_theme` 以使用原生 Godot `Theme` 资源。

## 推荐的目录结构

```
res://
├── addons/ui_flow/          # 插件本体
├── UIScene/                 # 你的页面场景
│   ├── MainMenuPage.tscn
│   └── SettingsPage.tscn
└── project.godot
```

## 验证安装

运行示例场景：

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

若 Demo Hub 正常出现，说明安装成功。
