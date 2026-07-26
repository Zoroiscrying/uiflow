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

![Confirm 对话框](/assets/screenshots/confirm_dialog.png)
![Alert 对话框](/assets/screenshots/alert_dialog.png)

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
grid.add_column("名称", 200)
grid.add_column("等级", 80)
grid.add_column("生命", 100)
grid.set_data([
    ["战士", 5, 150],
    ["法师", 3, 80],
])
```

也可以使用 `set_columns([{"title": "名称", "width": 200}])` 批量定义列。

![DataGrid 示例](/assets/screenshots/data_grid_example.png)

## InventoryGrid / ItemSlot

基于槽位的背包网格，绑定 `InventoryData` 资源，支持拖拽。槽位显示物品图标；未设置图标时显示物品名首字母和稀有度颜色边框：

```gdscript
var inventory := InventoryData.new(20)

var potion := ItemData.new()
potion.item_name = "Health Potion"
potion.rarity = ItemData.Rarity.COMMON
inventory.add_item(potion)

$InventoryGrid.setup(inventory)
```

![Survivors 演示中的 InventoryGrid](/assets/screenshots/inventory_grid.png)

网格会转发 `item_right_clicked` 和各槽位的 `item_dropped` 信号，可据此接入装备槽、右键菜单（`UIFlowContextMenu`）和悬浮提示（`UIFlowTooltip`）——完整示例见 Survivors 演示。

### 快速装备绑定

`UIFlowInventoryGrid.bind_equipment_slots()` 封装了背包与装备槽之间的拖放逻辑，无需手写样板代码：

```gdscript
$InventoryGrid.setup(inventory)
$InventoryGrid.bind_equipment_slots(equipment_data, {
    &"weapon": weapon_slot,
    &"chest": chest_slot,
})
```

右键背包物品会发出 `item_right_clicked(item, slot_index, pos)`；可装备物品可直接装备或通过右键菜单操作。

## EquipmentGrid

`UIFlowEquipmentGrid` 自动生成带标签的装备槽网格，内部处理装备拖放、类型过滤和显示同步：

```gdscript
var grid := UIFlowEquipmentGrid.new()
grid.slot_names = {&"weapon": "武器", &"chest": "胸甲"}
add_child(grid)
grid.setup(equipment_data, inventory_data)
grid.slot_right_clicked.connect(_on_equipment_right_clicked)
```

每个槽位都是已配置好 `setup_equipment()` 的 `UIFlowItemSlot`，与背包网格拖放开箱即用。

## VirtualList

大数据量列表，只渲染可视区域：

```gdscript
virtual_list.bind(data_array, item_template, _setup_item)
```

## Tooltip / HoverHint

悬停提示。显示时会挂到高层 [CanvasLayer]，避免被页面栈盖住：

```gdscript
$HoverHint.hint_text = "攻击力 +10"
UIFlowHoverHint.attach($Button, "[b]Rich Text[/b]\nSupports BBCode", true)
UIFlowTooltip.attach($Button, "Click to confirm")
```

## Input Prompts

`UIFlowInputPrompt` 是按键提示徽章。默认字母徽章即可用；也可把 Kenney Input Prompts（CC0）PNG 放进 `addons/ui_flow/assets/input_prompts/` 并赋给 `icon`。

```gdscript
add_child(UIFlowInputPrompt.make("A", "Confirm", Color(0.2, 0.72, 0.32)))
```

## Code Overlay

Free Demo 用 `UIFlowCodeOverlay`（CanvasLayer）展示当前页 API 片段。按 **F1** 开关。请优先用它，而不是可能被页层盖住的旧版 `UIFlowCodePanel`。

## 输入动作条

`UIFlowActionBar` 把当前栈顶页面声明的 `UIInputActionNode` 渲染成提示条（按键/图标 + 文案），类似 Unreal CommonUI 的 BoundActionBar。把它放进 HUD 场景即可——会自动跟随导航栈切换：

```gdscript
var bar := UIFlowActionBar.new()
add_child(bar)  # 自动绑定栈顶页面
```

动作设置了 `icon` 时显示图标，否则显示 `godot_action` 绑定的按键（如 `[I]`）。禁用的动作默认隐藏，设 `show_disabled = true` 可改为置灰显示。实际效果见 Survivors 演示的 HUD。

## Children Switcher

`UIFlowChildrenSwitcher` 用一个离散 `state` **同时**驱动多个 NodePath 目标上的可选外观补丁（`visible`、`modulate`、`scale`、`disabled`、`font_size` 等）。卖点就是多子节点联动——卡片选中/禁用、槽位空/满、步骤指示。

```gdscript
$CardSwitcher.set_state(1)                 # 一次更新图标+标题+详情+按钮
$CardSwitcher.set_state_by_name("selected")
```

编辑器里改 **Preview State** 可即时预览。用 **Bake Current State** 把当前预览写入场景基线（并同步 `initial_state`）；普通保存会先还原基线，避免随手预览污染 `.tscn`。

完整多目标卡片示例见 Free Hub → **Workflow Glue**。

## 工作流胶水组件

减轻日常 UI 胶水代码的场景节点。演示：Free Hub → **Workflow Glue**。

| 组件 | 作用 |
|---|---|
| `UIFlowPageOpener` | 从按钮 push / replace / async / instance 打开页面 |
| `UIFlowPageCloser` | pop / pop-to-root / 按脚本 close |
| `UIFlowChildPool` | `ensure_count(n, init_fn)` — 无数据数组的槽位填充 |
| `UIFlowInputRelay` | 局部 InputMap → 信号（可选焦点/可见性门控） |
| `UIFlowHoldRepeater` | 按住重复触发（数量加减 / 快滚） |
| `UIFlowCooldownGate` | 按钮冷却（`accepted` / `rejected`） |
| `UIFlowVisibilityGroup` | N 选 1 互斥显示 |
| `UIFlowAutoFocus` | ready / 页面再次显示时抢焦点 |

```gdscript
$OpenShopBtn/PageOpener.page_script = ShopPage
$OpenShopBtn/PageOpener.mode = UIFlowPageOpener.Mode.PUSH

$SkillPool.ensure_count(6, func(slot, i): slot.setup(skills[i]))
```

## 自定义组件

可以继承 `UIFlowComponentBase` 实现项目专属组件，保持与 UIFlow 生命周期一致。
