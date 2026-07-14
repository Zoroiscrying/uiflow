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

## Custom Components

Extend `UIFlowComponentBase` to implement project-specific components that follow the UIFlow lifecycle.
