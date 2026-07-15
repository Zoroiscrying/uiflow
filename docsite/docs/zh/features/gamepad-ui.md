# 手柄 UI

UIFlow 在 Free 核心中内置了手柄优先的 UI 支持：**方向焦点导航**和摇杆驱动的**虚拟光标**（对标 CommonUI 的 `CommonAnalogCursor`）。

## 方向焦点导航

Godot 本身不会在方向输入时移动焦点——`UIFlow.Focus` 为顶层页面实现了这一能力：

- `ui_left` / `ui_right` / `ui_up` / `ui_down`（方向键、十字键、左摇杆）在可聚焦控件间移动焦点。
- 控件上显式设置的 `focus_neighbor_*` 优先于自动几何搜索。
- 禁用和不可见的控件会被自动跳过。

```gdscript
# 以代码方式移动焦点（一般不需要——输入已自动处理）：
UIFlow.Focus.move_focus(Vector2.RIGHT)
```

### 配置项

| `UIFlowConfig` 属性 | 默认值 | 作用 |
|---|---|---|
| `enable_directional_focus` | `true` | 方向焦点导航总开关。 |
| `focus_wrap_enabled` | `false` | `true`：焦点在边缘环绕到对侧；`false`：焦点被限制在边缘。 |
| `auto_focus_on_push` | `true` | 页面打开时自动聚焦 `default_focus_path` 指定的控件。 |
| `restore_focus_on_pop` | `true` | 页面重新显示时，焦点恢复到它被隐藏前聚焦的控件。 |

### 焦点记忆

每个页面会记住自己被隐藏时（push、replace、置顶）哪个控件持有焦点。页面重新显示时焦点恢复到该控件——如果没有记忆则回退到 `default_focus_path`。页面关闭时记忆条目会被清除。

## 虚拟光标

`UIFlow.Cursor` 是摇杆驱动的虚拟光标，用于面向鼠标设计的 UI（背包、悬浮提示、拖放）。默认关闭：

```gdscript
UIFlow.Cursor.enable()    # 显示光标，隐藏系统鼠标
UIFlow.Cursor.disable()   # 隐藏光标，恢复系统鼠标
UIFlow.Cursor.is_enabled()
UIFlow.Cursor.get_cursor_position()
```

启用时的行为：

- **左摇杆**移动光标（十字键和方向键仍然用于焦点导航）。
- 系统鼠标被隐藏并对齐到光标位置，悬停高亮和 tooltip 照常工作（可用 `warp_os_cursor = false` 关闭，例如在 headless 测试中）。
- `ui_accept` 在光标位置触发点击；代码中可直接调用 `UIFlow.Cursor.click()`。

可调导出属性：`cursor_speed`、`acceleration`、`deadzone`、`joy_device`、`accept_action`、`cursor_texture`（未设置时绘制一个简单箭头）。

## 演示

一个独立演示场景展示了焦点移动、环绕/限制、禁用按钮跳过、焦点记忆以及虚拟光标：

```
res://addons/ui_flow/examples/scenes/gamepad_demo.tscn
```

也可以从演示中心进入（"Gamepad Demo" 按钮）。
