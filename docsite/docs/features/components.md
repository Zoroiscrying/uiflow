# Built-in Components

UIFlow Free provides a set of common UI components, accessible through `UIFlowUI` or as scene nodes.

## Toast

Lightweight popup notifications:

```gdscript
UIFlowUI.Toast.show("Saved successfully", UIFlowToastType.SUCCESS)
UIFlowUI.Toast.show("Network disconnected", UIFlowToastType.ERROR, 3.0)
```

![Toast example](/assets/screenshots/toast_example.png)

## Confirm / Alert Dialogs

```gdscript
UIFlowUI.Confirm.show("Delete save file?", _on_confirm, _on_cancel)
UIFlowUI.Alert.show("Operation complete")
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
