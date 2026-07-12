# 数据绑定

UIFlow 提供两类绑定工具：`UIFlowBindUtils` 与 `UIFlowPage` 上的便捷方法。页面关闭时会自动解绑。

## 属性绑定

把数据对象的属性同步到 UI 控件的属性：

```gdscript
func _on_opened(_data: Dictionary) -> void:
    bind_property(player_data, "health", health_bar, "value")
    bind_property(player_data, "name", name_label, "text")
```

## 信号绑定

当信号触发时，调用指定方法：

```gdscript
bind_signal(player_data.health_changed, _on_health_changed)
```

## 列表绑定

把数组信号绑定到模板节点，自动增删列表项：

```gdscript
var list_binder := UIFlowListBinder.new()
list_binder.bind(
    inventory.items,
    item_container,
    preload("res://UIScene/ItemRow.tscn"),
    _setup_item
)

func _setup_item(item: ItemData, node: Control) -> void:
    node.get_node("Icon").texture = item.icon
    node.get_node("Name").text = item.name
```

## 自动解绑

`UIFlowPage._unbind_all()` 会在页面关闭时被调用，无需手动管理。

## 数据存储

`UIFlowDataStore` 提供全局键值存储，适合跨页面共享轻量状态：

```gdscript
UIFlow.DataStore.set_value("player_name", "Alice")
var name := UIFlow.DataStore.get_value("player_name", "")
```
