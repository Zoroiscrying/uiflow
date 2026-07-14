# Built-in Components

UIFlow Free provides a set of common UI components, accessible through `UIFlowUI` or as scene nodes.

## Toast

Lightweight popup notifications:

```gdscript
UIFlowUI.Toast.show_toast("Saved successfully", "success")
UIFlowUI.Toast.show_toast("Network disconnected", "error", 3.0)
```

![Toast example](/assets/screenshots/toast_example.png)

### Customizing Toast

Change exported properties at runtime:

```gdscript
UIFlowUI.Toast.toast_position = UIFlowToast.Position.BOTTOM_CENTER
UIFlowUI.Toast.max_visible = 3
UIFlowUI.Toast.default_duration = 2.0
```

Register custom types with their own color, duration, sound, or even a custom item scene:

```gdscript
var achievement := UIFlowToastType.new()
achievement.bg_color = Color(0.2, 0.2, 0.2, 0.95)
achievement.text_color = Color.GOLD
achievement.default_duration = 5.0
achievement.custom_scene = preload("res://UIScene/MyToastItem.tscn")
UIFlowUI.Toast.register_type("achievement", achievement)
```

## Confirm / Alert Dialogs

```gdscript
UIFlowUI.Confirm.show_confirm("Delete save file?", "Are you sure?", _on_confirm, _on_cancel)
UIFlowUI.Alert.show_alert("Operation complete", "Your data has been saved.")
```

![Confirm dialog](/assets/screenshots/confirm_dialog.png)
![Alert dialog](/assets/screenshots/alert_dialog.png)

### Customizing Confirm / Alert

Both dialogs expose exported properties for button text, icons, and custom button scenes:

```gdscript
UIFlowUI.Confirm.confirm_text = "OK"
UIFlowUI.Confirm.cancel_text = "Back"
UIFlowUI.Confirm.cancel_first = false
UIFlowUI.Confirm.custom_button_scene = preload("res://UIScene/MyButton.tscn")

UIFlowUI.Alert.ok_text = "Got it"
UIFlowUI.Alert.ok_icon = preload("res://icon.svg")
```

Per-call overrides are also supported:

```gdscript
UIFlowUI.Confirm.show_confirm(
    "Quit", "Really quit?",
    func(): get_tree().quit(),
    Callable(),
    {"confirm_text": "Yes", "cancel_text": "No", "cancel_first": true}
)
```

For full control, subclass `UIFlowConfirmDialog` or `UIFlowAlertDialog` and override `_create_button()` or `_create_ok_button()`, then replace the default instance:

```gdscript
UIFlowUI.set_custom_confirm(my_custom_confirm)
UIFlowUI.set_custom_alert(my_custom_alert)
```

## DataGrid

Display tabular data with column definitions, sorting, and selection callbacks:

```gdscript
var grid := $DataGrid
grid.set_columns([
    {"name": "name", "title": "Name", "width": 200},
    {"name": "score", "title": "Score", "width": 100}
])
grid.set_data(player_list)
```

![DataGrid example](/assets/screenshots/data_grid_example.png)

## InventoryGrid / ItemSlot

Slot-based inventory grid with drag-and-drop, bound to an `InventoryData` resource. Slots show the item icon, or the first letter of the item name with a rarity-colored border when no icon is set:

```gdscript
var inventory := InventoryData.new(20)

var potion := ItemData.new()
potion.item_name = "Health Potion"
potion.rarity = ItemData.Rarity.COMMON
inventory.add_item(potion)

$InventoryGrid.setup(inventory)
```

![InventoryGrid in the Survivors demo](/assets/screenshots/inventory_grid.png)

The grid emits `item_dropped` per slot so you can wire equipment slots, context menus (`UIFlowContextMenu`), and tooltips (`UIFlowTooltip`) — see the Survivors demo for a full example.

## VirtualList

Large lists that only render the visible area:

```gdscript
virtual_list.bind(data_array, item_template, _setup_item)
```

## Tooltip / HoverHint

Show hints on hover:

```gdscript
$HoverHint.hint_text = "Attack +10"
```

## Input Action Bar

`UIFlowActionBar` renders the current top page's declared `UIInputActionNode` entries as a hint bar (key/icon + label), similar to Unreal CommonUI's bound action bar. Drop it into a HUD scene — it auto-follows the navigation stack:

```gdscript
var bar := UIFlowActionBar.new()
add_child(bar)  # auto-binds to the top page
```

Actions show their `icon` when set, otherwise the key bound to `godot_action` (e.g. `[I]`). Disabled actions are hidden by default; set `show_disabled = true` to keep them visible but dimmed. See the Survivors demo HUD for a live example.

## Custom Components

Extend `UIFlowComponentBase` to implement project-specific components that follow the UIFlow lifecycle.
