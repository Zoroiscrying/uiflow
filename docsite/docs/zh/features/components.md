# 内置组件

UIFlow Free 提供一组常用 UI 组件，可通过 `UIFlowUI` 便捷访问或作为场景节点直接使用。

## Toast

轻量弹出提示：

```gdscript
UIFlowUI.Toast.show_toast("保存成功", "success")
UIFlowUI.Toast.show_toast("网络断开", "error", 3.0)
```

![Toast 示例](/assets/screenshots/toast_example.png)

### 自定义 Toast

运行时修改导出属性：

```gdscript
UIFlowUI.Toast.toast_position = UIFlowToast.Position.BOTTOM_CENTER
UIFlowUI.Toast.max_visible = 3
UIFlowUI.Toast.default_duration = 2.0
```

注册自定义类型，可配颜色、时长、音效，甚至自定义条目场景：

```gdscript
var achievement := UIFlowToastType.new()
achievement.bg_color = Color(0.2, 0.2, 0.2, 0.95)
achievement.text_color = Color.GOLD
achievement.default_duration = 5.0
achievement.custom_scene = preload("res://UIScene/MyToastItem.tscn")
UIFlowUI.Toast.register_type("achievement", achievement)
```

## Confirm / Alert 对话框

```gdscript
UIFlowUI.Confirm.show_confirm("删除存档？", "确定删除吗？", _on_confirm, _on_cancel)
UIFlowUI.Alert.show_alert("操作完成", "数据已保存。")
```

### 自定义 Confirm / Alert

两个对话框都通过导出属性支持按钮文案、图标和自定义按钮场景：

```gdscript
UIFlowUI.Confirm.confirm_text = "确定"
UIFlowUI.Confirm.cancel_text = "返回"
UIFlowUI.Confirm.cancel_first = false
UIFlowUI.Confirm.custom_button_scene = preload("res://UIScene/MyButton.tscn")

UIFlowUI.Alert.ok_text = "知道了"
UIFlowUI.Alert.ok_icon = preload("res://icon.svg")
```

单次调用也可以覆盖：

```gdscript
UIFlowUI.Confirm.show_confirm(
    "退出", "确定退出吗？",
    func(): get_tree().quit(),
    Callable(),
    {"confirm_text": "是", "cancel_text": "否", "cancel_first": true}
)
```

如需完全控制，可以继承 `UIFlowConfirmDialog` 或 `UIFlowAlertDialog`，重写 `_create_button()` 或 `_create_ok_button()`，然后替换默认实例：

```gdscript
UIFlowUI.set_custom_confirm(my_custom_confirm)
UIFlowUI.set_custom_alert(my_custom_alert)
```

## DataGrid

用于表格化展示数据，支持列定义、排序、选中回调：

```gdscript
var grid := $DataGrid
grid.set_columns([
    {"name": "name", "title": "名称", "width": 200},
    {"name": "score", "title": "分数", "width": 100}
])
grid.set_data(player_list)
```

## VirtualList

大数据量列表，只渲染可视区域：

```gdscript
virtual_list.bind(data_array, item_template, _setup_item)
```

## Tooltip / HoverHint

鼠标悬停显示提示：

```gdscript
$HoverHint.hint_text = "攻击力 +10"
```

## 自定义组件

可以继承 `UIFlowComponentBase` 实现项目专属组件，保持与 UIFlow 生命周期一致。
