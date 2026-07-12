# 内置组件

UIFlow Free 提供一组常用 UI 组件，可通过 `UIFlowUI` 便捷访问或作为场景节点直接使用。

## Toast

右下角（可配置）弹出轻量提示：

```gdscript
UIFlowUI.Toast.show("保存成功", UIFlowToastType.SUCCESS)
UIFlowUI.Toast.show("网络断开", UIFlowToastType.ERROR, 3.0)
```

![Toast 示例](/assets/screenshots/toast_example.png)

## Confirm / Alert 对话框

```gdscript
UIFlowUI.Confirm.show("确定删除存档？", _on_confirm, _on_cancel)
UIFlowUI.Alert.show("操作完成")
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
