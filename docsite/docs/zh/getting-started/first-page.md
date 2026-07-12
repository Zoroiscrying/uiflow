# 第一个页面

UIFlow 的页面继承自 `UIFlowPage`，并关联一个 `.tscn` 场景文件。

## 创建页面脚本

```gdscript
# main_menu_page.gd
extends UIFlowPage
class_name MainMenuPage

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton

func _on_opened(data: Dictionary) -> void:
    start_button.pressed.connect(_on_start)
    settings_button.pressed.connect(_on_settings)

func _on_closed() -> void:
    start_button.pressed.disconnect(_on_start)
    settings_button.pressed.disconnect(_on_settings)

func _on_start() -> void:
    UIFlow.push(GamePage)

func _on_settings() -> void:
    UIFlow.push(SettingsPage)
```

## 创建场景

1. 新建 `Control` 节点，命名为 `MainMenuPage`。
2. 把脚本拖给该节点。
3. 保存为 `res://UIScene/MainMenuPage.tscn`。
4. 确保场景根节点的 `class_name` 与文件名一致：`MainMenuPage`。

## 启动页面

在任意入口脚本中：

```gdscript
func _ready() -> void:
    UIFlow.push(MainMenuPage)
```

UIFlow 会通过 `UIFlowSceneResolver` 自动查找 `MainMenuPage.tscn` 并实例化。

## 生命周期钩子

页面从创建到销毁会依次触发：

1. `_on_created(data)` — 实例已创建，尚未加入树。
2. `_on_opened(data)` — 已加入树，进入动画之前。
3. `_on_after_opened()` — 进入动画完成，焦点已应用。
4. `_on_hidden()` — 被新页面覆盖。
5. `_on_shown()` — 上层页面被关闭，重新可见。
6. `_on_before_closed()` — 退出动画之前。
7. `_on_closed()` — 已移出栈，退出动画之后。
8. `_on_destroyed()` — 节点即将被释放。

在 `_on_opened` / `_on_closed` 中连接 / 断开信号是常见做法。
