# 3D 世界示例

3D World Demo 展示如何在 Godot 3D 游戏中集成 UIFlow 页面系统：对话、商店、主 HUD。

## 如何运行

在 Demo Hub 中点击 **3D World Demo** 按钮，或直接运行：

```bash
godot --path . --scene res://addons/ui_flow/examples/3d_world/game_world.tscn
```

## 场景结构

```
addons/ui_flow/examples/3d_world/
├── game_world.tscn        # 3D 场景根
├── game_world.gd          # 游戏入口，负责 push HUD
├── interactive_object.gd  # 可交互对象，触发对话/商店
├── main_hud.tscn / .gd    # 主 HUD 页面
├── dialog_page.tscn / .gd # 对话页面
└── shop_page.tscn / .gd   # 商店页面
```

## 交互逻辑

1. 玩家靠近可交互对象并按交互键。
2. `interactive_object.gd` 调用 `UIFlow.push(DialogPage, {"npc": ...})` 或 `UIFlow.push(ShopPage, ...)`。
3. 页面使用模态或半模态方式覆盖在 3D 场景之上。

![3D 世界示例](/assets/screenshots/3d_world_demo.png)

## 注意事项

- HUD 页面通常不需要进入/退出动画，可在资源中关闭 Enter / Exit Effect。
- 对话页面建议启用模态，防止玩家移动。
